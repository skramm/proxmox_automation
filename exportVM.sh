
# Génération d'une liste de VM

# -x pour debug
set +x

# désactive l'interprétation de '!' dans une chaine
set +H

# argument id 5+3

if [ "$1" = "" ]
then
	echo "Erreur, donner votre id 5+3 en argument"
	exit 1
fi
PVUSER=$1

if [ -f out.csv ]; then rm out.csv;fi

# on stocke les logs la bas
mkdir -p /tmp/proxmox


TODAY=$(date '+%Y%m%d_%H%M%S')
out=out.csv
CURLLOG=/tmp/proxmox/curl_$TODAY.log

#---------------------------------------------------------------------------
function process()
{
#	echo "process $1"
	curl -k --silent \
		-H "Authorization: PVEAPIToken=$PVUSER@${REALM}!${TOK_NAME}=${TOK_VALUE}" \
		https://anvers.univ-rouen.fr:8006/api2/json/nodes/$1/qemu | jq -r '.data[]' >out_$1.json 2>>$CURLLOG
	err=$?
	if ! [ $err = 0 ]
	then
		echo "node '$1': echec!"
		exit 1
	fi
	jq -r '(.vmid|tostring) + ";" + .name + ";" + .tags + ";" + (.template|tostring)' < out_$1.json >out_$1.csv

# Ajout nom node en tete du csv
	IFS=";";while read line;
	do
		echo "$1;${line}" >> out.csv
 	done < out_$1.csv

# extraction des template de chaque node
	NBT=0
	if [ -f template_$1.csv ]; then rm template_$1.csv; fi
	IFS=";";while read -a ARR
	do
#		echo "0:${ARR[0]} - 1:${ARR[1]} - 2:${ARR[2]} - 3:${ARR[3]}"
		if [ ${ARR[3]} = 1 ]
		then
			NBT=$((NBT+1))
			echo "${ARR[1]};${ARR[2]};${ARR[0]}" >> template_$1.csv
		fi
 	done < out_$1.csv
 	echo " -node '$1': $(wc -l <out_$1.csv) machines, dont $NBT template(s)"
}
#---------------------------------------------------------------------------

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
  -H "Authorization: PVEAPIToken=$PVUSER@${REALM}!${TOK_NAME}=${TOK_VALUE}" \
  https://anvers.univ-rouen.fr:8006/api2/json/version) 1>>$CURLLOG

if [ $? -eq 0 ] && [ -n "$response" ]; then
    echo "API disponible"
else
    echo "API indisponible, réponse='$response'"
	exit 1
fi

# liste des nodes 
echo "Récupération liste des nodes..."
curl --silent -k \
	-H "Authorization: PVEAPIToken=$PVUSER@${REALM}!${TOK_NAME}=${TOK_VALUE}" \
	https://anvers.univ-rouen.fr:8006/api2/json/nodes|jq | jq -r '.data[] | .node' >nodes.csv 2>>$CURLLOG

echo "Nodes accessibles: $(wc -l < nodes.csv)"

while read -r nodename
do
#	echo "process node $nodename"
	process $nodename
done < nodes.csv






