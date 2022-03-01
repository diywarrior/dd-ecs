resource "aws_ecs_cluster" "dd" {
  name = "dd"
}

resource "aws_ecs_task_definition" "dd" {
  family = "dd"
  container_definitions = jsonencode([
    {
      name = "dd"
      image = "${aws_ecr_repository.repo.repository_url}:latest"
      cpu = local.cpu
      memory = local.memory
      essential = true
    }
  ])
  requires_compatibilities = [
    "FARGATE"]
  cpu = local.cpu
  memory = local.memory
  network_mode = "awsvpc"
  task_role_arn = aws_iam_role.dd.arn
  execution_role_arn = aws_iam_role.dd.arn
}

resource "aws_ecs_service" "dd" {
  name = "dd"
  cluster = aws_ecs_cluster.dd.id
  task_definition = aws_ecs_task_definition.dd.arn
  desired_count = local.desired_count

  network_configuration {
    security_groups = [
      aws_security_group.allow_traffic.id
    ]
    subnets = [
      aws_subnet.production_1a.id,
      aws_subnet.production_1b.id,
      aws_subnet.production_1c.id]
    assign_public_ip = true
  }
  capacity_provider_strategy {
    capacity_provider = "FARGATE_SPOT"
    weight = 1
  }
  force_new_deployment = true
  deployment_maximum_percent = 100
  deployment_minimum_healthy_percent = 0
}