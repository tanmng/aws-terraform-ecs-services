#--------------------------------------------------------------
# Tagging Variables
#--------------------------------------------------------------
variable tags {
  description = "Map of all the tags we wish to set onto our services"
  type        = "map"
  default     = {}
}

#--------------------------------------------------------------
# ECS config
#--------------------------------------------------------------
variable service_name {
  description = "Name of the service in ECS"
  type        = "string"
}

variable include_cluster_name_to_service_name {
  description = "Specify whether we wish to inlucde the name of ECS cluster into the full service name"
  default     = true
}

variable service_launch_type {
  description = "Launch Type of the ECS service, possible values are EC2 and FARGATE"
  type        = "string"
  default     = "EC2"
}

variable service_iam_role_arn {
  description = "IAM role to assign onto our ECS service, set to empty to use the default one (created by AWS)"
  default     = ""
}

variable service_network_configuration {
  type        = "list"
  description = "Network configs for the service"
  default     = []
}

#--------------------------------------------------------------
# Container config
#--------------------------------------------------------------
# For this section settings, refer to AWS documentations in
# https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task_definition_parameters.html
# for further details
# Network mode
variable task_containers {
  description = "Config data for containers inside the task of this service"
  type        = "list"
  default     = []
}

variable register_port {
  description = "The port of the first container that you wish to register on ALB, sorry for this but TF is really bad at parsing values right now"
}

variable ordered_placement_strategy {
  description = "How we wish to set up ordered_placement_strategy of our service's tasks"
  type        = "list"
  default     = []
}

#--------------------------------------------------------------
# External resources that were already set up from cluster module
#--------------------------------------------------------------
variable cluster_name {
  description = "Name of the ECS cluster in which we want to run our service"
  type        = "string"
}

#--------------------------------------------------------------
# Service and Task settings
#--------------------------------------------------------------
variable task_desired_count {
  description = "Number of tasks we wish to run for service"
  default     = 1
}

variable task_volumes {
  description = "List of mount volumes definition"
  type        = "list"
  default     = []
}

variable docker_network_mode {
  description = "The network node to run our containers in"
  type        = "string"
  default     = "bridge"
}

variable task_placement_constraints {
  description = "List of placement constraints that we want to set onto our tasks"
  default     = []
}

variable task_fargate_cpu {
  description = "Amount of CPU we wish to use for the task - only necessary if we are using Fargate"
  default     = 1024
}

variable task_fargate_memory {
  description = "Amount of memory we wish to use for the task - only necessary if we are using Fargate"
  default     = 2048
}

#--------------------------------------------------------------
# IAM role that we can assign on our ECS task, set to empty to ignore
#--------------------------------------------------------------
variable task_iam_role_arn {
  description = "IAM role that we can assign on our ECS task, set to empty to ignore"
  default     = ""
}

variable task_execution_iam_role_arn {
  description = "IAM role that we can assign on executor of our ECS task, set to empty to ignore"
  default     = ""
}

variable task_execution_iam_role_create {
  description = "Specify whether we should create an IAM role for the task execution"
  default     = false
}

variable task_execution_iam_role_inline_policies {
  type        = "list"
  description = "List of all JSON policy documents to add as inline policy to the task_execution role if we DO create it"
  default     = []
}

variable task_execution_iam_role_policies {
  type        = "list"
  description = "List of ARN of policies to attach to our task_execution role if we DO create it"
  default     = []
}

#--------------------------------------------------------------
# Logging related
#--------------------------------------------------------------
variable log_retention {
  description = "How many days should we keep the logs from containers within this service"
  default     = 3
}

variable log_prefix {
  description = "Which prefix we will set to the log stream from our container, note that this will be prepended with the container name (main) and the ECS instance"
  default     = "container"
}

variable log_lambda_functions {
  description = "List of names of Lambda function which we should set up subscription filter to notify about logs from our CloudWatch"
  type        = "list"
  default     = []
}

variable log_filter_pattern {
  description = "Filter patter for the log - View AWS documentation for further details"
  type        = "string"
  default     = "[message]"
}

variable target_group_arn {
  description = "ARN of the target group that we wish to connect to our service"
}

variable service_discovery_namespace_id {
  description = "ID of the DNS zone we set up for service discovery"
  type        = "string"
  default     = ""
}

variable service_discovery_name {
  description = "DNS name to set for our ECS service on service discovery registry"
  type        = "string"
  default     = ""
}

#--------------------------------------------------------------
# Misc variables
#--------------------------------------------------------------

variable string_indicator {
  description = "A string to indicate when a numeric string should be a string rather than integer, see https://github.com/hashicorp/terraform/issues/17033 for more details"
  type        = "string"
  default     = "STRING:"
}

variable bool_indicator {
  description = "Similar to string indicator, we prepend this prefix to indicate any field to be boolean"
  type        = "string"
  default     = "BOOL:"
}

variable hc_grace_period {
  description = "How long should we wait (in seconds) before starting to accept the healthcheck status from ELB"
  default     = 0
}
