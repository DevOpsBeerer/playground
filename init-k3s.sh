#!/bin/sh
#
set -x

KUBECONFIG=/etc/rancher/k3s/k3s.yaml

## Install Nginx ingress controller
helm --kubeconfig $KUBECONFIG upgrade --install ingress-nginx ingress-nginx \
    --repo https://kubernetes.github.io/ingress-nginx \
    --namespace ingress-nginx \
    --create-namespace \
    -f k3s/ingress-controller.yaml

sleep 10

## Install cert-manager
helm --kubeconfig $KUBECONFIG repo add jetstack https://charts.jetstack.io --force-update
helm --kubeconfig $KUBECONFIG install \
    cert-manager jetstack/cert-manager \
    --namespace cert-manager \
    --create-namespace \
    --version v1.17.2 \
    --set crds.enabled=true

sleep 20
k3s kubectl apply -f k3s/cert-manager.yaml

## Install Keycloak as SSO
helm --kubeconfig $KUBECONFIG upgrade --install sso oci://registry-1.docker.io/bitnamicharts/keycloak \
    --namespace sso \
    --create-namespace \
    -f k3s/keycloak.yaml
