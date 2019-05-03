locals {
  service_name = "${join("-", compact(list(
    "${var.service_name}",
    "${var.include_cluster_name_to_service_name? var.cluster_name : ""}"
  )))}"

  # Task exec role name

  # This logic is rather complicated
  #     - If there's a role already - DO NOT create
  #     - Otherwise
  #         - If task_execution_iam_role_create is set -> create
  #         - Otherwise
  #             - If the service is fargate -> we have to create it
  #             - Otherwise -> DO NOT create
  task_exec_role_count = "${var.task_execution_iam_role_arn != ""? 0 : (var.task_execution_iam_role_create? 1 : (var.service_launch_type == "FARGATE"? 1 : 0))}"
  task_exec_role_name = "task-execution-${local.service_name}"
  # This is hackery
  first_container      = "${var.task_containers[0]}"
  first_container_name = "${element(data.template_file.task_container_names.*.rendered, 0)}"

  # first_container_port_mapping       = "${local.first_container["portMappings"]}"
  /* first_container_port_mapping       = "${lookup(var.task_containers[0], "portMappings")}" */
  /* first_container_first_port_mapping = "${local.first_container_port_mapping[0]}" */


  # first_container_first_port         = "${lookup(local.first_container_first_port_mapping, "containerPort")}"
  /* first_container_first_port = 80 */

  # Detect whether we should enable service discovery
  # only set this up when we have both service_discovery_name and service_discovery_namespace_id
  service_discovery_count = "${
    signum(length(var.service_discovery_name)) + signum(length(var.service_discovery_namespace_id)) == 2? 1 : 0
  }"
}
