resource null_resource local_dtr {

    provisioner "local-exec" {
      command = "./scripts/local-dtr.sh"
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
  
  depends_on = [null_resource.local_dtr,]
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

# apply crds version 0.11
resource null_resource crds {

    provisioner "local-exec" {
      command = "export KUBE_CONFIG_PATH=~/.kube/config && kubectl apply -f cert-manager/00-crds.yaml"
    }

    depends_on = [kubernetes_namespace.cert_manager,]
}

# apply cert-manager version 0.12
resource null_resource cert_manager_jetstack {
    provisioner "local-exec" {
      command = "export KUBE_CONFIG_PATH=~/.kube/config && kubectl apply -f cert-manager/cert-manager.yaml"
    }
    depends_on = [null_resource.crds,]
}

resource null_resource confirm_controller_manager {
    provisioner "local-exec" {
        command = "./scripts/confirm-cert-manager.sh"
    }
    depends_on = [null_resource.cert_manager_jetstack,]
}