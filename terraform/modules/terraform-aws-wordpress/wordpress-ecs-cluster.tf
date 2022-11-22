data "aws_caller_identity" "current" { }

resource "aws_security_group" "ALBSecurityGroup" {
  name        = "Wordpress-Demo-ALB-SG"
  description = "ALB Security Group"
  vpc_id      = var.VpcId

  ingress {
    description = "Allow database access to the whole world"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }
}

resource "aws_lb" "WordPressALB" {
  name               = "wof-load-balancer"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.ALBSecurityGroup.id]
  subnets            = [var.PublicSubnet0, var.PublicSubnet1]
}

resource "aws_alb_target_group" "WordpressTargetgroup" {
  name        = "WordPressTargetGroup"
  port        = 8080
  protocol    = "HTTP"
  target_type = "ip"
  health_check {
    port = 8080
  }
  vpc_id = var.VpcId
}

resource "aws_alb_listener" "WordPressALBListener" {
  load_balancer_arn = aws_lb.WordPressALB.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    forward {
      target_group {
        arn = aws_alb_target_group.WordpressTargetgroup.arn
        weight = 1
      }
    }
  }
}

resource "aws_cloudwatch_log_group" "task_log_group" {
  name              = "/aws/ecs/app-WordpressApp"
  retention_in_days = 1 # expire logs after 1 day
}

resource "aws_ecs_task_definition" "WordPressTask" {
  family                   = "wof-tutorial"
  cpu                      = 1024
  memory                   = 3072
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  execution_role_arn       = var.task_execution_role

  container_definitions = jsonencode([
    {
      name  = "wordpress"
      image = "bitnami/wordpress"

      portMappings = [
        {
          containerPort = 8080
          protocol      = "tcp"
        }
      ]

      environment = [
        {
          name  = "MARIADB_HOST",
          value = var.WordpressDB
        },
        {
          name  = "WORDPRESS_DATABASE_USER",
          value = "admin"
        },
        {
          name  = "WORDPRESS_DATABASE_PASSWORD",
          value = "supersecretpassword"
        },
        {
          name  = "WORDPRESS_DATABASE_NAME",
          value = "wordpress"
        },
        {
          name  = "PHP_MEMORY_LIMIT",
          value = "512M"
        },
        {
          name  = "enabled",
          value = "false"
        },
        {
          name  = "ALLOW_EMPTY_PASSWORD",
          value = "yes"
        }
      ]

      mountPoints = [
          { 
              containerPath = "/bitnami/wordpress"
              sourceVolume = "wordpress"
          }
      ]
      logConfiguration = {
          logDriver = "awslogs",
          options = {
            awslogs-group = aws_cloudwatch_log_group.task_log_group.name
            awslogs-region = "us-east-1"
            awslogs-stream-prefix = "ecs"
          }
        }

    }
  ])

  volume {
    name      = "wordpress"
    efs_volume_configuration {
      file_system_id     = var.FileSystemId
      transit_encryption = "ENABLED"
      authorization_config {
        access_point_id = var.AccessPoint
        iam             = "DISABLED"
      }
    }
  }
}

resource "aws_ecs_cluster" "WordPressCluster" {
  name = "ecs-fargate-wordpressexport"
}

resource "aws_ecs_cluster_capacity_providers" "WordpressCluster_CP" {
  cluster_name = aws_ecs_cluster.WordPressCluster.name

  capacity_providers = ["FARGATE_SPOT"]
}

resource "aws_security_group" "WordPressServiceSG" {
  name        = "Svc-WordPress-on-Fargate"
  description = "Svc-WordPress-on-Fargate"
  vpc_id      = var.VpcId
  ingress {
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [aws_security_group.ALBSecurityGroup.id]
  }
  
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }
}

resource "aws_ecs_service" "WordPressService" {
  name                               = "WordPressService"
  cluster                            = aws_ecs_cluster.WordPressCluster.id
  deployment_maximum_percent         = 100
  deployment_minimum_healthy_percent = 0
  desired_count                      = 2
  launch_type                        = "FARGATE"
  load_balancer {
    container_name   = "wordpress"
    container_port   = 8080
    target_group_arn = aws_alb_target_group.WordpressTargetgroup.arn
  }
  network_configuration {
    assign_public_ip = false
    security_groups  = [aws_security_group.WordPressServiceSG.id]
    subnets          = [var.PrivateSubnet0, var.PrivateSubnet1]
  }
  platform_version = "1.4.0"
  task_definition  = aws_ecs_task_definition.WordPressTask.arn
}

resource "aws_appautoscaling_target" "ECSScalableTarget" {
  max_capacity       = 4
  min_capacity       = 1
  resource_id        = "service/${aws_ecs_cluster.WordPressCluster.name}/${aws_ecs_service.WordPressService.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
  role_arn           = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/aws-service-role/ecs.application-autoscaling.amazonaws.com/AWSServiceRoleForApplicationAutoScaling_ECSService"
}

resource "aws_appautoscaling_policy" "ServiceScalingPolicyCPU" {
  #   TODO: HOW??
  name        = "AWS::StackName-target-tracking-cpu70"
  policy_type = "TargetTrackingScaling"
  resource_id = aws_appautoscaling_target.ECSScalableTarget.id
  scalable_dimension = aws_appautoscaling_target.ECSScalableTarget.scalable_dimension
  service_namespace  = aws_appautoscaling_target.ECSScalableTarget.service_namespace
  target_tracking_scaling_policy_configuration {
    target_value       = 75.0
    scale_in_cooldown  = 60
    scale_out_cooldown = 60
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
  }
}

resource "aws_appautoscaling_policy" "ServiceScalingPolicyMem" {
  #   TODO: HOW??
  name        = "AWS::StackName-target-tracking-mem90"
  policy_type = "TargetTrackingScaling"
  resource_id = aws_appautoscaling_target.ECSScalableTarget.id
  scalable_dimension = aws_appautoscaling_target.ECSScalableTarget.scalable_dimension
  service_namespace  = aws_appautoscaling_target.ECSScalableTarget.service_namespace
  target_tracking_scaling_policy_configuration {
    target_value       = 90.0
    scale_in_cooldown  = 60
    scale_out_cooldown = 60
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageMemoryUtilization"
    }
  }
}
