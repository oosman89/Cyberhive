# Create KMS key
resource "aws_kms_key" "kms_key" {}

resource "aws_kms_alias" "kms_alias" {
  name          = "alias/my-key-alias"
  target_key_id = aws_kms_key.kms_key.key_id
}
# Create Security Group
resource "aws_security_group" "ubuntu_sgrp" {
  name        = "allow_tls"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.cyberhive_vpc.id

  ingress {
    description      = "Allow SSH"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  ingress {
    description      = "Allow Http"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  ingress {
    description      = "Allow Https"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }
}

# Create Ubutun EC2
resource "aws_instance" "ubuntu_instance" {
  ami           = "ami-08c40ec9ead489470" 
  instance_type = "t2.micro"
  security_groups = [aws_security_group.ubuntu_sgrp.id]
  availability_zone = "us-east-1a"
}

# Create EBS Volume
resource "aws_ebs_volume" "ebs_volume" {
  availability_zone = "us-east-1a"
  size              = 40
  kms_key_id = aws_kms_alias.kms_alias.id

}

# Attach EBS Volume
resource "aws_volume_attachment" "ebs_att" {
     device_name = "/dev/sdh"
     volume_id   = aws_ebs_volume.ebs_volume.id
     instance_id = aws_instance.ubuntu_instance.id
    #  kms_key_id = aws_kms_alias.kms_alias.id
}

