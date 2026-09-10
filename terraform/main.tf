provider "aws" {
  region = var.region

  default_tags {
    tags = {
      Environment = "dev"
      Project     = "static-site"
      ManagedBy   = "opentofu"
    }
  }
}

resource "aws_vpc" "vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "static-site-vpc"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "static-site-igw"
  }
}

resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "${var.region}a"
  map_public_ip_on_launch = true
  tags = {
    Name = "static-site-public-subnet1a"
  }
}

# resource "aws_subnet" "private_subnet" {
#   vpc_id            = aws_vpc.vpc.id
#   cidr_block        = "10.0.2.0/24"
#   availability_zone = "${var.region}a"
#   tags = {
#     Name = "static-site-private-subnet1a"
#   }
# }

resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
  tags = {
    Name = "static-site-route-table"
  }
}

resource "aws_route_table_association" "public_route_table_association" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_iam_role" "ec2_role" {
  name = "static-site-EC2-SSM"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ec2_role_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  role       = aws_iam_role.ec2_role.name
}

resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = "EC2_SSM_Instance_Profile"

  role = aws_iam_role.ec2_role.name
}

resource "aws_security_group" "instance_security_group" {
  name_prefix = "instance-sg"
  vpc_id      = aws_vpc.vpc.id
  description = "static-site - security group for the EC2 instance"

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTPS"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound IPv4"
  }

  tags = {
    Name = "static-site-instance-sg"
  }

  lifecycle {
    create_before_destroy = true
  }
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_instance" "app_server" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "t3.micro"
  subnet_id                   = aws_subnet.public_subnet.id
  associate_public_ip_address = true
  vpc_security_group_ids = [
    aws_security_group.instance_security_group.id,
  ]
  iam_instance_profile = aws_iam_instance_profile.ec2_instance_profile.name

  tags = {
    Name = "static-site-ec2"
  }
}
