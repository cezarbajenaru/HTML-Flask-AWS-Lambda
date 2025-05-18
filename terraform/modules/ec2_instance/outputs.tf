output "instance_public_ip" {
    description = "Public IP for the EC2 instance"
    value = aws_instance.EC2TFDocker-Server.public_ip
}