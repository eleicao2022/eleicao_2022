# Eleições 2022

Scripts para montar banco de dados SQL com votos e modelo de urnas eletronicas das Eleições brasileiras de 2022
Boilerplate para análise de logs

# Requisitos:

Docker e DockerCompose instalados

# Instruções:

1. docker-compose up eleicao
2. Entre no cmd do container `docker exec -it eleicao bash`
3. Execute o comando `./scripts/download.sh` para baixar todos os arquivos de log do segundo turno (aproximadamente 85 GB)
4. Execute o comando `./scripts/extrair_arquivos.sh` para extrair todos os arquivos .bu e logs (pode levar várias horas)
5. Execute o comando `./scripts/gerar_sql.sh` para gerar os arquivos SQL das urnas e votos e importar no banco de dados

Para gerar Banco de dados sqlite execute o comando `./scripts/importar_sqlite.sh`
Importe para seu banco de dados SQL preferido os arquivos `schema.sql`, `urnas.sql`, `index.sql` dentro da pasta `sql`
