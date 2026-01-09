# lambda-mecanica-xpto

Este repositorio contem apenas o deploy da Lambda authorizer.
Infra de EKS/Kubernetes e pipelines relacionados foram removidos.

## Estrutura
- `infra/lambda/authorizer.py`: codigo da Lambda
- `infra/*.tf`: Terraform para criar IAM role e Lambda

## Prerequisitos
- AWS CLI configurado com credenciais
- Terraform >= 1.5

## Deploy
```bash
cd infra
terraform init
terraform apply -var "jwt_secret=SEU_SEGREDO"
```

## Variaveis principais
- `aws_region`: regiao AWS (default: `us-east-1`)
- `lambda_function_name`: nome da Lambda
- `jwt_secret`: segredo HS256 (sensivel)
- `jwt_algo`: algoritmo JWT (default: `HS256`)
- `authorizer_invoke_arn`: ARN do API Gateway que pode invocar a Lambda (opcional)

## Atualizar o codigo
Edite `infra/lambda/authorizer.py` e execute `terraform apply` novamente.
