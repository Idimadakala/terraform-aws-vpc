output "vpc_id" {
    value = aws_vpc.main.id
}

output "igw_id" {
    value = aws_internet_gateway.main.id
  
}

/* output "azs_info" {
    value = data.aws_availability_zones.available
} */

output "public_subnet_ids" {
    description = "Public subnet ids"
    value = [for subnets in aws_subnet.public_subnet : subnets.id]    
}

output "private_subnet_ids" {
    description = "Private subnet ids"
    value = [for subnets in aws_subnet.private_subnet : subnets.id]    
}

output "database_subnet_ids" {
    description = "Database subnet ids"
    value = [for subnets in aws_subnet.database_subnet : subnets.id]    
}

output "eip_id" {
    description = "EIP Address"
    value = aws_eip.eip.id
}

output "nat_gateway_id" {
    description = "NAT Gateway id"
    value = aws_nat_gateway.nat.id
}

output "public_rt_id" {
    value = aws_route_table.public.id
  
}

output "private_rt_id" {
    value = aws_route_table.private.id
  
}

output "database_rt_id" {
    value = aws_route_table.database.id 
}

output "vpc_peering_connection_id" {
    description = "VPC Peering connection id"
    value = [for ids in aws_vpc_peering_connection.default : ids.id]
    
}