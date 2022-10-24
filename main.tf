# pulling data from aws organisation account 
data "aws_organizations_organization" "organisation" {}

# Created an organisation account called DEV 
resource "aws_organizations_organizational_unit"  "DEV" {
    name = "Dev"
    parent_id = data.aws_organizations_organization.organisation.id
  
}

# Create VPC
resource "aws_vpc" "cyberhive_vpc" {
  cidr_block = "10.0.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true
}

# Create internet Gateway
resource "aws_internet_gateway" "gw" {}

# Attach interet Gateway

resource "aws_internet_gateway_attachment" "igw_attachment" {
  internet_gateway_id = aws_internet_gateway.gw.id
  vpc_id              = aws_vpc.cyberhive_vpc.id
}

# Create Public Route
resource "aws_route_table" "pub_route" {
  vpc_id = aws_vpc.cyberhive_vpc.id 

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
}

  # Create private Route
resource "aws_route_table" "priv_route" {
  vpc_id = aws_vpc.cyberhive_vpc.id 

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.natgw.id
  }
}


# Route Association pub_subnet_1
resource "aws_route_table_association" "pub_route_1" {
  subnet_id      = aws_subnet.pub_1.id
  route_table_id = aws_route_table.pub_route.id
}

# Route Association Pub_subnet_2
resource "aws_route_table_association" "pub_route_2" {
  subnet_id      = aws_subnet.pub_2.id
  route_table_id = aws_route_table.pub_route.id
}

# Route Association private_subnet
resource "aws_route_table_association" "priv_route_1" {
  subnet_id      = aws_subnet.priv_1.id
  route_table_id = aws_route_table.priv_route.id
}
# Public Subnet 1
resource "aws_subnet" "pub_1" {
  vpc_id     = aws_vpc.cyberhive_vpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-east-1a"
}

# Public Subnet 2
resource "aws_subnet" "pub_2" {
  vpc_id     = aws_vpc.cyberhive_vpc.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "us-east-1b"
}

# Private Subnet
resource "aws_subnet" "priv_1" {
  vpc_id     = aws_vpc.cyberhive_vpc.id
  cidr_block = "10.0.3.0/24"
  availability_zone = "us-east-1c"
}

# Create Elastic IP for NATGW Association
resource "aws_eip" "eip" {}

# Create NATGW
resource "aws_nat_gateway" "natgw" {
  allocation_id = aws_eip.eip.id
  subnet_id     = aws_subnet.pub_1.id
}