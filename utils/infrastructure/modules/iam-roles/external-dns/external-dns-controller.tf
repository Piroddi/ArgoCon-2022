resource "aws_iam_role" "eks-alb-ingress-controller" {
  name                = "eks-external-dns"
  assume_role_policy  = data.aws_iam_policy_document.external-dns-assume.json
  managed_policy_arns = [aws_iam_policy.external-dns.arn]
  tags = merge(var.tags, {
    k8-controller = "eks-ingress-controller"
    tf-blueprint  = "kubernetes-role"
  })
}

data "aws_iam_policy_document" "external-dns-assume" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    condition {
      test     = "StringEquals"
      variable = "${replace(var.oidc_provider_url, "https://", "")}:sub"
      values   = var.external-dns-service-account
    }

    principals {
      identifiers = [var.oidc_provider_arn]
      type        = "Federated"
    }
  }
}

resource "aws_iam_policy" "external-dns" {
  policy      = data.aws_iam_policy_document.external-dns.json
  name        = "eks-external-dns-controller"
  description = "Policy need in controller in order to create AWS resources"
  tags = merge(var.tags, {
    k8-controller = "external-dns-controller"
    tf-blueprint  = "kubernetes-role"
  })
}

data "aws_iam_policy_document" "external-dns" {
  statement {
    sid       = ""
    effect    = "Allow"
    resources = ["arn:aws:route53:::hostedzone/*"]
    actions   = ["route53:ChangeResourceRecordSets"]
  }

  statement {
    sid       = ""
    effect    = "Allow"
    resources = ["*"]

    actions = [
      "route53:ListHostedZones",
      "route53:ListResourceRecordSets",
    ]
  }
}