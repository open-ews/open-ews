resource "aws_launch_template" "this" {
  name_prefix   = var.identifier
  image_id      = jsondecode(data.aws_ssm_parameter.this_ami.value).image_id
  instance_type = data.aws_ec2_instance_type.this.instance_type

  iam_instance_profile {
    name = aws_iam_instance_profile.this.name
  }

  network_interfaces {
    associate_public_ip_address = var.associate_public_ip_address
    security_groups             = concat([aws_security_group.this.id], var.security_groups)
  }

  user_data = base64encode(join("\n", [
    "#cloud-config",
    yamlencode({
      # https://cloudinit.readthedocs.io/en/latest/topics/modules.html
      write_files : local.user_data,
      runcmd : [for i, v in local.user_data : v.path]
    })
  ]))

  lifecycle {
    create_before_destroy = true
  }
}
