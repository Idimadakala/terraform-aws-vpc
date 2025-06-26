# steps to create a VPC
1. create a vpc in region: us-east-1
2. create an EIP and IGW and associate IGW with VPC
3. create a subnet - 
    i. two public subnet in us-east-1a, us-east-1b
    ii. two private subnet in us-east-1a, us-east-1b
    iii. two database subnet in us-east-1a, us-east-1b
4. create a route table, route and associate it with public subnet
    i. resource "aws_route_table"
    ii. resource "aws_route"
        1. add Internet as a route through IGW
    iii. resource "aws_route_table_associate"
4. create a route table, route and associate it with private subnet
    i. resource "aws_route_table"
    ii. resource "aws_route"
        1. add NAT gateway for Internet
    iii. resource "aws_route_table_associate"
