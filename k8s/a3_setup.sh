#!/usr/bin/env bash

run() {
    kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
    kubectl -nkube-system edit deploy/metrics-server
    ## maunally add a flag --kubelet-insecure-tls to deployment.spec.containers[].args[] (around line 40)
    kubectl -nkube-system rollout restart deploy/metrics-server

    kubectl apply -f manifests/k8s/backend-hpa.yaml
    sleep 3
    kubectl wait --for=condition=ready pod -l app=backend-hpa --timeout=180s
    ## review
    kubectl get deployment/backend-hpa
    kubectl get po
    kubectl describe hpa

    kubectl get nodes -L topology.kubernetes.io/zone

    kubectl apply -f manifests/k8s/backend-zone-aware.yaml
    sleep 3
    kubectl wait --for=condition=ready pod -l app=backend-zone-aware --timeout=180s
    ## review
    kubectl get deployment/backend-zone-aware
    kubectl get po -l app=backend-zone-aware -owide --sort-by='.spec.nodeName'
}

main() {
    set -x
    run
    exit
}

main
