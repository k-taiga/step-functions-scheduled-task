# Step Functions × ECS 定期実行タスク

## 1. 定期実行パターンの比較と選択

| パターン | 構成                                                | 特徴 | 使いどころ |
|----------|---------------------------------------------------|------|------------|
| EventBridge → ECS **RunTask** | EventBridge Scheduler が RunTask API を直接叩く         | ・最小構成でシンプル<br>・at-least-once なので重複起動し得る<br>・リトライ/エラー分岐を細かく制御できない | シンプルな定期実行で十分な場合 |
| EventBridge → **Step Functions** → ECS | EventBridge ルールでステートマシンを起動、内部で `ecs:runTask.sync` | ・タスクが完了するまでステートマシンが待機 → 進行中の重複実行を防げる<br>・Retry / Catch / タイムアウト / SNS 通知などをフローに組み込みやすい | 複雑なワークフローや確実な実行が必要な場合 |

### ref: 
- [Step Functions を使って、ECS のワンショットタスクを実行する](https://tech.classi.jp/entry/one-shot-task-with-step-functions-and-ecs)
- [AWS Step Functionsでコンテナタスクを実行する](https://blog.serverworks.co.jp/aws/stepfunctions/runtask)
- [RunTask API を用いた ECS タスク実行時に気をつけたいこと４選](https://developers.play.jp/entry/2023/10/27/150024)

## 2. Step Functions での ecs run 実行のポイント

### `.sync` パターンの理解
- `ecs:runTask.sync` を使うことで、タスクの完了を待機できる
- Step Functions が CloudWatch Events ルールを自動作成してタスクを監視
- これにより重複実行を防ぎ、確実な処理完了を保証

### 必要な IAM 権限

```hcl
# Step Functions が ECS タスクを実行するために必要な権限
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
        Action = ["iam:PassRole"]
        Resource = [aws_iam_role.ecs_task_execution_role.arn]
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
```

## 3. ECS タスク実行時の注意点

### アーキテクチャの一致
Apple Silicon で buildしている場合、デフォルトだとlinux/amd64になるので下記がおすすめ

```terraform
runtime_platform {
  cpu_architecture        = "ARM64"
  operating_system_family = "LINUX"
}
```

`exec format error` が出た場合は、ビルドしたイメージとECSのアーキテクチャが一致していない。

