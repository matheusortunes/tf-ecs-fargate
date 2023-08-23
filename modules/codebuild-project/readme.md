# Módulo Terraform para Projeto AWS CodeBuild

Este módulo Terraform cria um projeto AWS CodeBuild com parâmetros personalizáveis.

## Uso

```hcl
module "codebuild" {
  source = "caminho/para/modulo"

  codebuild_project_name = "meu-projeto-codebuild"
  description           = "Meu Projeto CodeBuild"
  buildspec_path        = "buildspec.yml"
  codebuild_service_role = "arn:aws:iam::123456789012:role/codebuild-service-role"
  compute_type          = "BUILD_GENERAL1_SMALL"
  image                 = "aws/codebuild/standard:4.0"
  type                  = "LINUX_CONTAINER"
  privileged            = "false"

  tags = {
    Ambiente = "Produção"
    Dono     = "MinhaEquipe"
  }
}
```

## Entradas

| Nome                   | Descrição                           | Tipo   | Padrão | Obrigatório |
|------------------------|------------------------------------|--------|--------|-------------|
| codebuild_project_name | O nome do projeto CodeBuild.       | string |        | sim         |
| description            | A descrição do projeto CodeBuild.  | string |        | sim         |
| buildspec_path         | O caminho para o arquivo buildspec. | string |        | sim         |
| codebuild_service_role | A ARN da função IAM para o CodeBuild.| string |        | sim         |
| compute_type           | O tipo de computação para o CodeBuild.| string |        | sim         |
| image                  | A imagem Docker para o ambiente de build.| string |        | sim         |
| type                   | O tipo de ambiente de build.        | string |        | sim         |
| privileged             | Se o ambiente de build é privilegiado.| string |        | sim         |
| tags                   | Tags a serem aplicadas ao projeto CodeBuild.| map |        | sim         |

## Saídas

| Nome | Descrição                      |
|------|-------------------------------|
| name | O nome do projeto CodeBuild. |
