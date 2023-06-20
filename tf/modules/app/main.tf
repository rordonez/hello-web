locals {
  subnet_ids = [aws_default_subnet.default_subnet_a.id, aws_default_subnet.default_subnet_b.id]
}

data "aws_iam_role" "task_execution" {
  name = "ecsTaskExecutionRole"
}

resource "aws_ecs_task_definition" "app_task" {
  family                   = var.application_name
  container_definitions    = <<DEFINITION
  [
    {
      "name": "${var.application_name}",
      "image": "${var.ecr_repository_url}",
      "essential": true,
      "portMappings": [
        {
          "containerPort": ${var.container.port},
          "hostPort": ${var.container.host_port}
        }
      ],
      "memory": ${var.container.memory},
      "cpu": ${var.container.cpu}
    }
  ]
  DEFINITION
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  memory                   = var.container.memory
  cpu                      = var.container.cpu
  execution_role_arn       = data.aws_iam_role.task_execution.arn
  tags = {
    Name        = var.application_name
    Component   = "Application ECS task"
    Environment = var.environment
  }
}


data "aws_ecs_cluster" "ecs" {
  cluster_name = var.ecs_cluster_name
}

resource "aws_ecs_service" "app_service" {
  name            = var.application_name
  cluster         = data.aws_ecs_cluster.ecs.id
  task_definition = aws_ecs_task_definition.app_task.arn
  launch_type     = "FARGATE"
  desired_count   = var.container.count

  load_balancer {
    target_group_arn = aws_lb_target_group.target_group.arn
    container_name   = aws_ecs_task_definition.app_task.family
    container_port   = var.container.port
  }

  network_configuration {
    subnets          = local.subnet_ids
    assign_public_ip = true
    security_groups  = [aws_security_group.service_security_group.id]
  }
  tags = {
    Name        = var.application_name
    Component   = "ECS service"
    Environment = var.environment
  }
}

resource "aws_alb" "application_load_balancer" {
  name               = "load-balancer-${var.application_name}"
  load_balancer_type = "application"
  subnets            = local.subnet_ids
  security_groups    = [aws_security_group.load_balancer_security_group.id]
  tags = {
    Name        = var.application_name
    Component   = "Application Load Balancer"
    Environment = var.environment
  }
}

resource "aws_security_group" "load_balancer_security_group" {
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name        = var.application_name
    Component   = "Load balancer security group"
    Environment = var.environment
  }
}

resource "aws_lb_target_group" "target_group" {
  name        = "target-group"
  port        = 80
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = aws_default_vpc.default_vpc.id
  tags = {
    Name        = var.application_name
    Component   = "Load balancer security group"
    Environment = var.environment
  }
}

resource "aws_lb_listener" "listener" {
  load_balancer_arn = aws_alb.application_load_balancer.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.target_group.arn
  }
  tags = {
    Name        = var.application_name
    Component   = "Load balancer listener"
    Environment = var.environment
  }
}

resource "aws_security_group" "service_security_group" {
  ingress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    security_groups = [aws_security_group.load_balancer_security_group.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name        = var.application_name
    Component   = "Load balancer security group"
    Environment = var.environment
  }
}

# For the purpose of this exercise, I will keep basic network configurations
resource "aws_default_vpc" "default_vpc" {
}

resource "aws_default_subnet" "default_subnet_a" {
  availability_zone = "us-east-1a"
}

resource "aws_default_subnet" "default_subnet_b" {
  availability_zone = "us-east-1b"
}
