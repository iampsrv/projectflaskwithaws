
resource "aws_ecrpublic_repository" "aws_ecr_repo_pub" {

  repository_name = "aws_ecr_repo_pub_batchfive"

  catalog_data {
    about_text        = "This ecr pub repo is created by terraform"
    architectures     = ["ARM", "ARM 64"]
    operating_systems = ["Linux", "Windows"]
  }
}

resource "aws_ecs_task_definition" "flaskapp_task_def" {
  family                   = "flaskapp_task_def_batchfive-tf"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 1024
  memory                   = 2048
  task_role_arn            = "arn:aws:iam::633423483143:role/ecsTaskExecutionRole"
  execution_role_arn       = "arn:aws:iam::633423483143:role/ecsTaskExecutionRole"
  runtime_platform {
    operating_system_family = "LINUX"
  }

  container_definitions = jsonencode([
    {
      name  = "myflaskcontainer"
      image = "public.ecr.aws/b5z7k8i9/aws_ecr_repo_pub_batchfive:latest"
      essential = true
      portMappings = [
        { "protocol"    = "tcp"
          containerPort = 8080
          hostPort      = 8080
        }
      ]
      logConfiguration = {
        "logDriver" = "awslogs",
        "options" = {
          "awslogs-group"         = "/ecs/flaskapp_task_def_batchfive-tf",
          "awslogs-region"        = "us-east-1",
          "awslogs-stream-prefix" = "ecs"
      } }
    }
  ])
}

resource "aws_ecs_task_definition" "flaskapp_task_defec2" {
  family                = "flaskapp_task_def_batchfive-tfec2"
  cpu    = 512
  memory = 512
  requires_compatibilities = ["EC2"]
  task_role_arn      = "arn:aws:iam::633423483143:role/ecsTaskExecutionRole"
  execution_role_arn = "arn:aws:iam::633423483143:role/ecsTaskExecutionRole"
  network_mode             = "awsvpc" 
  container_definitions = jsonencode([
    {
      name      = "myflaskcontainer"
      image     = "public.ecr.aws/b5z7k8i9/aws_ecr_repo_pub_batchfive:latest"
      essential = true
      portMappings = [
        {
          containerPort = 8080
          hostPort      = 8080
          protocol      = "tcp"
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = "/ecs/flaskapp_task_def_batchfive-tf"
          "awslogs-region"        = "us-east-1"
          "awslogs-stream-prefix" = "ecs"
        }
      }
    }
  ])
}
