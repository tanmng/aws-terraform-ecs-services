#--------------------------------------------------------------
# Task and Service
#--------------------------------------------------------------
resource aws_ecs_task_definition this {
  family                = "${local.service_name}"
  container_definitions = "${data.template_file.container_definition.rendered}"
  network_mode          = "${var.docker_network_mode}"
  task_role_arn         = "${var.task_iam_role_arn}"
  execution_role_arn    = "${var.task_execution_iam_role_arn}"

  # Why are these here (╯°□°）╯︵ ┻━┻
  volume = "${var.task_volumes}"
}

resource aws_ecs_service this_wo_sd {
  count                             = "${1 - local.service_discovery_count}"
  name                              = "${local.service_name}"
  cluster                           = "${var.cluster_name}"
  task_definition                   = "${aws_ecs_task_definition.this.arn}"
  desired_count                     = "${var.task_desired_count}"
  depends_on                        = ["aws_ecs_task_definition.this"]
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
  task_definition                   = "${aws_ecs_task_definition.this.arn}"
  desired_count                     = "${var.task_desired_count}"
  depends_on                        = ["aws_ecs_task_definition.this"]
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
