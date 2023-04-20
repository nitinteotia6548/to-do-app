provider "aws" {
  region = "ap-southeast-1"
}

data "aws_eks_cluster_auth" "eks-cluster-auth" {
  name =  aws_eks_cluster.tss-cluster.name
}
provider "kubernetes" {
  host                   = aws_eks_cluster.tss-cluster.endpoint
  cluster_ca_certificate = base64decode(aws_eks_cluster.tss-cluster.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.eks-cluster-auth.token
}