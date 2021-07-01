sleep 60
COUNTER=0

while [ $COUNTER -lt 21 ]; do
   if [ $COUNTER == 20 ]; then
   echo "cert-manager deploy didn't come up, please review deployment" && exit 1;
   fi
   if kubectl get pods -n cert-manager | grep 0/1; then
   echo "waiting on cert manager pods" && sleep 30 && let COUNTER=COUNTER+1; else
   echo "cert manager pods are up and running" && break
   fi
done