#!/bin/bash

# Prepare GCP evn
gcloud_init(){
    ./gcloud_init.sh
}

# Router init which should already respond
router_init(){
    kubectl apply -f ./deploy/namespace.yml
    kubectl apply -f ./nginx_operator/rbac.yml
    kubectl apply -f ./nginx_operator/errors_backend.yml
    kubectl apply -f ./nginx_operator/nginx_controller.yml
    kubectl apply -f ./nginx_operator/nginx_service.yml
    sleep 10
    # Deploy REDIS as part of preparation: 1 redis for all services
    kubectl apply -f ./deploy/redis_deployment.yml
    kubectl apply -f ./deploy/redis_service.yml
}

# Deploy microservice
service_init(){

    usage()
    {
	    echo
        echo "usage: service_init [[[-n service_name ] [-p service_path]] | [-h]]" >&2
	    service_menu
    }

    while [ "$1" != "" ]; do
        case $1 in
            --name )                export SERVICE_NAME=$2
    				                shift 2
                                    ;;
            --path )                export SERVICE_PATH=$2
    				                shift 2
                                    ;;
            -h | --help )           usage
    				                service_menu
                                    ;;
            -q | --quit )           exit 1
                                    ;;
            * )                     usage
    				                service_menu
        esac
    done

    sh ./deploy/deployment_template.yml
    kubectl apply -f ./deploy/deployment_${SERVICE_NAME}.yml
    sleep 5
    sh ./deploy/rules_template.yml
    kubectl apply -f ./deploy/rules.yml
    sleep 10 # Let nginx apply rules and get external IP
    export SERVICE_IP=$(kubectl get svc -n micro-namespace -l app=ingress-nginx | awk '/ingress-nginx/{print $4}')
    echo "try running 'curl -v ${SERVICE_IP}${SERVICE_PATH}'"
    exit 0
}

main_menu(){
	PS3='First you need preparing environment. Do you have GCP serviceaccount key?: '
	options=("Yes" "No" "Skip")
	select opt in "${options[@]}"
	do
	case $opt in
	    "Yes")
		echo "Setting up GCP account"
		gcloud_init
		echo "GCP was prepared"
		router_menu
		;;
	    "Skip")
		router_menu
		;;
	    "No")
		echo "Come back later once you have it"
		break
		;;
	    *) echo "invalid option $REPLY";;
	esac
	done

}

router_menu(){
	PS3='Ready to deploy router?: '
	options=("Yes" "No" "Skip")
	select opt in "${options[@]}"
	do
	    case $opt in
		"Yes")
		    echo "Setting up ingress router"
		    router_init
		    service_menu
		    ;;
		"Skip")
		    service_menu
		    ;;
		"No")
		    echo "Come back later"
		    break
		    ;;
		*) echo "invalid option $REPLY";;
	    esac
	done
}

service_menu(){
    while true; do
        name_re='[^[:alnum:]]'
        path_re='^/[A-Za-z0-9]+(/[A-Za-z0-9]*)*'

        read -rp "SERVICE_NAME to use: ($SERVICE_NAME): " input_name;
        read -rp "SERVICE_PATH to use: ($SERVICE_PATH): " input_path;
	if [ -z '$input_name' ] || [ -z '$input_path' ] ; then
		echo "Both service name and service path are required"
		PS3='Retry?'
		options=("Yes" "Quit")
		select opt in "${options[@]}"
		do
		    case $opt in
			"Yes")
			    echo "Setting up ingress router"
			    service_menu
			    ;;
			"Quit")
			    break
			    ;;
			*) echo "invalid option $REPLY";;
		    esac
		done
	fi

    	if ! [[ "$input_name" =~ $name_re ]] ; then
    		export SERVICE_NAME="$input_name";
		echo "Service name = " $SERVICE_NAME
	else
		echo
		echo "should be alpha-numeric value" >&2
	        service_menu

    	fi

    	if [[ $input_path =~ $path_re ]] ; then
    		export SERVICE_PATH="$input_path";
		echo "Service path = " $SERVICE_PATH
	else
		echo
		echo "should be path - e.g. '/path/to/service'" >&2
		service_menu
    	fi

        service_init --name $SERVICE_NAME --path $SERVICE_PATH
        if [[ $? -eq 0 ]]; then
            break
        fi
    done
}

main_menu
