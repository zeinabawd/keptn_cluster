cd keptn_files
echo ""
echo "================================================================================="
echo " Creating brand new Git repo ($GIT_NEW_REPO_NAME) on your GitHub.com account     "
echo "================================================================================="
gh repo create $GIT_NEW_REPO_NAME --public

echo "#=================================#"
echo "# Please enter Keptn details now  #"
echo "#=================================#"
read -p 'Project name: ' PROJECT_NAME
read -p 'Keptn service name: ' SERVICE_NAME
echo ""
echo "================================================================================="
echo " Creating Keptn project ($PROJECT_NAME) and a Keptn service ($SERVICE_NAME)      "
echo "================================================================================="
keptn create project $PROJECT_NAME --shipyard shipyard.yaml --git-remote-url $GIT_REPO --git-user $GIT_USER --git-token $GITHUB_TOKEN
keptn create service $SERVICE_NAME --project=$PROJECT_NAME

echo ""
echo "================================================================================="
echo "Adding Helm Chart ($SERVICE_NAME.tgz), Locust files and Job Executor Service files to Git"
echo "================================================================================="
keptn add-resource --project=$PROJECT_NAME --service=$SERVICE_NAME --all-stages --resource=./helm/$SERVICE_NAME.tgz --resourceUri=helm/$SERVICE_NAME.tgz
keptn add-resource --project=$PROJECT_NAME --service=$SERVICE_NAME --stage=qa --resource=./helm/endpoints.yaml --resourceUri=helm/endpoints.yaml
# keptn add-resource --project=$PROJECT_NAME --service=$SERVICE_NAME --stage=qa --resource=./locust/basic.py
# keptn add-resource --project=$PROJECT_NAME --service=$SERVICE_NAME --stage=qa --resource=./locust/locust.conf
keptn add-resource --project=$PROJECT_NAME --service=$SERVICE_NAME --stage=qa --resource=./load.jmx --resourceUri=jmeter/load.jmx
# keptn add-resource --project=$PROJECT_NAME --service=$SERVICE_NAME --all-stages --resource=./job-executor/job-executor-config.yaml --resourceUri=job/config.yam

echo "===================================================="
echo "Configuring Keptn to Use Prometheus                 "
echo "===================================================="
keptn add-resource --project=$PROJECT_NAME --service=$SERVICE_NAME --stage=qa --resource=./prometheus/sli.yaml --resourceUri=prometheus/sli.yaml
keptn add-resource --project=$PROJECT_NAME --service=$SERVICE_NAME --stage=qa --resource=./quality_gated_release/slo.yaml --resourceUri=slo.yaml
keptn configure monitoring prometheus --project=$PROJECT_NAME --service=$SERVICE_NAME

# kubectl port-forward svc/prometheus-server 8080:80 -n monitoring

echo ""
echo "================================================================================="
echo "Triggering Delivery of the $SERVICE_NAME v0.1.1 Artifact (Follow progress in the Bridge)"
echo "================================================================================="
keptn trigger delivery \
--project=$PROJECT_NAME \
--service=$SERVICE_NAME \
--image="ghcr.io/podtato-head/podtatoserver:v0.1.1" \
--labels=image="ghcr.io/podtato-head/podtatoserver",version="v0.1.1"
