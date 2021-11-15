resource "docker_container" "local_dtr" {
  name  = "local-registry"
  image = "registry:2"

  ports {
    internal = "5000"
    external = "5000"
  }
}

resource "kind_cluster" "local" {
  name        = "test-cluster"
  kind_config = <<KIONF
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
- role: control-plane
  kubeadmConfigPatches:
  - |
    kind: InitConfiguration
    nodeRegistration:
      kubeletExtraArgs:
        node-labels: "ingress-ready=true"
containerdConfigPatches:
- |-
  [plugins."io.containerd.grpc.v1.cri".registry.mirrors."localhost:5000"]
    endpoint = ["http://local-registry:5000"]
KIONF

  depends_on = [docker_container.local_dtr, ]
}

# get kube config
resource "local_file" "kube_config" {
  filename   = "~/.kube/config"
  depends_on = [kind_cluster.local, ]
}


resource "helm_release" "cert_manager_jetstack" {
  name             = "cert-manager"
  repository       = "https://charts.jetstack.io"
  chart            = "cert-manager"
  version          = "v1.4.0"
  create_namespace = "true"
  namespace        = "cert-manager"

  set {
    name  = "installCRDs"
    value = "true"
  }
  depends_on = [kind_cluster.local, ]
}

# deploying dashboard

resource "helm_release" "kubernetes_dashboard" {
  name             = "kubernetes-dashboard"
  repository       = "https://kubernetes.github.io/dashboard"
  chart            = "kubernetes-dashboard"
  version          = "4.3.1"
  create_namespace = "true"
  namespace        = "kubernetes-dashboard"

  depends_on = [helm_release.cert_manager_jetstack, ]
}

resource "kubectl_manifest" "dashboard_usr" {
  yaml_body = <<YAML
apiVersion: v1
kind: ServiceAccount
metadata:
  name: admin-user
  namespace: kubernetes-dashboard
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: admin-user
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
- kind: ServiceAccount
  name: admin-user
  namespace: kubernetes-dashboard
  YAML

  depends_on = [helm_release.kubernetes_dashboard, ]
}