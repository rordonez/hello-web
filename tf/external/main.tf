resource "aws_ecr_repository" "app" {
  for_each = toset(var.repositories)
  name     = each.key
  tags = {
    Name        = each.key
    Component   = "ECR repository"
    Environment = var.environment
  }
}

resource "aws_ecs_cluster" "test-cluster" {
  name = var.cluster_name
  tags = {
    Name        = "ECS"
    Component   = "ECS cluster"
    Environment = var.environment
  }
}

resource "aws_iam_role" "ecs_task_execution" {
  name               = "ecsTaskExecutionRole"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
  tags = {
    Name        = "ECS Task Execution role"
    Component   = "ECS Task execution role"
    Environment = var.environment
  }
}

data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "ecs_lask_execution_policy" {
  role       = aws_iam_role.ecs_task_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}
