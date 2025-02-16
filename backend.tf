terraform {
  backend "s3" {
    bucket         = "terraform-state-bucket" # Nome do bucket para armazenar o estado
    key            = "terraform.tfstate"     # Nome do arquivo de estado
    region         = "us-east-1"             # Região
    endpoint       = "http://localhost:4566" # Endpoint do LocalStack
    encrypt        = false                   # LocalStack não suporta criptografia
    skip_credentials_validation = true
    skip_metadata_api_check     = true
    force_path_style            = true       # Necessário para LocalStack
  }
}
