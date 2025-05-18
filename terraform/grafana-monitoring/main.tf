resource "aws_instance" "grafana" {
  ami           = "ami-0abcdef1234567890"  # your Linux AMI
  instance_type = "t2.micro"
  key_name      = "graphana key bla bla" #create it
  security_groups = [aws_security_group.grafana_sg.name]

  user_data = <<-EOF
    #!/bin/bash
    sudo yum update -y
    sudo yum install -y grafana
    sudo systemctl start grafana-server
    sudo systemctl enable grafana-server
  EOF

  tags = {
    Name = "GrafanaServer"
  }
}

resource "aws_security_group" "grafana_sg" {
  name        = "grafana_sg"
  description = "Allow HTTP and HTTPS"
  vpc_id      = "your-vpc-id"

  ingress {
    from_port   = 3000
    to_port     = 3000
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
