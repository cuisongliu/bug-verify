# bugs-verfiy 
> 复用Github-Action来验证一些bug

等待pod启动完成:

```shell
function checker() {
  # for Creating
  kubectl get pods -oname --all-namespaces | sort >"all.$HOSTNAME.pods"
  until ! diff <(kubectl get pods -oname --all-namespaces | sort) "all.$HOSTNAME.pods" &>/dev/null; do
    sleep 3
    # timeout
    if ! find . -type f -name "all.$HOSTNAME.pods" -mmin -1 | grep "all.$HOSTNAME.pods" &>/dev/null; then break; fi
  done
  # for Running
  until ! kubectl get pods --no-headers --all-namespaces | grep -vE Running &>/dev/null; do
    sleep 9
    if kubectl get pods --no-headers --all-namespaces | grep -vE Running; then
      echo
    fi
    # timeout
    if ! find . -type f -name "all.$HOSTNAME.pods" -mmin -3 | grep "all.$HOSTNAME.pods" &>/dev/null; then break; fi
  done
  rm -f "all.$HOSTNAME.pods"
}

if kubectl version; then
  kubectl get pods -owide --all-namespaces
  kubectl get node -owide
  checker
  kubectl get pods -owide --all-namespaces
  kubectl get node -owide
fi
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
