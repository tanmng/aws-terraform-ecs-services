#--------------------------------------------------------------
# Task and Service
#--------------------------------------------------------------
resource aws_ecs_task_definition this_fargate {
  count                 = "${var.service_launch_type == "FARGATE"? 1 : 0}"
  family                = "${local.service_name}"
  container_definitions = "${data.template_file.container_definition.rendered}"
  network_mode          = "${var.docker_network_mode}"
  task_role_arn         = "${var.task_iam_role_arn}"
  execution_role_arn    = "${var.task_execution_iam_role_arn}${join("", aws_iam_role.task_execution_role.*.arn)}"
  cpu                   = "${var.task_fargate_cpu}"
  memory                = "${var.task_fargate_memory}"

  requires_compatibilities = [
    "${var.service_launch_type}",
  ]

  # Why are these here (╯°□°）╯︵ ┻━┻
  volume = "${var.task_volumes}"
}

resource aws_ecs_task_definition this_ec2 {
  execution_role_arn    = "${var.task_execution_iam_role_arn}${join("", aws_iam_role.task_execution_role.*.arn)}"
  family                = "${local.service_name}"
  container_definitions = "${data.template_file.container_definition.rendered}"
  network_mode          = "${var.docker_network_mode}"
  task_role_arn         = "${var.task_iam_role_arn}"
  count                 = "${var.service_launch_type == "EC2"? 1 : 0}"

  requires_compatibilities = [
    "${var.service_launch_type}",
  ]

  # Why are these here (╯°□°）╯︵ ┻━┻
  volume = "${var.task_volumes}"
}

resource aws_ecs_service this_wo_sd {
  count                             = "${1 - local.service_discovery_count}"
  name                              = "${local.service_name}"
  cluster                           = "${var.cluster_name}"
  task_definition                   = "${join("", concat(aws_ecs_task_definition.this_ec2.*.arn, aws_ecs_task_definition.this_fargate.*.arn))}"
  desired_count                     = "${var.task_desired_count}"
  depends_on                        = ["aws_ecs_task_definition.this_fargate", "aws_ecs_task_definition.this_ec2"]
  health_check_grace_period_seconds = "${var.hc_grace_period}"
  launch_type                       = "${var.service_launch_type}"

  load_balancer {
    target_group_arn = "${var.target_group_arn}"
    container_name   = "${local.first_container_name}"
    container_port   = "${var.register_port}"
  }

  placement_constraints      = "${var.task_placement_constraints}"
  ordered_placement_strategy = "${var.ordered_placement_strategy}"
}

resource aws_ecs_service this_w_sd {
  count                             = "${local.service_discovery_count}"
  name                              = "${local.service_name}"
  cluster                           = "${var.cluster_name}"
  task_definition                   = "${join("", concat(aws_ecs_task_definition.this_ec2.*.arn, aws_ecs_task_definition.this_fargate.*.arn))}"
  desired_count                     = "${var.task_desired_count}"
  depends_on                        = ["aws_ecs_task_definition.this_fargate", "aws_ecs_task_definition.this_ec2"]
  health_check_grace_period_seconds = "${var.hc_grace_period}"
  launch_type                       = "${var.service_launch_type}"
  iam_role                          = "${var.service_iam_role_arn}"

  load_balancer {
    target_group_arn = "${var.target_group_arn}"
    container_name   = "${local.first_container_name}"
    container_port   = "${var.register_port}"
  }

  placement_constraints      = "${var.task_placement_constraints}"
  ordered_placement_strategy = "${var.ordered_placement_strategy}"

  # depends_on = ["aws_service_discovery_service.this"]

  service_registries {
    registry_arn   = "${join("", aws_service_discovery_service.this.*.arn)}"
    container_name = "${local.first_container_name}"
    container_port = "${var.register_port}"
  }
}
