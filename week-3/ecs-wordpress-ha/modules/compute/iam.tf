# Data resources to fetch managed policy ARNs
data "aws_iam_policy" "ecs_ec2_role_policy" {
  name = "AmazonEC2ContainerServiceforEC2Role"
}

data "aws_iam_policy" "ecs_task_execution_role_policy" {
  name = "AmazonECSTaskExecutionRolePolicy"
}

# --- EC2 Node Infrastructure Role ---
resource "aws_iam_role" "ecs_node_role" {
  name = "wordpress-ecs-node-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_node_role_policy" {
  role       = aws_iam_role.ecs_node_role.name
  policy_arn = data.aws_iam_policy.ecs_ec2_role_policy.arn
}

resource "aws_iam_instance_profile" "ecs_node_profile" {
  name = "wordpress-ecs-node-profile"
  role = aws_iam_role.ecs_node_role.name
}

# --- ECS Task Execution Role ---
resource "aws_iam_role" "ecs_task_execution_role" {
  name = "wordpress-task-execution-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "ecs-tasks.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = data.aws_iam_policy.ecs_task_execution_role_policy.arn
}

# --- Custom Secrets Access Policy ---
resource "aws_iam_role_policy" "ecs_secrets_policy" {
  name = "wordpress-ecs-secrets-policy"
  role = aws_iam_role.ecs_task_execution_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = ["ssm:GetParameters", "secretsmanager:GetSecretValue", "kms:Decrypt"]
        Resource = [
          "arn:aws:ssm:ap-south-1:959157916756:parameter/wordpress/*",
          "arn:aws:secretsmanager:ap-south-1:959157916756:secret:rds!db-*"
        ]
      }
    ]
  })
}
