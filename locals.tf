locals {
  service_name = "${var.service_name}-${var.cluster_name}"

  # This is hackery
  first_container      = "${var.task_containers[0]}"
  first_container_name = "${element(data.template_file.task_container_names.*.rendered, 0)}"

  # first_container_port_mapping       = "${local.first_container["portMappings"]}"
  /* first_container_port_mapping       = "${lookup(var.task_containers[0], "portMappings")}" */
  /* first_container_first_port_mapping = "${local.first_container_port_mapping[0]}" */

  # first_container_first_port         = "${lookup(local.first_container_first_port_mapping, "containerPort")}"
  /* first_container_first_port = 80 */
}
