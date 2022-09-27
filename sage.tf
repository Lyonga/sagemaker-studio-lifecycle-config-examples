data "aws_sagemaker_prebuilt_ecr_image" "omf-ds" {
  repository_name = "kmeans"
}


 #AWS sagemaker r-image
 resource "aws_sagemaker_image" "custom-r" {
   image_name = "custom-r"
   role_arn     = aws_iam_role.sagemaker-ds-role.arn
   display_name = var.sagemaker_image_display_name

   tags = merge(
     {
       Name = "${var.account_code}-sagemaker-r-image-${var.env}-data-science-${var.domain}-${var.category}-${var.region_code}-all"
     },
     var.tags
   )

}

# AWS sagemaker app image config
 resource "aws_sagemaker_app_image_config" "omf-ds-image-config" {
   app_image_config_name = "${var.account_code}-custom-r-image-${var.env}-data-science-${var.domain}-${var.category}-${var.region_code}-all"
   kernel_gateway_image_config {
     kernel_spec {
       name = "r"
       display_name = "R (Custom R Image)"
     }
     file_system_config {
       default_gid = 100
       default_uid = 1000
       mount_path  = "/home/sagemaker-user"
    }
   }
 }
 
 resource "aws_sagemaker_image_version" "r-image" {
   image_name = aws_sagemaker_image.custom-r.id
   base_image = "401929272813.dkr.ecr.us-east-1.amazonaws.com/smstudio-custom:r"
 }


# AWS Sagemaker domain
resource "aws_sagemaker_domain" "sagemaker-domain" {
  domain_name             = "${var.account_code}-sagemaker-domain-${var.env}-data-science-${var.domain}-${var.category}-${var.region_code}-all"
  auth_mode               = var.sagemaker_domain_auth_mode
  vpc_id                  = data.terraform_remote_state.datajobs_vpc.outputs.vpc_id
  subnet_ids              = var.sagemaker_domain_subnet_ids
  app_network_access_type = var.vpc_network

  default_user_settings {
    execution_role = aws_iam_role.sagemaker-ds-role.arn

    security_groups = [aws_security_group.sagemaker-ds-security.id, aws_security_group.sage_maker_security_group.id]

    dynamic "sharing_settings" {
      iterator = sharing_settings
      for_each = lookup(var.sagemaker_domain_default_user_settings, "sharing_settings", [])

      content {
        notebook_output_option = lookup(sharing_settings.value, "notebook_output_option", null)
        s3_kms_key_id          = lookup(sharing_settings.value, "s3_kms_key_id", null)
        s3_output_path         = lookup(sharing_settings.value, "s3_output_path", null)
      }
    }
     jupyter_server_app_settings {
       default_resource_spec {
         #instance_type       = "system"
         #sagemaker_image_arn = "arn:aws:sagemaker:us-east-1:401929272813:image/jupyter-server-3"
        }
        lifecycle_config_arns = [aws_sagemaker_studio_lifecycle_config.kgw_lcc.arn]
     }

    kernel_gateway_app_settings {
       default_resource_spec {
          instance_type       = var.instance_type
          sagemaker_image_arn = aws_sagemaker_image.custom-r.arn
       }
       lifecycle_config_arns = [aws_sagemaker_studio_lifecycle_config.kgw_lcc.arn]

       custom_image {
         app_image_config_name = aws_sagemaker_app_image_config.omf-ds-image-config.app_image_config_name
         image_name            = "custom-r"
         image_version_number  = "1"
      }

    }

  }

  tags = merge(
    {
      Name = "${var.account_code}-sagemaker-domain-${var.env}-data-science-${var.domain}-${var.category}-${var.region_code}-all"
    },
    var.tags
  )
  lifecycle {
    create_before_destroy = true
  }
  depends_on = []
}


resource "aws_sagemaker_model" "sagemaker-model" {
  name               = "${var.account_code}-model-${var.env}-data-science-${var.domain}-${var.category}-${var.region_code}-all"
  execution_role_arn = aws_iam_role.sagemaker-ds-role.arn

  primary_container {
    image = data.aws_sagemaker_prebuilt_ecr_image.omf-ds.registry_path
  }

  dynamic "vpc_config" {
    iterator = vpc_config
    for_each = var.sagemaker_model_vpc_config
    content {
      subnets            = var.subnet_id
      security_group_ids = var.security_groups
    }
  }

  tags = merge(
    {
      Name = "${var.account_code}-model-${var.env}-data-science-${var.domain}-${var.category}-${var.region_code}-all"
    },
    var.tags
  )

}

resource "aws_sagemaker_endpoint_configuration" "sagemaker-endpoint-configuration" {
  name = "${var.account_code}-endpt-config-${var.env}-data-science-${var.domain}-${var.category}-${var.region_code}"

  production_variants {
    model_name             = aws_sagemaker_model.sagemaker-model.name
    initial_instance_count = 1
    instance_type          = "ml.g4dn.12xlarge"

    variant_name = "variant-1"
    initial_variant_weight = 1.0
  }

  tags = merge(
    {
      Name = "${var.account_code}-sagemaker-configuration-${var.env}-data-science-${var.domain}-${var.category}-${var.region_code}-all"
    },
    var.tags
  )
  depends_on = [
    aws_sagemaker_model.sagemaker-model
  ]
}

#sagemaker studio lifecycle configuration
resource "aws_sagemaker_studio_lifecycle_config" "js_lcc" {
  studio_lifecycle_config_name     = "${var.account_code}-jupyterserver-${var.env}-data-science-${var.domain}-${var.category}-${var.region_code}-all"
  studio_lifecycle_config_app_type = "JupyterServer"
  studio_lifecycle_config_content  = base64encode(file("${path.module}/scripts/auto_stop.sh"))
  tags = merge(
    {
      Name = "${var.account_code}-sagemaker-studio-jupyterserver-config-${var.env}-data-science-${var.domain}-${var.category}-${var.region_code}-all"
    },
    var.tags
  )

}

resource "aws_sagemaker_studio_lifecycle_config" "kgw_lcc" {
  studio_lifecycle_config_name     = "${var.account_code}-kernelgateway-${var.env}-data-science-${var.domain}-${var.category}-${var.region_code}-all"
  studio_lifecycle_config_app_type = "KernelGateway"
  studio_lifecycle_config_content  = base64encode(file("${path.module}/scripts/auto_stop.sh"))
  tags = merge(
    {
      Name = "${var.account_code}-sagemaker-studio-kernelgateway-config-${var.env}-data-science-${var.domain}-${var.category}-${var.region_code}-all"
    },
    var.tags
  )
}

resource "aws_ecr_repository" "sagemaker" {
  name                 = "${var.account_code}-ecr-${var.env}-data-science-${var.domain}-${var.category}-${var.region_code}-all"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = false
  }
  tags = merge(
    {
      Name = "${var.account_code}-ecr-${var.env}-data-science-${var.domain}-${var.category}-${var.region_code}-all"
    },
    var.tags
  )
}

resource "aws_security_group" "sage_maker_security_group" {
  description = "Permit sagemaker VPC-Only connection"

  ingress {
    cidr_blocks = ["10.29.0.0/19"]
    from_port   = "8192"
    protocol    = "tcp"
    self        = "true"
    to_port     = "65535"
  }

  ingress {
    cidr_blocks = ["10.28.120.0/23"]
    from_port   = "2049"
    protocol    = "tcp"
    self        = "false"
    to_port     = "2049"
  }
  
  ingress {
    cidr_blocks = ["10.29.0.0/19"]
    from_port   = "8192"
    protocol    = "tcp"
    self        = "false"
    to_port     = "65535"
  }

  ingress {
    cidr_blocks = ["10.29.0.0/19"]
    from_port   = "2049"
    protocol    = "tcp"
    self        = "false"
    to_port     = "2049"
  }
    ingress {
    cidr_blocks = ["10.28.120.0/23"]
    from_port   = "8192"
    protocol    = "tcp"
    self        = "true"
    to_port     = "65535"
  }

  ingress {
    cidr_blocks = ["10.28.120.0/23"]
    from_port   = "443"
    protocol    = "tcp"
    self        = "false"
    to_port     = "443"
  }
  
  ingress {
    cidr_blocks = ["10.29.0.0/19"]
    from_port   = "443"
    protocol    = "tcp"
    self        = "true"
    to_port     = "443"
  }

  ingress {
    cidr_blocks = ["10.29.0.0/19"]
    from_port   = "443"
    protocol    = "tcp"
    self        = "false"
    to_port     = "443"
  }

  egress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = "443"
    protocol    = "tcp"
    self        = "false"
    to_port     = "443"
  }

  egress {
    cidr_blocks = ["10.28.112.0/20"]
    from_port   = "8192"
    protocol    = "tcp"
    self        = "false"
    to_port     = "65535"
  }

  egress {
    cidr_blocks = ["10.29.120.0/23"]
    from_port   = "2049"
    protocol    = "tcp"
    self        = "false"
    to_port     = "2049"
  }

  egress {
    cidr_blocks = ["10.29.120.0/23"]
    from_port   = "8192"
    protocol    = "tcp"
    self        = "true"
    to_port     = "65535"
  }
    egress {
    cidr_blocks = ["10.29.120.0/23"]
    from_port   = "8192"
    protocol    = "tcp"
    self        = "false"
    to_port     = "65535"
  }

  egress {
    cidr_blocks = ["10.28.112.0/20"]
    from_port   = "2049"
    protocol    = "tcp"
    self        = "false"
    to_port     = "2049"
  }

  #egress {
  #  cidr_blocks = sort(var.egress_cidr_blocks)
  #  from_port   = "80"
  #  protocol    = "tcp"
  #  self        = "false"
  #  to_port     = "80"
  #}

  tags = merge(
    {
      Name = "${var.account_code}-security_group-${var.env}-data-science-${var.domain}-${var.category}-${var.region_code}-all"
    },
    var.tags
  )

  name   = "sagemaker-staging-security"
  vpc_id      = data.terraform_remote_state.datajobs_vpc.outputs.vpc_id
}

resource "aws_security_group" "sagemaker-ds-security" {
  name        = "${var.account_code}-security_group-${var.env}-data-science-${var.domain}-${var.category}-${var.region_code}-all"
  description = "Security Group for VPC-Only traffic in sagemaker studio."
  vpc_id      = data.terraform_remote_state.datajobs_vpc.outputs.vpc_id
  tags = merge(
    {
      Name = "${var.account_code}-security_group-${var.env}-data-science-${var.domain}-${var.category}-${var.region_code}-all"
    },
    var.tags
  )

  ingress {
    from_port     = "443"
    to_port       = "443"
    protocol      = "tcp"
    self = true
    }
 
  ingress {
    protocol    = "tcp"
    from_port   = 8888
    to_port     = 8898
    self = true
  }

  ingress {
    protocol    = "tcp"
    from_port   = 2049
    to_port     = 2049
    self = true
  }

  // Allow all egress
  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

}




module "ip-allow-list" {
source = "git::https://github.com/omfterraform/terraform-allow-ip-list.git?ref=1.0.30"
}
