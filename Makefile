SHELL := /bin/bash

kubectl_context:
	kubectl config set-context --current --namespace=argocd

create-projects: kubectl_context
	# Create project-a
	helm template project-a argocd-steps/1-create-projects --set team="team-a" --set cluster_name="cluster-a" --set app_namespace="service-a" | kubectl apply -f -
	# Deploy cluster-b
	helm template project-b argocd-steps/1-create-projects --set team="team-b" --set cluster_name="cluster-b" --set app_namespace="service-b" | kubectl apply -f -

deploy-clusters: kubectl_context
    # Deploy cluster-a
	helm template cluster-a argocd-steps/2-deploy-clusters | kubectl apply -f -
	# Deploy cluster-b
	helm template cluster-b argocd-steps/2-deploy-clusters | kubectl apply -f -

add-clusters-argocd: kubectl_context
	# cluster-a secret
	helm template cluster-a argocd-steps/3-add-clusters-argocd --set cluster_name="cluster-a" \
    --set argocd_token=$(shell vcluster connect -s cluster-a -- kubectl get secrets -o jsonpath="{.items[?(@.metadata.annotations['kubernetes\.io/service-account\.name']=='argocd-admin')].data.token}" | base64 --decode) \
	| kubectl apply -f -
	# cluster-b secret
	helm template cluster-b argocd-steps/3-add-clusters-argocd --set cluster_name="cluster-b" \
	--set argocd_token=$(shell vcluster connect -s cluster-b -- kubectl get secrets -o jsonpath="{.items[?(@.metadata.annotations['kubernetes\.io/service-account\.name']=='argocd-admin')].data.token}"| base64 --decode) \
	| kubectl apply -f -

add-apps: kubectl_context
	# service-a
	helm template service-a argocd-steps/4-add-apps --set project_name="project-a" --set cluster_name="cluster-a" | kubectl apply -f -
	# service-b
	helm template service-b argocd-steps/4-add-apps --set project_name="project-b" --set cluster_name="cluster-b" | kubectl apply -f -