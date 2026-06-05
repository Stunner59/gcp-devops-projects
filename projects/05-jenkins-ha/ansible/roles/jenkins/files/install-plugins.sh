#!/bin/bash
# Wait for Jenkins to start
until curl -s http://localhost:8080/login > /dev/null; do
  echo "Waiting for Jenkins..."
  sleep 10
done

# Get initial admin password
ADMIN_PASS=$(cat /var/lib/jenkins/secrets/initialAdminPassword)

# Install essential plugins
PLUGINS=(
  "git"
  "workflow-aggregator"
  "docker-workflow"
  "kubernetes"
  "google-oauth-plugin"
  "gcs-plugin"
  "credentials-binding"
  "pipeline-stage-view"
  "blueocean"
  "configuration-as-code"
)

for plugin in "${PLUGINS[@]}"; do
  echo "Installing plugin: $plugin"
  curl -s -X POST \
    "http://admin:$ADMIN_PASS@localhost:8080/pluginManager/installNecessaryPlugins" \
    -d "<jenkins><install plugin='$plugin@latest'/></jenkins>" \
    -H "Content-Type: text/xml"
done

echo "Plugins installed successfully!"
