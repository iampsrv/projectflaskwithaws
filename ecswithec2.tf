resource "aws_ecs_cluster" "cluster" {
  name = "ecs-devl-cluster"
  tags = {
   name = "ecswithec2"
   }
  }


  resource "aws_instance" "ec2_instance" {
  ami                    = "ami-0bf5ac026c9b5eb88"
  subnet_id              = aws_subnet.subnet1.id
  instance_type          = var.instance_type
  associate_public_ip_address = true
  iam_instance_profile   = "ecsInstanceRole"
  vpc_security_group_ids      = [aws_security_group.ecs_security_group.id]
  key_name                    = "batch5kp"
  user_data                   = <<-EOF
              #!/bin/bash
              sudo yum update -y
              sudo yum install -y ecs-init
              sudo service docker start
              sudo start ecs
              echo ECS_CLUSTER=ecs-devl-cluster >> /etc/ecs/ecs.config
              cat /etc/ecs/ecs.config | grep "ECS_CLUSTER"
              EOF

  tags = {
    Name                   = "ecs-ec2_instance"
}
}

resource "aws_ecs_service" "service" {
  cluster                = "${aws_ecs_cluster.cluster.id}"                                 
  desired_count          = 1                                                         
  launch_type            = "EC2"                                                     
  name                   = "mysvcec2"                                         
  task_definition        = "${aws_ecs_task_definition.flaskapp_task_defec2.arn}"       
  load_balancer {
    container_name       = "ecs-container"                                
    container_port       = "8080"
    target_group_arn     = "${aws_lb_target_group.lb_target_group.arn}"         
 }
  network_configuration {
    security_groups = [aws_security_group.ecs_security_group.id]
    subnets         = [aws_subnet.subnet1.id]
    assign_public_ip = false
  }
  depends_on              = ["aws_lb_listener.lb_listener"]
}