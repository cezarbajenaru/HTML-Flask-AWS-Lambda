#A map of the variables in modules 

#Module name	  |                       Variables it expects	                                 | Outputs it provides
#security_group	  |                     sg_name, sg_description, vpc_id                          |  security_group_id
#ec2_instance	  |  ami, instance_type, key_name, security_group_id, user_data, instance_name	 | instance_public_ip

#root main.tf passes variables to modules. In order for variables to be passed to modules, variables.tf must exist and everything to be passed must be there declared
#Env variables with TF_VAR_ prefix can also be used to provide values and keep security good
provider "aws" {
    region = "eu-north-1"    #get region from AWS console in cont
}

module "security_group" {
  source         = "./modules/security_group"    #this goes in variables | entry point to security group
  sg_name        = "my_sec_group"                #this goes in variables
  sg_description = "Allow SSH and HTTP"          #this goes in variables
  vpc_id         =  var.vpc_id             #stored in env variables / this goes in variables in linux with export command ( TF_VAR_name_variable / vpc_id in this case)
}
#commands are for Amazon Linux 2

module "ec2_instance" {
  source              = "./modules/ec2_instance" # should not be declared in variables. It is a special argument used only in the root main.tf
  ami                 = "ami-0453ec754f44f9a4a"
  instance_type       = "t2.micro"
  key_name            = "ec2terraform_key"
  security_group_id   = module.security_group.security_group_id #this goes in variables #Gives the EC2 instance the security group ID that was created in the security_group module in AWS.
  instance_name       = "EC2TFDocker-Server"
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
}