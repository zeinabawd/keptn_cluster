resource "aws_eks_cluster" "eks_cluster" {
  name     = var.eks_name
  role_arn = aws_iam_role.cluser_role.arn

  vpc_config {
    endpoint_public_access = true
    subnet_ids = [
      aws_subnet.eks_subnet1.id,
      aws_subnet.eks_subnet2.id
    ]
    security_group_ids = [aws_security_group.eks_nodes_sg.id]
  }

  # Ensure that IAM Role permissions are created before and deleted after EKS Cluster handling.
  # Otherwise, EKS will not be able to properly delete EKS managed EC2 infrastructure such as Security Groups.
  depends_on = [
    aws_iam_role_policy_attachment.AmazonEKSClusterPolicy_cluster,
    aws_iam_role_policy_attachment.AmazonEKSVPCResourceController_cluster,
  ]
}
