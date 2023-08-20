#!/bin/bash

# Verifica se o script está sendo executado como root (usuário com permissões administrativas)
if [ "$(id -u)" != "0" ]; then
   echo "Este script deve ser executado como root." 1>&2
   exit 1
fi

# Instala as dependências e o PostgreSQL 14
apt-get update
apt-get install -y postgresql-14

# Inicia o servidor PostgreSQL
service postgresql start

# Solicita o nome de usuário
read -p "Digite o nome de usuário para o PostgreSQL: " username

# Solicita a senha para o usuário
read -s -p "Digite a senha para o usuário '$username': " password
echo

# Cria um usuário com o nome e senha fornecidos no PostgreSQL com privilégios de superusuário
sudo -u postgres psql -c "CREATE USER $username WITH SUPERUSER CREATEDB CREATEROLE PASSWORD '$password';"

# Cria um banco de dados com o nome do usuário e concede permissões apropriadas
sudo -u postgres psql -c "CREATE DATABASE $username;"
sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE $username TO $username;"

echo "O PostgreSQL 14 foi instalado e configurado. O usuário '$username' foi criado com privilégios de superusuário, e o banco de dados '$username' foi criado com as mesmas permissões."

