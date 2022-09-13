# --- root/main.tf --- 

module "vpc" {
  source           = "./vpc"
  vpc_cidr         = "10.0.0.0/16"
  public_sn_count  = 2
  public_cidrs     = ["10.0.1.0/24", "10.0.2.0/24"]
  max_subnet       = 2
  access_ip        = "0.0.0.0/0"
}

module "ec2" {
  source                 = "./ec2"
  public_subnets         = module.vpc.public_subnets
  instance_type          = "t3.micro"
  key_name               = "MyKey"
  user_data              = filebase64("./userdata.tpl")
  vpc_id                 = module.vpc.vpc_id
}