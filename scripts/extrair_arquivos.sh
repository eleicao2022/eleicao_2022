#!/bin/bash

DIR=$(cd $(dirname $BASH_SOURCE) && pwd)

mkdir -p "$DIR/temp"
mkdir -p "$DIR/logs/turno=1"
mkdir -p "$DIR/logs/turno=2/bu"
mkdir -p "$DIR/logs/originais"

# Converte os arquivos ".7z" baixados em ".txt"
for zipfile in $(ls $DIR/bu_imgbu_logjez_rdv_vscmr_*.zip)
do
	base=$( basename $zipfile | awk '{gsub(".zip", "");print}')

	mkdir -p "$DIR/temp/${base}"

	echo "Descompactando ${base}..."
	unzip -q $zipfile -d "$DIR/temp/${base}"

	echo "Criando subpastas..."
	idx=0;
	for f in $DIR/temp/$base/*;
	do
		subdir=dir_$(printf %04d $((idx/5000+1)));
		mkdir -p $DIR/temp/$base/$subdir;
		mv "$f" $DIR/temp/$base/$subdir;
		let idx++;
	done

	mkdir -p "$DIR/logs/turno=2/bu/${base}"
	for d in $DIR/temp/$base/*/ ; do
		echo "Movendo BUs..."
		mv ${d}*.bu $DIR/logs/turno=2/bu/$base

		echo "Descomprimindo arquivos... ${d}"

		for file in ${d}*.logjez; do
			if 7za l $file | grep -q " *\.jez$"; then
				#7za e -y "$file" "-o${d}7z" > nul:
				#7za x -y "${d}7z/*.jez" -so >> "${d}7z/temp.dat"
				#cat ${d}7z/temp.dat >> ${d}7z/logd.dat
				cat ${d}7z/logd.dat >> "$DIR/temp/${base}.dat"
				rm -rf ${d}7z
			else
				7za x -y "$file" -so >> "${d}logd.dat"
			fi
		done

		cat ${d}logd.dat >> "$DIR/temp/${base}.dat"
		rm -rf $d
	done

	mv $DIR/temp/*_1t_*.dat $DIR/logs/turno=1
	mv $DIR/temp/*_2t_*.dat $DIR/logs/turno=2

	mv $zipfile $DIR/logs/originais

	rm -rf $DIR/temp/$base
done
rm -rf "$DIR/temp"

echo "Todos os arquivos convertidos."


