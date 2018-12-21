#--------------------------------------------------------------
# Service discovery for our ECS service
#--------------------------------------------------------------
resource aws_service_discovery_service this {
  count       = "${local.service_discovery_count}"
  name        = "${var.service_discovery_name}"
  description = "Service discovery for our ECS service ${local.service_name}"

  dns_config {
    namespace_id = "${var.service_discovery_namespace_id}"

    dns_records {
      ttl  = 10
      type = "SRV"
    }

    routing_policy = "MULTIVALUE"
  }

  health_check_custom_config {
    failure_threshold = 1
  }
}
