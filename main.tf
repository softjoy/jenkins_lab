
#creating local name for my resources
locals {
  name = "row"
}

# RSA key of size 4096 bits
resource "tls_private_key" "key"{
  algorithm ="RSA"
  rsa_bits = 4096
}

//creating private key
resource "local_file" "key" {
  content = tls_private_key.key.private_key_pem
  filename = "rowjenkey"
  file_permission = 400
}

//creating public key
resource "aws_key_pair" "key" {
  key_name = "rowjenkey"
  public_key = tls_private_key.key.public_key_openssh
}

//creating seccurity group
resource "aws_security_group" "jenkins-sg" {
  name        = "jenkings instance"
  description = "jenkins instance secuirty group"
  
  ingress {
    description = "ssh from vpc"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.allcidr]
  }

ingress {
    description = "ssh from vpc"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = [var.allcidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.allcidr]
  }

  tags = {
    Name = "${local.name}-jenkins-sg"
  }
}

//creating seccurity group
resource "aws_security_group" "prod-sg" {
  name        = "prod sg"
  description = "prod instance secuirty group"
  
  ingress {
    description = "ssh from vpc"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.allcidr]
  }

ingress {
    description = "ssh from vpc"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = [var.allcidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.allcidr]
  }

  tags = {
    Name = "${local.name}-prod-sg"
  }
}

//creating jenkins instance
resource "aws_instance" "jenkins" {
  ami                         = var.redhat //jenkins redhat ami
  instance_type               = "t2.medium"
  key_name                    = aws_key_pair.key.id
  vpc_security_group_ids      = [aws_security_group.jenkins-sg.id] 
  associate_public_ip_address = true
  user_data                   = file("./userdata1.sh")
  tags = {
    Name = "${local.name}-jenkins"
  }
}

//creating maven insstance
resource "aws_instance" "prod" {
  ami                         = var.redhat //maven redhat ami
  instance_type               = "t2.medium"
  key_name                    = aws_key_pair.key.id
  vpc_security_group_ids      = [aws_security_group.prod-sg.id]
  associate_public_ip_address = true
  user_data                   = file("./userdata2.sh")
  tags = {
    Name = "${local.name}-prod"
  }
}




