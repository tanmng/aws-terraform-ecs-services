resource aws_cloudwatch_log_group this {
  name              = "${local.service_name}"
  retention_in_days = "${var.log_retention}"

  tags = "${merge(
    var.tags,
    map(
      "Name", "${local.service_name}",
      "Description", "Docker logs of containers from the service ${local.service_name} running on ECS cluster ${var.cluster_name}",
    )
  )}"
}

data aws_lambda_function notification_functions {
  count         = "${length(var.log_lambda_functions)}"
  function_name = "${element(var.log_lambda_functions, count.index)}"
}

# For some reason the aws_lambda_function data source attomatically append the ":$LATEST" to it ಠ_ಠ
resource aws_cloudwatch_log_subscription_filter notify_lambda {
  name            = "${aws_cloudwatch_log_group.this.name}-to-lambda-${count.index}"
  count           = "${length(var.log_lambda_functions)}"
  log_group_name  = "${aws_cloudwatch_log_group.this.name}"
  filter_pattern  = "${var.log_filter_pattern}"
  destination_arn = "${replace(element(data.aws_lambda_function.notification_functions.*.arn, count.index), "/:\\$LATEST$/", "")}"
  distribution    = "ByLogStream"
}
