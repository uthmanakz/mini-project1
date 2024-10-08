terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region = "eu-west-2"
}

resource "aws_vpc" "main_vpc" {
  cidr_block = "10.0.0.0/16"

  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "VPC"
  }
}



resource "aws_subnet" "public_subnet_a" {
  vpc_id            = aws_vpc.main_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "eu-west-2a"

  tags = {
    Name = "SubnetA"
  }
}

resource "aws_subnet" "public_subnet_b" {
  vpc_id            = aws_vpc.main_vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "eu-west-2b"

  tags = {
    Name = "SubnetB"
  }
}

resource "aws_security_group" "sg_frontend" {
  vpc_id = aws_vpc.main_vpc.id
  name   = "sg_frontend"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
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


resource "aws_instance" "frontend1" {
  ami                         = var.frontend1_ami
  instance_type               = var.frontend1_instance_type
  key_name                    = var.frontend1_key_name
  user_data                   = file("./frontend.install.sh")
  subnet_id                   = aws_subnet.public_subnet_a.id
  vpc_security_group_ids      = [aws_security_group.sg_frontend.id]
  associate_public_ip_address = true

  tags = {
    Name = "frontend"
  }
}




resource "aws_instance" "frontend2" {
  ami                         = var.frontend2_ami
  instance_type               = var.frontend2_instance_type
  key_name                    = var.frontend2_key_name
  user_data                   = file("./frontend.install.sh")
  subnet_id                   = aws_subnet.public_subnet_b.id
  vpc_security_group_ids      = [aws_security_group.sg_frontend.id]
  associate_public_ip_address = true


  tags = {
    Name = "frontend"
  }
}


resource "aws_security_group" "sg_backend" {
  vpc_id = aws_vpc.main_vpc.id
  name   = "sg_backend"


  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
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


resource "aws_instance" "backend1" {
  ami                         = var.backend1_ami
  instance_type               = var.backend1_instance_type
  key_name                    = var.backend1_key_name
  user_data                   = file("./backend.install.sh")
  subnet_id                   = aws_subnet.public_subnet_a.id
  vpc_security_group_ids      = [aws_security_group.sg_backend.id]
  associate_public_ip_address = true


  tags = {
    Name = "backend"
  }
}




resource "aws_instance" "backend2" {
  ami                         = var.backend2_ami
  instance_type               = var.backend2_instance_type
  key_name                    = var.backend2_key_name
  user_data                   = file("./backend.install.sh")
  subnet_id                   = aws_subnet.public_subnet_b.id
  vpc_security_group_ids      = [aws_security_group.sg_backend.id]
  associate_public_ip_address = true


  tags = {
    Name = "backend"
  }
}

resource "aws_security_group" "sg_database" {
  vpc_id = aws_vpc.main_vpc.id
  name   = "sg_database"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 3306
    to_port     = 3306
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


resource "aws_instance" "database" {
  ami                         = var.database_ami
  instance_type               = var.database_instance_type
  key_name                    = var.database_key_name
  subnet_id                   = aws_subnet.public_subnet_a.id
  vpc_security_group_ids      = [aws_security_group.sg_database.id]
  associate_public_ip_address = true



  tags = {
    Name = "database"
  }
}

resource "aws_db_subnet_group" "db_subnet_group" {
  name       = "my-db-subnet-group"
  subnet_ids = [aws_subnet.public_subnet_a.id, aws_subnet.public_subnet_b.id]
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main_vpc.id

  tags = {
    Name = "main-vpc-igw"
  }
}

resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.main_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "public-route-table"
  }
}

resource "aws_route_table_association" "public_subnet_a_association" {
  subnet_id      = aws_subnet.public_subnet_a.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table_association" "public_subnet_b_association" {
  subnet_id      = aws_subnet.public_subnet_b.id
  route_table_id = aws_route_table.public_route_table.id
}




resource "aws_db_instance" "db_mysql" {

  instance_class         = "db.t4g.micro"
  allocated_storage      = 20
  engine                 = "mysql"
  engine_version         = "8.0.35"
  username               = "mysqldb"
  password               = var.mysql_password
  db_name                = "db_mysql"
  vpc_security_group_ids = [aws_security_group.sg_database.id]
  publicly_accessible    = true
  skip_final_snapshot    = true
  db_subnet_group_name   = aws_db_subnet_group.db_subnet_group.name
  availability_zone      = "eu-west-2b"
}






