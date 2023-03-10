#!/bin/bash

# Opção de inicialização da instancia para agilizar.

wget https://repo.zabbix.com/zabbix/6.0/ubuntu/pool/main/z/zabbix-release/zabbix-release_6.0-4%2Bubuntu22.04_all.deb

sudo dpkg -i zabbix-release_6.0-4+ubuntu22.04_all.deb

sudo apt update

sudo apt install zabbix-server-mysql zabbix-frontend-php zabbix-apache-conf zabbix-sql-scripts zabbix-agent

sudo apt-get install mysql-client

sudo apt update
