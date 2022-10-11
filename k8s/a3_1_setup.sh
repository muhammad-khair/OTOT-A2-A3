#!/usr/bin/env bash

create_cluster() {
    kind create cluster --name kind-1 --config kind/cluster-config.yaml
    
    ## review
    docker ps
    kubectl get nodes
    kubectl cluster-info
}

apply_backend() {
    kubectl apply -f manifests/k8s/backend.yaml

    sleep 3
    kubectl wait --for=condition=ready pod -l app=backend --timeout=180s

    ## review
    kubectl get deployment/backend
}

apply_ingress_deploy() {
    kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml

    sleep 3
    kubectl wait --namespace ingress-nginx --for=condition=ready pod --selector=app.kubernetes.io/component=controller --timeout=180s

    ## review
    kubectl -n ingress-nginx get deploy
}

apply_service() {
    kubectl apply -f manifests/k8s/service.yaml

    ## review
    kubectl get svc 
}

apply_ingress() {
    kubectl apply -f manifests/k8s/ingress.yaml

    ## review
    kubectl get ingress 
    kubectl get nodes
}

apply_metrics() {
    kubectl apply -f manifests/k8s/metrics.yaml
}

apply_hpa() {
    kubectl apply -f manifests/k8s/hpa.yaml

    sleep 3
    kubectl wait --for=condition=ready pod -l app=backend --timeout=180s

    ## review
    kubectl get deployment/backend
    kubectl get nodes -L topology.kubernetes.io/zone
    kubectl get pods
    kubectl describe hpa
}

run() {
    create_cluster

    apply_backend
    apply_ingress_deploy
    apply_service
    apply_ingress

    apply_metrics
    apply_hpa
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
