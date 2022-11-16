#!/bin/bash

DIR=$(cd $(dirname $BASH_SOURCE) && pwd)

sqlite3 "$DIR/../eleicao.db" < "$DIR/../sql/schema.sql"
#sqlite3 "$DIR/../eleicao.db" < "$DIR/../sql/urnas.sql"
sqlite3 "$DIR/../eleicao.db" < "$DIR/../sql/secoes.sql"
sqlite3 "$DIR/../eleicao.db" < "$DIR/../sql/votos.sql"
sqlite3 "$DIR/../eleicao.db" < "$DIR/../sql/index.sql"
