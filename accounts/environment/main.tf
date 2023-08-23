#--------------------------------------------
# Deploy ECS
# Documentation: https://registry.terraform.io/modules/terraform-aws-modules/ecs/aws/5.2.0
#--------------------------------------------

module "ecs" {
  source  = "terraform-aws-modules/ecs/aws"
  version = "5.2.0"

  cluster_name = "ecs-${var.project_name}-${var.env}"

  cluster_configuration = {
    execute_command_configuration = {
      logging = "OVERRIDE"
      log_configuration = {
        cloud_watch_log_group_name = "/aws/ecs"
      }
    }
  }

  fargate_capacity_providers = {
    FARGATE = {
      default_capacity_provider_strategy = {
        weight = 100
      }
    }
  }

  tags = var.tags
}


module "ecs_service" {
  source = "terraform-aws-modules/ecs/aws//modules/service"
  version = "5.2.0"

  name        = "SERVICE_NAME"
  cluster_arn = module.ecs.cluster_arn

  cpu    = 1024
  memory = 2048

  autoscaling_max_capacity = 4
  autoscaling_min_capacity = 1

  enable_execute_command = true

  # Container definition(s)
  container_definitions = {
    auto-api = {
      cpu                      = 1024
      memory                   = 2048
      essential                = true
      image                    = "${var.devops_account_id}.dkr.ecr.us-east-1.amazonaws.com/IMAGE_NAME"
      readonly_root_filesystem = false
      port_mappings = [
        {
          name          = "my-project"
          containerPort = 3000
          protocol      = "tcp"
        }
      ]
    }
  }

  load_balancer = {
    service = {
      target_group_arn = module.alb_ecs.target_group_arns[0]
      #target_group_arn = "arn:aws:elasticloadbalancing:us-east-1:628571470349:targetgroup/ecs-20230721191541895200000003/95a3df463b2b2fae"
      container_name = "my-project"
      container_port = 3000
    }
  }

  subnet_ids = [module.private_subnets["pvt-sb-a"].id, module.private_subnets["pvt-sb-b"].id]
  security_group_rules = {
    alb_ingress_3000 = {
      type                     = "ingress"
      from_port                = 3000
      to_port                  = 3000
      protocol                 = "tcp"
      description              = "Service port"
      source_security_group_id = module.lb_securitygroup.security_group_id
    }
    egress_all = {
      type        = "egress"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  task_exec_secret_arns = [
    module.secrets_manager["aurora"].arn
  ]

  force_new_deployment = false
  triggers             = null

  tags = var.tags
}


#--------------------------------------------
# Deploy Security Group LB
# Documentation: https://registry.terraform.io/modules/terraform-aws-modules/security-group/aws/5.1.0
#--------------------------------------------
module "lb_securitygroup" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "5.1.0"

  name        = "lb-sg-${var.project_name}-${var.env}"
  description = "Security group for LB traffic"
  vpc_id      = module.vpc.id

  ingress_cidr_blocks = [var.vpc_cidr_block]
  # ingress_with_source_security_group_id = [
  #   {
  #     from_port                = 80
  #     to_port                  = 80
  #     protocol                 = "tcp"
  #     description              = "LB to ECS traffic"
  #     source_security_group_id = module.apig_securitygroup.security_group_id
  #   }
  # ]
  egress_rules = ["all-all"]
}


#--------------------------------------------
# Deploy NLB
# Documentation: https://registry.terraform.io/modules/terraform-aws-modules/alb/aws/8.7.0
#--------------------------------------------

module "alb_ecs" {
  source  = "terraform-aws-modules/alb/aws"
  version = "8.7.0"

  name     = "alb-internal-${var.project_name}-${var.env}"
  internal = true

  load_balancer_type = "application"

  vpc_id  = module.vpc.id
  subnets = [module.private_subnets["pvt-sb-a"].id, module.private_subnets["pvt-sb-b"].id]
  #subnets = [module.public_subnets["pub-sb-a"].id, module.public_subnets["pub-sb-b"].id]
  security_groups = ["${module.lb_securitygroup.security_group_id}"]

  access_logs = {
    bucket = "alb-logs"
  }

  target_groups = [
    {
      name_prefix      = "my-project-"
      backend_protocol = "HTTP"
      backend_port     = 80
      target_type      = "ip"
      health_check = {
        enabled             = true
        interval            = 30
        path                = "/healthcheck"
        port                = "traffic-port"
        healthy_threshold   = 5
        unhealthy_threshold = 2
        timeout             = 6
        protocol            = "HTTP"
        matcher             = "200"
      }
    }
  ]

  http_tcp_listeners = [
    {
      port               = 80
      protocol           = "HTTP"
      target_group_index = 0
    }
  ]

  tags = var.tags
}

#--------------------------------------------
# Deploy Aurora Serverless Mysql
# Documentation: https://registry.terraform.io/modules/terraform-aws-modules/rds-aurora/aws/8.3.1/examples/serverless
#--------------------------------------------

module "aurora_serverless" {
  source  = "terraform-aws-modules/rds-aurora/aws"
  version = "8.3.1"

  name                                   = "aurora-mysql"
  engine                                 = "aurora-mysql"
  engine_mode                            = "provisioned"
  engine_version                         = "8.0"
  storage_encrypted                      = true
  create_cloudwatch_log_group            = true
  cloudwatch_log_group_retention_in_days = "7"
  master_username                        = "root"
  master_password                        = module.random_password_aurora.result
  manage_master_user_password            = false

  vpc_id                 = module.vpc.id
  create_db_subnet_group = true
  subnets                = [module.private_subnets["pvt-sb-a"].id, module.private_subnets["pvt-sb-b"].id]
  db_subnet_group_name   = "db-subnet-group"

  security_group_rules = {
    vpc_ingress = {
      source_security_group_id = module.ecs_service.security_group_id
    }
  }

  monitoring_interval = 60

  apply_immediately   = true
  skip_final_snapshot = true

  serverlessv2_scaling_configuration = {
    min_capacity = 0.5
    max_capacity = 1
  }

  instance_class = "db.serverless"
  instances = {
    one = {}
  }

  tags = var.tags
}

module "random_password_aurora" {
  source = "../../modules/randompassword"
}