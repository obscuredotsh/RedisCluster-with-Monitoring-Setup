# workstation ASG cluster creation based on defined variables
# workstation is like a K8s master and used to access EKS master

module "cluster" {
  source               = "../../../../modules/vpc"
  env                  = var.env
#  region               = var.region
  vpc_cidr             = var.vpc_cidr
  vpc_name             = var.vpc_name
  domain_name          = var.domain_name
  az                   = var.az
  private_subnet_cidrs = var.private_subnet_cidrs
  public_subnet_cidrs  = var.public_subnet_cidrs
  redis_ami            = lookup(var.ami, "redis-ami")
}