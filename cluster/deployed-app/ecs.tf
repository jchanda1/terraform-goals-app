/*
 *    CLUSTER
 */

resource "aws_ecs_cluster" "cluster" {
    name = var.cluster_name 

    setting {
        name = "containerInsights"
        value = "enabled"
    }
}

/*
 *   SERVICE
 */

#   gets information about the default vpc
data "aws_vpc" "default_vpc" {
    default = true
}

#   this gets the subnets that have vpc id that is the same as the default vpc id above
data "aws_subnets" "default_subnets" {
    filter {
      name = "vpc-id"
      values = [data.aws_vpc.default_vpc.id]
    }
}

resource "aws_ecs_service" "goals-app" {
    name = var.service_name
    cluster = aws_ecs_cluster.cluster.id
    task_definition = aws_ecs_task_definition.task_def_app.arn
    desired_count = 1
    launch_type = "FARGATE"

    network_configuration {
      subnets = data.aws_subnets.default_subnets.ids
      security_groups = [ aws_security_group.container_for_app.id ]
      assign_public_ip = true
    }

    load_balancer {
      target_group_arn = aws_lb_target_group.target_group_frontend.arn
      container_name = "node-goals"
      container_port = 80
    }
    depends_on = [ aws_lb_listener.listener_app_alb ]
}

/*
 *   TASK DEFINITION
 */

resource "aws_ecs_task_definition" "task_def_app" {
    family = var.task_def_family_name
    cpu = 512
    memory = 1024
    requires_compatibilities = ["FARGATE"]
    network_mode = "awsvpc"
    execution_role_arn = "arn:aws:iam::412381772242:role/ecsTaskExecutionRole"
    container_definitions = jsonencode(([
        {
            "name": "mongodb",
            "image": "mongo",
            "portMappings": [
                {
                    "name": "mongod",
                    "containerPort": 27017,
                    "hostPort": 27017,
                    "protocol": "tcp",
                    "appProtocol": "http"
                }
            ],
            "essential": true,
            "environment": [
                {
                    "name": "MONGO_INITDB_ROOT_USERNAME",
                    "value": "max"
                },
                {
                    "name": "MONGO_INITDB_ROOT_PASSWORD",
                    "value": "secret"
                }
            ],
            "environmentFiles": [],
            "mountPoints": [],
            "volumesFrom": [],
            "ulimits": [],
            "logConfiguration": {
                "logDriver": "awslogs",
                "options": {
                    "awslogs-group": "/ecs/goals-node-tf",
                    "mode": "non-blocking",
                    "awslogs-create-group": "true",
                    "max-buffer-size": "25m",
                    "awslogs-region": "eu-west-2",
                    "awslogs-stream-prefix": "ecs"
                },
                "secretOptions": []
            },
            "healthCheck": {
                "command": [
                    "CMD-SHELL",
                    "mongosh --eval 'db.runCommand(\"ping\").ok' --quiet"
                ],
                "interval": 30,
                "timeout": 5,
                "retries": 3
            },
            "systemControls": []
        },
        {
            "name": "node-goals",
            "image": "jchanda1/goals-node",
            "portMappings": [
                {
                    "name": "node-goals",
                    "containerPort": 80,
                    "hostPort": 80,
                    "protocol": "tcp",
                    "appProtocol": "http"
                }
            ],
            "essential": false,
            "environment": [
                {
                    "name": "MONGODB_PASSWORD",
                    "value": "secret"
                },
                {
                    "name": "MONGODB_USERNAME",
                    "value": "max"
                },
                {
                    "name": "MONGODB_URL",
                    "value": "localhost"
                }
            ],
            "environmentFiles": [],
            "mountPoints": [],
            "volumesFrom": [],
            "dependsOn": [
                {
                    "containerName": "mongodb",
                    "condition": "HEALTHY"
                }
            ],
            "logConfiguration": {
                "logDriver": "awslogs",
                "options": {
                    "awslogs-group": "/ecs/goals-node-tf",
                    "mode": "non-blocking",
                    "awslogs-create-group": "true",
                    "max-buffer-size": "25m",
                    "awslogs-region": "eu-west-2",
                    "awslogs-stream-prefix": "ecs"
                },
                "secretOptions": []
            },
            "systemControls": []
        }
    ]))
}