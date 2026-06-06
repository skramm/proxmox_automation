
# Génération d'une liste de VM

set -x

# désactive l'interprétation de '!' dans une chaine
set +H

# arg

USER=$1
NB=$2

TODAY=$(date '+%Y%m%d_%H%M%S')
out=out.csv

CURLLOG=curl_$TODAY.log

function process()
{
	curl -k -H 'Authorization: PVEAPIToken=krammseb@UR!'"${TOK_NAME}=${TOK_VALUE}" \
		https://anvers.univ-rouen.fr:8006/api2/json/nodes/$1/qemu>>out_$1.json 2>>$CURLLOG
		
#		 | jq -r '.data[] | [.vmid|tostring,.name] | join (";")' >> out_$1.csv 
	err=$?
	if ! [ $err = 0 ]
	then
		echo "node '$1': echec!"
	fi
}

# read token details
source ../token_20260110

#echo "TOK_NAME"
# "test de la réponse de l'API

response=$(curl -s -k \
  -H "Authorization: PVEAPIToken=$USER@UR!${TOK_NAME}=${TOK_VALUE}" \
  https://anvers.univ-rouen.fr:8006/api2/json/version)

echo "Réponse API=$response"


if [ $? -eq 0 ] && [ -n "$response" ]; then
    echo "API disponible"
else
    echo "API indisponible, réponse='$response'"
	exit 1
fi
exit


# liste des nodes 
	curl -k -H "Authorization: PVEAPIToken=krammseb@UR!${TOK_NAME}=${TOK_VALUE}" \
		https://anvers.univ-rouen.fr:8006/api2/json/nodes|jq | jq -r '.data[] | .node' >nodes.csv 2>>$CURLLOG

exit
while read -r nodename
do
	echo "process node $nodename"
	process $nodename
done < nodes.csv



