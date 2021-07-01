terraform {
    required_providers {
        kind = {
            source  = "unicell/kind"
            version = "0.0.2-u2"
        }
        kubernetes  = {
            version = ">= 2.1.0"
        }
        helm = {
            source  = "hashicorp/helm"
            version = "2.2.0"
        }
        kustomization = {
            source  = "kbst/kustomization"
            version = ">= 0.4.3"
        }
    }
}