//to print out public ip
output "jenkins_ip" {
  value = aws_instance.jenkins.public_ip
}

output "prod_ip" {
  value = aws_instance.prod.public_ip
}