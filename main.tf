# KEY PAIR SSH
resource "aws_key_pair" "at-key-pair-hamza" {
  key_name   = "tp-terraform-key"
  public_key = file("~/.ssh/tp-terraform-key.pub")
}

# Subnet Public - Frontend Angular
resource "aws_subnet" "at-sn-public-hamza" {
  vpc_id                  = data.aws_vpc.existing.id
  cidr_block              = var.subnet_public_cidr
  availability_zone       = var.availability_zone
  map_public_ip_on_launch = true

  tags = {
    Name = "at-sn-public-hamza"
  }
}

# Subnet Privé - Backend Flask
resource "aws_subnet" "at-sn-private-hamza" {
  vpc_id                  = data.aws_vpc.existing.id
  cidr_block              = var.subnet_private_cidr
  availability_zone       = var.availability_zone
  map_public_ip_on_launch = false

  tags = {
    Name = "at-sn-private-hamza"
  }
}

# INTERNET GATEWAY
#resource "aws_internet_gateway" "at-igw-hamza" {
#  vpc_id = data.aws_vpc.existing.id

#  tags = {
#    Name = "at-igw-hamza"
#  }
#}

# ELASTIC IP pour le NAT Gateway
resource "aws_eip" "at-eip-hamza" {
  domain = "vpc"

  tags = {
    Name = "at-eip-hamza"
  }
}

# NAT GATEWAY (dans le subnet public)
resource "aws_nat_gateway" "at-nat-hamza" {
  allocation_id = aws_eip.at-eip-hamza.id
  subnet_id     = aws_subnet.at-sn-public-hamza.id

  tags = {
    Name = "at-nat-hamza"
  }

  depends_on = [data.aws_internet_gateway.existing]
}

# ROUTE TABLE PUBLIQUE (frontend)
resource "aws_route_table" "at-rt-frontend-hamza" {
  vpc_id = data.aws_vpc.existing.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = data.aws_internet_gateway.existing.id
  }

  tags = {
    Name = "at-rt-frontend-hamza"
  }
}

# Association subnet public → route table publique
resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.at-sn-public-hamza.id
  route_table_id = aws_route_table.at-rt-frontend-hamza.id
}

# ROUTE TABLE PRIVÉE (backend)
resource "aws_route_table" "at-rt-backend-hamza" {
  vpc_id = data.aws_vpc.existing.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.at-nat-hamza.id
  }

  tags = {
    Name = "at-rt-backend-hamza"
  }
}

# Association subnet privé → route table privée
resource "aws_route_table_association" "private" {
  subnet_id      = aws_subnet.at-sn-private-hamza.id
  route_table_id = aws_route_table.at-rt-backend-hamza.id
}

# SECURITY GROUP FRONTEND
resource "aws_security_group" "at-sg-frontend-hamza" {
  name        = "at-sg-frontend-hamza"
  description = "Security Group pour le frontend Angular"
  vpc_id      = data.aws_vpc.existing.id

  ingress {
   description = "HTTP depuis Internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH"
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

 tags = {
    Name = "at-sg-frontend-hamza"
 }
}

# EC2 FRONTEND
resource "aws_instance" "at-instance-frontend-hamza" {
  ami                         = data.aws_ami.amazon_linux.id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.at-sn-public-hamza.id
  vpc_security_group_ids      = [aws_security_group.at-sg-frontend-hamza.id]
  key_name                    = aws_key_pair.at-key-pair-hamza.key_name
  associate_public_ip_address = true

 user_data = file("frontend-user-data.sh")

  tags = {
    Name = "at-instance-frontend-hamza"
  }
}

# SECURITY GROUP BACKEND
resource "aws_security_group" "at-sg-backend-hamza" {
  name        = "at-sg-backend-hamza"
  description = "Security Group pour le backend Flask"
  vpc_id      = data.aws_vpc.existing.id

  # Port Flask uniquement depuis le subnet public (frontend)
  ingress {
    description = "Flask depuis subnet public"
    from_port   = 8081
    to_port     = 8081
    protocol    = "tcp"
    cidr_blocks = [var.subnet_public_cidr]
  }

  # SSH pour administration
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.subnet_public_cidr]
  }

  # Tout le trafic sortant autorisé
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "at-sg-backend-hamza"
  }
}

# EC2 BACKEND
resource "aws_instance" "at-instance-backend-hamza" {
  ami                    = data.aws_ami.amazon_linux_2023.id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.at-sn-private-hamza.id
  vpc_security_group_ids = [aws_security_group.at-sg-backend-hamza.id]
  key_name               = aws_key_pair.at-key-pair-hamza.key_name

  user_data = file("backend-user-data.sh")

  tags = {
    Name = "at-instance-backend-hamza"
  }
}
