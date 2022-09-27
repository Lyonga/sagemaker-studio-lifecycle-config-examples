resource "aws_instance" "data-science-ec2" {
  ami           =      var.instance_ami
  instance_type    =   var.instance_type
  availability_zone  = var.instance_availability_zone
  monitoring        =   var.instance_monitoring
  ebs_optimized    =   var.instance_ebs_optimized
  subnet_id        =   var.private_subnet_id
  associate_public_ip_address = var.instance_associate_public_ip_address
  key_name               = var.instance_key_name
  security_groups        = [aws_security_group.data-science-security.id]
  iam_instance_profile   = aws_iam_instance_profile.data-science-profile.name
  disable_api_termination =  true
  instance_initiated_shutdown_behavior = "stop"

 root_block_device {
      delete_on_termination = true
      volume_size           = 1000
      volume_type           = "gp2"
      encrypted             = true
    }
  tags = merge(
    {
      Name = "${var.account_code}-ec2-${var.env}-data-science-${var.domain}-${var.category}-${var.region_code}-${var.az_zone}"
    },
    var.tags
  )
lifecycle {
    ignore_changes = [
      disable_api_termination, ebs_optimized, hibernation, security_groups, monitoring, associate_public_ip_address, root_block_device,
      credit_specification, network_interface, ephemeral_block_device, iam_instance_profile
      ]
  }
}

resource "aws_eip" "ds_eip" {
  instance = aws_instance.data-science-ec2.id
  vpc      = true
  tags = merge(
    {  
     Name  = "${var.account_code}-eip-${var.env}-data-science-${var.domain}-${var.category}-${var.region_code}-${var.az_zone}"
    },
    var.tags
  )
}
# AWS EBS volume
resource "aws_ebs_volume" "data-science-ebs" {
  availability_zone = var.ebs_volume_availability_zone
  type              = var.ebs_volume_type
  size              = var.ebs_volume_size
  encrypted         = true

  tags = merge(
    {
      Name = "${var.account_code}-ebs-${var.env}-data-science-${var.domain}-${var.category}-${var.region_code}-${var.az_zone}"
    },
    var.tags
  )

lifecycle {
    ignore_changes = [
      tags, availability_zone
      ]
  }
  depends_on = [aws_instance.data-science-ec2]
}

resource "aws_volume_attachment" "ebs_volume_attachment" {
  device_name = var.ebs_volume_attachment_device_name
  instance_id = aws_instance.data-science-ec2.id
  volume_id   = aws_ebs_volume.data-science-ebs.id
  force_detach = var.ebs_volume_attachment_force_detach

  lifecycle {
    create_before_destroy = true
    ignore_changes        = []
  }

  depends_on = [
    aws_ebs_volume.data-science-ebs
  ]
}
resource "aws_cloudwatch_dashboard" "dashboard" {
  dashboard_name = "${var.account_code}-CW-${var.env}-data-science-${var.domain}-${var.category}-${var.region_code}-${var.az_zone}"
  dashboard_body = <<EOF
{
  "widgets": [
    {
      "type": "metric",
      "x": 0,
      "y": 0,
      "width": 12,
      "height": 6,
      "properties": {
        "metrics": [
          [
            "AWS/EC2",
            "CPUUtilization",
            "InstanceId",
            "aws_instance.data-science-ec2.id"
          ]
        ],
        "period": 3600,
        "stat": "Average",
        "region": "us-east-1",
        "title": "EC2 Instance CPU"
      }
    },
    {
      "type": "text",
      "x": 0,
      "y": 7,
      "width": 3,
      "height": 3,
      "properties": {
        "markdown": "Hello world"
      }
    }
  ]
}
EOF
}

resource "aws_cloudwatch_metric_alarm" "data-science-alarm" {
  alarm_name                = "${var.account_code}-CW-alarm-${var.env}-data-science-${var.domain}-${var.category}-${var.region_code}-${var.az_zone}"
  comparison_operator       = "LessThanOrEqualToThreshold"
  evaluation_periods        = "2"
  metric_name               = "CPUUtilization"
  namespace                 = "AWS/EC2"
  period                    = "3600"
  statistic                 = "Average"
  threshold                 = "3"
  alarm_description         = "This metric monitors ec2 cpu utilization below 3%"
  insufficient_data_actions = []
  treat_missing_data         = "notBreaching"
  #alarm_actions             = [aws_sns_topic.ds-topic.arn, "arn:aws:automate:${var.region}:ec2:stop"]
  alarm_actions             = [aws_sns_topic.ds-topic.arn]
  depends_on = [aws_instance.data-science-ec2]
  dimensions = {
        InstanceId = aws_instance.data-science-ec2.id
        }
}

resource "aws_sns_topic" "ds-topic" {
  name              = "${var.account_code}-sns-${var.env}-data-science-${var.domain}-${var.category}-${var.region_code}-${var.az_zone}"
  delivery_policy   = <<EOF
{
  "http": {
    "defaultHealthyRetryPolicy": {
      "minDelayTarget": 20,
      "maxDelayTarget": 20,
      "numRetries": 3,
      "numMaxDelayRetries": 0,
      "numNoDelayRetries": 0,
      "numMinDelayRetries": 0,
      "backoffFunction": "linear"
    },
    "disableSubscriptionOverrides": false,
    "defaultThrottlePolicy": {
      "maxReceivesPerSecond": 1
    }
  }
}
EOF
}
resource "aws_sns_topic_subscription" "ds_topic_subscription" {
  topic_arn = aws_sns_topic.ds-topic.arn
  protocol = "email"
  endpoint = var.your_email

  lifecycle {
    create_before_destroy = true
    ignore_changes        = []
  }

  depends_on = [
    aws_sns_topic.ds-topic
  ]
}

resource "aws_security_group" "data-science-security" {
  name        = "${var.account_code}-${var.env}-ds-security-${var.domain}-${var.category}-${var.region}"
  
  description = "Security Group for NFS File Gateway."
  vpc_id      = data.terraform_remote_state.databricks_vpc.outputs.vpc_id
  tags = merge(
    {
      Name = "${var.account_code}-${var.env}-ds-security-${var.domain}-${var.category}-${var.region}"
    },
    var.tags
  )
  dynamic "ingress" {
    for_each = var.inbound_tcp_ports
    content {
      from_port = ingress.value
      to_port = ingress.value
      protocol = "tcp"
      cidr_blocks = concat(
        sort(module.ip-allow-list.omf_enterprise_internal_cidr_list),
        sort(keys(module.ip-allow-list.zscaler_cidrs)))
    }
  }
 
  /*dynamic "egress" {
    for_each = var.outbound_tcp_ports
    content {
      from_port = egress.value
      to_port = egress.value
      protocol = "tcp"
      cidr_blocks = concat(
        sort(module.ip-allow-list.omf_enterprise_internal_cidr_list),
        sort(keys(module.ip-allow-list.zscaler_cidrs)))
    }
  }*/

  // Allow all egress
  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_iam_instance_profile" "data-science-profile" {
  name = "${var.account_code}-instance_profile-${var.env}-data-science-${var.domain}-${var.category}-${var.region_code}-all"
  
  role = aws_iam_role.data-science-role.name
  depends_on = [
    aws_iam_role.data-science-role
  ]
}
resource "aws_s3_bucket" "data-science-storage" {
  bucket = "${var.account_code}-s3-${var.env}-data-science-${var.domain}-${var.category}-${var.region_code}-all"

  tags = merge(
    var.tags,
    {
      name = "${var.account_code}-s3-${var.env}-data-science-${var.domain}-${var.category}-${var.region_code}-all"
    }
  )
    server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

}
resource "aws_s3_bucket_public_access_block" "data-science-storage" {
  bucket = aws_s3_bucket.data-science-storage.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
  depends_on = [aws_s3_bucket.data-science-storage]
}
resource "aws_iam_role" "data-science-role" {
  name = "${var.account_code}-iam_role-${var.env}-data-science-${var.domain}-${var.category}-${var.region_code}-all"
  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "sts:AssumeRole",
            "Principal": {
               "Service": "ec2.amazonaws.com"
            },
            "Effect": "Allow",
            "Sid": ""
        }
    ]
}
EOF
}


resource "aws_iam_role_policy" "data-science-policy" {
  name     =   "${var.account_code}-iam_policy-${var.env}-data-science-${var.domain}-${var.category}-${var.region_code}-all"
  role     =   aws_iam_role.data-science-role.id
  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "AllowS3BucketsDataBricks",
            "Effect": "Allow",
            "Action": [
                "s3:ListBucket"
            ],
            "Resource": [
                "arn:aws:s3:::oedsd-s3-dev-data-science-omf-ec2-ue1-all",
                "arn:aws:s3:::oedsd-dev-s3-dl-sandbox-data-science-useast1-all"                
            ]
        },
        {
            "Sid": "AllowS3ObjectsDataBricks",
            "Effect": "Allow",
            "Action": [
                "s3:PutObject",
                "s3:GetObject",
                "s3:PutObjectAcl"
            ],
            "Resource": [
                "arn:aws:s3:::oedsd-s3-dev-data-science-omf-ec2-ue1-all/*",
                "arn:aws:s3:::oedsd-dev-s3-dl-sandbox-data-science-useast1-all" 
            ]
        },
        {
            "Sid": "AllowDeleteS3ObjectsDataBricks",

            "Effect": "Allow",

            "Action": [
                "s3:DeleteObject"
            ],
            "Resource": [
                "arn:aws:s3:::oedsd-s3-dev-data-science-omf-ec2-ue1-all/*" ,
                "arn:aws:s3:::oedsd-dev-s3-dl-sandbox-data-science-useast1-all"    
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "ssm:DescribeAssociation",
                "ssm:GetDeployablePatchSnapshotForInstance",
                "ssm:GetDocument",
                "ssm:DescribeDocument",
                "ssm:GetManifest",
                "ssm:GetParameter",
                "ssm:GetParameters",
                "ssm:ListAssociations",
                "ssm:ListInstanceAssociations",
                "ssm:PutInventory",
                "ssm:PutComplianceItems",
                "ssm:PutConfigurePackageResult",
                "ssm:UpdateAssociationStatus",
                "ssm:UpdateInstanceAssociationStatus",
                "ssm:UpdateInstanceInformation"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "ssmmessages:CreateControlChannel",
                "ssmmessages:CreateDataChannel",
                "ssmmessages:OpenControlChannel",
                "ssmmessages:OpenDataChannel"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "ec2messages:AcknowledgeMessage",
                "ec2messages:DeleteMessage",
                "ec2messages:FailMessage",
                "ec2messages:GetEndpoint",
                "ec2messages:GetMessages",
                "ec2messages:SendReply"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "cloudwatch:PutMetricData",
                "ec2:DescribeVolumes",
                "ec2:DescribeTags",
                "logs:PutLogEvents",
                "logs:DescribeLogStreams",
                "logs:DescribeLogGroups",
                "logs:CreateLogStream",
                "logs:CreateLogGroup"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "ssm:GetParameter"
            ],
            "Resource": "arn:aws:ssm:*:*:parameter/AmazonCloudWatch-*"
        }
    ]
}
EOF
}

# AWS EFS file system
resource "aws_efs_file_system" "ds_efs_file_system" {
  creation_token   = var.efs_file_system_creation_token
  encrypted        = var.efs_file_system_encrypted
  kms_key_id       = var.efs_file_system_kms_key_id
  performance_mode = var.efs_file_system_performance_mode

  throughput_mode  = var.efs_file_system_throughput_mode
  tags = merge(
    {
      Name = "${var.account_code}-efs-${var.env}-data-science-${var.domain}-${var.category}-${var.region_code}-${var.az_zone}"
    },
    var.tags
  )

  lifecycle_policy {
    transition_to_ia = "AFTER_30_DAYS"
  }


}

#--mount target
resource "aws_efs_mount_target" "efs_mount_target" {
  count   = var.subnet_counts
  file_system_id  = aws_efs_file_system.ds_efs_file_system.id
  subnet_id       = var.efs_mount_target_subnet_ids[count.index]
  #ip_address      = var.efs_mount_target_ip_address
  security_groups = [aws_security_group.efs_security_grp.id]

  lifecycle {
    create_before_destroy = true
    ignore_changes        = []
  }

  depends_on = [
    aws_efs_file_system.ds_efs_file_system
  ]
}
/*
#efs policy
resource "aws_efs_file_system_policy" "efs_policy" {
  file_system_id = aws_efs_file_system.ds_efs_file_system.id
  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Id": "Policy01",
    "Statement": [
        {
            "Sid": "Statement01",
            "Effect": "Allow",
            "Principal": {
                "AWS": "*"
            },
            "Resource": "${aws_efs_file_system.ds_efs_file_system.arn}",
            "Action": [
                "elasticfilesystem:ClientRootAccess",
                "elasticfilesystem:ClientMount",
                "elasticfilesystem:ClientWrite"
            ],
            "Condition": {
                "Bool": {
                    "aws:SecureTransport": "true"
                }
            }
        }
    ]
}
POLICY
}
*/
resource "aws_efs_backup_policy" "data_science_policy" {
  file_system_id = aws_efs_file_system.ds_efs_file_system.id

  backup_policy {
    status = "ENABLED"
  }
}

resource "aws_security_group" "efs_security_grp" {
   name = "${var.account_code}-efs-security-group-${var.env}-data-science-${var.domain}-${var.category}-${var.region_code}-all"
   description = "Allows inbound efs traffic from ec2"
   vpc_id     =  data.terraform_remote_state.dfp-datajobs-vpc.outputs.vpc_id
   tags = merge(
    {
      name = "${var.account_code}-efs-security-group-${var.env}-data-science-${var.domain}-${var.category}-${var.region_code}-all"
    },
    var.tags
  )
    /* 
 ingress {
     security_groups = ["sg-01117e0d446e4e6d8"]
     from_port = 2049
     to_port = 2049 
     protocol = "tcp"
   }
  */
  dynamic "ingress" {

  }    
  
 dynamic "egress" {

  }
 }


