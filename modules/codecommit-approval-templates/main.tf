resource "aws_codecommit_approval_rule_template" "approval" {
  name        = var.approval_template_name
  description = var.approval_template_description

  content = var.content
}

resource "aws_codecommit_approval_rule_template_association" "association" {
  depends_on = [ aws_codecommit_approval_rule_template.approval ]
  approval_rule_template_name = var.approval_template_name
  repository_name             = var.repository_name
}