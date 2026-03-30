output "load_balancer_dns" {
  value = aws_lb.mylb.dns_name
}

output "instance1_public_ip" {
  value = aws_instance.webserver1.public_ip
}

output "instance2_public_ip" {
  value = aws_instance.webserver2.public_ip
}