output "repository_urls" {
  value = { for repo in aws_ecr_repository.app : repo.name => repo.repository_url }
}

output "region" {
  value = var.region
}

output "ecs_cluster_name" {
  value = var.cluster_name
}
