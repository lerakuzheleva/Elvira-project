#!/usr/bin/env sh
# run.sh tag region account ecr_repo_uri

[ "${DEBUG:-0}" = "1" ] && set -x
set -u

_main () {
    _fail=0
    testsh_pwd="$(pwd)"

    tag="$("$1")"
    region="$("$2")"
    account="$("$3")"
    uri="$("$4")"

    echo 'Provison EKS Cluster'
    try 
        terraform -chdir=eks init
        terraform -chdir=eks plan
        terraform -chdir=eks apply --auto-approve
    catch 
        echo "Raised an Error (@ $__EXCEPTION_LINE__)"


    echo 'Update Kubectl with EKS CONFIG Details'
    try 
        aws eks --region $(terraform -chdir=eks output -raw region) update-kubeconfig --name $(terraform -chdir=eks output -raw cluster_name)
    catch 
        echo "Raised an Error (@ $__EXCEPTION_LINE__)"


    echo 'Update Kubectl with EKS CONFIG Details'
    try 
        docker build --tag timestampapi app
        docker run -d --name timestampapi -p 5000:5000 timestampapi
    catch 
        echo "Raised an Error (@ $__EXCEPTION_LINE__)"


    echo 'Publish Docker Image'
    try 
        aws ecr get-login-password --region {region} | docker login --username AWS --password-stdin {aws_account_id}.dkr.ecr.us-east-1.amazonaws.com
        docker image tag timestampapi:latest  {uri}
        docker image push {uri}:latest
    catch 
        echo "Raised an Error (@ $__EXCEPTION_LINE__)"

    echo 'Deploy with Kubernetes'
    try 
        kubectl apply -f deployment/api-deployment.yaml

        kubectl apply -f deployment/service.yaml
    catch 
        echo "Raised an Error (@ $__EXCEPTION_LINE__)"

}

_main "$@"
if [ $_fail -gt 0 ] ; then
    echo "$0: Failed"
    exit 1
fi