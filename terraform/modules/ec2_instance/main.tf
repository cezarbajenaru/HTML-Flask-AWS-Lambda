resource "aws_instance" "EC2TFDocker-Server" {
    ami             = var.ami
    instance_type   = var.instance_type
    key_name        = var.key_name
    vpc_security_group_ids = [var.security_group_id]

    user_data = var.user_data

    tags = {
        Name = var.instance_name
    }
}