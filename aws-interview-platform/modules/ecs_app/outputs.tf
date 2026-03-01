output "alb_arn_suffix" {
  value = aws_lb.app.arn_suffix
}

output "target_group_arn_suffix" {
  value = aws_lb_target_group.app.arn_suffix
}

output "ecs_service_name" {
  value = aws_ecs_service.app.name
}

output "ecs_cluster_name" {
  value = aws_ecs_cluster.this.name
}