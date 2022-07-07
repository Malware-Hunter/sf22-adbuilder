[ "$1" ] &&  [ -f "$1" ] || { echo "Uso: $0 <sha256.txt>"; exit;}
while read SHA256

do  
  start=$(date +%s)
	echo -n "Realizando o download do APK $SHA256 ... "
	/usr/bin/time -f "$SHA256 Tempo decorrido Download = %e, CPU = %P, Memoria = %M KiB" -a -o stats_"$1".txt curl -s -S -O --remote-header-name -G -d apikey=44e1937815802c68ee461e4f186f388107ad2ac5f10d0a38f93de5d56a7420ec -d sha256=$SHA256 https://androzoo.uni.lu/api/download
	echo "Download finalizado!!!"
	end=$(date +%s)
  echo $SHA256 "Levou: $(($end-$start)) segundos" >> log_"$1".txt 
done < "$1"