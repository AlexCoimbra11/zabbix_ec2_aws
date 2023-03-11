# Introdução

Laboratório de configuração da ferramenta Zabbix 6.0 utilizando duas instancias Ec2 AWS com o serviço de RDS para o banco de dados MySql 8.0 onde uma instancia será o Servidor e a outra o Agente.
Por se tratar de um laboratório foram utilizados os recursos mínimos de Freetier da AWS na mesma VPC, portanto não foram levados em consideração as exigências de uma situação de uso real.

 

## 1) Configurações iniciais da instancia que será o servidor zabbix.

Ubuntu 22.04  
Freetier  
t2.micro  
Vpc (Default)  
SG (portas 80 e 22 liberadas)  

## 2) Configuração do RDS para criação do banco de dados.
Mysql versao 8.0  
Freetier  
t3.Micro  
DB INSTANCE IDENTIFIER: dbzabbix(Exemplo)  
USERNAME: admin(Exemplo)  
PASS:12345678(Exemplo)  
!!!!IMPORTANTE: ATACHAR O BANCO NA INSTANCIA CRIADA PARA O SERVER  
VPC: a mesma da instancia ec2 criada para o server.  
SG: Default  
NAO CRIAR DATABASE BASE! Será criado depois no terminal.  

### 3) Baixando o repositório na instancia EC2 (SERVER)

```
$ wget https://repo.zabbix.com/zabbix/6.0/ubuntu/pool/main/z/zabbix-release/zabbix-release_6.0-4%2Bubuntu22.04_all.deb

$ sudo dpkg -i zabbix-release_6.0-4+ubuntu22.04_all.deb

$ sudo apt update
```

### 4) Instalando o pacote completo Zabbix

``` 
$ sudo apt install zabbix-server-mysql zabbix-frontend-php zabbix-apache-conf zabbix-sql-scripts zabbix-agent
```

### 5) Instalando mysql-client

```
$ sudo apt-get install mysql-client
$ sudo apt update
```
### 6) Conectando a instancia ao RDS

```
$ mysql -h <ENDPOINT RDS> -u <USER> -p<PASS> 
```
EXEMPLO: mysql -h zabbix.c63irvdx0ogk.us-east-1.rds.amazonaws.com -u admin -p12345678 

### 7) Criando o Banco de Dados

```
$ CREATE DATABASE zabbix CHARACTER SET utf8 COLLATE utf8_bin;

$ quit
```
### 8) Verificando se o banco esta conectado a instancia

```
$ mysqladmin -h <ENDPOINT RDS> -u <USER> -p ping
```
EXEMPLO: mysqladmin -h zabbix.c63irvdx0ogk.us-east-1.rds.amazonaws.com -u admin -p ping

DEVE RETORNAR:mysqld is alive

### 9) Importar esquema inicial de dados

```
$ zcat /usr/share/zabbix-sql-scripts/mysql/server.sql.gz | mysql -h <ENDPOINT> -u<USER> -p<PASS> zabbix
```
EXEMPLO: zcat /usr/share/zabbix-sql-scripts/mysql/server.sql.gz | mysql -h zabbix.c63irvdx0ogk.us-east-1.rds.amazonaws.com -u admin -p12345678 zabbix

### 10) Editar arquivo de configuração do Servidor Zabbix

```
$ sudo nano /etc/zabbix/zabbix_server.conf
```
Ctrl+w e busque as sequintes variaveis para inclusão dos dados.

```
DBUser=<USER>

DBPassword=<PASS>(precisa descomentar)

DBHost=<ENDPOINT>(precisa descomentar)
```
Ctrl+o e Enter (para salvar) Ctrl+x (para fechar)

### 11) Editar Timezone do Apache
```
$ sudo nano /etc/zabbix/apache.conf
```
#editar timezone para America/Sao_Paulo (Descomentar)

### 12) Reiniciando e ativando Servidor Zabbix
```
$ sudo systemctl restart zabbix-server zabbix-agent apache2
$ sudo systemctl enable zabbix-server zabbix-agent apache2
```
### 13) Verificando Status do Servidor ####################
```
$ sudo systemctl status zabbix-server zabbix-agent apache2
```
# Instalação concluída: Configuração do Zabbix pelo navegador


### 14) Abra o navegador e coloque o ip publico da instancia adicionando /zabbix

EXEMPLO: 34.1.15.25/zabbix

### 15) Prossiga confirmando os passos com os parâmetros padrões

User: Admin
Password: zabbix

Nesse ponto já vai ser possível fazer o monitoramento dos dados do servidor, mas agora vamos realizar a instalação do agente em uma outra instancia para o monitoramento.

## 16) Configuração inicial da instancia 2 (Agente)

Ubuntu 22.04  
Freetier  
t2.micro  
Vpc (Default)  
SG (porta 22) e (porta 10050-10051)  

### 17) Baixando o repositório na instancia EC2 e instalando o agente (AGENTE)

```
$ wget https://repo.zabbix.com/zabbix/6.0/ubuntu/pool/main/z/zabbix-release/zabbix-release_6.0-4%2Bubuntu22.04_all.deb

$ sudo dpkg -i zabbix-release_6.0-4+ubuntu22.04_all.deb

$ sudo apt update

$ sudo apt install -y zabbix-agent
```

### 18) Editando os parametros do agente

```
$ sudo nano /etc/zabbix/zabbix_agentd.conf
```
Ctrl+w e busque as sequintes variaveis para inclusão dos dados.

```
Server=127.0.0.1
ServerActive=127.0.0.1
Hostname= Zabbix server
```
Substitua pelo ip privado da Instancia EC2 do zabbix server e na variavel Hostname insira um nome de sua preferencia.
Ctrl+o e Enter (para salvar) Ctrl+x (para fechar)

### 19) Reiniciando o agente e verificando o status

```
$ sudo systemctl restart zabbix-agent
$ sudo systemctl enable zabbix-agent
$ sudo systemctl status zabbix-agent
```
Pronto! Agora retorne ao painel do Zabbix e adicione o agente para monitoramento.

### 20) Adicionando o host agente para monitoramento

Na aba Configuration:  
Host  
Create host  
criar um nome para o host  
Groups> Linux servers  
Templates: Templates operation sistem > linux by zabbix agent  
No campo interface insira o ip privado da instancia do agente.
