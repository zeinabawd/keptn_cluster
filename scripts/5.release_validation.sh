echo ""
echo "===================================================="
echo " Adding Prometheus SLIs and SLOs to production stage"
echo "===================================================="
cd
keptn add-resource --project=$PROJECT_NAME --service=$SERVICE_NAME --stage=production --resource=./prometheus/sli.yaml --resourceUri=prometheus/sli.yaml
keptn add-resource --project=$PROJECT_NAME --service=$SERVICE_NAME --stage=production --resource=./quality_gated_release/slo.yaml --resourceUri=slo.yaml

echo ""
echo "===================================================="
echo " Adding Locust files to production stage            "
echo "===================================================="
keptn add-resource --project=$PROJECT_NAME --service=$SERVICE_NAME --stage=production --resource=./locust/basic.py
keptn add-resource --project=$PROJECT_NAME --service=$SERVICE_NAME --stage=production --resource=./locust/locust.conf

echo ""
echo "===================================================="
echo " Add new test and evaluation tasks to production    "
echo "===================================================="
cd ~/$GIT_NEW_REPO_NAME
cp ~/release_validation/shipyard.yaml ~/$GIT_NEW_REPO_NAME/shipyard.yaml

git remote set-url origin https://$GIT_USER:$GITHUB_TOKEN@github.com/$GIT_USER/$GIT_NEW_REPO_NAME.git
git config --global user.email "keptn@keptn.sh"
git config --global user.name "Keptn"
git add -A
git commit -m "add load gen and evaluation to production"
git push

echo ""
echo "===================================================="
echo "Trigger another delivery of $SERVICE_NAME v0.1.1     "
echo "===================================================="
keptn trigger delivery \
--project=$PROJECT_NAME \
--service=$SERVICE_NAME \
--image="ghcr.io/podtato-head/podtatoserver:v0.1.1" \
--labels=image="ghcr.io/podtato-head/podtatoserver",version="v0.1.1"