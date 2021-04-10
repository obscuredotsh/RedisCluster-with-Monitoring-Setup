##### Create VPC ######
resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags =    {
                Name = "${var.env}-${var.vpc_name}"
                Environment = var.env
            }
  lifecycle { create_before_destroy = true }
}

###### Create private subnets ######
resource "aws_subnet" "private_subnet" {
  vpc_id            = aws_vpc.vpc.id
  count             = length(var.private_subnet_cidrs)
  cidr_block        = element(var.private_subnet_cidrs, count.index)
  availability_zone = element(var.az, count.index)

  tags =    {
                Name = "${var.env}-${var.vpc_name}-private-${count.index + 1}"
                Environment = var.env
                "kubernetes.io/role/internal-elb" = "1"
                "kubernetes.io/cluster/${var.cluster_name}" = "shared"
            }
  lifecycle {
              create_before_destroy = true
              ignore_changes = [ tags ]
            }
}

###### Create public subnets ######

resource "aws_subnet" "public_subnet" {
  vpc_id            = aws_vpc.vpc.id
  count             = length(var.public_subnet_cidrs)
  cidr_block        = element(var.public_subnet_cidrs, count.index)
  availability_zone = element(var.az, count.index)

  tags =    {
                Name = "${var.env}-${var.vpc_name}-public-${count.index + 1}"
                Environment = var.env
                "kubernetes.io/role/elb" = "1"
                "kubernetes.io/cluster/${var.cluster_name}" = "shared"
            }
  lifecycle {
                create_before_destroy = true
                ignore_changes = [ tags ]
            }
}


##### Create Internet gateway #####

resource "aws_internet_gateway" "internet_gw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "${var.env}-${var.vpc_name}-internet-gw"
    Environment = var.env
  }

  lifecycle { create_before_destroy = true }
}

##### Create NAT gateway #####
resource "aws_eip" "nat_elastic_ip" {
  vpc     = true
  count   = "1"
  tags    = {
                Name = "${var.env}-${var.vpc_name}-nat-ip-${count.index + 1}"
                Environment = var.env
            }

  lifecycle { create_before_destroy = true }
}

resource "aws_nat_gateway" "nat_gw" {
  allocation_id = aws_eip.nat_elastic_ip[0].id
  subnet_id     = element(aws_subnet.public_subnet[*].id, 0)

  tags = {
    Name = "${var.env}-${var.vpc_name}-nat-gw-1"
    Environment = var.env
  }

  depends_on = [aws_eip.nat_elastic_ip]

  lifecycle { create_before_destroy = true }
}


##### Create private route tables #####

resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.vpc.id

  tags = {
                Name = "${var.env}-${var.vpc_name}-private-rt"
                Environment = var.env
         }
  lifecycle { create_before_destroy = true }
}

resource "aws_route" "for_nat_gateway" {
    route_table_id         = aws_route_table.private_rt.id
    destination_cidr_block = "0.0.0.0/0"
    nat_gateway_id         = aws_nat_gateway.nat_gw.id
    depends_on             = [aws_nat_gateway.nat_gw]
}

resource "aws_route_table_association" "private_rt_association" {
  count          = length(var.private_subnet_cidrs)
  subnet_id      = element(aws_subnet.private_subnet[*].id, count.index)
  route_table_id = aws_route_table.private_rt.id

  lifecycle { create_before_destroy = true }
}

##### Create public route tables #####

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.vpc.id

  tags =    {
                "Name" = "${var.env}-${var.vpc_name}-public-rt"
                "Environment" = var.env
            }
  lifecycle { create_before_destroy = true }
}

resource "aws_route" "for_internet_gateway" {
    route_table_id         = aws_route_table.public_rt.id
    destination_cidr_block = "0.0.0.0/0"
    gateway_id             = aws_internet_gateway.internet_gw.id

    depends_on             = [aws_internet_gateway.internet_gw]
}



resource "aws_route_table_association" "public_rt_association" {
  count          = length(var.public_subnet_cidrs)
  subnet_id      = element(aws_subnet.public_subnet[*].id, count.index)
  route_table_id = aws_route_table.public_rt.id

  lifecycle { create_before_destroy = true }
}

#### redis ####
resource "aws_security_group" "redis_sg" {
  name        = "${var.env}-${var.vpc_name}-redis"
  description = "For ${var.env} redis"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [ "0.0.0.0/0" ]
    description = "allow SSH"
  }

    ingress {
    from_port   = 6379
    to_port     = 6379
    protocol    = "tcp"
    cidr_blocks = [ "10.20.0.0/16" ]
    description = "allow 6379"
  }


    ingress {
    from_port   = 6380
    to_port     = 6380
    protocol    = "tcp"
    cidr_blocks = [ "10.20.0.0/16" ]
    description = "allow 6380"
  }

    ingress {
    from_port   = 16379
    to_port     = 16379
    protocol    = "tcp"
    cidr_blocks = [ "10.20.0.0/16" ]
    description = "allow 16379"
  }

    ingress {
    from_port   = 16380
    to_port     = 16380
    protocol    = "tcp"
    cidr_blocks = [ "10.20.0.0/16" ]
    description = "allow 1638-"
  }

    ingress {
    from_port   = 9121
    to_port     = 9121
    protocol    = "tcp"
    cidr_blocks = [ "10.20.0.0/16" ]
    description = "allow 9121 redis exporter"
  }


    ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = [ "0.0.0.0/0" ]
    description = "allow grafana"
  }


#  16379 and 16380

    ingress {
    from_port   = 9090
    to_port     = 9090
    protocol    = "tcp"
    cidr_blocks = [ "0.0.0.0/0" ]
    description = "allow 9090 Prom"
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.env}-${var.vpc_name}-redis"
    Environment = var.env
  }

}


module "redis" {
  source                      = "../ec2/"
  env                         = var.env
  app_name                    = "REDIS"
  app_role                    = "main"
  domain_name                 = var.domain_name
  ami                         = var.redis_ami
  instance_type               = "t3.medium"
  volume_size                 = "120"
  security_group_ids          = aws_security_group.redis_sg.id
  subnet_id                   = aws_subnet.public_subnet[0].id
  associate_public_ip_address = "true"
  tags_Type                   = "redis"
  disable_api_termination     = false
  ebs_optimized = true
}


resource "aws_security_group" "internal_sg" {
  name        = "${var.env}-${var.vpc_name}-internal"
  description = "For ${var.env} internal instances"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["${var.vpc_cidr}"]
    description = "allow everythin within the VPC"
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.env}-${var.vpc_name}-internal"
    Environment = var.env
  }

  lifecycle {
                ignore_changes = [ingress]
            }

}
