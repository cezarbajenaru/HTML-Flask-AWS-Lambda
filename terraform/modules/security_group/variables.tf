variable "sg_name" {
    type = string
}
#variable "security_group_id" {
#  type = string
#}
variable "sg_description" {
  type = string
}
variable "vpc_id" {
  type = string
  description = "The VPC where resources will be created" # export TF_VAR_ + nameofvpc or in this case TF_VAR_vpc_id. Putting TF_VAR_ in front of vpc_id variable makes it a tf readable variable
}
