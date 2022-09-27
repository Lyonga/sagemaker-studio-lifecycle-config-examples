resource "aws_iam_role" "sagemaker-ds-role" {
  name               = "${var.account_code}-iam_role-${var.env}-data-science-${var.domain}-${var.category}-${var.region_code}-all"
  tags = merge(
    {
      Name = "${var.account_code}-iam_role-${var.env}-data-science-${var.domain}-${var.category}-${var.region_code}-all"
    },
    var.tags
  )
  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "",
            "Effect": "Allow",
            "Principal": {
                "Service": "sagemaker.amazonaws.com"
            },
            "Action": "sts:AssumeRole"
        },
        {
            "Sid": "",
            "Effect": "Allow",
            "Principal": {
                "AWS": "arn:aws:iam::168318340072:user/oaqn-s-v2sx0139"
            },
            "Action": "sts:AssumeRole",
            "Condition": {
                "StringEquals": {
                    "sts:ExternalId": "ZCA03077_SFCRole=2_rkvHvnlSAXKLRQgZF4Qkk61O8u4="
                }
            }
        }
    ]
 }
 EOF
}

resource "aws_iam_role_policy_attachment" "sagemaker-ds-attachment" {
  role       = aws_iam_role.sagemaker-ds-role.name
  policy_arn = aws_iam_policy.sagemaker-ds-policy.arn
}

resource "aws_iam_policy" "sagemaker-ds-policy" {
  name        = "${var.account_code}-iam_policy-${var.env}-data-science-${var.domain}-${var.category}-${var.region_code}-all"
  policy      = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
       {
            "Effect": "Allow",
            "Action": [
                "sagemaker:*"
            ],
            "NotResource": [
                "arn:aws:sagemaker:*:*:domain/*",
                "arn:aws:sagemaker:*:*:user-profile/*",
                "arn:aws:sagemaker:*:*:app/*",
                "arn:aws:sagemaker:*:*:flow-definition/*"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "sagemaker:DescribeDomain",
                "sagemaker:ListDomains",
                "sagemaker:DescribeUserProfile",
                "sagemaker:ListUserProfiles",
                "sagemaker:*App",
                "sagemaker:ListApps"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": "sagemaker:*",
            "Resource": [
                "arn:aws:sagemaker:*:*:flow-definition/*"
            ],
            "Condition": {
                "StringEqualsIfExists": {
                    "sagemaker:WorkteamType": [
                        "private-crowd",
                        "vendor-crowd"
                    ]
                }
            }
        },
        {
            "Effect": "Allow",
            "Action": [
                "application-autoscaling:*",
                "aws-marketplace:ViewSubscriptions",
                "cloudformation:GetTemplateSummary",
                "cloudwatch:*",
                "codecommit:*",
                "cognito-idp:*",
                "ec2:*",
                "ecr:*",
                "elastic-inference:*",
                "fsx:DescribeFileSystems",
                "glue:*",
                "groundtruthlabeling:*",
                "iam:ListRoles",
                "kms:*",
                "lambda:ListFunctions",
                "logs:*",
                "robomaker:*",
                "secretsmanager:ListSecrets",
                "servicecatalog:Describe*",
                "servicecatalog:List*",
                "servicecatalog:ScanProvisionedProducts",
                "servicecatalog:SearchProducts",
                "servicecatalog:SearchProvisionedProducts",
                "sns:ListTopics",
                "tag:GetResources"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": "ecr:*",
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "codecommit:GitPull",
                "codecommit:GitPush"
            ],
            "Resource": "*"
        },
        {
            "Action": [
                "codebuild:BatchGetBuilds",
                "codebuild:StartBuild"
            ],
            "Resource": "*",
            "Effect": "Allow"
        },
        {
            "Action": "states:*",
            "Resource": "*",
            "Effect": "Allow"
        },
        {
            "Effect": "Allow",
            "Action": [
                "secretsmanager:DescribeSecret",
                "secretsmanager:GetSecretValue"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "secretsmanager:DescribeSecret",
                "secretsmanager:GetSecretValue"
            ],
            "Resource": "*",
            "Condition": {
                "StringEquals": {
                    "secretsmanager:ResourceTag/SageMaker": "true"
                }
            }
        },
        {
            "Effect": "Allow",
            "Action": "servicecatalog:ProvisionProduct",
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "servicecatalog:TerminateProvisionedProduct",
                "servicecatalog:UpdateProvisionedProduct"
            ],
            "Resource": "*",
            "Condition": {
                "StringEquals": {
                    "servicecatalog:userLevel": "self"
                }
            }
        },
        {
            "Effect": "Allow",
            "Action": [
                "s3:GetObject",
                "s3:PutObject",
                "s3:DeleteObject",
                "s3:AbortMultipartUpload"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": "s3:GetObject",
            "Resource": "*",
            "Condition": {
                "StringEqualsIgnoreCase": {
                    "s3:ExistingObjectTag/SageMaker": "true"
                }
            }
        },
        {
            "Effect": "Allow",
            "Action": "s3:GetObject",
            "Resource": "*",
            "Condition": {
                "StringEquals": {
                    "s3:ExistingObjectTag/servicecatalog:provisioning": "true"
                }
            }
        },
        {
            "Effect": "Allow",
            "Action": [
                "s3:GetBucketLocation",
                "s3:ListBucket",
                "s3:ListAllMyBuckets"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "s3:GetBucketAcl",
                "s3:PutObjectAcl"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": "lambda:InvokeFunction",
            "Resource": "*"
        },
        {
            "Action": "iam:CreateServiceLinkedRole",
            "Effect": "Allow",
            "Resource": "arn:aws:iam::*:role/aws-service-role/sagemaker.application-autoscaling.amazonaws.com/AWSServiceRoleForApplicationAutoScaling_SageMakerEndpoint",
            "Condition": {
                "StringLike": {
                    "iam:AWSServiceName": "sagemaker.application-autoscaling.amazonaws.com"
                }
            }
        },
        {
            "Effect": "Allow",
            "Action": "iam:CreateServiceLinkedRole",
            "Resource": "*",
            "Condition": {
                "StringEquals": {
                    "iam:AWSServiceName": "robomaker.amazonaws.com"
                }
            }
        },
        {
            "Effect": "Allow",
            "Action": [
                "sns:Subscribe",
                "sns:Publish"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": "iam:PassRole",
            "Resource": "arn:aws:iam::*:role/*AmazonSageMaker*",
            "Condition": {
                "StringEquals": {
                    "iam:PassedToService": [
                        "glue.amazonaws.com",
                        "robomaker.amazonaws.com",
                        "states.amazonaws.com"
                    ]
                }
            }
        },
        {
            "Effect": "Allow",
            "Action": "iam:PassRole",
            "Resource": "arn:aws:iam::*:role/*",
            "Condition": {
                "StringEquals": {
                    "iam:PassedToService": "sagemaker.amazonaws.com"
                }
            }
        },
        {
            "Effect": "Allow",
            "Action": "athena:*",
            "Resource":"*"
        },
        {
            "Effect": "Allow",
            "Action": "glue:CreateTable",
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": "glue:UpdateTable",
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": "glue:DeleteTable",
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "glue:GetDatabases",
                "glue:GetTable",
                "glue:GetTables"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "glue:CreateDatabase",
                "glue:GetDatabase"
            ],
            "Resource": "*"
        },
        {
            "Sid": "AllowS3List",
            "Effect": "Allow",
            "Action": "s3:ListAllMyBuckets",
            "Resource": "*"
        },
        {
            "Sid": "AllowS3Buckets",
            "Effect": "Allow",
            "Action": [
                "s3:Get*",
                "s3:ListBucket"
            ],
            "Resource": [
                "arn:aws:s3:::oedsp-stg-s3-dl-*"
            ]
        },
        {
            "Sid": "AllowS3ReadOnlyBucketAccess",
            "Effect": "Allow",
            "Action": [
                "s3:GetBucket*"
            ],
            "Resource": [
                "arn:aws:s3:::oedsp-stg-s3-dl-*prepared-*"
            ]
        },
        {
            "Sid": "AllowS3ObjectByTag",
            "Effect": "Allow",
            "Action": [
                "s3:GetObject*"
            ],
            "Resource": [
                "arn:aws:s3:::oedsp-stg--s3-dl-*prepared-*/*"
            ],
            "Condition": {
                "StringLike": {
                    "s3:ExistingObjectTag/Domain": [
                        "Loan",
                        "CC",
                        "Insurance",
                        "Corp",
                        "Ref"
                    ],
                    "s3:ExistingObjectTag/Classification": [
                        "General",
                        "PII.Sensitive",
                        "PII.NonSensitive"
                    ]
                }
            }
        },
        {
            "Sid": "AllowS3TempWritePermissions",
            "Effect": "Allow",
            "Action": [
                "s3:Get*",
                "s3:DeleteObjectVersion",
                "s3:RestoreObject",
                "s3:PutObject",
                "s3:DeleteObject"
            ],
            "Resource": [
                "arn:aws:s3:::oedsp-stg-s3-dl-analyst-pub-*/*",
                "arn:aws:s3:::oedsp-stg-s3-dl-analyst-pub-*",
                "arn:aws:s3:::oedsp-stg-s3-dl-analyst-con-*/*",
                "arn:aws:s3:::oedsp-stg-s3-dl-analyst-con-*",
                "arn:aws:s3:::oedsp-stg-s3-dl-analyst-temp-con-ue1-all/*",
                "arn:aws:s3:::oedsp-stg-s3-dl-analyst-temp-pub-ue1-all/*",
                "arn:aws:s3:::oedsp-stg-s3-dl-sandbox-data-science-*",
                "arn:aws:s3:::oedsp-stg-s3-dl-sandbox-data-science-*/*"
            ]
        },
        {
            "Sid": "Listathena",
            "Effect": "Allow",
            "Action": [
                "athena:List*"
            ],
            "Resource": "*"
        },
        {
            "Sid": "AthenaAccess",
            "Effect": "Allow",
            "Action": [
                "athena:Get*",
                "athena:StartQueryExecution",
                "athena:CreateNamedQuery",
                "athena:StopQueryExecution",
                "athena:DeleteNamedQuery",
                "athena:List*",
                "athena:BatchGet*"
            ],
            "Resource": [
                "arn:aws:athena:*:*:workgroup/oedsp-stg-wrkgrp-dl-analyst-pub",
                "arn:aws:athena:*:*:workgroup/oedsp-stg-wrkgrp-dl-analyst-con"
            ]
        },
        {
            "Sid": "AllowListGlueDB",
            "Effect": "Allow",
            "Action": [
                "glue:Get*",
                "glue:List*"
            ],
            "Resource": [
                "*"
            ]
        },
        {
            "Sid": "AllowReadMainGlueDB",
            "Effect": "Allow",
            "Action": [
                "glue:Get*"
            ],
            "Resource": [
                "arn:aws:glue:*:*:catalog",
                "arn:aws:glue:*:*:database/*",
                "arn:aws:athena:*:*:table/*",
                "arn:aws:s3:::oedsp-stg-s3-dl-*"
            ]
        }

    ]
}
EOF
}
