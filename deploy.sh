#!/bin/bash
# deploy.sh

echo "=========================================="
echo "🚀 Welcome to the Tracker Simulator Next Gen Automated Installer"
echo "=========================================="

# Check if user configured their values
read -p "Did you review the 'tracker-simulator-nextgen.values.yaml' and 'tracker-simulator-envoy-nextgen.yaml' files? (y/n) " -n 1 -r
echo ""
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Please review the values files and run this script again."
    exit 1
fi

# 1. Prerequisites Check
if ! command -v terraform &> /dev/null; then echo "Error: Terraform not installed."; exit 1; fi
if ! command -v kubectl &> /dev/null; then echo "Error: kubectl not installed (required to fetch LB IP)."; exit 1; fi

# 2. Prompt for the DigitalOcean token
read -p "Enter your DigitalOcean Token (Input will be hidden): " -s DO_TOKEN
echo ""
export TF_VAR_do_token=$DO_TOKEN

# 3. Prompt for the Google API key
read -p "Enter your Google Maps API Key (Input will be hidden): " -s GOOGLE_API_KEY
echo ""
if [ -z "$GOOGLE_API_KEY" ]; then
    echo "Error: Google Maps API Key cannot be empty."
    exit 1
fi
export TF_VAR_google_api_key=$GOOGLE_API_KEY

# 4. Prompt for the SSH public key
read -p "Enter path to your SSH public key [~/.ssh/id_rsa.pub]: " SSH_KEY_PATH
SSH_KEY_PATH=${SSH_KEY_PATH:-~/.ssh/id_rsa.pub}
if [ ! -f "$SSH_KEY_PATH" ]; then
    echo "Error: SSH public key not found at '$SSH_KEY_PATH'."
    exit 1
fi
export TF_VAR_ssh_public_key=$(cat "$SSH_KEY_PATH")

# 5. Execute Terraform (Phase 1 — provision infra + deploy with placeholder LB IP)
echo ""
echo "Initializing Terraform..."
terraform init -input=false
terraform apply -auto-approve

# 6. Extract Kubeconfig
terraform output -raw kubeconfig > kubeconfig.yaml
export KUBECONFIG=$(pwd)/kubeconfig.yaml

# 7. Wait for the Load Balancer IP
echo ""
echo "⏳ Phase 2: Waiting for DigitalOcean to assign a Load Balancer IP..."
echo "(This usually takes 2-3 minutes)"

ENVOY_SVC_NAME=$(kubectl get svc -n envoy-gateway-system -l gateway.envoyproxy.io/owning-gateway-namespace=default -o jsonpath='{.items[0].metadata.name}' 2>/dev/null)

REAL_IP=""
while [ -z "$REAL_IP" ]; do
    sleep 10
    echo "Still waiting for IP..."
    REAL_IP=$(kubectl get svc $ENVOY_SVC_NAME -n envoy-gateway-system -o jsonpath='{.status.loadBalancer.ingress[0].ip}' 2>/dev/null)
done

echo "✅ Load Balancer IP acquired: $REAL_IP"

# 8. Phase 3: Final configuration injection
echo ""
echo "⚙️  Phase 3: Injecting Load Balancer IP into application configuration..."
export TF_VAR_load_balancer_ip=$REAL_IP
terraform apply -auto-approve

echo ""
echo "🎉 DEPLOYMENT COMPLETE! 🎉"
echo "Your application is live at: $REAL_IP"
