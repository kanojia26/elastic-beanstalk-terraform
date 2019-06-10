provider "aws" {
    version = "~> 1.22"
    region = "ap-southeast-1"
}
resource "aws_elastic_beanstalk_application" "ElasticBeanStalkApplication" {
    name = "${var.application_name}-beanstalk"
    description = "AWS Elastic Beanstalk JAVA Application"

    lifecycle {
        create_before_destroy = true
    }
}

#####################
#SOURCE CODE BUCKET
#####################

resource "aws_s3_bucket" "default" {
    bucket = "${var.application_name}-bucket"
    lifecycle {
        create_before_destroy = true
    }
}

########### 
##STATE
############

terraform {
  backend "s3" {
    bucket  = "ams-demo-tf-state"
    #key     = "${var.application_name}/eb.tfstate"
    region  = "ap-southeast-1"
    encrypt = true
  }

}

variable "application_name" {
  default = "ams-application"
}

######
#OUTPUT
#########

output "eb_id" {
  value = "${aws_elastic_beanstalk_application.ElasticBeanStalkApplication.id}"
}

output "bucketid" {
  value = "${aws_s3_bucket.default.id}"
}

