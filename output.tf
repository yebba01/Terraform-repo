output "server" {
  value = aws_instance.yebbas-server.public_ip

}


output "vpc_id" {
  value = aws_vpc.yebbas-vpc.id

}

output "server_arn" {
  value = aws_instance.yebbas-server.arn
}