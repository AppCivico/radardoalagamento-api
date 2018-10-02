#!/bin/bash

## AVISO:
##   Este é um arquivo de exemplo. Copie-o e defina as variaveis com os 
##   valores corretos
##

# $ cp envs.sample.sh envs_local.sh
# # Edite as variaveis com os dados corretos
# $ TUPA_ENV_FILE=deploy/envs_local.sh deploy/restart_services.sh


source ~/perl5/perlbrew/etc/bashrc


export TUPA_API_WORKERS=1
# diretorios

# diretorio de log dos daemons
export TUPA_LOG_DIR='/caminho/para/pasta/dos/logs'

# diretorio raiz do projeto
export TUPA_APP_DIR='/home/ubuntu/radardoalagamento-api'


export TUPA_SQITCH_DEPLOY_NAME=local

# Altera porta se necessário
export TUPA_API_PORT=2029

export TUPA_MODE='tupa'

export CATALYST_DEBUG=1
export DBIC_TRACE=1
export DBIC_TRACE_PROFILE=console

# Banco de dados
export TUPA_DB_HOST=127.0.0.1
export TUPA_DB_PASS=xa
export TUPA_DB_PORT=5432
export TUPA_DB_USER=postgres
export TUPA_DB_NAME=tupa

# Sendgrid é o serviço de envio de emails. É necessário possuir uma conta.
export SENDGRID_USER=username123
export SENDGRID_PASSWORD=XXXxx88WWWbbb


export TUPA_API_HOST=dtupa

# arquivo de config do Catalyst. Faça uma cópia do tupa_web_app_local_example.pl
# Ex: cp tupa_web_app_local_example.pl tupa_web_app_local.pl
export TUPA_CONFIG_FILE="$TUPA_APP_DIR/tupa_web_app_local.pl"

# Contacte-nos para conseguir essas credenciais
export SAISP_USER=saisp-user-example
export SAISP_PASS=saips-password
