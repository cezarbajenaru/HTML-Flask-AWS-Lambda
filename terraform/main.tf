provider "aws" {
    region = "us-east-whatever"    #get region from AWS console in cont
}

resource "aws_instance" "ec2terraformjenkins" {
    ami             = "ami-0453ec754f44f9a4a" #get AMI din AWS console
    instance_type   = "t2.micro"
    key_name        = "ec2terraform_key" #creeaza daca nu exista ( sigur nu mai exista)
    security_groups = [aws_security_group.my_sg.name] #verifica daca mai exista security group-ul asta sau creeaza unul
#commands are for Amazon Linux 2
    user_data = <<-EOF
        #!/bin/bash
        sudo yum update -y
        sudo yum install -y docker
        sudo systemctl start docker
        echo "Docker has started"
        docker --version
        sudo systemctl enable docker
        sudo usermod -aG docker ec2-user
    EOF

    tags = {
        Name = "Ec2terraformjenkins-Server"
    }
}

resource "aws_security_group" "my_sg" {
    name = "my_sg"
    description = "Allow SSH and HTTP"
    vpc_id = "vpc-0237bd2a8d3ee0738"  #verifica VPC ID!

    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        from_port = 8080
        to_port = 8080
        protocol ="tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}
# alegem IP static pentru a putea lucra si in viitor pe aceeasi adresa