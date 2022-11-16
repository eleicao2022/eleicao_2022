#!/bin/bash

curl https://dadosabertos.tse.jus.br/dataset/resultados-2022-arquivos-transmitidos-para-totalizacao \
   -H 'User-Agent: Mozilla/5.0 (iPhone; CPU iPhone OS 10_3 like Mac OS X) AppleWebKit/603.1.23 (KHTML, like Gecko) Version/10.0 Mobile/14E5239e Safari/602.1' \
   -H "Content-Type: application/json" \
   | grep "\.zip" | cut -f2 -d"\"" \
   > "logs_zip.txt"

for url in $(cat "logs_zip.txt")
do
	if [[ "$url" =~ .*_2t_* ]]; then # Apenas arquivos do segundo turno
		filename=$(basename $url)
		if ! ([ -f "logs/originais/$filename" ] || [ -f "$filename" ]); then
			echo "Baixando log ${filename}:"
			curl $url \
			-H 'User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/107.0.0.0 Safari/537.36' \
			-H "Content-Type: application/json" \
			-o $filename
		fi

	fi
done
