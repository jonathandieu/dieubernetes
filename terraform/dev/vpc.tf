resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"

  # requirement for EFS, CSI driver, client VPNs
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name        = "${local.environment}-main"
    environment = "${local.environment}"
  }
}

data "aws_availability_zones" "available" {}

