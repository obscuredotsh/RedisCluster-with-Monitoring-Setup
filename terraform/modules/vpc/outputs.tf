output "vpc_id" { value = "${aws_vpc.vpc.id}" }

output "private_subnet_id" { value = "${aws_subnet.private_subnet[*].id}" }
output "public_subnet_id" { value = "${aws_subnet.public_subnet[*].id}" }

output "nat_ip" { value = "${aws_nat_gateway.nat_gw.public_ip}" }

output "private_rt_id" { value = "${aws_route_table.private_rt.id}" }
output "public_rt_id" { value = "${aws_route_table.public_rt.id}" }

#output "redis_ip" { value = "${aws_eip.redis_elastic_ip.public_ip}" }

output "sg_redis" { value= "${aws_security_group.redis_sg.id}" }
output "sg_internal" { value= "${aws_security_group.internal_sg.id}" }
