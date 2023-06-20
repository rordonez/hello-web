#! /bin/bash

# Environment configuration
export env_name=dev
region="us-east-1"
app_name="hello-world"

# Grab external module dependencies. Normally CI/CD systems have functionalities to perform this task
external_terraform_state_file=/home/vagrant/app/tf/external/terraform.tfstate
ecr_repository=$(terraform output -state=$external_terraform_state_file -json repository_urls | jq -r ".\"$app_name\"")
ecr_url=$(echo $ecr_repository | cut -d/ -f1)

# This multi-stage docker build copies, compiles and run unit tests. Some integration tests can be added as well
docker build --tag $app_name .

# At this point, it should apply a newer version instead of latest
docker tag $app_name:latest $ecr_repository:latest

# Push container to a Container registry
aws ecr get-login-password --region $region | docker login --username AWS --password-stdin $ecr_url
docker push $ecr_repository:latest

# Init, format and validate infrastructure. CI/CD systems have functionalities to perform this task
cd tf
terraform workspace select $env_name || terraform workspace new $env_name
terraform fmt
terraform init
terraform validate

# Some CI/CD modules can handle Terraform inputs and output and module dependencies gracefully.
ecs_cluster_name=$(terraform output -raw -state=$external_terraform_state_file ecs_cluster_name)
terraform plan -auto-approve -var-file=environments/$env_name/terraform.tfvars -var "ecr_repository_url=$ecr_repository" -var "ecs_cluster_name=$ecs_cluster_name"

# At this point you can run infrastructure tests with libraries like terratest or TestContainers before applying the
# code. Some pre or post hooks can be placed as well to review certain changes
terraform apply -auto-approve -var-file=environments/$env_name/terraform.tfvars -var "ecr_repository_url=$ecr_repository" -var "ecs_cluster_name=$ecs_cluster_name"

# Finally you can run smoke tests to check whether the infrastructure ran successfully and is running correctly and
# notify about any event. Also at this point should propagate the new version.
