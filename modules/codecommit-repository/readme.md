# Módulo Terraform para Criar um repositório AWS CodeCommit

Este módulo Terraform permite criar um repositório AWS CodeCommit com os parâmetros especificados.

## Uso

```hcl
module "codecommit_repo" {
  source           = "caminho/para/o/modulo"
  repository_name  = "nome-do-repositorio"
  description      = "descrição-do-repositorio"
}
```

## Entradas

| Nome              | Tipo        | Descrição                           |
|-------------------|-------------|-------------------------------------|
| repository_name   | string      | **(obrigatório)** O nome do repositório AWS CodeCommit a ser criado. |
| description       | string      | **(obrigatório)** A descrição do repositório AWS CodeCommit a ser criado. |


## Saídas

| Nome    | Descrição                               |
|---------|-----------------------------------------|
| arn     | ARN do Repositório: O ARN (Amazon Resource Name) do repositório AWS CodeCommit criado. |
| name    | Nome do Repositório: O nome do repositório AWS CodeCommit criado. |