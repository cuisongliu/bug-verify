#!/bin/bash

set -e

readonly C_TIMEOUT=${1:-1m}
readonly R_TIMEOUT=${2:-5m}

echo "CheckCreating(timeout=$C_TIMEOUT), CheckRunning(timeout=$R_TIMEOUT)"

function checker() {
  # for Creating
  kubectl get pods -oname --all-namespaces | sort >"all.$HOSTNAME.pods"
  until ! diff <(kubectl get pods -oname --all-namespaces | sort) "all.$HOSTNAME.pods" &>/dev/null; do
    sleep 3
    # timeout
    if kubectl get pods -owide --all-namespaces | grep -E "$C_TIMEOUT.+s" &>/dev/null; then break; fi
  done
  rm -f "all.$HOSTNAME.pods"
  # for Running
  until ! kubectl get pods --no-headers --all-namespaces | grep -vE Running &>/dev/null; do
    sleep 9
    if kubectl get pods --no-headers --all-namespaces | grep -vE Running; then
      echo
    fi
    # timeout
    if kubectl get pods -owide --all-namespaces | grep -E "$R_TIMEOUT.+s" &>/dev/null; then break; fi
  done
}

if kubectl version; then
  kubectl get pods -owide --all-namespaces
  kubectl get node -owide
  checker
  kubectl get pods -owide --all-namespaces
  kubectl get node -owide
fi
