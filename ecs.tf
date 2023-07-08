resource "aws_ecs_service" "example_service" {
  name            = "mysvc"
  cluster         = aws_ecs_cluster.my_cluster.id
  task_definition = aws_ecs_task_definition.flaskapp_task_def.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    security_groups = [aws_security_group.ecs_security_group.id]
    subnets         = [aws_subnet.subnet1.id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.example_target_group.arn
    container_name   = "example-container"
    container_port   = 80
  }

  lifecycle {
    ignore_changes = [task_definition]
  }
}
