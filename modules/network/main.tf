# The VPC itself 
resource "aws_vpc" "main" {
    cidr_block = var.vpc_cidr
    enable_dns_hostnames = true # Allows ec2 instances to have public DNS names
    enable_dns_support = true # Allows ec2 instances to resolve public DNS names

    tags = {
        Name = "${var.project_name}-vpc"
    }
}

# Public subnet
resource "aws_subnet" "public" {
    vpc_id = aws_vpc.main.id
    cidr_block = var.subnet_cidr
    availability_zone = var.availability_zone
    map_public_ip_on_launch = true # Automatically assign public IP to instances launched in this subnet

    tags = {
        Name = "${var.project_name}-public-subnet"
    }
}

# Internet Gateway - allows instances in the VPC to access the internet
resource "aws_internet_gateway" "main" {
    vpc_id = aws_vpc.main.id

    tags = {
        Name = "${var.project_name}-igw"
    }
}

# Route table - defines how traffic is routed in the VPC
resource "aws_route_table" "public" {
    vpc_id = aws_vpc.main.id

    route {
        cidr_block = "0.0.0.0/0" # Route all traffic to the internet
        gateway_id = aws_internet_gateway.main.id
    }

    tags = {
        Name = "${var.project_name}-public-rt"
    }
}

# Route table association - associates the route table with the public subnet
resource "aws_route_table_association" "public" {
    subnet_id = aws_subnet.public.id
    route_table_id = aws_route_table.public.id
}