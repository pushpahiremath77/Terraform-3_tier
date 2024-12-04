output "frontend_public_ip" {
  value = aws_instance.frontend.public_ip
  description = "The public IP address of the Frontend EC2 instance"
}


output "backend_private_ip" {
  value = aws_instance.backend.private_ip
  description = "The private IP address of the Backend EC2 instance"
}

output "database_private_ip" {
  value = aws_instance.database.private_ip
  description = "The private IP address of the Database EC2 instance"
}

output "vpc_id" {
  value = aws_vpc.my_vpc.id
  description = "The vpc id of MyVPC"
}

output "public_subnet_id_1" {
  value = aws_subnet.public_subnet_1.id
  description = "subnet id of public subnet 1"
}

output "public_subnet_id_2" {
  value = aws_subnet.public_subnet_2.id
  description = "subnet id of public subnet 2"
}

output "private_subnet_id_1" {
  value = aws_subnet.private_subnet_1.id
  description = "subnet id of private subnet 1"
}

output "private_subnet_id_2" {
  value = aws_subnet.private_subnet_2.id
  description = "subnet id of private subnet 2"
}
