resource "aws_subnet" "private_zone1" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.0.0/19"
  availability_zone = local.zone1

  tags = {
    Name                                                           = "${local.environment}-private-${local.zone1}"
    "kubernetes.io/role/internal-elb"                              = "1" # allows us to expose services internally within the vpc
    "kubernetes.io/cluster/${local.environment}-${local.eks_name}" = "owned"
  }
}

resource "aws_subnet" "private_zone2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.32.0/19"
  availability_zone = local.zone2
  tags = {
    Name                                                           = "${local.environment}-private-${local.zone1}"
    "kubernetes.io/role/internal-elb"                              = "1" # allows us to expose services internally within the vpc
    "kubernetes.io/cluster/${local.environment}-${local.eks_name}" = "owned"
  }
}

resource "aws_subnet" "public_zone1" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.64.0/19"
  availability_zone       = local.zone1
  map_public_ip_on_launch = true

  tags = {
    "Name"                                                         = "${local.environment}-public-${local.zone1}"
    "kubernetes.io/role/elb"                                       = "1"
    "kubernetes.io/cluster/${local.environment}-${local.eks_name}" = "owned"
  }
}

resource "aws_subnet" "public_zone2" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.96.0/19"
  availability_zone       = local.zone2
  map_public_ip_on_launch = true

  tags = {
    "Name"                                                         = "${local.environment}-public-${local.zone2}"
    "kubernetes.io/role/elb"                                       = "1"
    "kubernetes.io/cluster/${local.environment}-${local.eks_name}" = "owned"
  }
}
