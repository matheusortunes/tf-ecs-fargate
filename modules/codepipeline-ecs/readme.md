# Módulo Terraform: AWS CodePipeline com Implantação no ECS

Este módulo Terraform cria um AWS CodePipeline que automatiza a implantação de um aplicativo em contêiner no Amazon ECS (Elastic Container Service). O pipeline consiste em estágios para a recuperação do código-fonte, a criação da imagem do contêiner e a implantação no cluster ECS.

## Uso

```hcl
module "ecs_codepipeline" {
  source = "../../modules/codepipeline-ecs"

  for_each = var.pipelines-ecs

  codepipeline_name      = each.key
  role_arn               = module.iam-role-codepipeline.iam_role_arn
  bucket                 = module.s3["codepipeline"].s3_bucket_id
  repository_name        = module.codecommit_repositories["${each.value.repo_name}"].name
  branch                 = each.value.branch
  codebuild_project_name = module.codebuild_projects["${each.value.build_project}"].name
  env                    = each.value.env
  service_name           = each.value.service_name
  assume_role            = each.value.assume_role
  kms_arn                = module.kms.key_arn

  tags = var.tags
}

variable "pipelines-ecs" {
  type = map(object({
    build_project = string
    repo_name     = string
    branch        = string
    env           = string
    service_name  = string
    assume_role   = string
  }))
  default = {
    "ecs-exemplo-ENVIRONMENT" = {
      repo_name     = "repo.exemplo"
      build_project = "ecs-exemplo-ENVIRONMENT-build"
      branch        = "develop"
      env           = "ENVIRONMENT"
      service_name  = "exemplo"
      assume_role   = "arn:aws:iam::ACCOUNT_ID:role/CICD-Ecs-Role-ENVIRONMENT"
    }

```

## Variáveis

| Nome da Variável       | Tipo   | Descrição                                              |
|------------------------|--------|--------------------------------------------------------|
| tags                   | map    | Um mapa de tags para aplicar aos recursos criados.     |
| role_arn               | string | O ARN da função IAM a ser assumida pelo pipeline.      |
| bucket                 | string | O nome do bucket S3 onde os artefatos do pipeline serão armazenados. |
| repository_name        | string | O nome do repositório CodeCommit para o código-fonte.  |
| branch                 | string | A branch do repositório a ser usado como fonte.          |
| codebuild_project_name | string | O nome do projeto CodeBuild para criar a imagem do contêiner. |
| codepipeline_name      | string | O nome do CodePipeline a ser criado.                   |
| service_name           | string | O nome do serviço ECS para implantação.                |
| env                    | string | O nome do ambiente (por exemplo, "ENVIRONMENT", "prod").       |
| assume_role            | string | O ARN da função IAM a ser assumida pelo ECS durante a implantação. |
| kms_arn                | string | O ARN da chave KMS para criptografia de artefatos.     |