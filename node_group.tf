resource "aws_eks_node_group" "eks_nodegroup" {
  cluster_name    = aws_eks_cluster.eks_cluster.name
  node_group_name = var.ng_name
  node_role_arn   = aws_iam_role.eks_ec2_node_role.arn
  subnet_ids = [
    aws_subnet.eks_subnet1.id,
    aws_subnet.eks_subnet2.id
  ]
  ami_type       = var.ami_type
  capacity_type  = var.capacity
  instance_types = ["${var.ins_type}"]
  /*remote_access {
    ec2_ssh_key  = aws_key_pair.key_pair.key_name
  }*/
  tags = {
    Name = "${var.ec2_name}"
  }

  scaling_config {
    desired_size = var.desired_n
    max_size     = var.max_n
    min_size     = var.min_n
  }

  depends_on = [
    aws_iam_role_policy_attachment.AmazonEKSWorkerNodePolicy_ec2,
    aws_iam_role_policy_attachment.AmazonEKS_CNI_Policy_ec2,
    aws_iam_role_policy_attachment.AmazonEC2ContainerRegistryReadOnly_ec2,
  ]

}
