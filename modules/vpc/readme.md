# Módulo VPC
Este módulo Terraform cria uma VPC (Virtual Private Cloud) na AWS.

## Uso
```hcl
module "vpc" {
  source         = "../../modules/vpc"
  vpc_cidr_block = var.vpc_cidr_block
  project_name   = var.project_name
  env            = var.env
  tags           = var.tags
}
```

## Entradas
| Nome              | Tipo        | Descrição                  |
|-------------------|-------------|----------------------------|
| vpc_cidr_block    | string      | Bloco CIDR da VPC          |
| project_name      | string      | Nome do projeto            |
| env               | string      | Ambiente                   |
| tags              | map(string) | Tags adicionais            |

## Saídas
| Nome    | Descrição                               |
|---------|-----------------------------------------|
| id      | ID da VPC criada pelo módulo             |
| ig-id   | ID do Internet Gateway criado pelo módulo |

## Recursos Criados
- `VPC`: Cria uma VPC com o bloco CIDR especificado.
- `Internet Gateway`: Cria um gateway de internet para fornecer acesso à internet para a VPC.

## Notas
- Certifique-se de que a variável vpc_cidr_block esteja corretamente preenchida, fornecendo o valore necessário para criação da vpc.
- Tags adicionais podem ser fornecidas através da variável tags.