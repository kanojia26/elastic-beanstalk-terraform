##################### GLOBAL STATE BACKEND ############################
terraform {
  backend "s3" {
    #bucket  = "ams-demo-tf-state"
    #key     = "eb-public-ams-web-api-app.tfstate"
    region  = "ap-southeast-1"
    encrypt = true
  }

}
