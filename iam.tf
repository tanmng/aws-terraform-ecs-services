// Only create this if we don't have the role for our task execution
resource aws_iam_role task_execution_role {
  count       = "${local.task_exec_role_count}"
  name_prefix = "${substr(local.task_exec_role_name, 0, min(32, length(local.task_exec_role_name)))}"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF

  tags = "${merge(
    var.tags,
    map(
      "Description", "IAM role to use as task execution role for ECS service ${local.service_name}",
    )
  )}"
}
