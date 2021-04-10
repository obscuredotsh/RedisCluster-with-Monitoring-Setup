variable "vpc_name" { }
variable "domain_name" { }
variable "vpc_cidr" { }
variable "env" { }
variable "az" { type = list }

variable "private_subnet_cidrs" { type = list }
variable "public_subnet_cidrs" { type = list }

variable "bastion_whitelisted_ip" { default = "0.0.0.0/0"}
variable "redis_ami" {}
variable "cluster_name" { default = "cluster" }
