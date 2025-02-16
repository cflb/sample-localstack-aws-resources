provider "aws" {
  region                      = var.region
  access_key                  = var.access_key
  secret_key                  = var.secret_key
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true
  endpoints {
    dynamodb     = var.endpoints
    ec2          = var.endpoints
    s3           = var.s3_endpoints
    route53      = var.endpoints
  }
}

resource "aws_dynamodb_table" "minha_tabela" {
  name           = var.dinamo_db_name
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "id"

  attribute {
    name = "id"
    type = "S"
  }
}

resource "aws_s3_bucket" "bucket_publico" {
  bucket = var.public_s3_bucket_name
}

resource "aws_vpc" "vpc" {
  cidr_block = var.cidr_block
}

resource "aws_subnet" "public_1" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.cidr_public_subnets[0]
  availability_zone = var.az_list[0]
}

resource "aws_subnet" "public_2" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.cidr_public_subnets[1]
  availability_zone = var.az_list[1]
}

resource "aws_subnet" "private_1" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.cidr_private_subnets[0]
  availability_zone = var.az_list[0]
}

resource "aws_subnet" "private_2" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.cidr_private_subnets[1]
  availability_zone = var.az_list[1]
}

# Criando um Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
}

resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id 
  }
}

resource "aws_route_table_association" "public_1_association" {
  subnet_id      = aws_subnet.public_1.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table_association" "public_2_association" {
  subnet_id      = aws_subnet.public_2.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route53_zone" "domain_1" {
  name = var.route53_domain
}

resource "aws_route53_record" "www_private" {
  zone_id = aws_route53_zone.domain_1.zone_id
  name    = "internal.${var.route53_domain}"
  type    = "A"
  records = [aws_instance.ec2_instance_1.private_ip]  # Referenciando o IP privado
}

resource "aws_instance" "ec2_instance_1" {
  ami           = var.ami_id
  instance_type = var.instance_type
  subnet_id     = aws_subnet.private_1.id # Colocando na subnet privada
  private_ip    = var.instance_privite_ip
}

resource "aws_security_group" "ec2_sg" {
  name        = "ec2-security-group"
  description = "Allow inbound traffic on port 80 for EC2 instance"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
