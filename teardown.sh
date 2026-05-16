#!/bin/bash
# teardown.sh

echo "=========================================="
echo "⚠️  Tracker Simulator Next Gen Automated Teardown / Cleanup"
echo "=========================================="
echo "WARNING: This will permanently DESTROY all infrastructure"
echo "and data created by deploy.sh."
echo "=========================================="
echo ""

# 1. Check if Terraform is installed
if ! command -v terraform &> /dev/null; then
    echo "Error: Terraform is not installed."
    exit 1
fi

# 2. Check if the Terraform state file exists
if [ ! -f "terraform.tfstate" ]; then
    echo "Error: No terraform.tfstate file found."
    echo "There is no record of an active deployment in this directory to destroy."
    exit 1
fi

# 3. Securely prompt for the DigitalOcean token
read -p "Enter your DigitalOcean Token to authorize deletion (Input will be hidden): " -s DO_TOKEN
echo ""

# Export the token
export TF_VAR_do_token=$DO_TOKEN

# 4. Execute Terraform Destroy
echo ""
echo "Calculating what needs to be destroyed..."
terraform plan -destroy -out=tfdestroyplan

echo ""
read -p "Are you ABSOLUTELY SURE you want to permanently destroy these resources? (y/n) " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]
then
    echo "Destroying resources... This may take a few minutes."
    terraform apply tfdestroyplan
    echo "✅ Teardown complete. All resources have been removed from your DigitalOcean account."
else
    echo "Teardown cancelled. Your resources are still running."
    exit 0
fi
