# Módulo Subnet
Este módulo Terraform cria sub-redes públicas ou privadas em uma VPC específica.

## Uso
```hcl
module "public_subnets" {
  depends_on = [module.vpc]
  source     = "../../modules/subnet"

  for_each = var.public_subnets

  public_ip         = true
  vpc_id            = module.vpc.id
  name              = each.value.name
  cidr_block        = each.value.cidr_block
  availability_zone = each.value.availability_zone
  tags = merge(
    { "kubernetes.io/role/elb" = "1" },
    { "kubernetes.io/cluster/cluster-tools" = "shared" },
    { "kubernetes.io/cluster/cluster-tfsports" = "shared" },
    { "kubernetes.io/cluster/cluster-sales" = "shared" },
    var.tags
  )
}

module "private_subnets" {
  depends_on = [module.vpc]
  source     = "../../modules/subnet"

  for_each = var.private_subnets

  public_ip         = false
  vpc_id            = module.vpc.id
  name              = each.value.name
  cidr_block        = each.value.cidr_block
  availability_zone = each.value.availability_zone
  tags              = each.value.tags
}
```

## Entradas
| Nome             | Tipo   | Descrição                                              |
|------------------|--------|--------------------------------------------------------|
| public_subnets   | map    | Mapa de objetos contendo informações das sub-redes públicas. |
| private_subnets  | map    | Mapa de objetos contendo informações das sub-redes privadas. |
| vpc_id           | string | ID da VPC onde as sub-redes serão criadas.              |
| tags             | map    | Tags adicionais a serem aplicadas às sub-redes.         |

#### Variáveis de public_subnets
| Nome                | Tipo   | Descrição                                              |
|---------------------|--------|--------------------------------------------------------|
| name                | string | Nome da sub-rede.                                      |
| cidr_block          | string | Bloco CIDR da sub-rede.                                |
| availability_zone   | string | Zona de disponibilidade onde a sub-rede será criada.   |

#### Variáveis de private_subnets
| Nome                | Tipo   | Descrição                                              |
|---------------------|--------|--------------------------------------------------------|
| name                | string | Nome da sub-rede.                                      |
| cidr_block          | string | Bloco CIDR da sub-rede.                                |
| availability_zone   | string | Zona de disponibilidade onde a sub-rede será criada.   |
| tags                | map    | Tags adicionais a serem aplicadas à sub-rede.          |

## Saída
| Nome   | Descrição                                       |
|--------|-------------------------------------------------|
| id     | ID da sub-rede criada pelo módulo.               |

## Notas
- Certifique-se de que a variável public_subnets ou private_subnets esteja corretamente preenchida, fornecendo os valores necessários para cada sub-rede.
- o valor public_ip determina se a sub-rede criada será pública ou privada.
- O módulo depende de um recurso de VPC já criado e referenciado pela variável vpc_id.
- Tags adicionais podem ser fornecidas através da variável tags.