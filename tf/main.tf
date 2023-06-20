module "service" {
  source = "./modules/app"

  application_name   = var.application_name
  container          = var.container
  ecr_repository_url = var.ecr_repository_url
  ecs_cluster_name   = var.ecs_cluster_name
  environment        = var.environment
  region             = var.region
}

output "service_url" {
  value = module.service.app_url
}