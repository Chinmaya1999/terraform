resource "aws_vpc" "myvpc" {
  cidr_block = var.cidr_block
  
  tags = {
    Name = "main-vpc"
  }
}

resource "aws_subnet" "sub1" {
  vpc_id     = aws_vpc.myvpc.id
  cidr_block = var.subnet_cidr1
  availability_zone = var.az1
  map_public_ip_on_launch = true
  
  tags = {
    Name = "public-subnet-1"
  }
}

resource "aws_subnet" "sub2" {
  vpc_id     = aws_vpc.myvpc.id
  cidr_block = var.subnet_cidr2
  availability_zone = var.az2
  map_public_ip_on_launch = true
  
  tags = {
    Name = "public-subnet-2"
  }
}


resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.myvpc.id
  
  tags = {
    Name = "my-igw"
  }
}

resource "aws_route_table" "RT" {
  vpc_id = aws_vpc.myvpc.id
  
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  
  tags = {
    Name = "my-rt"
  }
}


resource "aws_route_table_association" "rta1" {
  subnet_id = aws_subnet.sub1.id
  route_table_id = aws_route_table.RT.id
}

resource "aws_route_table_association" "rta2" {
  subnet_id = aws_subnet.sub2.id
  route_table_id = aws_route_table.RT.id
}

resource "aws_security_group" "web-sg" {
  name = "web-sg"
  description = "Security group for web servers"
  vpc_id = aws_vpc.myvpc.id
  
  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  tags = {
    Name = "web-sg"
  }
}

resource "aws_s3_bucket" "mybucket" {
  bucket = var.bucket_name
  tags = {
    Name = var.bucket_name
  }
}

resource "aws_instance" "webserver1" {
  ami = var.ami
  instance_type = var.instance_type
  subnet_id = aws_subnet.sub1.id
  vpc_security_group_ids = [aws_security_group.web-sg.id]

   user_data = base64encode(file(var.user_data1))

  
  tags = {
    Name = "web"
  }
}

resource "aws_instance" "webserver2" {
  ami = var.ami
  instance_type = var.instance_type
  subnet_id = aws_subnet.sub2.id
  vpc_security_group_ids = [aws_security_group.web-sg.id]
  
  user_data = base64encode(file(var.user_data2))
  
  tags = {
    Name = "web2"
  }
  
}

resource "aws_lb" "mylb" {
  name = "my-lb"
  load_balancer_type = "application"
  security_groups = [aws_security_group.web-sg.id]
  subnets = [aws_subnet.sub1.id, aws_subnet.sub2.id]
  
  tags = {
    Name = "my-lb"
  }
}


resource "aws_lb_target_group" "tg" {
  name = "my-tg"
  port = 80
  protocol = "HTTP"
  vpc_id = aws_vpc.myvpc.id
  
}

resource "aws_lb_target_group_attachment" "tg_attachment1" {
  target_group_arn = aws_lb_target_group.tg.arn
  target_id = aws_instance.webserver1.id
  port = 80
}

resource "aws_lb_target_group_attachment" "tg_attachment2" {
  target_group_arn = aws_lb_target_group.tg.arn
  target_id = aws_instance.webserver2.id
  port = 80
}


resource "aws_lb_listener" "listener" {
  load_balancer_arn = aws_lb.mylb.arn
  port = 80
  protocol = "HTTP"
  
  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.tg.arn
  }
}
