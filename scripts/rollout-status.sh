target=$1
ns=$2
timeout=$3

kubectl rollout status $target -n $ns
sleep $timeout