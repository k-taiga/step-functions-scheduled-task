resource "aws_sfn_state_machine" "main" {
  name     = "ecs-schedule-state-machine"
  role_arn = aws_iam_role.sfn.arn

  definition = jsonencode({
    StartAt = "RunLaravelBatch"
    States = {
      RunLaravelBatch = {
        Type     = "Task"
        Resource = "arn:aws:states:::ecs:runTask.sync"
        Parameters = {
          LaunchType     = "FARGATE"
          PlatformVersion  = "LATEST"
          Cluster        = aws_ecs_cluster.batch_cluster.arn
          TaskDefinition = aws_ecs_task_definition.laravel_batch.arn
          NetworkConfiguration = {
            AwsvpcConfiguration = {
              Subnets        = data.aws_subnets.default.ids
              SecurityGroups = [aws_security_group.fargate_default.id]
              AssignPublicIp = "ENABLED"
            }
          }
        }
        End = true
      }
    }
  })
}

resource "aws_security_group" "fargate_default" {
  name   = "laravel-batch-fargate-sg"
  vpc_id = data.aws_vpc.default.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_iam_role" "sfn" {
  name               = "example-sfn-role"
  assume_role_policy = data.aws_iam_policy_document.sfn_assume_role_policy.json
}

data "aws_iam_policy_document" "sfn_assume_role_policy" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["states.amazonaws.com"]
    }
  }
}

# Step FunctionsがECSタスクを実行するためのポリシー
resource "aws_iam_role_policy" "sfn_ecs_policy" {
  name = "sfn-ecs-policy"
  role = aws_iam_role.sfn.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ecs:RunTask",
          "ecs:StopTask",
          "ecs:DescribeTasks"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "iam:PassRole"
        ]
        Resource = [
          aws_iam_role.ecs_task_execution_role.arn
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "events:PutTargets",
          "events:PutRule",
          "events:DescribeRule"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "iam:CreateServiceLinkedRole",
          "iam:AttachRolePolicy",
          "iam:PutRolePolicy"
        ]
        Resource = "arn:aws:iam::*:role/aws-service-role/events.amazonaws.com/AWSServiceRoleForCloudWatchEvents*"
        Condition = {
          StringEquals = {
            "iam:AWSServiceName" = "events.amazonaws.com"
          }
        }
      }
    ]
  })
}