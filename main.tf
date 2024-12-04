terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.67.0"
    }
  }
}

#AWS provider
provider "aws" {
  region     = var.region
  access_key = var.access_key
  secret_key = var.secrete_key
}




#VPC
resource "aws_vpc" "my_vpc" {
  cidr_block = var.vpc_cidr
  tags = {
    Name = var.vpc_name
  }
}


#PublicSubnet1
resource "aws_subnet" "public_subnet_1" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = var.subnet_cidr_public_1
  map_public_ip_on_launch = true
  availability_zone = var.availability_zone_1

  tags = {
    Name = var.public_subnet_1_name
  }
}



#PublicSubnet2
resource "aws_subnet" "public_subnet_2" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = var.subnet_cidr_public_2
  map_public_ip_on_launch = true
  availability_zone = var.availability_zone_2

  tags = {
    Name = var.public_subnet_2_name
  }
}



#PrivateSubnet1
resource "aws_subnet" "private_subnet_1" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = var.subnet_cidr_private_1
  availability_zone = var.availability_zone_2

  tags = {
    Name = var.private_subnet_1_name
  }
}



#PrivateSubnet2
resource "aws_subnet" "private_subnet_2" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = var.subnet_cidr_private_2
  availability_zone = var.availability_zone_3

  tags = {
    Name = var.private_subnet_2_name
  }
}



#InternetGateway
resource "aws_internet_gateway" "my_igw" {
  vpc_id = aws_vpc.my_vpc.id

  tags = {
    Name = var.internet_gateway_name
  }
}



#PublicRouteTable
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.my_vpc.id

  route{
     cidr_block = var.allow_all_ip
     gateway_id = aws_internet_gateway.my_igw.id
  }

  tags = {
	Name = var.public_route_table_name
  }
}


#Associating public subnets to public route table
resource "aws_route_table_association" "public_route_assoc_1" {
  subnet_id      = aws_subnet.public_subnet_1.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table_association" "public_route_assoc_2" {
  subnet_id      = aws_subnet.public_subnet_2.id
  route_table_id = aws_route_table.public_route_table.id
}

#Allocating elastic ip for NAT 
resource "aws_eip" "elastic_ip"{
  vpc = true
}


#NAT gateway
resource "aws_nat_gateway" "nat_gateway" {
  allocation_id = aws_eip.elastic_ip.id
  subnet_id = aws_subnet.public_subnet_2.id

  tags = {
	Name = var.nat_gateway_name
	}
}



#PrivateRouteTable
resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.my_vpc.id

  route{
     cidr_block = var.allow_all_ip
     nat_gateway_id = aws_nat_gateway.nat_gateway.id
  }

  tags = {
        Name = var.private_route_table_name
  }
}


#Associating private subnets to private route table
resource "aws_route_table_association" "private_route_assoc_1" {
  subnet_id      = aws_subnet.private_subnet_1.id
  route_table_id = aws_route_table.private_route_table.id
}

resource "aws_route_table_association" "private_route_assoc_2" {
  subnet_id      = aws_subnet.private_subnet_2.id
  route_table_id = aws_route_table.private_route_table.id
}



#Security group for frontend instance

resource "aws_security_group" "frontend_sg" {
  vpc_id = aws_vpc.my_vpc.id

  ingress {
    from_port   = var.http_port
    to_port     = var.http_port
    protocol    = var.tcp_protocol
    cidr_blocks = [var.allow_all_ip]  
  }

ingress {
    from_port   = var.ssh_port
    to_port     = var.ssh_port
    protocol    = var.tcp_protocol
    cidr_blocks = [var.allow_all_ip]  
  }

ingress {
    from_port   = var.django_port
    to_port     = var.django_port
    protocol    = var.tcp_protocol
    cidr_blocks = [var.allow_all_ip]  
  }

egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"  
    cidr_blocks = [var.allow_all_ip]  
  }

tags = {
    Name = var.frontend_security_group_name
  }
}


#Frontend instance
resource "aws_instance" "frontend" {
  ami           = var.frontend_ami_id
  instance_type = var.instance_type
  subnet_id     = aws_subnet.public_subnet_1.id
  key_name      = var.key_pair
  security_groups = [aws_security_group.frontend_sg.id]

  tags = {
    Name = var.frontend_name
  }

    provisioner "remote-exec" {
    inline = [
        
      "sudo sed -i 's|server_name .*|server_name ${aws_lb.frontend_lb.dns_name};|' /etc/nginx/sites-available/fundoo.conf",
      "sudo sed -i 's|proxy_pass .*|proxy_pass http://${aws_lb.backend_lb.dns_name}:8000;|' /etc/nginx/sites-available/fundoo.conf",   

      "sudo rm -f /etc/nginx/sites-enabled/fundoo.conf",
     
      "sudo ln -s /etc/nginx/sites-available/fundoo.conf /etc/nginx/sites-enabled/",
      "sudo systemctl restart nginx" 
    ]

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("C:/Users/DELL/Downloads/script.pem")
      host        = self.public_ip
    }
  }
}




#Backend security group
resource "aws_security_group" "backend_sg" {
  vpc_id = aws_vpc.my_vpc.id

  ingress {
    from_port   = var.ssh_port
    to_port     = var.ssh_port
    protocol    = var.tcp_protocol
    cidr_blocks = [var.allow_all_ip]
  }

  ingress {
    from_port   = var.django_port
    to_port     = var.django_port
    protocol    = var.tcp_protocol
    cidr_blocks = [var.allow_all_ip]
  }

  ingress {
    from_port   = var.postgresql_port
    to_port     = var.postgresql_port
    protocol    = var.tcp_protocol
    cidr_blocks = [var.allow_all_ip]
  }

 egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.allow_all_ip]
  }

tags = {
    Name = var.backend_security_group_name
  }
}


#Backend Instance
  resource "aws_instance" "backend" {
  ami             = var.backend_ami_id
  instance_type   = var.instance_type
  key_name      = var.key_pair
  subnet_id       = aws_subnet.private_subnet_1.id  
  security_groups = [aws_security_group.backend_sg.id]


  provisioner "remote-exec" {
    inline = [
      "sudo sed -i 's/DB_HOST=.*/DB_HOST=${aws_instance.database.private_ip}/' /etc/fundoo/env.conf",
      "sudo -u pushpa bash -c 'source ~/myenv/bin/activate && cd /Aws_test/fundoo_notes && python3 manage.py makemigrations && python3 manage.py migrate'",


      "sudo systemctl restart fundoo.service"
    ]

  connection {
      type               = var.ssh_protocol
      user               = var.ubuntu_user
      private_key        = file("C:/Users/DELL/Downloads/script.pem")
      host               = self.private_ip
      bastion_host       = aws_instance.frontend.public_ip
      bastion_private_key = file("C:/Users/DELL/Downloads/script.pem")
      }
}

  tags = {
    Name = var.backend_name
  }
}



#Database security group
resource "aws_security_group" "database_sg" {
  vpc_id = aws_vpc.my_vpc.id

  ingress {
    from_port   = var.ssh_port
    to_port     = var.ssh_port
    protocol    = var.tcp_protocol
    cidr_blocks = [var.allow_all_ip]
  }

  ingress {
    from_port   = var.postgresql_port
    to_port     = var.postgresql_port
    protocol    = var.tcp_protocol
    cidr_blocks = [var.allow_all_ip]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.allow_all_ip]
  }

  tags = {
    Name = var.database_security_group_name
  }
}

#Database instance
  resource "aws_instance" "database" {
  ami           = var.database_ami_id
  instance_type = var.instance_type
  subnet_id     = aws_subnet.private_subnet_2.id
  key_name      = var.key_pair
  security_groups = [aws_security_group.database_sg.id]

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update -y",
      "sudo apt-get install postgresql postgresql-contrib -y",
      "sudo -u postgres psql -c \"CREATE USER pushpa WITH PASSWORD 'root';\"",
      "sudo -u postgres psql -c \"CREATE DATABASE pushpadb OWNER pushpa;\"",

      "sudo sed -i \"s/#listen_addresses = 'localhost'/listen_addresses = '*'/g\" /etc/postgresql/16/main/postgresql.conf",

      "sudo bash -c 'echo \"host    all             all             0.0.0.0/0               md5\" >> /etc/postgresql/16/main/pg_hba.conf'",

      "sudo systemctl restart postgresql"
    ]

  connection {
      type                = var.ssh_protocol
      user                = var.ubuntu_user
      private_key         = file("C:/Users/DELL/Downloads/script.pem")
      host                = self.private_ip
      bastion_host        = aws_instance.frontend.public_ip
      bastion_private_key = file("C:/Users/DELL/Downloads/script.pem")
      }
  }

     tags = {
    Name = var.database_name
  }
}





#Frontend Target group
resource "aws_lb_target_group" "frontend_tg" {
  name     = var.frontend_tg_name
  port     = var.frontend_tg_port
  protocol = var.frontend_tg_protocol
  vpc_id   = aws_vpc.my_vpc.id

  health_check {
    path                = "/"
    protocol            = var.http_protocol
    interval            = var.interval
    timeout             = var.timeout
    healthy_threshold   = var.health_threshold
    unhealthy_threshold = var.health_threshold
  }

}

#Frontend Load Balancer

resource "aws_lb" "frontend_lb" {
  name               = var.frontend_lb_name
  internal           = false
  load_balancer_type = var.load_balancer_type
  security_groups    = [aws_security_group.frontend_sg.id]
  subnets            = [aws_subnet.public_subnet_1.id, aws_subnet.public_subnet_2.id]

  
}


#Frontend Listner
resource "aws_lb_listener" "frontend_listener" {
  load_balancer_arn = aws_lb.frontend_lb.arn
  port              = var.http_port
  protocol          = var.http_protocol

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.frontend_tg.arn
  }
}

#Register targets as Frontend instance

resource "aws_lb_target_group_attachment" "frontend_attachment" {
  target_group_arn = aws_lb_target_group.frontend_tg.arn
  target_id        = aws_instance.frontend.id
  port             = var.http_port
}






#Backtend Target group
resource "aws_lb_target_group" "backend_tg" {
  name     = var.backend_tg_name
  port     = var.django_port
  protocol = var.http_protocol
  vpc_id   = aws_vpc.my_vpc.id

  health_check {
    path                = "/"
    protocol            = var.http_protocol
    interval            = var.interval
    timeout             = var.timeout
    healthy_threshold   = var.health_threshold
    unhealthy_threshold = var.health_threshold
  }

}


#Backend Load balancer
resource "aws_lb" "backend_lb" {
  name               = var.backend_lb_name
  internal           = true  
  load_balancer_type = var.load_balancer_type
  security_groups    = [aws_security_group.backend_sg.id]
  subnets            = [aws_subnet.private_subnet_1.id, aws_subnet.private_subnet_2.id]

}


#Backend Listener
resource "aws_lb_listener" "backend_listener" {
  load_balancer_arn = aws_lb.backend_lb.arn
  port              = var.django_port
  protocol          = var.http_protocol

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.backend_tg.arn
  }
}


#Register target Backend Instance
resource "aws_lb_target_group_attachment" "backend_targets" {
  target_group_arn = aws_lb_target_group.backend_tg.arn
  target_id        = aws_instance.backend.id  
  port             = var.django_port
}



#Frontend Launch template
resource "aws_launch_template" "frontend_launch_config" {
  name          = "frontend-launch-config"
  image_id      = var.frontend_ami_id
  instance_type = var.instance_type
  key_name      = var.key_pair

network_interfaces {
  security_groups = [aws_security_group.frontend_sg.id]
}

}


#Frontend auto scaling
resource "aws_autoscaling_group" "frontend_asg" {
 name                  = var.frontend_asg_name 
 desired_capacity      = var.desired  
  max_size             = var.max_size
  min_size             = var.min_size
  
  launch_template {
    id      = aws_launch_template.frontend_launch_config.id
    version = "$Latest"
  }

  vpc_zone_identifier  = [aws_subnet.public_subnet_1.id, aws_subnet.public_subnet_2.id]
 
  target_group_arns    = [aws_lb_target_group.frontend_tg.arn]
  

  tag {
    key                 = "Name"
    value               = var.frontend_asg_instance
    propagate_at_launch = true
  }

  health_check_type         = var.health_check_type
  health_check_grace_period = var.grace_period
   
 
  lifecycle {
    create_before_destroy = true
  }

}


#Frontend auto scaling policy
resource "aws_autoscaling_policy" "frontend_target_tracking_policy" {
  name                   = "frontend-target-tracking-policy"
  autoscaling_group_name   = aws_autoscaling_group.frontend_asg.id
  policy_type            = "TargetTrackingScaling"

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = var.metric_type
    }

    target_value = var.target_value
  }
}





#Backend Launch template
resource "aws_launch_template" "backend_launch_config" {
  name          = "backend-launch-config"
  image_id      = var.backend_ami_id
  instance_type = var.instance_type
  key_name      = var.key_pair

  network_interfaces {
  security_groups = [aws_security_group.backend_sg.id]
 }

}


#Backend auto scaling
resource "aws_autoscaling_group" "backend_asg" {
 name = var.backend_asg_name 
 desired_capacity     = var.desired
  max_size             = var.max_size
  min_size             = var.min_size

  launch_template {
    id      = aws_launch_template.backend_launch_config.id
    version = "$Latest"
  }

  vpc_zone_identifier  = [aws_subnet.private_subnet_1.id, aws_subnet.private_subnet_2.id]

  target_group_arns    = [aws_lb_target_group.backend_tg.arn]


  tag {
    key                 = "Name"
    value               = var.backend_asg_instance
    propagate_at_launch = true
  }

  health_check_type         = var.health_check_type
  health_check_grace_period = var.grace_period

  lifecycle {
    create_before_destroy = true
  }

}



#Backend auto scaling policy
resource "aws_autoscaling_policy" "bacend_target_tracking_policy" {
  name                   = "backend-target-tracking-policy"
  autoscaling_group_name   = aws_autoscaling_group.backend_asg.id
  policy_type            = "TargetTrackingScaling"

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = var.metric_type
    }

    target_value = var.target_value
  }
}










