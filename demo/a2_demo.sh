#!/usr/bin/env bash

run() {
    kind create cluster --name kind-1 --config kind/cluster-config.yaml
    ## review
    docker ps
    kubectl get nodes
    kubectl cluster-info

    docker pull nginx:stable
    kind load docker-image nginx:stable --name kind-1

    kubectl apply -f manifests/k8s/backend-deployment.yaml
    sleep 3
    kubectl wait --for=condition=ready pod -l app=backend --timeout=180s
    ## review
    kubectl get deployment/backend

    kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml
    sleep 3
    kubectl wait --namespace ingress-nginx --for=condition=ready pod --selector=app.kubernetes.io/component=controller --timeout=180s
    ## review
    kubectl -n ingress-nginx get deploy

    kubectl apply -f manifests/k8s/service.yaml
    ## review
    kubectl get svc 

    kubectl apply -f manifests/k8s/ingress.yaml
    ## review
    kubectl get ingress 
    kubectl get nodes
}

delete() {
    kind delete cluster --name kind-1
}

main() {
    if [ $# -eq 0 ]; then
        set -x
        run
        exit
    elif [ $1 == "d" ]; then
        set -x
        delete
        exit 
    elif [ $1 == "r" ]; then
        set -x
        delete
        run
        exit
    fi
}

main $@
