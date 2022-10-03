#!/bin/bash
# -----------------------------------------#
#        Setting Global variables          #
# -----------------------------------------#
# DEBUG_VERSION=7
# KUBECTL_VERSION=v1.22.12
GH_CLI_VERSION=2.15.0
KEPTN_VERSION=0.18.2
JOB_EXECUTOR_SERVICE_VERSION=0.3.0
JOB_EXECUTOR_NAMESPACE=keptn-jes
KEPTN_PROMETHEUS_SERVICE_VERSION=0.9.1
PROMETHEUS_VERSION=15.12.0


# ----------------------------------------#
#      Step 1/11: Installing Kubectl      #
# ----------------------------------------#
# curl -LO https://dl.k8s.io/release/$KUBECTL_VERSION/bin/linux/amd64/kubectl

# ----------------------------------------#
#      Step 2/11: Installing Helm         #
# ----------------------------------------#
# curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 && chmod 700 get_helm.sh
# ./get_helm.sh
# Downloading https://get.helm.sh/helm-v3.10.0-linux-amd64.tar.gz
# Verifying checksum... Done.
# Preparing to install helm into /usr/local/bin
# helm installed into /usr/local/bin/helm

# -----------------------------------------#
#      Step 3/11: Installing Keptn CLI     #
# -----------------------------------------#
# curl -sL https://get.keptn.sh | KEPTN_VERSION=$KEPTN_VERSION bash

# -----------------------------------------#
#    Step 4/11: Installing GitHub CLI      #
# -----------------------------------------#
# wget -q https://github.com/cli/cli/releases/download/v${GH_CLI_VERSION}/gh_${GH_CLI_VERSION}_linux_amd64.deb
# chmod +x gh_${GH_CLI_VERSION}_linux_amd64.deb
# sudo dpkg -i gh_${GH_CLI_VERSION}_linux_amd64.deb

# -------------------------------------------#
# Step 5/11: Installing Keptn Control Plane  #
# -------------------------------------------#
helm install keptn https://github.com/keptn/keptn/releases/download/$KEPTN_VERSION/keptn-$KEPTN_VERSION.tgz \
 -n keptn --create-namespace \
 --set=continuousDelivery.enabled=true \
 --set=apiGatewayNginx.type=LoadBalancer \
 --set mongo.resources.requests.cpu=0 \
 --set mongo.resources.requests.memory=0 \
 --set nats.nats.resources.requests.cpu=0 \
 --set nats.nats.resources.requests.memory=0 \
 --set nats.nats.jetstream.memStorage.size=0M \
 --set apiGatewayNginx.resources.requests.cpu=0 \
 --set apiGatewayNginx.resources.requests.memory=0 \
 --set remediationService.resources.requests.cpu=0 \
 --set remediationService.resources.requests.memory=0 \
 --set apiService.resources.requests.cpu=0 \
 --set apiService.resources.requests.memory=0 \
 --set bridge.versionCheck.enabled=false \
 --set bridge.resources.requests.cpu=0 \
 --set bridge.resources.requests.memory=0 \
 --set distributor.resources.requests.cpu=0 \
 --set distributor.resources.requests.memory=0 \
 --set shipyardController.resources.requests.cpu=0 \
 --set shipyardController.resources.requests.memory=0 \
 --set secretService.resources.requests.cpu=0 \
 --set secretService.resources.requests.memory=0 \
 --set configurationService.resources.requests.cpu=0 \
 --set configurationService.resources.requests.memory=0 \
 --set resourceService.resources.requests.cpu=0 \
 --set resourceService.resources.requests.memory=0 \
 --set mongodbDatastore.resources.requests.cpu=0 \
 --set mongodbDatastore.resources.requests.memory=0 \
 --set lighthouseService.resources.requests.cpu=0 \
 --set lighthouseService.resources.requests.memory=0 \
 --set statisticsService.enabled=false \
 --set approvalService.resources.requests.cpu=0 \
 --set approvalService.resources.requests.memory=0 \
 --set webhookService.resources.requests.cpu=0 \
 --set webhookService.resources.requests.memory=0

# ---------------------------------------------#
#    Step 6/11: Installing Execusion plan      #
# ---------------------------------------------#
helm repo add keptn https://charts.keptn.sh
helm install jmeter-service keptn/jmeter-service -n keptn
helm install helm-service keptn/helm-service -n keptn

# -----------------------------------------#
#    Step 7/11: Installing Prometheus      #
# -----------------------------------------#
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm install prometheus prometheus-community/prometheus \
 --namespace monitoring --create-namespace \
 --version ${PROMETHEUS_VERSION}

# --------------------------------------------#
# Step 8/11: Installing Prometheus Service   #
# --------------------------------------------#
helm install -n keptn prometheus-service https://github.com/keptn-contrib/prometheus-service/releases/download/$KEPTN_PROMETHEUS_SERVICE_VERSION/prometheus-service-$KEPTN_PROMETHEUS_SERVICE_VERSION.tgz --set resources.requests.cpu=0m

# NOTES:
# The Prometheus server can be accessed via port 80 on the following DNS name from within your cluster:
# prometheus-server.monitoring.svc.cluster.local


# Get the Prometheus server URL by running these commands in the same shell:
#   export POD_NAME=$(kubectl get pods --namespace monitoring -l "app=prometheus,component=server" -o jsonpath="{.items[0].metadata.name}")
#   kubectl --namespace monitoring port-forward $POD_NAME 9090


# The Prometheus alertmanager can be accessed via port 80 on the following DNS name from within your cluster:
# prometheus-alertmanager.monitoring.svc.cluster.local


# Get the Alertmanager URL by running these commands in the same shell:
#   export POD_NAME=$(kubectl get pods --namespace monitoring -l "app=prometheus,component=alertmanager" -o jsonpath="{.items[0].metadata.name}")
#   kubectl --namespace monitoring port-forward $POD_NAME 9093
# #################################################################################
# ######   WARNING: Pod Security Policy has been moved to a global property.  #####
# ######            use .Values.podSecurityPolicy.enabled with pod-based      #####
# ######            annotations                                               #####
# ######            (e.g. .Values.nodeExporter.podSecurityPolicy.annotations) #####
# #################################################################################


# The Prometheus PushGateway can be accessed via port 9091 on the following DNS name from within your cluster:
# prometheus-pushgateway.monitoring.svc.cluster.local


# Get the PushGateway URL by running these commands in the same shell:
#   export POD_NAME=$(kubectl get pods --namespace monitoring -l "app=prometheus,component=pushgateway" -o jsonpath="{.items[0].metadata.name}")
#   kubectl --namespace monitoring port-forward $POD_NAME 9091


# --------------------------------------------#
# Step 9/11: Installing Job Executor Service  #
# --------------------------------------------#
KEPTN_API_TOKEN=$(kubectl get secret keptn-api-token -n keptn -o jsonpath={.data.keptn-api-token} | base64 -d)
helm install --namespace $JOB_EXECUTOR_NAMESPACE \
 --create-namespace \
 --set=remoteControlPlane.api.hostname=api-gateway-nginx.keptn \
 --set=remoteControlPlane.api.token=$KEPTN_API_TOKEN --set=remoteControlPlane.topicSubscription="sh.keptn.event.deployment.triggered\,sh.keptn.event.test.triggered\,sh.keptn.event.action.triggered" \
 job-executor-service https://github.com/keptn-contrib/job-executor-service/releases/download/$JOB_EXECUTOR_SERVICE_VERSION/job-executor-service-$JOB_EXECUTOR_SERVICE_VERSION.tgz


# -----------------------------------------#
#    Step 10/12: Retrieving demo files     #
# -----------------------------------------#
kubectl apply -f https://raw.githubusercontent.com/christian-kreuzberger-dtx/keptn-job-executor-delivery-poc/main/job-executor/workloadClusterRoles.yaml

# -----------------------------------------#
#    Step 11/11: Wait for all pods         #
# -----------------------------------------#
kubectl -n monitoring wait --for condition=Available=True --timeout=5m deployment/prometheus-kube-state-metrics
kubectl -n monitoring wait --for condition=Available=True --timeout=5m deployment/prometheus-pushgateway
kubectl -n monitoring wait --for condition=Available=True --timeout=5m deployment/prometheus-alertmanager
kubectl -n monitoring wait --for condition=Available=True --timeout=5m deployment/prometheus-server
kubectl -n keptn-jes wait --for condition=Available=True --timeout=5m deployment/job-executor-service
kubectl -n keptn wait --for condition=Available=True --timeout=5m deployment/api-gateway-nginx
kubectl -n keptn wait --for condition=Available=True --timeout=5m deployment/resource-service
kubectl -n keptn wait --for condition=Available=True --timeout=5m deployment/secret-service
kubectl -n keptn wait --for condition=Available=True --timeout=5m deployment/api-service
kubectl -n keptn wait --for condition=Available=True --timeout=5m deployment/bridge
kubectl -n keptn wait --for condition=Available=True --timeout=5m deployment/mongodb-datastore
kubectl -n keptn wait --for condition=Available=True --timeout=5m deployment/keptn-mongo
kubectl -n keptn wait --for condition=Available=True --timeout=5m deployment/shipyard-controller
kubectl -n keptn wait --for condition=Available=True --timeout=5m deployment/remediation-service
kubectl -n keptn wait --for condition=Available=True --timeout=5m deployment/approval-service
kubectl -n keptn wait --for condition=Available=True --timeout=5m deployment/webhook-service
kubectl -n keptn wait --for condition=Available=True --timeout=5m deployment/lighthouse-service
kubectl -n keptn wait --for condition=Available=True --timeout=5m deployment/prometheus-service

# ---------------------------------------------#
#       🎉 Installation Complete 🎉           #
# ---------------------------------------------#

# ---------------------------------------------#
#                Authentication              #
# ---------------------------------------------#
keptn auth --endpoint=http://$(kubectl get svc -n keptn -o jsonpath='{.items[?(@.metadata.name=="api-gateway-nginx")].status.loadBalancer.ingress[0].hostname}') --api-token=$(kubectl get secret keptn-api-token -n keptn -o jsonpath='{.data.keptn-api-token}' | base64 -d)

keptn configure bridge --output

