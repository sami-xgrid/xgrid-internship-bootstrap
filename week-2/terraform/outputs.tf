output "compute_instance_public_ip" {
  description = "The public IP address of the EC2 instance created by the compute module"
  value       = module.compute_module.public_ip

}
