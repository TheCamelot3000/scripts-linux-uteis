#!/bin/bash

# Função para mostrar porcentagem de conclusão
show_progress() {
    current_step=$1
    total_steps=$2
    percentage=$((current_step * 100 / total_steps))
    echo -ne "Configurando... $percentage% concluído.\r"
}

# Verifica se o usuário é root
if [ "$(id -u)" != "0" ]; then
   echo "Este script deve ser executado como root." 1>&2
   exit 1
fi

# Verifica se o Docker está instalado e o remove, se necessário
if [ -x "$(command -v docker)" ]; then
   echo "Removendo o Docker..."
   sudo apt remove -y docker docker.io containerd runc
   sudo rm -rf /var/lib/docker
   sudo rm -rf $HOME/.docker/desktop
   sudo rm /usr/local/bin/com.docker.cli
   sudo apt purge -y docker-desktop
   echo "Docker removido."
fi

total_steps=9
current_step=1

# Configure o apt repository
echo "Configurando repositório APT..."
sudo apt-get update > /dev/null
show_progress $current_step $total_steps
((current_step++))

sudo apt-get install -y ca-certificates curl gnupg > /dev/null
show_progress $current_step $total_steps
((current_step++))

# Adicione a chave GPG oficial do Docker
echo "Adicionando chave GPG oficial do Docker..."
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg
show_progress $current_step $total_steps
((current_step++))

# Adicione o repositório do Docker ao APT sources
echo "Adicionando repositório do Docker ao APT sources..."
echo \
  "deb [arch=\"$(dpkg --print-architecture)\" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
show_progress $current_step $total_steps
((current_step++))

# Atualize os repositórios
echo "Atualizando repositórios..."
sudo apt-get update > /dev/null
show_progress $current_step $total_steps
((current_step++))

# Instale a versão do Docker
echo "Instalando Docker..."
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin > /dev/null
show_progress $current_step $total_steps
((current_step++))

# Execute sudo docker run hello-world como teste
echo "Testando o Docker com 'hello-world'..."
sudo docker run hello-world > /dev/null
show_progress $current_step $total_steps
((current_step++))

# Pergunte se o usuário deseja configurar o seu usuário pessoal para utilizar o docker
read -p "Deseja configurar seu usuário pessoal para usar o Docker? (y/n): " configure_docker
if [ "$configure_docker" == "y" ]; then
    echo "Configurando seu usuário para usar o Docker..."
    sudo groupadd docker
    read -p "Digite o nome do seu usuário: " username
    sudo usermod -aG docker $username
    echo "Usuário '$username' configurado para usar o Docker."
fi
show_progress $current_step $total_steps
((current_step++))

# Pergunte se o usuário deseja reiniciar o computador
read -p "Deseja reiniciar o computador agora? (y/n): " reboot_choice
if [ "$reboot_choice" == "y" ]; then
    echo "Reiniciando o computador..."
    sudo reboot
fi

echo "Configuração concluída!"

