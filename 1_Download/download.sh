[ "$1" ] &&  [ -f "$1" ] || { echo "Uso: $0 <sha256.txt>"; exit;}
while read SHA256

do  
	echo -n "Realizando o download do APK $SHA256 ... "
	/usr/bin/time -f "$SHA256 Tempo decorrido Download = %e segundos, CPU = %P, Memoria = %M KiB" -a -o stats_"$1".txt curl -s -S -O --remote-header-name -G -d apikey=44e1937815802c68ee461e4f186f388107ad2ac5f10d0a38f93de5d56a7420ec -d sha256=$SHA256 https://androzoo.uni.lu/api/download
	mv $SHA256.apk ../5_Temp/1_APKs
	echo "Download finalizado!!!"
done < "$1"

echo "Movendo arquivos stats_logs para Logs"
for i in stats*
do
	mv $i ../5_Temp/2_Logs/1_Download/
done
echo "Finalizado!!!"

echo "Removendo arquivos moto_*"
for i in moto_*
do
	rm $i
done
echo "Finalizado!!!"