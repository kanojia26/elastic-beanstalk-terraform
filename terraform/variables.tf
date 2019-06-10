################# Dev & Stage Variables ################
########################################################
variable "CidrIPforElbSecurityGroups" {
    description = "CIDR block for ELB Security Groups"
    type = "map"
    default = {
        dev = "0.0.0.0/0"
        stage = "0.0.0.0/0"
    }
}
variable "AutoScalingMaxInstanceCount" {
    description = "Maximum instance(s) on ASG"
    type = "map"
    default = {
        dev = "2"
        stage = "2"
    }
}

variable "AutoScalingMinInstanceCount" {
    description = "Minimum instance(s) on ASG"
    type = "map"
    default = {
        dev = "1"
        stage = "1"
    }
}

variable "StackType" {
    description = "Type of application stack"
    type = "map"
    default = {
        dev = "64bit Amazon Linux 2018.03 v2.8.3 running Java 8"
        stage = "64bit Amazon Linux 2018.03 v2.8.3 running Java 8"
    }
}

variable "aws_region" {
    description = "Region of AWS to interact with"
    default = "ap-southeast-1"
}

variable "instancetype" {
    description = "EC2 Instance type in ASG"
    type = "map"
    default = {
        dev = "t2.micro"
        stage = "t2.medium"
    }
  
}

variable code_version {
    description = "Benastalk release version"
    default = "8"
}

### SERVER_PORT
variable "serverport" {
   description = "Application Properties env"
   type = "map"
   default = {
       dev = "5000"
       stage = "5000"
   }
}
##SPRING_PROFILES_ACTIVE
variable "spring_profile" {
   description = "SPRING PROFILE Application Properties env"
   type = "map"
   default = {
       dev = "stage"
       stage = "stage"
   }
}

variable "root_volume_size" {
   description = "The size of the EBS root volume"
   type = "map"
   default = {
       dev = "8"
       stage = "8"
   }   
}

variable "root_volume_type" {
   description = "The type of the EBS root volume"
   type = "map"
   default = {
       dev = "gp2"
       stage = "gp2"
   }
}

variable "keypair" {
    description = "The type of the EBS root volume"
    type = "map"
    default = {
        dev = "ams_demo_dev"
        stage = "ams_demo_stage"
    }
}


###################
# TAGS
###################
variable "ApplicationID" {
    description = "Name of the application"
    type = "map"
    default = {
        dev = "AMSDEV"
        stage = "AMSSTAGE"
    }
}


variable "application_name" {
    default = "ams-web-app-beanstalk"
  
}

variable BusinessOwner {
    description = "Business Owner Email Address"
    type = "map"
    default = {
        dev = "nicholas_lee@astro.com.my"
        stage = "nicholas_lee@astro.com.my"
    } 
} 

variable TechnicalOwner {
    description = "Technical Owner Email Address"
    type = "map"
    default = {
        dev = "eleazer_tubigan@astro.com.my"
        stage = "eleazer_tubigan@astro.com.my"
    }
}

variable project {
    description = "Name of the project"
    type = "map"
    default = {
        dev = "eb-ams-web-app-beanstalk-dev"
        stage = "eb-ams-web-app-beanstalk-stage"
    }
}

variable environment {
    description = "Env of the project"
    type = "map"
    default = {
        dev = "dev-env"
        stage = "staging-env"
    }
}

variable Application_Role {
    description = "Name of the Application Role"
    type = "map"
    default = {
        dev = "Assest Management System"
        stage = "Assest Management System"
    }
}

variable CrossBUWorkload {
    description = "CrossBUWorkload of the project"
    type = "map"
    default = {
        dev = "NO"
        stage = "NO"
    }
}

variable "ServiceName" {
    type = "map"
    default = {
        dev = "BACKEND-API"
        stage = "BACKEND-API"
    }
  
}

variable "OS_VERSION" {
    type = "map"
    default = {
        dev = "Amazon Linux"
        stage = "Amazon Linux"
    }
  
}

variable "Team" {
    type = "map"
    default = {
        dev = "AMS-TEAM"
        stage = "AMS-TEAM"
    }
  
}

