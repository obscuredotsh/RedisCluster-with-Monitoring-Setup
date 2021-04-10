resource "aws_key_pair" "redis" {
  key_name   = "redis"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDGSOtICAN2KDV1HKg+PgOXFXuPZzy4j0Tt82NNSCzIKWzwkhwzF3Y2TQdI2GZIhYqzCmx0uUqdmAVvz33rdZpH8IGgkykWh2YREUYnkksl6csTSEGHSSll2H6ael9nt3SAavnJJiy8D+2343243242r/33nF2+stsrEJqDLr1N92jeQnhUlVb5Kck7cnjFyx/h49UHkvFxwot5Xl1cqjzVIKLWkrJ2per4bmqfNeZ3TJs+MztqAS5DePxKmDH3n8D0Q1dslXmLImwsC1hBMul1iKf7hX8GEm2CfjiE9+VzJXE93bZmde5gSUbXgLBacfiDwhp8AbqNSC3HBogRW1 prateekkaien@coffeebeanss-MacBook-Pro.local"
}

resource "aws_instance" "ec2promandgraf" {
  count                       = 1
  ami                         = "ami-09926f47f6132d1f4"
  instance_type               = var.instance_type
  key_name                    = "redis"
  monitoring                  = "false"
  vpc_security_group_ids      = split(",",var.security_group_ids)
  subnet_id                   = element(split(",", var.subnet_id), count.index)
  associate_public_ip_address = true

  tags = {
    Name         = "Prometheus + Grafana"
    Environment  = var.env
    Type         = var.tags_Type
  }

}

 
 resource "aws_launch_configuration" "launch_configurations" {
   count                = 3
   associate_public_ip_address = true
   name_prefix          = "${var.app_name}-${count.index + 1}-lc"
   image_id             = var.ami
   instance_type        = var.instance_type
   security_groups      = split(",",var.security_group_ids)
   key_name             = "redis"
 }


output "lc_id" { 
value = "${aws_launch_configuration.launch_configurations[*]}"
}



resource "aws_autoscaling_group" "asg" {
  count                = 3
  desired_capacity     = 1
  launch_configuration = aws_launch_configuration.launch_configurations[count.index].id
#  launch_configuration = lc_id[count.index].id
  max_size             = 1
  min_size             = 1
  name                 = "${var.app_name}-${count.index + 1}-ASG"
  vpc_zone_identifier  = split(",",var.subnet_id)

  tag {
    key                 = "Name"
    value               = "${var.app_name}-${count.index + 1}-ASG"
    propagate_at_launch = true
  }
  }

