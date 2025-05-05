module "container_instances" {
  source = "../container_instances"

  identifier       = var.container_instances_name
  vpc              = var.region.vpc
  instance_subnets = var.region.vpc.private_subnets
  cluster_name     = aws_ecs_cluster.this.name
  max_capacity     = (var.webserver_max_tasks * 2) + (var.worker_max_tasks * 2)
}
