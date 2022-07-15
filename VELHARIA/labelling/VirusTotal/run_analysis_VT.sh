[ "$1" ] &&  [ -f "$1" ] && [ "$2" ] || { echo "Uso: $0 <sha256.txt> <API Key>"; exit;}
while read SHA256

do  
	echo -n "Realizando o download do json $SHA256 ... "
	curl  --request GET --url "https://www.virustotal.com/api/v3/files/"$SHA256 --header  'x-apikey:'$2 > $SHA256".json" &

	sleep 20
	echo "Download finalizado!!!"
done < "$1"