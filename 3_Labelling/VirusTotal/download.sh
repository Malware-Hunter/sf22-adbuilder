[ "$1" ] &&  [ -f "$1" ] || { echo "Uso: $0 <sha256.txt>"; exit;}
while read SHA256

do  
	echo -n "Realizando o download do json $SHA256 ... "
	curl  --request GET --url "https://www.virustotal.com/api/v3/files/"$SHA256 --header  'x-apikey: 4b8ad0bc4f9acbd4f6fef87e165122652f94124975b5298caa1bee2f37a7d941' > $SHA256".json"

	echo "Download finalizado!!!"
	sleep 20
done < "$1"