[ "$1" ] &&  [ -f "$1" ] || { echo "Uso: $0 <sha256.txt>"; exit;}
while read SHA256

do  
	echo "Iniciando a extração de características..."
	/usr/bin/time -f "$SHA256 Tempo decorrido Extração = %e segundos, CPU = %P, Memoria = %M KiB" -a -o stats_"$1".txt python3 get_caracteristicas.py -a $SHA256".apk"
	echo "Gerado o CSV do APK!!!"
done < "$1"