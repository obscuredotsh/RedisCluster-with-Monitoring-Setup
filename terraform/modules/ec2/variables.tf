variable "env" {}
variable "domain_name" { default =  "" }
variable "subnet_id" {}
variable "ebs_optimized" { default = "true" }
#variable "key_name" {}
variable "security_group_ids" {}
variable "ami" {}
variable "disable_api_termination" { default = "true" }
variable "resource_count" { default = 3 }
variable "instance_type" {}
variable "associate_public_ip_address" { default = "false" }
variable "volume_size" { default = "32" }
variable "app_name" { }
variable "app_role" { default = "main" }
variable "tags_Type" {}


