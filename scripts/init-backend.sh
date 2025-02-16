#!/bin/bash

# Cria o bucket S3 para armazenar o estado do Terraform
aws --endpoint-url=http://localhost:4566 s3api create-bucket --bucket terraform-state-bucket

# Habilita a versionamento no bucket (opcional)
aws --endpoint-url=http://localhost:4566 s3api put-bucket-versioning --bucket terraform-state-bucket --versioning-configuration Status=Enabled