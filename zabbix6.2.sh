#!/bin/bash
#
# zabbix6.2.sh - Instala zabbix 6.2 no Debian 11
#
# Site:       https://www.youtube.com/c/CaindonaRede/videos
# Autor:      Deivid Duarte
# Manutenção: Deivid Duarte
#
# ------------------------------------------------------------------------ #
#
#  Exemplos:
#      $ ./zabbix6.2.sh
# ------------------------------------------------------------------------ #
#
# Baixando repositório:
wget https://repo.zabbix.com/zabbix/6.2/debian/pool/main/z/zabbix-release/zabbix-release_6.2-2%2Bdebian11_all.deb
#
# Instalando repositório
sudo dpkg -i zabbix-release_6.2-2+debian11_all.deb
#
# Atualizando lista de repositórios
sudo apt update;
#
# Instale o servidor, o frontend e o agente Zabbix
sudo apt install zabbix-server-mysql zabbix-frontend-php zabbix-apache-conf zabbix-sql-scripts zabbix-agent mariadb-server zabbix-get -y
#
# Starta mariadb
sudo systemctl restart mariadb.service
#
# Cria base de dados
sudo mysql -e "create database zabbix character set utf8mb4 collate utf8mb4_bin;"
#
# Cria usuário zabbix no banco
sudo mysql -e "CREATE USER 'zabbix'@'localhost' IDENTIFIED BY 'zabbix';";
#
# Atribuir permissão do usuário zabbix
sudo mysql -e "grant all privileges on zabbix.* to zabbix@localhost;";
#
# Define função de criação de log
sudo mysql -e "set global log_bin_trust_function_creators = 1;";
#
# Popular o banco de dados com esquema inicial
sudo zcat /usr/share/zabbix-sql-scripts/mysql/server.sql.gz | mysql --default-character-set=utf8mb4 -uzabbix -p"zabbix" zabbix;
#
# Insere a senha no arquivo de conf do zabbix-server
sudo sed 's/# DBPassword=/DBPassword=zabbix/g' /etc/zabbix/zabbix_server.conf -i;
#
# Cópia arquivo que contém página inicial do zabbix
cp zabbix.config.php /etc/zabbix/web/zabbix.conf.php
#
# Adiciona pacote de idioma no linux server
sed -i "s/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/g" /etc/locale.gen
# Gera idioma adicionado
locale-gen
# Reinicia serviços
sudo systemctl restart zabbix-server zabbix-agent apache2 mariadb.service 
#
# Habilita para inicialização de serviços de forma automática
sudo systemctl enable zabbix-server zabbix-agent apache2 mariadb.service
