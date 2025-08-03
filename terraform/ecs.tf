# ECSクラスター
resource "aws_ecs_cluster" "batch_cluster" {
  name = "laravel-batch-cluster"
}

# ECSタスク定義
resource "aws_ecs_task_definition" "laravel_batch" {
  family                   = "laravel-batch-task"
  requires_compatibilities = ["FARGATE"]
  network_mode            = "awsvpc"
  cpu                     = "256"
  memory                  = "512"
  execution_role_arn      = aws_iam_role.ecs_task_execution_role.arn

  runtime_platform {
    cpu_architecture        = "ARM64"
    operating_system_family = "LINUX"
  }

  container_definitions = jsonencode([
    {
      name             = "laravel-batch"
      image            = "${aws_ecr_repository.laravel_app.repository_url}:latest"
      command          = ["php", "artisan", "batch:test"]
      workingDirectory = "/app"
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.laravel_batch.name
          awslogs-region        = "ap-northeast-1"
          awslogs-stream-prefix = "batch"
          awslogs-create-group  = "true"
        }
      }
    }
  ])
}

resource "aws_cloudwatch_log_group" "laravel_batch" {
  name              = "/ecs/laravel-batch"
  retention_in_days = 1
}

resource "aws_security_group" "ecs_tasks" {
  name        = "laravel-batch-ecs-sg"
  description = "Security group for ECS tasks"
  vpc_id      = data.aws_vpc.default.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# ECSタスク実行ロール
resource "aws_iam_role" "ecs_task_execution_role" {
  name = "laravel-batch-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })
}

# ECS実行権限
resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}