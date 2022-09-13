output "public_subnets" {
  value = aws_subnet.public_subnets.*.id
}

output "vpc_id" {
  value = aws_vpc.project_vpc.id
}