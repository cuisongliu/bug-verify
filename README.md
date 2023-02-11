# bugs-verfiy 
> 复用Github-Action来验证一些bug

等待pod启动完成:

```shell
# wait Creating
kubectl get pods -oname --all-namespaces | sort | tee all.pods
until ! diff <(kubectl get pods -oname --all-namespaces | sort) all.pods; do
sleep 1
if kubectl get pods -owide --all-namespaces | grep -E "3m.+s" &>/dev/null; then
  kubectl get pods -owide --all-namespaces
  break
fi
done
# wait Running
until ! kubectl get pods --no-headers --all-namespaces | grep -vE Running; do
sleep 5
kubectl get pods -owide --all-namespaces | grep -vE Running
echo;echo;echo
if kubectl get pods -owide --all-namespaces | grep -E "30m.+s"; then
  break
fi
done
kubectl get pods -owide --all-namespaces
kubectl get node -owide
sudo crictl ps -a
sudo cat /etc/hosts
sudo systemctl status kubelet
```

安装K8s单机模式
```shell
sudo sealos run labring/kubernetes:v1.25.0 labring/helm:v3.8.2 labring/calico:v3.24.1 labring/cert-manager:v1.8.0 --single --debug
mkdir -p "$HOME/.kube"
sudo cp -i /etc/kubernetes/admin.conf "$HOME/.kube/config"
sudo chown "$(whoami)" "$HOME/.kube/config"
kubectl get nodes --no-headers -oname | while read -r node; do kubectl get "$node" -o template='{{range .spec.taints}}{{.key}}{{"\n"}}{{end}}' | while read -r taint; do
kubectl taint ${node/\// } "$taint"-
done; done
```
