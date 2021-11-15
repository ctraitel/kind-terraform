output local_dtr {
  value       = docker_container.local_dtr.name
  description = <<-EOT
  EOT
}

output dashboard_token {
  value       = "kubectl get secret -n kubernetes-dashboard $(kubectl get sa -n kubernetes-dashboard admin-user -o jsonpath='{.secrets[].name}') -o jsonpath='{.data.token}'"
  description = "run command for dashboard token"
}

output run_dashboard {
  value       = "kubectl port-forward -n kubernetes-dashboard service/kubernetes-dashboard 8443:443"
  description = "Run following command to start kubernetes dashboard"
}

output name {
  value       = "https://localhost:8443"
  description = "Url for local cluster kubernetes-dashboard"
}


