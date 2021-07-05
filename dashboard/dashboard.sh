echo "token =" && kubectl get secret $(kubectl get serviceaccount admin-user -n kubernetes-dashboard -o jsonpath='{.secrets[0].name}') -n kubernetes-dashboard -o jsonpath='{.data.token}{"\n"}'
echo "dashboard = https://localhost:8001/#/login"
kubectl port-forward -n kubernetes-dashboard service/kubernetes-dashboard 8001:443 