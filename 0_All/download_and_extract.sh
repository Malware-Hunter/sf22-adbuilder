[ "$1" ] &&  [ -f "$1" ] || { echo "Uso: $0 <sha256.txt>"; exit;}
while read SHA256

do  
	echo -n "Realizando o download do APK $SHA256 ... "
	/usr/bin/time -f "$SHA256 Tempo decorrido Download = %e segundos, CPU = %P, Memoria = %M KiB" -a -o stats_download_"$1".txt curl -s -S -O --remote-header-name -G -d apikey=44e1937815802c68ee461e4f186f388107ad2ac5f10d0a38f93de5d56a7420ec -d sha256=$SHA256 https://androzoo.uni.lu/api/download
	echo "Download finalizado!!!"
	echo "Iniciando a extração das características..."
	/usr/bin/time -f "$SHA256 Tempo decorrido Extração = %e segundos, CPU = %P, Memoria = %M KiB" -a -o stats_extraction_"$1".txt python3 get_caracteristicas.py -a $SHA256".apk"
	while [ ! -f "$SHA256".csv ]
	do
		sleep 1
	done
	echo "Extração finalizada!!!"
	#mv $SHA256.apk ../5_Temp/1_APKs
	#mv $SHA256.csv ../5_Temp/3_CSVs
	mv $SHA256\_API_Calls_original.zip ../5_Temp/4_API_Calls
done < "$1"

#mv $SHA256.apk ../5_Temp/1_APKs

echo "Movendo arquivos stats_logs para Logs"
for i in stats_download_*
do
	mv $i ../5_Temp/2_Logs/1_Download/
done

for i in stats_extraction_*
do
	mv $i ../5_Temp/2_Logs/2_Extraction/
done
echo "Finalizado!!!"

echo "Removendo arquivos moto_*"
for i in moto_*
do
	rm $i
done
echo "Finalizado!!!"