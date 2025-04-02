provider "aws" {
  region = var.region
}


resource "aws_vpc" "task14_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "task14-vpc"
  }
}

resource "aws_internet_gateway" "task14_igw" {
  vpc_id = aws_vpc.task14_vpc.id

  tags = {
    Name = "task14-igw"
  }
}

resource "aws_route_table" "task14_public_rt" {
  vpc_id = aws_vpc.task14_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.task14_igw.id
  }

  tags = {
    Name = "task14-public-rt"
  }
}


# Jump Subnet (public) 

resource "aws_subnet" "task14_jump_subnet" {
  vpc_id                  = aws_vpc.task14_vpc.id
  cidr_block              = var.jump_subnet_cidr
  availability_zone       = var.az
  map_public_ip_on_launch = true

  tags = {
    Name = "task14-jump-subnet"
  }
}

resource "aws_route_table_association" "task14_jump_assoc" {
  subnet_id      = aws_subnet.task14_jump_subnet.id
  route_table_id = aws_route_table.task14_public_rt.id
}

# Public Subnet for WordPress EC2 instance
resource "aws_subnet" "task14_public_subnet" {
  vpc_id                  = aws_vpc.task14_vpc.id
  cidr_block              = var.public_subnet_cidr
  availability_zone       = var.az
  map_public_ip_on_launch = true

  tags = {
    Name = "task14-public-subnet"
  }
}

resource "aws_route_table_association" "task14_public_assoc" {
  subnet_id      = aws_subnet.task14_public_subnet.id
  route_table_id = aws_route_table.task14_public_rt.id
}

# Private Subnet 1 for RDS
resource "aws_subnet" "task14_private_subnet1" {
  vpc_id            = aws_vpc.task14_vpc.id
  cidr_block        = var.private_subnet1_cidr
  availability_zone = var.az

  tags = {
    Name = "task14-private-subnet-1"
  }
}

# Private Subnet 2 for RDS
resource "aws_subnet" "task14_private_subnet2" {
  vpc_id            = aws_vpc.task14_vpc.id
  cidr_block        = var.private_subnet2_cidr
  availability_zone = var.az2

  tags = {
    Name = "task14-private-subnet-2"
  }
}

# RDS MySQL Instance & DB Subnet Group

resource "aws_db_subnet_group" "task14_db_subnets" {
  name       = "task14-db-subnet-group"
  subnet_ids = [
    aws_subnet.task14_private_subnet1.id,
    aws_subnet.task14_private_subnet2.id
  ]

  tags = {
    Name = "task14-db-subnet-group"
  }
}

resource "aws_security_group" "task14_db_sg" {
  name        = "task14-db-sg"
  description = "Allow MySQL access from the WordPress EC2 instance"
  vpc_id      = aws_vpc.task14_vpc.id

  ingress {
    description     = "MySQL access from WordPress EC2"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.task14_ec2_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_db_instance" "task14_wordpress_db" {
  identifier              = "task14-wordpress-db"
  engine                  = "mysql"
  engine_version          = "8.0"
  instance_class          = "db.t3.micro"
  allocated_storage       = 20
  db_name                 = "wordpressdb"      
  username                = var.db_username
  password                = var.db_password
  parameter_group_name    = "default.mysql8.0"
  db_subnet_group_name    = aws_db_subnet_group.task14_db_subnets.name
  vpc_security_group_ids  = [aws_security_group.task14_db_sg.id]
  skip_final_snapshot     = true

  tags = {
    Name = "task14-wordpress-db"
  }
}
# Security Group for WordPress EC2

resource "aws_security_group" "task14_ec2_sg" {
  name        = "task14-ec2-sg"
  vpc_id      = aws_vpc.task14_vpc.id

  ingress {
    description = "Allow HTTP access"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow SSH access from jump subnet"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.jump_subnet_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# EC2 Instance for WordPress and AMI Creation

resource "aws_instance" "task14_wordpress_ec2" {
  ami                    = var.base_ami
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.task14_public_subnet.id
  vpc_security_group_ids = [aws_security_group.task14_ec2_sg.id]

  user_data = templatefile("${path.module}/wp_userdata.sh.tpl", {
    db_username = var.db_username
    db_password = var.db_password
    db_host     = aws_db_instance.task14_wordpress_db.address
  })

  tags = {
    Name = "task14-wordpress-ec2"
  }
}

resource "aws_ami_from_instance" "task14_wp_ami" {
  name               = "task14-wordpress-ami"
  source_instance_id = aws_instance.task14_wordpress_ec2.id

  depends_on = [aws_instance.task14_wordpress_ec2]
}
