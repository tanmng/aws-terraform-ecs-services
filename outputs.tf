output service_full_name {
  description = "The full name of the service"
  value       = "${aws_ecs_service.this.name}"
}

output service_log_group {
  description = "Name of the Log Group that containers in this service will write to"
  value       = "${aws_cloudwatch_log_group.this.name}"
}
