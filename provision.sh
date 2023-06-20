#!/usr/bin/env bash

set -e

terraform_version="1.5.0-*"
pro=$(dpkg --print-architecture)

echo installing jq and unzip ...
sudo apt-get update && sudo apt-get install -y unzip jq

echo installing AWS cli
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install --update
rm awscliv2.zip && rm -rf aws

echo Installing terraform onto machine...
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
sudo apt-get update
sudo apt-get install "terraform=${terraform_version}"

echo Verifying installed tools
aws --version
jq --version
terraform --version

echo Installing Terraform and AWS autocompletion
terraform -install-autocomplete
echo 'complete -C aws_completer aws' >> /home/vagrant/.profile

# Deploy some infrastructure to configure ECS and ECR simulating an environment with existing infrastructure
cd app/tf/external
terraform init
terraform apply -auto-approve

