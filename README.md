# Infraestrutura AWS com OpenTofu e LocalStack

Este repositório contém uma configuração para provisionamento de recursos de infraestrutura em AWS, simulados pelo LocalStack, utilizando o **OpenTofu**.

# Recursos 

Configure recursos como **DynamoDB**, **EC2**, **Route53**, um **Bucket público** e uma **VPC** com quatro **subnets** ***(duas públicas e duas privadas)***, além de **tabelas de rotas** e um **Internet Gateway**.
A instãncia EC2 vai ser colocada em uma rede privada e seu acesso só será possível via uma VPN ou uma Bastion.

## Pré-requisitos

Antes de executar os scripts, você precisará configurar seu ambiente local:

1. **OpenTofu**: Você precisa ter o OpenTofu instalado. Para isso, siga os seguintes passos:
   - [Instalar o OpenTofu](https://github.com/opentofu/opentofu#installation).

2. **LocalStack**: O OpenTofu está configurado para interagir com o LocalStack para simular os serviços da AWS. Instale o LocalStack utilizando os seguintes comandos:
   - [Instalar o LocalStack](https://docs.localstack.cloud/references/installation/).

3. **AWS CLI (opcional)**: Se você deseja interagir com os recursos após o provisionamento, pode ser útil ter o AWS CLI configurado.
   - [Instalar o AWS CLI](https://aws.amazon.com/cli/).

## Como executar

### Passo 1: Clonar o repositório

Clone este repositório para sua máquina local:

```bash
git clone git@github.com:cflb/sample-localstack-aws-resources.git
cd sample-localstack-aws-resources
```

### Passo 2: Instalar dependências

Se você ainda não tem o OpenTofu ou o LocalStack instalados, siga as instruções acima para instalá-los.

#### Para instalar o LocalStack via Docker e rodar, execute:

```
docker pull localstack/localstack
docker run --rm -e DOCKER_HOST=unix:///var/run/docker.sock -p 4566:4566 localstack/localstack
```

## Configuração do AWS CLI para LocalStack

Antes de interagir com o LocalStack via AWS CLI, você pode configurar um perfil personalizado que aponte para o endpoint LocalStack.

### Passo 1: Criar o arquivo de credenciais

No diretório `~/.aws/`, crie ou edite o arquivo `credentials` com as seguintes credenciais para o LocalStack:

```ini
[localstack]
aws_access_key_id = "test"
aws_secret_access_key = "test"
aws_default_region = "us-east-1"
endpoint_url = http://localhost.localstack.cloud:4566
```
#### Configurar o arquivo config

Se necessário, crie ou edite o arquivo ~/.aws/config para garantir que a região e o perfil padrão estejam configurados corretamente:

```ini
[profile localstack]
region = us-east-1
output = json
```

### Passo 3: Configurar o Backend (S3 para Terraform State)

Para armazenar o estado do Terraform no LocalStack (simulando o S3), execute o seguinte script Bash. Este script cria um bucket S3 e habilita o versionamento para garantir que os estados do Terraform possam ser mantidos com segurança:

```
chmod +x scripts/init-backend.sh
sh scripts/init-backend.sh
```

### Passo 4: Inicializar o OpenTofu

Com o OpenTofu e o LocalStack configurados, inicialize o OpenTofu no diretório do repositório:

```
tofu init
```

Este comando irá baixar e configurar os provedores necessários para executar os planos do OpenTofu, além de configurar o backend e o ambiente de trabalho.

### Passo 5: Validar o código

Antes de executar a aplicação, valide os arquivos de configuração para garantir que não há erros sintáticos ou lógicos:

```
tofu validate
```

### Passo 6: Planejar a execução
O comando tofu plan irá gerar um plano de execução, mostrando o que será alterado na infraestrutura:

```
tofu plan
```

### Passo 7: Aplicar o plano

Para criar os recursos definidos nos arquivos de configuração, execute o seguinte comando:

```
tofu apply -auto-approve
```

Isso irá provisionar os recursos conforme o plano, sem pedir confirmação (graças ao -auto-approve).

### Passo 8: Verificar recursos

Após a execução bem-sucedida, você pode verificar os recursos no LocalStack ou usar a AWS CLI (se estiver configurada para apontar para o LocalStack).

#### Testando recursos criados
```
# Verificar o bucket S3
aws --profile localstack s3 ls

# Verificar as tabelas do DynamoDB
aws --profile localstack dynamodb list-tables

# Verificar a VPC
aws --profile localstack ec2 describe-vpcs

# Verificar as subnets
aws --profile localstack ec2 describe-subnets

# Verificar as instâncias EC2
aws --profile localstack ec2 describe-instances

# Verificar as zonas do Route 53
aws --profile localstack route53 list-hosted-zones

# Verificar os registros DNS do Route 53
aws --profile localstack route53 list-resource-record-sets --hosted-zone-id <zone_id>

# Verificar o Internet Gateway
aws --profile localstack ec2 describe-internet-gateways
```

### Passo 9: Destruir a infraestrutura

Quando você não precisar mais dos recursos, você pode destruir a infraestrutura criada com o seguinte comando:

```
tofu destroy -auto-approve
```

Isso removerá todos os recursos provisionados.

## Estrutura de Arquivos
O repositório contém os seguintes arquivos`principais:

- ***main.tf***: O arquivo principal de configuração, onde os recursos são definidos.
- ***variables.tf***: Onde as variáveis utilizadas no main.tf são declaradas.
