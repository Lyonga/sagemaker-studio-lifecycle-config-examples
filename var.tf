


variable "domain" {
  type    = string
  default = "analytics"
}

variable "name" {
  description = "Name to be used on all resources as prefix"
  default     = "data-science"
}

variable "tags" {
  description = "A list of tag blocks. Each element should have keys named key, value, etc."
  type        = map(string)
  default = {
      environment = "stg"
      project     = ""
      created_by  = "terraform"
      CostCenter  = ""
  }
}
#sagemaker model
variable "enable_sagemaker_model" {
  description = "Enable sagemaker model usage"
  default     = true
}

variable "sagemaker_model_name" {
  description = "The name of the model (must be unique). If omitted, Terraform will assign a random, unique name."
  default     = "ds_model"
}


# AWS Sagemaker endpoint configuration
variable "enable_sagemaker_endpoint_configuration" {
  description = "Enable sagemaker endpoint configuration usage"
  default     = true
}

variable "enable_sagemaker_endpoint" {
  description = "Enable sagemaker endpoint usage"
  default     = true
}

variable "instance_type" {
  description = "instance type for sagemaker"
  default     = "ml.t3.medium"
}


# AWS Sagemaker user profile
variable "enable_sagemaker_user_profile" {
  description = "Enable sagemaker user profile usage"
  default     = true
}

variable "sagemaker_user_profile_user_settings" {
  description = "AAA"
  default = {
    execution_role = "aws_iam_role.sagemaker-ds-role.name"

    security_groups = "aws_security_group.sagemaker-ds-security.id"
  }
}
variable "security_groups" {
  description = "(Optional) A specifier for sagemaker security access"
  default     = ["aws_security_group.data-science-security.id"]
}
variable "sagemaker_user_profile_sharing_settings" {
  type        = list(any)
  description = "(Optional) The sharing settings."
  default     = ["Allowed"]
}

variable "sagemaker_model_vpc_config" {
  type        = list(any)
  description = "(Optional) - Specifies the VPC that you want your model to connect to. VpcConfig is used in hosting services and in batch transform."
  default     = []
}

# AWS Sagemaker domain
variable "enable_sagemaker_domain" {
  description = "Enable sagemaker domain usage"
  default     = true
}

variable "sagemaker_domain_auth_mode" {
  description = "(Required) The mode of authentication that members use to access the domain. Valid values are IAM and SSO"
  default     = "SSO"
}

variable "sagemaker_domain_vpc_id" {
  description = "(Required) The ID of the Amazon Virtual Private Cloud (VPC) that Studio uses for communication."
  default     = "data.terraform_remote_state.datajobs_vpc.outputs.vpc_id"
}

variable "sagemaker_domain_subnet_ids" {
  description = "(Required) The VPC subnets that Studio uses for communication."
  default     = ["subnet-0006f7d7b831d9361"]
}

variable "vpc_network" {
  description = "Routes through which sagemaker communicates"
  default     = "VpcOnly"
}

variable "sagemaker_domain_sharing_settings" {
  type        = list(any)
  description = "(Optional) The sharing settings. "
  default     = ["Allowed"]
}


variable "sagemaker_domain_default_user_settings" {
  description = "(Required) The default user settings."
  default = {
    execution_role = "aws_iam_role.sagemaker-ds-role.name"

    security_groups = "aws_security_group.sagemaker-ds-security.id"
  }
}
# AWS sagemaker image
variable "enable_sagemaker_image" {
  description = "Enable sagemaker image usage"
  default     = true
}

variable "sagemaker_image_display_name" {
  description = "(Optional) The display name of the image."
  default     = "Custom r image"
}

# AWS sagemaker image version
variable "enable_sagemaker_image_version" {
  description = "Enable sagemaker image version usage"
  default     = true
}

# AWS sagemaker app image config
variable "enable_sagemaker_app_image_config" {
  description = "Enable sagemaker app image config usage"
  default     = true
}


#security groups
variable "ingress_cidr_blocks" {
  type    = list(string)
  default = ["10.29.0.0/17"]
}

variable "outbound_tcp_ports" {
  default     = [2049, 8888, 443]
}


variable "instance_name" {
  type = string
  default     = "data_science_ec2"
}
variable "instance_ebs_optimized" {
  default     = true
}

variable "instance_ami" {
  type = string
  default     = "ami-07452e54e776102de"
}

variable "instance_availability_zone" {
  type = string
  default     = "us-east-1a"
}

variable "instance_type" {
  type = string
  default     = "m6a.48xlarge"
}

variable "instance_disk_size" {
  type = number
  default     = 1000
}

variable "instance_key_name" {
  type = string
  default     = "databricksML"
}

variable "instance_associate_public_ip_address" {
  default     = false
}

variable "data-science-ec2_id" {
  type = string
  default     = "aws_instance.data-science-ec2.id"
}
variable "private_subnet_id" {
  description = "ID of public subnet"
  default     = "subnet-05caea06fa96a12f3"
}

variable "instance_monitoring" {
  default     = true
}

variable "instance_iam_instance_profile" {
  type = string
  default     = "aws_iam_instance_profile.data-science-profile"
}
variable "OTAP" {
  default = "T"
  type    = string
}

variable "inbound_tcp_ports" {
  default     = [80, 443, 8888, 20048, 111, 2049]
}

variable "outbound_tcp_ports" {
  default     = [80, 443, 8888, 20048, 111, 2049]
}

variable "accound_id"{
type = string
default = ""
}
variable "your_email"{
type = string
default = "charles.lyonga.ce@omf.com"
}

variable "domain" {
  type        = string
  default     = "omf"
}

variable "project" {
  type        = string
  default     = "ml"
}

#EBS VOLUME
variable "ebs_volume_availability_zone" {
  type = string
  default     = "us-east-1a"
}

variable "ebs_volume_type" {
  type = string
  default     = "gp3"
}

variable "ebs_volume_size" {
  type = number
  default     = 1000
}

variable "ebs_volume_iops" {
  type = number
  default     = 3000
}
# AWS EBS volume attachment
variable "enable_ebs_volume_attachment" {
  default     = true
}

variable "ebs_volume_attachment_device_name" {
  type = string
  default     = "/dev/sdf"
}

variable "ebs_volume_attachment_force_detach" {
  default     = true
}
#security groups
variable "ingress_cidr_blocks" {
  type        = list(string)
  default     = ["0.0.0.0/0"]
}
variable "bucket_arn" {
  type        = string
  description = "The ARN of the Bucket that we're connecting to the Storage Gateway NFS File Share."
  default     = "aws_s3_bucket.data-science-storage.arn"
}

#efs file system
variable "enable_efs_file_system" {
  description = "Enable EFS usage"
  default     = true
}

variable "efs_file_system_performance_mode" {
  description = "The file system performance mode. Can be either 'generalPurpose' or 'maxIO' (Default: 'generalPurpose')."
  default     = "generalPurpose"
}

variable "efs_file_system_encrypted" {
  description = "If true, the disk will be encrypted."
  default     = true
}

variable "efs_file_system_kms_key_id" {
  description = "The ARN for the KMS encryption key. When specifying kms_key_id, encrypted needs to be set to true."
  default     = ""
}

variable "efs_file_system_creation_token" {
  description = "used as reference when creating the Elastic File System to ensure idempotent file system creation."
  default     = "data-science-efs"
}

variable "efs_file_system_throughput_mode" {
  description = "When using provisioned, also set provisioned_throughput_in_mibps."
  default     = "bursting"
}

variable "efs_file_system_lifecycle_policy" {
  description = "(Optional) A file system lifecycle policy object"
  default     = []
}

# AWS EFS mount targets
variable "enable_efs_mount_target" {
  description = "Enable EFS mount target usage"
  default     = false
}

variable "efs_mount_target_subnet_ids" {
  description = "The ID of the subnets to add the mount target in."
  default     = ["subnet-0b881a78934ddb180", "subnet-0b07f65916df83ea9", "subnet-045c9c37f55ee80de"]
}

variable "subnet_counts" {
  default = "3"
}

variable "efs_mount_target_ip_address" {
  description = "The address (within the address range of the specified subnet) at which the file system may be mounted via the mount target."
  default     = "10.30.57.241"
}

# AWS EFS file system policy
variable "enable_efs_file_system_policy" {
  description = "Enable EFS file system policy usage"
  default     = true
}

variable "efs_file_system_policy_file_system_id" {
  description = "The ID of the EFS file system."
  default     = ""
}

variable "efs_file_system_policy_policy" {
  description = "(Required) The JSON formatted file system policy for the EFS file system. see Docs for more info."
  default     = null
}

#EFS security group
variable "inbound_tcp_port" {
  default     = [2049]
}

variable "outbound_tcp_port" {
  default     = [2049]
}

variable "dev-ec2-security-group" {
  default     = "sg-0c72a2dee01ec8bf7"
}
