#!/usr/bin/env bash

create_cluster() {
    kind create cluster --name kind-1 --config kind/cluster-config.yaml
    
    ## review
    docker ps
    kubectl get nodes
    kubectl cluster-info
}

apply_backend_zone_aware() {
    kubectl apply -f manifests/k8s/backend-zone-aware.yaml

    sleep 3
    kubectl wait --for=condition=ready pod -l app=backend-zone-aware --timeout=180s

    ## review
    kubectl get deployment/backend-zone-aware
    kubectl get po -l app=backend-zone-aware -owide --sort-by='.spec.nodeName'
}

apply_ingress_deploy() {
    kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml

    sleep 3
    kubectl wait --namespace ingress-nginx --for=condition=ready pod --selector=app.kubernetes.io/component=controller --timeout=180s

    ## review
    kubectl -n ingress-nginx get deploy
}

apply_service_zone_aware() {
    kubectl apply -f manifests/k8s/service-zone-aware.yaml

    ## review
    kubectl get svc 
}

apply_ingress_zone_aware() {
    kubectl apply -f manifests/k8s/ingress-zone-aware.yaml

    ## review
    kubectl get ingress 
    kubectl get nodes
    kubectl get pods
    kubectl get nodes -L topology.kubernetes.io/zone
}

run() {
    create_cluster
    
    apply_backend_zone_aware
    apply_ingress_deploy
    apply_service_zone_aware
    apply_ingress_zone_aware
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
