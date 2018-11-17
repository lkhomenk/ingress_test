#!/bin/bash

gcloud auth activate-service-account --key-file /full/path/to/key.json
export PROJECT_ID=${PROJECT_ID:="your_project_id"}
export ZONE=${ZONE:="us-west1-b"}
export REGION=${REGION:="us-west1"}
export VM_TYPE=${VM_TYPE:="n1-standard-1"}
export CLUSTER_NAME=${CLUSTER_NAME:="tiny-cluster"}
# gcloud config set project $PROJECT_ID
# gcloud config set compute/region $REGION
# gcloud config set compute/zone $ZONE

# gcloud alpha services enable container.googleapis.com


gcloud beta container --project $PROJECT_ID clusters create $CLUSTER_NAME --zone $ZONE --username "admin" --cluster-version "1.9.7-gke.11" --machine-type $VM_TYPE --image-type "COS" --disk-type "pd-standard" --disk-size "100" --scopes "https://www.googleapis.com/auth/compute","https://www.googleapis.com/auth/devstorage.read_only","https://www.googleapis.com/auth/logging.write","https://www.googleapis.com/auth/monitoring","https://www.googleapis.com/auth/servicecontrol","https://www.googleapis.com/auth/service.management.readonly","https://www.googleapis.com/auth/trace.append" --num-nodes "1" --enable-cloud-logging --enable-cloud-monitoring --no-enable-ip-alias --network "projects/eval-task-project/global/networks/default" --subnetwork "projects/eval-task-project/regions/$REGION/subnetworks/default" --addons HorizontalPodAutoscaling,HttpLoadBalancing,KubernetesDashboard --enable-autoupgrade --enable-autorepair

# grant your user cluster-admin role
kubectl create clusterrolebinding cluster-admin-binding \
  --clusterrole cluster-admin \
  --user $(gcloud config get-value account)
