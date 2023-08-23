# Módulo Remote State
Este módulo implanta um bucket do S3 para armazenar o estado do Terraform. O bucket pode ser configurado com versionamento e uma tabela opcional do DynamoDB para bloqueio do estado.

## Uso
```hcl
module "state_bucket" {
  source       = "../../modules/remote-state"
  name         = "meu-bucket-de-estado-terraform"
  s3_versioning = true
  state_lock   = true
  tags = {
    Ambiente = "produção"
    Projeto  = "meu-projeto"
  }
}
```

### Entradas
| Nome          | Tipo        | Descrição                                                           |
|---------------|-------------|---------------------------------------------------------------------|
| name          | string      | (Obrigatório) O nome do bucket do S3. Deve ser único dentro da região. |
| s3_versioning | bool        | (Opcional) Indica se o versionamento deve ser ativado para o bucket do S3. O valor padrão é true. |
| state_lock    | bool        | (Opcional) Indica se uma tabela do DynamoDB deve ser criada para o bloqueio do estado. O valor padrão é true. |
| tags          | map(string) | (Opcional) Um mapa de tags para atribuir ao bucket do S3.            |

### Saídas
| Nome                   | Descrição                                                                               |
|------------------------|-----------------------------------------------------------------------------------------|
| bucket_name            | O nome do bucket do S3 criado.                                                          |
| bucket_arn             | O ARN (Amazon Resource Name) do bucket do S3 criado.                                     |
| versioning_enabled     | Indica se o versionamento está ativado para o bucket do S3.                              |
| dynamodb_table_name    | O nome da tabela do DynamoDB criada (se o bloqueio do estado estiver ativado).            |

## Notas
- Esse módulo deve ser executado primeiro e em uma pasta separada dos demais módulos do projeto.
- É necessário na pasta de execução do remote-state referenciar `providers.tf` para identificar o profile e região de execução.