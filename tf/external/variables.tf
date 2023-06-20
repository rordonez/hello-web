variable "environment" {
  description = "Name of the environment"
  type        = string
  validation {
    condition     = contains(["dev", "prod", "staging"], var.environment)
    error_message = "Environment can only be \"dev\", \"staging\" or \"prod\""
  }
}

variable "cluster_name" {
  description = "Name of the cluster"
  type        = string
}

variable "repositories" {
  description = "List of ECR repositories"
  type        = list(string)
}

variable "region" {
  description = "AWS region"
  default     = "us-east-1"
  type        = string
}

