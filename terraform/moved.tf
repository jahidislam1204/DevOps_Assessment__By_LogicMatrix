moved {
  from = module.eks.aws_eks_addon.this["coredns"]
  to   = aws_eks_addon.coredns
}
