###### region_id ######
variable "region" {}

###### cidr_block of vpc ######
variable "vpc_cidr" {}

###### vpc name ######
variable "vpc_name" {}

###### eks name ######
variable "igw_name" {}

###### subnet vars ######
variable "subnet1_name" {}
variable "subnet1_cidr" {}

variable "subnet2_name" {}
variable "subnet2_cidr" {}

###### route table name ######
variable "rtb_name" {}

###### security group name ######
variable "sg_name" {}

###### eks name ######
variable "eks_name" {}

###### node variables ######
variable "ng_name" {}
variable "max_n" {}
variable "min_n" {}
variable "ami_type" {}
variable "capacity" {}
variable "ins_type" {}
variable "desired_n" {}
variable "ec2_name" {}
