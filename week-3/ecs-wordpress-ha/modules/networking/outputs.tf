output "vpc_id" {
  value = module.vpc.vpc_id
}
output "private_subnets" {
  value = module.vpc.private_subnets
}
output "public_subnets" {
  value = module.vpc.public_subnets
}
output "alb_sg_id" {
  value = aws_security_group.alb_sg.id
}
output "ecs_sg_id" {
  value = aws_security_group.ecs_sg.id
}
