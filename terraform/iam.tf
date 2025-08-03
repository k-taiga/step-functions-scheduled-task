resource "aws_iam_role" "scheduler" {
  name = "ecs-scheduler-role"
  assume_role_policy = data.aws_iam_policy_document.scheduler_assume_role_policy.json
}

data "aws_iam_policy_document" "scheduler_assume_role_policy" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["scheduler.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy" "scheduler" {
  role   = aws_iam_role.scheduler.name
  name   = "scheduler-policy"
  policy = data.aws_iam_policy_document.scheduler_policy.json
}

# Step Functions の実行権限を付与
data "aws_iam_policy_document" "scheduler_policy" {
  statement {
    effect    = "Allow"
    actions   = ["states:StartExecution"]
    resources = [aws_sfn_state_machine.main.arn]
  }
}