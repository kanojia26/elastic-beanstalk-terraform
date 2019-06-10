data "aws_iam_policy_document" "service" {
  statement {
    sid = ""

    actions = [
      "sts:AssumeRole",
    ]

    principals {
      type        = "Service"
      identifiers = ["elasticbeanstalk.amazonaws.com"]
    }

    effect = "Allow"
  }
}

resource "aws_iam_role" "ServiceRole" {
    name = "service-role-${var.application_name}-${lookup(var.environment, terraform.workspace)}"
    path = "/"
    assume_role_policy = "${data.aws_iam_policy_document.service.json}"
    
    lifecycle {
        create_before_destroy = true
    }
}

data "aws_iam_policy_document" "ServiceRolePolicyDocument" {
    statement {
        # Defaults to the current version
        # version = "2012-10-17"
        actions = [
            "elasticloadbalancing:DescribeInstanceHealth", 
            "ec2:DescribeInstances",
            "ec2:DescribeInstanceStatus", 
            "ec2:GetConsoleOutput",
            "ec2:AssociateAddress", 
            "ec2:DescribeAddresses",
            "ec2:DescribeSecurityGroups", 
            "sqs:GetQueueAttributes",
            "sqs:GetQueueUrl", 
            "autoscaling:DescribeAutoScalingGroups",
            "autoscaling:DescribeAutoScalingInstances",
            "autoscaling:DescribeScalingActivities",
            "autoscaling:DescribeNotificationConfigurations",
        ]
        resources = ["*"],
        effect = "Allow"
    }
}

resource "aws_iam_role_policy" "ServiceRolePolicy" {
    name = "${aws_iam_role.ServiceRole.name}-policy"
    role = "${aws_iam_role.ServiceRole.id}"

    policy = "${data.aws_iam_policy_document.ServiceRolePolicyDocument.json}"
}

resource "aws_iam_instance_profile" "InstanceProfile" {
    name = "${var.application_name}-${lookup(var.environment, terraform.workspace)}-instance-profile"
    role = "${aws_iam_role.InstanceProfileRole.id}"
    lifecycle {
        create_before_destroy = true
    }
}

resource "aws_iam_role" "InstanceProfileRole" {
    name = "${var.application_name}-${lookup(var.environment, terraform.workspace)}-InstanceRole"
    path = "/"
    lifecycle {
        create_before_destroy = true
    }
    assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "sts:AssumeRole",
            "Principal": {
               "Service": "ec2.amazonaws.com"
            },
            "Effect": "Allow",
            "Sid": ""
        }
    ]
}
EOF
}

data "aws_iam_policy_document" "InstanceProfilePolicyDocument" {
    statement {
        # Defaults to the current version
        # version = "2012-10-17"
        actions = [
            "s3:Get*", 
            "s3:List*",
            "s3:PutObject"
        ]
        resources = ["*"],
        effect = "Allow"
    }
}

resource "aws_iam_role_policy" "InstanceProfilePolicy" {
    name = "${aws_iam_role.InstanceProfileRole.name}-policy"
    role = "${aws_iam_role.InstanceProfileRole.id}"

    policy = "${data.aws_iam_policy_document.InstanceProfilePolicyDocument.json}"
}
