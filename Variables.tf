variable "cidr_block" {
    type = list(string)
    default = [ "170.32.0.0/16","170.32.20.0/24", "170.32.30.0/24" ]
}

variable "ami" {
type = string
default = "ami-043aedb23a5659f53"
}

variable "instance_type" {
type = string
default = "t2.micro"
}

variable "instance_type_for_nexus" {
type = string
default = "t2.medium"
}
