#--------------------------------------------------------------
# Task's container definition
#--------------------------------------------------------------
data aws_region current {}

/* resource local_file foo { */
/*   content  = "${data.template_file.container_definition.rendered}" */
/*   filename = "foo.json" */
/* } */

data template_file container_definition {
  template = <<EOF
[
  ${join(",
  ", data.template_file.single_container_definition.*.rendered)}
]
EOF
}

data template_file single_container_definition {
  count = "${length(var.task_containers)}"

  template = "${replace(replace(replace(jsonencode(
    merge(
      var.task_containers[count.index],
      map(
        "logConfiguration", merge(map(
          "logDriver", "awslogs",
          "name", "${element(data.template_file.task_container_names.*.rendered, count.index)}",
        ), map(
          "options", map(
            "awslogs-group", "${aws_cloudwatch_log_group.this.name}",
            "awslogs-region", "${data.aws_region.current.name}",
            "awslogs-stream-prefix", "containers",
          )
        )
      )
    )
  )
  ), "/\"(-?[0-9]+\\.?[0-9]*)\"/", "$1"), var.string_indicator, ""),
  "/\"${var.bool_indicator}(true|false)\"/", "$1")
}"
}

data template_file task_container_names {
  count    = "${length(var.task_containers)}"
  template = "${lookup(var.task_containers[count.index], "name", "${local.service_name}-${count.index}")}"
}

/* resource local_file foo { */
/*   content = <<EOF */
/* ${local.first_container_port_mapping} */
/* EOF */


/*   filename = "foo.json" */
/* } */

