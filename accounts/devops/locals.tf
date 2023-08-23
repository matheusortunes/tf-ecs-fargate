locals {
  approval_templates = {
    "approval-template-iac" = {
      description                   = "Approval teste"
      repository_name               = module.codecommit_repositories["terraform-iac"].name
      approval_template_description = "Descrição do template de teste"
      content = jsonencode({
        Version               = "2018-11-08"
        DestinationReferences = ["refs/heads/master"]
        Statements = [{
          Type                    = "Approvers"
          NumberOfApprovalsNeeded = 1
          ApprovalPoolMembers     = ["arn:aws:sts::${data.aws_caller_identity.current.account_id}:assumed-role/${var.role_approve_admin}/*"]
        }]
      })
    }
  }
}
