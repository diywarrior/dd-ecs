resource "aws_vpc_dhcp_options" "main" {
  domain_name         = "eu-central-1.compute.internal"
  domain_name_servers = ["AmazonProvidedDNS"]
}

resource "aws_vpc_dhcp_options_association" "main" {
  vpc_id          = aws_vpc.main.id
  dhcp_options_id = aws_vpc_dhcp_options.main.id
}

resource "aws_vpc" "main" {
  assign_generated_ipv6_cidr_block = false
  cidr_block = "172.22.0.0/22"
  enable_classiclink = false
  enable_dns_hostnames = true
  enable_dns_support = true
  instance_tenancy = "default"
}

resource "aws_vpc_ipv4_cidr_block_association" "secondary_cidr" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "172.24.0.0/16"
}


resource "aws_subnet" "production_1a" {
  assign_ipv6_address_on_creation = false
  availability_zone = "eu-central-1a"
  cidr_block = "172.22.1.0/24"
  map_public_ip_on_launch = "true"
  vpc_id = aws_vpc.main.id
}

resource "aws_subnet" "production_1b" {
  assign_ipv6_address_on_creation = false
  availability_zone = "eu-central-1b"
  cidr_block = "172.22.0.0/24"
  map_public_ip_on_launch = "true"
  vpc_id = aws_vpc.main.id
}

resource "aws_subnet" "production_1c" {
  assign_ipv6_address_on_creation = false
  availability_zone = "eu-central-1c"
  cidr_block = "172.22.2.0/24"
  map_public_ip_on_launch = "true"
  vpc_id = aws_vpc.main.id
}

resource "aws_network_acl" "main" {
  vpc_id = aws_vpc.main.id
  subnet_ids = [
    aws_subnet.production_1a.id,
    aws_subnet.production_1b.id,
    aws_subnet.production_1c.id
  ]

  egress {
    protocol   = -1
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  ingress {
    protocol   = -1
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
}

resource "aws_route_table" "mixed" {
  vpc_id = aws_vpc.main.id
}

resource "aws_route" "mixed-1" {
  depends_on = [aws_route_table.mixed]
  route_table_id = aws_route_table.mixed.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.main.id
}

resource "aws_main_route_table_association" "mixed" {
  depends_on = [aws_route_table.mixed]
  route_table_id = aws_route_table.mixed.id
  vpc_id = aws_vpc.main.id
}

resource "aws_security_group" "allow_traffic" {
  name = "Allow Internal and outbound traffic"
  description = "Security Group for internal access and outbound connections"
  vpc_id = aws_vpc.main.id

  ingress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    self = true
  }

  ingress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = [aws_subnet.production_1a.cidr_block]
    description = "Subnet 1a"
  }

  ingress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = [aws_subnet.production_1b.cidr_block]
    description = "Subnet 1b"
  }

  ingress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = [aws_subnet.production_1c.cidr_block]
    description = "Subnet 1c"
  }

  ingress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = local.whitelisted_cidrs
    description = "Service IPs"
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow external traffic"
  }
}
