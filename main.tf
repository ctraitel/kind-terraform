resource docker_container local_dtr {
  name   = "local-registry"
  image  = "registry:2"

  ports {
    internal = "5000"
    external = "5000"
  }
}

resource kind_cluster local {
    name = "test-cluster"
    kind_config =<<KIONF
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
  extraPortMappings:
  - containerPort: 80
    hostPort: 80
    protocol: TCP
  - containerPort: 443
    hostPort: 443
    protocol: TCP
containerdConfigPatches:
- |-
  [plugins."io.containerd.grpc.v1.cri".registry.mirrors."localhost:5000"]
    endpoint = ["http://local-registry:5000"]
KIONF
  
  depends_on = [docker_container.local_dtr,]
}

# get kube config
resource local_file kube_config {
    filename = "~/.kube/config"
    depends_on = [kind_cluster.local,]
}

# create cert-manager ns with label
resource kubernetes_namespace cert_manager {
    metadata {
        name = "cert-manager"
        labels = {
            "certmanager.k8s.io/disable-validation" = "true"
        }
    }

    depends_on = [local_file.kube_config]
}

resource helm_release cert_manager_jetstack {
  name          = "cert-manager"
  repository    = "https://charts.jetstack.io"
  chart         = "cert-manager"
  version       = "v1.4.0"
  namespace     = "cert-manager"

  set {
    name  = "installCRDs"
    value = "true"
  }
  depends_on = [kubernetes_namespace.cert_manager,]
}

resource kubernetes_namespace kubernetes_dashboard {
    metadata {
        name = "kubernetes-dashboard"
    }

    depends_on = [helm_release.cert_manager_jetstack,]
}

resource helm_release kubernetes_dashboard {
  name        = "kubernetes-dashboard"
  repository  = "https://kubernetes.github.io/dashboard"
  chart       = "kubernetes-dashboard"
  version     = "4.3.1"
  namespace   = "kubernetes-dashboard"

  depends_on = [kubernetes_namespace.kubernetes_dashboard,]
}