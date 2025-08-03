output "cluster_arn" {
  value = aws_ecs_cluster.batch_cluster.arn
}

output "task_def_arn" {
  value = aws_ecs_task_definition.laravel_batch.arn
}

output "sg_id" {
  value = aws_security_group.ecs_tasks.id
}

output "subnet_ids" {
  value = data.aws_subnets.default.ids
}