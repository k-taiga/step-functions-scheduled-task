resource "aws_sfn_state_machine" "main" {
  name     = "ecs-schedule-state-machine"
  role_arn = aws_iam_role.sfn.arn

  # Hello, World するだけ
  definition = jsonencode({
    StartAt = "Hello"
    States = {
      Hello = {
        Type   = "Pass"
        Result = "Hello, World!"
        End    = true
      }
    }
  })
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