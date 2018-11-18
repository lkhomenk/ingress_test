#!/bin/bash
export INTERACTIVE=${INTERACTIVE:="true"}

# export PROJECT_ID=${PROJECT_ID:="your_project_id"}
export ZONE=${ZONE:="us-west1-b"}
export REGION=${REGION:="us-west1"}
export VM_TYPE=${VM_TYPE:="n1-standard-1"}
export CLUSTER_NAME=${CLUSTER_NAME:="tiny-cluster"}

if [ "$INTERACTIVE" = "true" ]; then

    read -rp "Path to service account JSON file: ($SECRET_KEY): " input;
	if [ "$input" != "" ] ; then
		export SECRET_KEY="$input";
    else
        echo "Service account key is required"
        exit 1
    fi

    export PROJECT_ID=$(awk -F'"' '/project_id/{print $4}' $SECRET_KEY)

	read -rp "Project ID to use: ($PROJECT_ID): " input;
	if [ "$input" != "" ] ; then
		export PROJECT_ID="$input";
	fi

    read -rp "Zone to use: ($ZONE): " input;
	if [ "$input" != "" ] ; then
		export ZONE="$input";
	fi

    read -rp "REGION to use: ($REGION): " input;
	if [ "$input" != "" ] ; then
		export REGION="$input";
	fi

    read -rp "Cluster name: ($CLUSTER_NAME): " input;
	if [ "$input" != "" ] ; then
		export CLUSTER_NAME="$input";
	fi

    echo

fi

# Set GCP account
gcloud auth activate-service-account --key-file $SECRET_KEY
gcloud config set project $PROJECT_ID
gcloud config set compute/region $REGION
gcloud config set compute/zone $ZONE

# Enable Kubernetes API
gcloud alpha services enable container.googleapis.com

# Creating GKE cluster
gcloud beta container --project $PROJECT_ID clusters create $CLUSTER_NAME --zone $ZONE --username "admin" --cluster-version "1.9.7-gke.11" --machine-type $VM_TYPE --image-type "COS" --disk-type "pd-standard" --disk-size "100" --scopes "https://www.googleapis.com/auth/compute","https://www.googleapis.com/auth/devstorage.read_only","https://www.googleapis.com/auth/logging.write","https://www.googleapis.com/auth/monitoring","https://www.googleapis.com/auth/servicecontrol","https://www.googleapis.com/auth/service.management.readonly","https://www.googleapis.com/auth/trace.append" --num-nodes "1" --enable-cloud-logging --enable-cloud-monitoring --no-enable-ip-alias --network "projects/$PROJECT_ID/global/networks/default" --subnetwork "projects/$PROJECT_ID/regions/$REGION/subnetworks/default" --addons HorizontalPodAutoscaling,HttpLoadBalancing,KubernetesDashboard --enable-autoupgrade --enable-autorepair


# grant your user cluster-admin role
kubectl create clusterrolebinding cluster-admin-binding \
  --clusterrole cluster-admin \
  --user $(gcloud config get-value account)
