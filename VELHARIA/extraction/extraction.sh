[ "$1" ] &&  [ -f "$1" ] || { echo "Uso: $0 <sha256.apk>"; exit;}
echo "O parametro é: $1"
do  
	echo "Iniciando a extração de características..."
	/usr/bin/time -f "$SHA256 Tempo decorrido Extração = %e segundos, CPU = %P, Memoria = %M KiB" -a -o stats_"$1".txt python3 get_caracteristicas.py -a $SHA256
	echo "Gerado o CSV do APK!!!"
	mv $SHA256.csv ../5_Temp/3_CSVs
	mv $SHA256\_API_Calls_original.zip ../5_Temp/4_API_Calls
done < "$1"