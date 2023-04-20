data "aws_vpc" "default_vpc" {
  default = true
}

data "aws_subnet_ids" "default_subnets" {
  vpc_id = data.aws_vpc.default_vpc.id
}

resource "aws_eks_cluster" "tss-cluster" {
  name     = "tss-cluster"
  role_arn = aws_iam_role.tss-eks-cluster.arn

  vpc_config {
    subnet_ids = data.aws_subnet_ids.default_subnets.ids
  }

  depends_on = [
    aws_iam_role_policy_attachment.tss-eks-cluster,
  ]
}

resource "aws_eks_node_group" "tss-cluster-node-groups" {
  cluster_name    = aws_eks_cluster.tss-cluster.name
  node_group_name = "tss-cluster-node-group"
  node_role_arn   = aws_iam_role.tss-cluster-worker-node-role.arn
  subnet_ids      = data.aws_subnet_ids.default_subnets.ids

  launch_template {
    name = aws_launch_template.tss-launch-template.name
    version = aws_launch_template.tss-launch-template.latest_version
  }

  scaling_config {
    desired_size = 2
    max_size     = 3
    min_size     = 1
  }

  update_config {
    max_unavailable = 1
  }

  depends_on = [
    aws_iam_role_policy_attachment.tss-cluster-AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.tss-cluster-AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.tss-cluster-AmazonEC2ContainerRegistryReadOnly,
  ]
}


resource "aws_iam_role" "tss-cluster-worker-node-role" {
  name               = "tss-cluster-worker-node-role"
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

resource "aws_launch_template" "tss-launch-template" {
  name = "tss-cluster-launch-template"
  instance_type = "t3.micro"

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "tss-cluster-managed-node"
    }
  }
}

resource "aws_iam_role_policy_attachment" "tss-cluster-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.tss-cluster-worker-node-role.name
}

resource "aws_iam_role_policy_attachment" "tss-cluster-AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.tss-cluster-worker-node-role.name
}

resource "aws_iam_role_policy_attachment" "tss-cluster-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.tss-cluster-worker-node-role.name
}

# Define the IAM role for your EKS cluster
resource "aws_iam_role" "tss-eks-cluster" {
  name = "tss-eks-cluster"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
      }
    ]
  })
}
resource "aws_iam_role_policy_attachment" "tss-eks-cluster" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.tss-eks-cluster.name
}