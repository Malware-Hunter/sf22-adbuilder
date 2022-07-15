#!/bin/bash
[ "$1" ]
cd "$1"
#mv run_extraction.sh "$1"
echo "Iniciando a extração de características..."
for arquivo in *.apk
do
    IN="$arquivo"
    arrIN=(${IN//./ })
	/usr/bin/time -f "$arquivo Tempo decorrido Extração = %e segundos, CPU = %P, Memoria = %M KiB" -a -o stats_${arrIN[0]}.txt python3 get_caracteristicas.py -a $arquivo
	echo "Gerado o CSV do APK!!!"
	mv ${arrIN[0]}.csv ../5_Temp/3_CSVs
	mv ${arrIN[0]}\_API_Calls_original.zip ../5_Temp/4_API_Calls
done

echo "Movendo arquivos stats_logs para Logs"
for i in stats*
do
	mv $i ../5_Temp/2_Logs/2_Extraction/
done
echo "Finalizado!!!"