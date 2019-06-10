###################################################
# ~~~ Author's Notes ~~~                          #
# Author:   Abhishek Kanojia                      #
# Email:    abhishek_kanojia@astro.com.my         #
# Project:  Asset Management System (AMS)         #
# Date of Update:   29-May-2019                   #
##################################################

provider "aws" {
    version = "~> 1.22"
    region = "${var.aws_region}"
}

##########################
# DATA SOURCE
#######################
data "terraform_remote_state" "vpc" {
  backend = "s3"
  config = {
    bucket = "ams-demo-tf-state"
    key    = "vpcdemo/vpc.tfstate"
    region = "ap-southeast-1"
  }
}

data "terraform_remote_state" "elastic" {
  backend = "s3"
  config = {
    bucket = "ams-demo-tf-state"
    key    = "${var.application_name}/eb.tfstate"
    region = "ap-southeast-1"
  }
}


########
# TAGS
#######
locals {
  common_tags = {
    Application_ID   =  "${lookup(var.ApplicationID, terraform.workspace)}"
    ApplicationRole =  "${lookup(var.Application_Role, terraform.workspace)}"
    Business_Owner  =  "${lookup(var.BusinessOwner, terraform.workspace)}"
    #Environment     =  "${lookup(var.environment, terraform.workspace)}"
    Technical_Owner =  "${lookup(var.TechnicalOwner, terraform.workspace)}"
    CrossBUWorkload =  "${lookup(var.CrossBUWorkload, terraform.workspace)}"
    Service_Name    =  "${lookup(var.ServiceName, terraform.workspace)}"
    Project         =  "${lookup(var.project, terraform.workspace)}"
    OS_VERSION      =  "${lookup(var.OS_VERSION, terraform.workspace)}"
    Team            =  "${lookup(var.Team, terraform.workspace)}"
    ReleaseVersion  =  "${var.code_version}"
  }
}
# ##################
# # ELB for UI App
# ##################
resource "aws_security_group" "ElbSecurityGroup" {
    name = "${var.application_name}-elb-sg-${lookup(var.environment, terraform.workspace)}"
    description = "Set security group for Elastic Load Balancer"
    vpc_id      = "${data.terraform_remote_state.vpc.vpc_id}"

    ingress = {
        # TLS
        from_port   = "443"
        to_port     = "443"
        protocol    = "tcp"
        # Please restrict your ingress to only necessary IPs and ports.description
        # Opening to 0.0.0.0/0 can lead to security vulnerabilities. 
        cidr_blocks = ["${lookup(var.CidrIPforElbSecurityGroups, terraform.workspace)}"]
    },

    ingress = {
        # TLS
        from_port   = "80"
        to_port     = "80"
        protocol    = "tcp"
        # Please restrict your ingress to only necessary IPs and ports.description
        # Opening to 0.0.0.0/0 can lead to security vulnerabilities. 
        cidr_blocks = ["${lookup(var.CidrIPforElbSecurityGroups,  terraform.workspace)}"]   
    }
    lifecycle {
        create_before_destroy = true
    }
}

resource "aws_security_group" "Ec2SecurityGroup" {
    name = "${var.application_name}-ec2-sg-${lookup(var.environment, terraform.workspace)}"
    description = "Set security group for EC2 Instances"
    vpc_id      = "${data.terraform_remote_state.vpc.vpc_id}"
    ingress = {
        # TLS
        from_port   = "80"
        to_port     = "80"
        protocol    = "tcp"
        # Please restrict your ingress to only necessary IPs and ports.description
        # Opening to 0.0.0.0/0 can lead to security vulnerabilities. 
        security_groups = ["${aws_security_group.ElbSecurityGroup.id}"]
    }

    egress = {
        # TLS
        from_port   = "0"
        to_port     = "65535"
        protocol    = "tcp"
        # Please restrict your ingress to only necessary IPs and ports.description
        # Opening to 0.0.0.0/0 can lead to security vulnerabilities. 
        cidr_blocks = ["0.0.0.0/0"]
    }
    lifecycle {
        create_before_destroy = true
    }
}

##################
# Test Bucket
##################
#resource "aws_s3_bucket" "default" {
#    bucket = "${var.application_name}-bucket"
#}

resource "aws_s3_bucket_object" "default" {
    bucket = "${data.terraform_remote_state.elastic.bucketid}"
    key    = "beanstalk/${lookup(var.environment, terraform.workspace)}/${var.code_version}-java.zip"
    source = "${var.code_version}-java.zip"
}

################################################################
# ELASTICBEANSTALK
############################################

resource "aws_elastic_beanstalk_application_version" "ElasticBeanStalkApplicationVersion" {
    name = "eb-version-${var.code_version}-${lookup(var.project, terraform.workspace)}"
    description = "AWS Elastic Beanstalk Java Application Version"
    application = "${data.terraform_remote_state.elastic.eb_id}"
    bucket      = "${data.terraform_remote_state.elastic.bucketid}"
    key         = "${aws_s3_bucket_object.default.id}"

    lifecycle {
        create_before_destroy = true
    }
}

resource "aws_elastic_beanstalk_environment" "ElasticBeanStalkEnvironment" {
    name = "${var.application_name}-${lookup(var.ApplicationID, terraform.workspace)}"
    description = "AWS Elastic Beanstalk Java Application Environment"    
    application = "${data.terraform_remote_state.elastic.eb_id}"
    version_label = "${aws_elastic_beanstalk_application_version.ElasticBeanStalkApplicationVersion.id}"
    #template_name = "${aws_elastic_beanstalk_configuration_template.ElasticBeanStalkConfigurationTemplate.name}"
    solution_stack_name = "${lookup(var.StackType, terraform.workspace)}"
    #wait_for_ready_timeout  = "25m"
    setting = {
        namespace   = "aws:elasticbeanstalk:environment"
        name        = "EnvironmentType"
        value       = "LoadBalanced"
    }

    setting = {
        namespace   = "aws:elasticbeanstalk:environment"
        name        = "LoadBalancerType"
        value       = "network"
    }

    setting = {
        namespace   = "aws:elasticbeanstalk:environment"
        name        = "ServiceRole"
        value       = "${aws_iam_role.ServiceRole.id}"
    }

    setting = {
        namespace   = "aws:elasticbeanstalk:application:environment"
        name        = "SERVER_PORT"
        value       = "${lookup(var.serverport, terraform.workspace)}"
    }
    
    setting = {
        namespace   = "aws:elasticbeanstalk:application:environment"
        name        = "SPRING_PROFILES_ACTIVE"
        value       = "${lookup(var.spring_profile, terraform.workspace)}"
    }
    
    setting = {
    namespace       = "aws:autoscaling:launchconfiguration"
    name            = "EC2KeyName"
    value           = "${lookup(var.keypair, terraform.workspace)}"
    }
    
    setting = {
    namespace       = "aws:autoscaling:launchconfiguration"
    name            = "RootVolumeSize"
    value           = "${lookup(var.root_volume_size, terraform.workspace)}"
    }

    setting = {
    namespace       = "aws:autoscaling:launchconfiguration"
    name            = "RootVolumeType"
    value           = "${lookup(var.root_volume_type, terraform.workspace)}"
    }

    setting = {
        namespace   = "aws:autoscaling:asg"
        name        = "MinSize"
        value       = "${lookup(var.AutoScalingMinInstanceCount, terraform.workspace)}"
    }

    setting = {
        namespace   = "aws:autoscaling:asg"
        name        = "MaxSize"
        value       = "${lookup(var.AutoScalingMaxInstanceCount, terraform.workspace)}"
    }
    setting = {
        namespace  = "aws:autoscaling:updatepolicy:rollingupdate"
        name       = "RollingUpdateType"
        value      = "Health"
    }
    setting = {
        namespace   = "aws:autoscaling:updatepolicy:rollingupdate"
        name        = "RollingUpdateEnabled"
        value       = "true"
    }

    setting = {
        namespace   = "aws:autoscaling:launchconfiguration"
        name        = "SecurityGroups"
        value       = "${aws_security_group.Ec2SecurityGroup.id}"
    }

    #setting = {
    #    namespace   = "aws:elbv2:loadbalancer"
    #    name        = "SecurityGroups"
    #    value       = "${aws_security_group.ElbSecurityGroup.id}"
    #}

    setting = {
        namespace   = "aws:ec2:vpc"
        name        = "VpcId"
        value       = "${data.terraform_remote_state.vpc.vpc_id}"
    }

    setting {
        namespace   = "aws:ec2:vpc"
        name        = "Subnets"
        value       = "${data.terraform_remote_state.vpc.PrivateSubnet1}, ${data.terraform_remote_state.vpc.PrivateSubnet2}, ${data.terraform_remote_state.vpc.PrivateSubnet3}"
    }

    setting {
        namespace   = "aws:ec2:vpc"
        name        = "ELBSubnets"
        value       = "${data.terraform_remote_state.vpc.PublicSubnet1}, ${data.terraform_remote_state.vpc.PublicSubnet2}, ${data.terraform_remote_state.vpc.PublicSubnet3}"
    }

    setting = {
        namespace   = "aws:autoscaling:launchconfiguration"
        name        = "IamInstanceProfile"
        value       = "aws-elasticbeanstalk-ec2-role"
    }

    setting = {
        namespace   = "aws:autoscaling:launchconfiguration"
        name        = "InstanceType"
        value       = "${lookup(var.instancetype, terraform.workspace)}"
    }
       
    lifecycle {
        create_before_destroy = true
    }
    tags = "${merge(
    local.common_tags, 
    map(
       "Environment", "${lookup(var.environment, terraform.workspace)}"
    )
    )}"
}


########################################################
#OUTPUT#
##############################################
output "ec2_sec_grp" {
    description = "aws security group"
    value = "${aws_security_group.Ec2SecurityGroup.id}"
}

output "ec2_sec_grp_owner" {
    description = "aws security group"
    value = "${aws_security_group.Ec2SecurityGroup.owner_id}"
}

output "ec2_sec_grp_name" {
    description = "aws security group"
    value = "${aws_security_group.Ec2SecurityGroup.name}"
}


