resource "aws_eks_cluster" "tss-eks" {
  name     = "tss-eks"
  role_arn = aws_iam_role.tss-eks-role.arn

  vpc_config {
    subnet_ids = data.aws_subnets.default_subnets.ids
  }

  # Ensure that IAM Role permissions are created before and deleted after EKS Cluster handling.
  # Otherwise, EKS will not be able to properly delete EKS managed EC2 infrastructure such as Security Groups.
  depends_on = [
    aws_iam_role_policy_attachment.tss-eks-AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.tss-eks-AmazonEKSVPCResourceController,
  ]
}

data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default_subnets" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# data "aws_subnet" "default_subnet" {
#   for_each = toset(data.aws_subnets.default_subnets.ids)
#   id       = each.value
# }

data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["eks.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "tss-eks-role" {
  name               = "tss-eks-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_role_policy_attachment" "tss-eks-AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.tss-eks-role.name
}

resource "aws_iam_role_policy_attachment" "tss-eks-AmazonEKSVPCResourceController" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  role       = aws_iam_role.tss-eks-role.name
}

resource "aws_eks_node_group" "tss-eks-node-groups" {
  cluster_name    = aws_eks_cluster.tss-eks.name
  node_group_name = "tss-eks-node-group"
  node_role_arn   = aws_iam_role.tss-eks-worker-node-role.arn
  subnet_ids      = data.aws_subnets.default_subnets.ids

  launch_template {
   name = aws_launch_template.tss-eks-launch-template.name
   version = aws_launch_template.tss-eks-launch-template.latest_version
  }

  scaling_config {
    desired_size = 2
    max_size     = 3
    min_size     = 1
  }

  update_config {
    max_unavailable = 1
  }

  # Ensure that IAM Role permissions are created before and deleted after EKS Node Group handling.
  # Otherwise, EKS will not be able to properly delete EC2 Instances and Elastic Network Interfaces.
  depends_on = [
    aws_iam_role_policy_attachment.tss-eks-AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.tss-eks-AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.tss-eks-AmazonEC2ContainerRegistryReadOnly,
  ]
}

resource "aws_launch_template" "tss-eks-launch-template" {
  name = "tss-eks-launch-template"
  instance_type = "t2.micro"

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "TSS-EKS-MANAGED-NODE"
    }
  }
}

resource "aws_iam_role" "tss-eks-worker-node-role" {
  name               = "tss-eks-worker-node-role"
  assume_role_policy = data.aws_iam_policy_document.node_group_assume_role.json
}

data "aws_iam_policy_document" "node_group_assume_role" {

  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role_policy_attachment" "tss-eks-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.tss-eks-worker-node-role.name
}

resource "aws_iam_role_policy_attachment" "tss-eks-AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.tss-eks-worker-node-role.name
}

resource "aws_iam_role_policy_attachment" "tss-eks-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.tss-eks-worker-node-role.name
}