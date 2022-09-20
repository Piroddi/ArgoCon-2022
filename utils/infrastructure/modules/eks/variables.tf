variable "vpc_id" {
  type = string
}
variable "private_subnets" {
  type = list(string)
}
variable "tags" {
  type = map(string)
}
variable "vpc_cidr" {
  type = string
}