provider kubernetes {
    config_path    = local_file.kube_config.filename
    config_context = "kind-test-cluster"
}

provider helm {
    kubernetes {
        config_path    = local_file.kube_config.filename
        config_context = "kind-test-cluster"
    }
}

provider "kind" {}

provider "docker" {}

provider "kubectl" {
  config_path    = local_file.kube_config.filename
  config_context = "kind-test-cluster"
    }