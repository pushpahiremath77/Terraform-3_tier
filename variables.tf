variable "region" {

	description = "The AWS region where my resources will be created"
	type	    = string
	default     = "us-east-1"
}


variable "access_key" {

        description = "access_key"
        type        = string
}


variable "secrete_key" {

        description = "Secrete access key"
        type        = string

}



variable "vpc_cidr" {
	description = "CIDR block for VPC"
	type	    = string
	default     = "10.0.0.0/16"
}


variable "vpc_name" {
        description = "Name of VPC"
        type        = string
        default     = "MyVPC"
}




#subnet1
variable "subnet_cidr_public_1" {
	description = "CIDR block for public subnet 1"
	type	    = string
	default     = "10.0.1.0/24"
}

variable "public_subnet_1_name" {
  type        = string
  description = "Name for the public subnet 1"
  default     = "PublicSubnet1"
}

variable "availability_zone_1" {
  type        = string
  description = "The Availability Zone for the public subnet 1"
  default     = "us-east-1a" 
}



#subnet2
variable "subnet_cidr_public_2" {
	description = "CIDR block for public subnet 2"
	type	    = string
	default     = "10.0.2.0/24"
}

variable "public_subnet_2_name" {
  type        = string
  description = "Name for the public subnet 2"
  default     = "PublicSubnet2"
}

variable "availability_zone_2" {
  type        = string
  description = "The Availability Zone for the public subnet 2"
  default     = "us-east-1b" 
}



#subnet3
variable "subnet_cidr_private_1" {
	description = "CIDR block for private subnet 1"
	type	    = string
	default     = "10.0.3.0/24"
}

variable "private_subnet_1_name" {
  type        = string
  description = "Name for the private subnet 1"
  default     = "PrivateSubnet1"
}



#Subnet4

variable "subnet_cidr_private_2" {
	description = "CIDR block for private subnet 2"
	type	    = string
	default     = "10.0.4.0/24"
}

variable "private_subnet_2_name" {
  type        = string
  description = "Name for the private subnet 2"
  default     = "PrivateSubnet2"
}


variable "availability_zone_3" {
  type        = string
  description = "The Availability Zone for the private subnet 2"
  default     = "us-east-1c" 
}


#Internet gateway
variable "internet_gateway_name" {
  type = string
  description = "Name of the Internet Gateway"
  default = "InternetGateway"
}

#Route to allow all ip addresses
variable "allow_all_ip" {
  type = string
  description = "For allowing all i addresses"
  default = "0.0.0.0/0"
}


#Public Route table
variable "public_route_table_name" {
  type        = string
  description = "Name for the public route table"
  default     = "PublicRouteTable"
}

#NAT gateway
variable "nat_gateway_name" {
  type = string
  description = "Name of the NAT Gateway"
  default = "NATgateway"
}


#Private Route table
variable "private_route_table_name" {
  type        = string
  description = "Name for the private route table"
  default     = "PrivateRouteTable"
}


#Frontend security group

variable "frontend_security_group_name" {
  type        = string
  description = "Name for the Frontend security group"
  default     = "FrontendSecurityGroup"
}

variable "http_port" {
  type        = number
  description = "Http port number"
  default     = 80
}


variable "ssh_port" {
  type        = number
  description = "SSH port number"
  default     = 22
}

variable "django_port" {
  type        = number
  description = "Http port number"
  default     = 8000
}


variable "postgresql_port" {
  type        = number
  description = "Postgresql port number"
  default     = 5432
}


variable "tcp_protocol" {
  type = string
  description = "Tcp protocol"
  default = "tcp"
}


variable "http_protocol" {
  type        = string
  description = "Http protocol"
  default     = "HTTP"
}

variable "ssh_protocol" {
  type        = string
  description = "ssh protocol"
  default     = "ssh"
}

variable "ubuntu_user" {
  type        = string
  description = "User ubuntu"
  default     = "ubuntu"
}

variable "timeout" {
  type    = number
  default = 5
}

variable "interval" {
  type    = number
  default = 30
}

variable "health_threshold" {
  type    = number
  default = 3
}

variable "health_check_type" {
  type    = string
  default = "ELB"
}


variable "grace_period" {
  type    = number
  default = 300
}



#Frontend Instance

variable "frontend_ami_id" {
  description = "AMI ID for the frontend instance"
  type        = string
  default     = "ami-0ef3b570060ceff59" 
}

variable "frontend_name" {
  description = "Name for the frontend instance"
  type        = string
  default     = "FrontendInstance"
}



variable "instance_type" {
  description = "Type of Ec2 instance"
  type        = string
  default     = "t2.micro"
}

variable "key_pair" {
  description = "key pair for instance"
  type        = string
  default     = "script" 
}





#Backend security group

variable "backend_security_group_name" {
  type        = string
  description = "Name for the Backend security group"
  default     = "BackendSecurityGroup"
}


#Backend instance
variable "backend_ami_id" {
  description = "AMI ID for the backend instance"
  type        = string
  default     = "ami-00b2e42f670840de9"  
}

variable "backend_name" {
  description = "Name for the Backend instance"
  type        = string
  default     = "BackendInstance"
}


#Database security

variable "database_security_group_name" {
  type        = string
  description = "Name for the Database security group"
  default     = "DatabaseSG"
}



#Database instance

variable "database_ami_id" {
  description = "AMI ID for the database instance"
  type        = string
   default     = "ami-0866a3c8686eaeeba"
}


variable "database_name" {
  description = "Name for the Database instance"
  type        = string
  default     = "DatabaseInstance"
}

#Frontend Target group
variable "frontend_tg_name" {
  description = "Name for the frontend target group"
  type        = string
  default     = "frontend-tg"

}

variable "frontend_tg_port" {
  description = "Port for the frontend target group"
  type        = number
  default     = 80
}


variable "frontend_tg_protocol" {
  description = "Protocol for the frontend target group"
  type        = string
  default     = "HTTP"
}



#Frontend Load balancer

variable "frontend_lb_name" {
  description = "Name of the frontend load balancer"
  type        = string
  default     = "frontend-lb"
}


variable "load_balancer_type" {
  description = "type of load balancer"
  type        = string
  default     = "application"
}

#Backend Target group
variable "backend_tg_name" {
  description = "Name for the backend target group"
  type        = string
  default     = "backend-tg"

}


#Backend Load balancer

variable "backend_lb_name" {
  description = "Name of the backend load balancer"
  type        = string
  default     = "backend-lb"
}


variable "desired" {
  type    = number
  default = 2
}

variable "max_size" {
  type    = number
  default = 4
}

variable "min_size" {
  type    = number
  default = 1
}


variable "target_value" {
  type    = string
  default = "50.0"
}

variable "metric_type" {
  type    = string
  default = "ASGAverageCPUUtilization"
}


variable "frontend_asg_name" {
  type = string
  default = "Frontend-ASG"
}

variable "frontend_asg_instance" {
  type = string
  default = "frontend-auto"
}



variable "backend_asg_name" {
  description = "Name of the Backend Auto Scaling Group"
  type        = string
  default     = "Backend-ASG"
}

variable "backend_asg_instance" {
  type = string
  default = "backend-auto"
}
