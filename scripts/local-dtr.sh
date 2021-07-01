localreg=$(docker inspect -f '{{.State.Running}}' "local-registry" 2>/dev/null || true)
if [ "${localreg}" != 'true' ]; then
docker run -d -p 5000:5000 --restart=always --name local-registry registry:2
fi