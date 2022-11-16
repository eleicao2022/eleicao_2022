#!/bin/bash

DIR=$(cd $(dirname $BASH_SOURCE) && pwd)

python3 "$DIR/../src/gerar_sql_votos.py"

#node "$DIR/../src/processar_logs.js"


