resource "aws_scheduler_schedule" "main" {
  name = "ecs-schedule"

  # 1時間ごとに実行
  schedule_expression = "rate(1 hours)"

  # 定期実行先
  target {
    arn  = aws_sfn_state_machine.main.arn

    role_arn = aws_iam_role.scheduler.arn

    # step functionsのInputにわたす場合はここで指定
    input = jsonencode({
      hoge = "fuga"
    })
  }

  flexible_time_window {
    mode = "OFF"
  }
}