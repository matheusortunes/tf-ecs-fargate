# Módulo Terraform para criar regras de approval de um repositório AWS CodeCommit

Este módulo Terraform permite criar as regras de approval para um repositório AWS CodeCommit com os parâmetros especificados.

## Uso

```hcl
module "codecommit_approval_template" {
  source = "path/to/module"

  repository_name             = var.repository_name
  approval_template_name      = var.approval_template_name
  approval_template_description = var.approval_template_description
  content                    = var.content
}
```
# Entradas
| Nome                             | Descrição                                          | Tipo   | Padrão | Obrigatório |
|----------------------------------|----------------------------------------------------|--------|--------|-------------|
| repository_name                  | O nome do repositório                             | string | -      | sim         |
| approval_template_name           | O nome do modelo de regra de aprovação             | string | -      | sim         |
| approval_template_description    | Descrição do modelo de regra de aprovação          | string | -      | sim         |
| content                          | O conteúdo do modelo de regra de aprovação         | string | -      | sim         |

# Recursos Criados
- `aws_codecommit_approval_rule_template.approval`: Cria um Modelo de Regra de Aprovação do AWS CodeCommit.
- `aws_codecommit_approval_rule_template_association.association`: Associa o Modelo de Regra de Aprovação ao repositório especificado.

# Dependências
`aws_codecommit_approval_rule_template_association.association` depende de `aws_codecommit_approval_rule_template.approval`.

## Notas

- Certifique-se de que as credenciais da AWS estejam configuradas corretamente para usar este módulo.
- O módulo presume que você já criou o repositório especificado em repository_name.
- Certifique-se de fornecer valores adequados para as variáveis ao usar o módulo.
- Este módulo foi projetado para funcionar com recursos do AWS CodeCommit.