variable "environment" {
  description = "Name of the environment"
  type        = string
  validation {
    condition     = contains(["dev", "prod", "staging"], var.environment)
    error_message = "Environment can only be \"dev\", \"staging\" or \"prod\""
  }
}

variable "application_name" {
  description = "Name of the application"
  type        = string
}

variable "container" {
  description = "Application container configuration"
  type = object({
    port      = number
    host_port = number
    memory    = number
    cpu       = number
    count     = number
  })
}

variable "ecs_cluster_name" {
  description = "ECS cluster name"
  type        = string
}

variable "ecr_repository_url" {
  description = "ECR repository url"
  type        = string
}

variable "region" {
  description = "AWS region"
  default     = "us-east-1"
  type        = string
}
