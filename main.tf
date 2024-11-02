variable "aws_access_key" {}
variable "aws_secret_key" {}
variable "vpc_id" {
  description = "The ID of the existing VPC"
  type        = string
}

# Configuração do provider AWS
provider "aws" {                        
  region     = "us-east-1"              
  access_key = var.aws_access_key  
  secret_key = var.aws_secret_key      
}

# Importar a VPC existente
data "aws_vpc" "existing" {
   id = var.vpc_id  # Usando a variável para o ID da VPC
   }

# Importar o Internet Gateway existente 
data "aws_internet_gateway" "existing" {
  filter {
    name   = "attachment.vpc-id"
    values = [data.aws_vpc.existing.id]
  }
}

# Declaração do grupo de segurança que será importado
resource "aws_security_group" "launch_wizard_2" {
  name        = "launch-wizard-2"  # Nome do grupo de segurança existente
  description = "Imported security group for Docker application"
  vpc_id      = var.vpc_id          # Usando a variável para o ID da VPC
}

# Configuração da instância EC2
resource "aws_instance" "sever-docker-app" {
  ami                    = "ami-0866a3c8686eaeeba"
  instance_type          = "t2.micro"
  key_name               = "chave1" #Adicione sua Key Pairs da AWS aqui!
  vpc_security_group_ids = [aws_security_group.launch_wizard_2.id]
  user_data              = file("script.sh")

  tags = {
    Name = "sever-docker-app"
  }
}

