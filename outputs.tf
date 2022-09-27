output "instance_id" {
  description = "ID of ec2 instance"
  value       = aws_instance.data-science-ec2.id
}

output "availability_zone" {
  description = "List of availability zones of instances"
  value       = aws_instance.data-science-ec2.availability_zone
}

output "private_dns" {
  description = "List of private DNS names assigned to the instances. Can only be used inside the Amazon EC2, and only available if you've enabled DNS hostnames for your VPC"
  value       = aws_instance.data-science-ec2.private_dns
}

output "private_ip" {
  description = "List of private IP addresses assigned to the instances"
  value       = aws_instance.data-science-ec2.private_ip
}
output "instance_arn" {
  description = "The ARN of the created EC2 File Gateway instance."
  value       = aws_instance.data-science-ec2.arn
}

output "security_groups" {
  description = "List of associated security groups of instances"
  value       = aws_instance.data-science-ec2.*.security_groups
}

output "vpc_security_group_ids" {
  description = "List of associated security groups of instances, if running in non-default VPC"
  value       = aws_instance.data-science-ec2.*.vpc_security_group_ids
}

output "tags" {
  description = "List of tags of instances"
  value       = aws_instance.data-science-ec2.*.tags
}
output "eip_public_ip" {
  description     = "public IP of EIP"
  value       = aws_eip.ds_eip
}
#for cloudwatch
output "cw_metric_alarm_arn" {
  description = "The ARN of the Cloudwatch metric alarm."
  value       = aws_cloudwatch_metric_alarm.data-science-alarm.arn
}

output "cw_metric_alarm_id" {
  description = "The ID of the Cloudwatch metric alarm."
  value       = aws_cloudwatch_metric_alarm.data-science-alarm.id
}

#for SNS
output "sns_topic_id" {
  description = "The ARN of the SNS topic"
  value       = aws_sns_topic.ds-topic.id
}

output "sns_topic_arn" {
  description = "The ARN of the SNS topic, as a more obvious property (clone of id)"
  value       = aws_sns_topic.ds-topic.arn
}
#FOR S3
output "s3_bucket_arn" {
  description = "The ARN of the s3 bucket)"
  value       = aws_s3_bucket.data-science-storage.arn
}

output "s3_bucket_id" {
  description = "ID of the s3 bucket)"
  value       = aws_s3_bucket.data-science-storage.id
}
output "s3_bucket_bucket_domain_name" {
  description = "The bucket domain name. Will be of format bucketname.s3.amazonaws.com."
  value       = aws_s3_bucket.data-science-storage.bucket_domain_name
}

# IAM role
output "iam_role_arn" {
  description = "The Amazon Resource Name (ARN) specifying the role."
  value       = aws_iam_role.data-science-role.arn
}

output "iam_role_name" {
  description = "The name of the role."
  value       = aws_iam_role.data-science-role.name
}

output "iam_role_id" {
  value       = aws_iam_role.data-science-role.id
}
# IAM instance profile
output "instance_profile_id" {
  value       = aws_iam_instance_profile.data-science-profile.id
}

output "instance_profile_arn" {
  value       = aws_iam_instance_profile.data-science-profile.arn
}

output "instance_profile_name" {
  value       = aws_iam_instance_profile.data-science-profile.name
}

# EBS volume
output "ebs_volume_id" {
  value       = aws_ebs_volume.data-science-ebs.id
}

output "ebs_volume_arn" {
  value       = aws_ebs_volume.data-science-ebs.arn
}

output "ebs_volume_attachment_device_name" {
  value       = aws_volume_attachment.ebs_volume_attachment.device_name
}

output "ebs_volume_attachment_instance_id" {
  value       = aws_volume_attachment.ebs_volume_attachment.instance_id
}

output "ebs_volume_attachment_volume_id" {
  value       = aws_ebs_volume.data-science-ebs.id
}

#Security group
output "security_group_id" {
  value      = aws_security_group.data-science-security.id
}

output "iam_role_policy_name" {
  value       = aws_iam_role_policy.data-science-policy.name
}


# AWS EFS file system
output "efs_file_system_id" {
  description = "The ID that identifies the file system (e.g. fs-ccfc0d65)."
  value       = aws_efs_file_system.ds_efs_file_system.id
}

output "efs_file_system_arn" {
  description = "Amazon Resource Name of the file system."
  value       = aws_efs_file_system.ds_efs_file_system.arn
}

output "efs_file_system_kms_key_id" {
  description = ""
  value       = aws_efs_file_system.ds_efs_file_system.kms_key_id
}

output "efs_file_system_dns_name" {
  description = "The DNS name for the filesystem per documented convention."
  value       = aws_efs_file_system.ds_efs_file_system.dns_name
}
/*
# AWS EFS mount target
output "efs_mount_target_id" {
  description = "The ID of the mount target."
  value       = aws_efs_mount_target.efs_mount_target.id[count.index]
}*/

  
# AWS sagemaker model
output "sagemaker_model_id" {
  value = aws_sagemaker_model.sagemaker-model.id
}

output "sagemaker_model_name" {
  value = aws_sagemaker_model.sagemaker-model.name
}

output "sagemaker_model_arn" {
  value = aws_sagemaker_model.sagemaker-model.arn
}

# # AWS Sagemaker domain
# output "sagemaker_domain_id" {
#   value = aws_sagemaker_domain.sagemaker-domain.id
# }

# output "sagemaker_domain_arn" {
#   value = aws_sagemaker_domain.sagemaker-domain.arn
# }
#
# output "sagemaker_domain_url" {
#   value = aws_sagemaker_domain.sagemaker-domain.url
# }
#
# output "sagemaker_domain_single_sign_on_managed_application_instance_id" {
#   value = aws_sagemaker_domain.sagemaker-domain.single_sign_on_managed_application_instance_id
# }
#
# output "sagemaker_domain_home_efs_file_system_id" {
#   value = aws_sagemaker_domain.sagemaker-domain.home_efs_file_system_id
# }


#Execution Role
output "iam_role_arn" {
  value = aws_iam_role.sagemaker-ds-role.arn
}

output "iam_role_name" {
  value = aws_iam_role.sagemaker-ds-role.name
}

output "policy_attachment_id" {
  value = aws_iam_role_policy_attachment.sagemaker-ds-attachment.id
}
output "iam_role_policy_attachment_policy_arn" {
  value = aws_iam_role_policy_attachment.sagemaker-ds-attachment.policy_arn
}
output "iam_policy_name" {
  value = aws_iam_policy.sagemaker-ds-policy.name
}
output "iam_policy_arn" {
  value = aws_iam_policy.sagemaker-ds-policy.arn
}

#Security group
output "security_group_id" {
  value      = aws_security_group.sagemaker-ds-security.id
}
/*
output "topic_arn" {
  value = aws_sns_topic.sagemaker-topic.arn
}
*/
