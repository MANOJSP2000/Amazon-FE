terraform {
  backend "s3" {
    bucket = "manojsp-terraform-s3-vpc-alb"
    key    = "EKS/terraform.tfstate"  
    region = "ap-south-1" 
  }
}
