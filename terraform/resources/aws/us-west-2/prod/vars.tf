# change the default value with name of vpc (ex. prod, nonprod etc..,)
variable "env" { default = "prod" }

# current aws region being used is US West (Oregon) => us-west-2
variable "region" { default = "us-west-2" }

# create a keypair call sandbox.pem from aws console
# this needs to be downloaded and stored in .ssh directory in the user's home folder
# if the default value is changed to nonprod, then nonprod.pem keypair will need to be created and used
#variable "key_name" { default = "redis" }

# vpc contains two public subnets and two private subnets defined below
# single vpc can host multiple hosts dedicated to various environments
# change the default value to the name of VPC (ex. prod-vpc, nonprod-vpc etc..,)
variable "vpc_name" { default = "main" }
variable "domain_name" { default = ".asnt" }

# Use https://cidr.xyz/ for calculations
# /16 CIDR provides 65536 IP's
# 10.20.0.1 to 10.20.255.254
variable "vpc_cidr" { default = "10.20.0.0/16" }

# /19 CIDR privides 8192 IP's per subnet
# two private subnets created, one is primary, second is secondary for DR
# private subnet a => 10.20.0.1 to 10.20.31.254 => 8192 IP's
# private subnet b => 10.20.32.1 to 10.20.63.254 => 8192 IP's
variable "private_subnet_cidrs" {
  type    = list
  default = ["10.20.0.0/19", "10.20.32.0/19"]
}

# /19 CIDR privudes 8192 IP's
# two public subnets created, one is primary, second is secondary for DR
# public subnet a => 10.20.64.1 to 10.20.95.254 => 8192 IP's
# public subnet b => 10.20.96.1 to 10.20.127.254 => 8192 IP's

variable "public_subnet_cidrs" {
  type    = list
  default = ["10.20.64.0/19", "10.20.96.0/19"]
}

# US East (Oregon) has two availability zone (a and b)
variable "az" {
  type    = list
  default = ["us-west-2a", "us-west-2b"]
}

# bastion can be configured to accept ssh connections from a list of whitelisted IP
# currently we can ssh into from anywhere
variable "bastion_whitelisted_ip" {
  type    = list
  default = ["0.0.0.0/0"]
}

# Current K8s version is 1.17
# EKS uses a K8s version which is 3 versions behind the current stable version
variable "kubernetes_version" { default = "1.17" }

# cluster name is prepended with env. so not needed to change
variable "cluster_name" { default = "cluster" }

# worker group name is prepended and appedend with other values, so not needed to change
variable "worker_group" { default = "OD" }
variable "spot_worker_group" { default = "spot" }
variable "ds_worker_group" { default = "ds" }
#variable "redis-ds_worker_group" { default = "redis-ds" }
variable "tempnodes_worker_group" { default = "tempnodes" }


# ami's change across aws regions, change only after verifying
# if you are changing aws region.
variable "ami" {
  type = map
  default = {
    redis-ami     = "ami-0d87e82adb04ce47e" #base-ubuntu with ssh key to access git
  }
}


