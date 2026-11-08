terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.50"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.30"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.14"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
  }

  # Production backend configuration (Uncomment and configure for remote state)
  # backend "s3" {
  #   bucket         = "myorg-terraform-state-prod"
  #   key            = "spark-on-eks/terraform.tfstate"
  #   region         = "us-west-2"
  #   dynamodb_table = "myorg-terraform-locks-prod"
  #   encrypt        = true
  # }
}
