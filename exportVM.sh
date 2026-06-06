
# Génération d'une liste de VM

# -x pour debug
set +x

# désactive l'interprétation de '!' dans une chaine
set +H

# arg

if [ "$1" = "" ]
then
	echo "Erreur, donner votre id 5+3 en argument"
	exit 1
fi

PVUSER=$1
NB=$2

if [ -f out.csv ]; then rm out.csv;fi

TODAY=$(date '+%Y%m%d_%H%M%S')
out=out.csv
CURLLOG=curl_$TODAY.log

function process()
{
echo "process $1"
	curl -k -H "Authorization: PVEAPIToken=$PVUSER@UR!${TOK_NAME}=${TOK_VALUE}" \
		https://anvers.univ-rouen.fr:8006/api2/json/nodes/$1/qemu | jq -r '.data[]' >out_$1.json 2>>$CURLLOG
	err=$?
	if ! [ $err = 0 ]
	then
		echo "node '$1': echec!"
	fi
	jq -r '(.vmid|tostring) + ";" + .name + ";" + .tags + ";" + (.template|tostring)' < out_$1.json >out1.csv

# Ajout nom node en tete du csv
	IFS=";";while read line;
	do
		echo "$1;${line}" >> out.csv
 	done < out1.csv
}

# read token details
source ../token_20260110

# test du tunnel VPN
ip a | grep tun 1>/dev/null
if [ $? != 0 ]
then
	echo "Tunnel VPN absent, arret"
	exit 1
fi

echo "Test de la réponse de l'API"

response=$(curl -s -k \
  -H "Authorization: PVEAPIToken=$PVUSER@UR!${TOK_NAME}=${TOK_VALUE}" \
  https://anvers.univ-rouen.fr:8006/api2/json/version) 1>>$CURLLOG

if [ $? -eq 0 ] && [ -n "$response" ]; then
    echo "API disponible"
else
    echo "API indisponible, réponse='$response'"
	exit 1
fi

# liste des nodes 
	curl -k -H "Authorization: PVEAPIToken=$PVUSER@UR!${TOK_NAME}=${TOK_VALUE}" \
		https://anvers.univ-rouen.fr:8006/api2/json/nodes|jq | jq -r '.data[] | .node' >nodes.csv 2>>$CURLLOG

while read -r nodename
do
	echo "process node $nodename"
	process $nodename
done < nodes.csv



