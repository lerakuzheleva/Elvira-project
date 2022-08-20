##  EKS CLUSTER FOR DOCKERISED FLASK API WITH (IAC)

## Requirements

This setup requires awscli docker and kubectl
- aws-cli/2.7.24
- Docker version 20.10.17
- kubectl 



## RUNNING THIS SETUP CAN BE DONE MANUALLY BY RUNNING THE STEPS BELOW OR BY EXECUTING the run.sh script

## 1. Running run.sh
```bash
$ chmod +x run.sh
```

```bash
$ run.sh image_tag aws_region aws_account ecr_uri
```

## 2. STEPS
## Deploy EKS Cluster
Initialise terraform 
```bash
$ terraform -chdir=eks init
```

Explore the Plan

```bash
$ terraform -chdir=eks plan
```

Apply 

```bash
$ terraform -chdir=eks apply --auto-approve
```

Update kubectl config
aws eks --region $(terraform -chdir=eks output -raw region) update-kubeconfig --name $(terraform -chdir=eks output -raw cluster_name)



## Build Docker

Build Docker Image Locally

```bash
$ docker build --tag timestampapi app
```

Docker Run to test

```bash
$ docker run -d --name timestampapi -p 5000:5000 timestampapi
```


## Publish Docker Image
Create a private repository on aws console


## setup aws ecr

Authenticate docker with ecr
Replace region and aws_account_id with your details
'''
aws ecr get-login-password --region {region} | docker login --username AWS --password-stdin {aws_account_id}.dkr.ecr.us-east-1.amazonaws.com
'''


Add tag to the image
```bash
$docker image tag timestampapi:latest  {uri}
```
Pushing Docker image

Push Image
```bash
$ docker image push {uri}:latest
```

## Kubernetes Manifest

Replace the image in deployment/api-deployment.yaml

Kubernete Deployment

Pod
```bash
$ kubectl apply -f deployment/api-deployment.yaml
```

Service
```bash
$ kubectl apply -f deployment/service.yaml
```
