#!/bin/bash

# Verifica se o script está sendo executado como root (usuário com permissões administrativas)
if [ "$(id -u)" != "0" ]; then
   echo "Este script deve ser executado como root." 1>&2
   exit 1
fi

# Desinstala o PostgreSQL e seus pacotes relacionados
apt-get remove --purge postgresql-14 postgresql-contrib
apt-get autoremove

# Remove os diretórios de configuração, dados e logs do PostgreSQL
rm -rf /etc/postgresql/ /var/lib/postgresql/ /var/log/postgresql/

# Remove o usuário e grupo postgres
deluser postgres
delgroup postgres

# Remove os repositórios do PostgreSQL do diretório sources.list.d
rm /etc/apt/sources.list.d/*pgdg.list

echo "O PostgreSQL foi desinstalado e todos os dados associados foram removidos."

