
# Script de gestion d'un ensemble de machines

# !!!!!!!!!!!! WIP !!!!!!!!!!!!

# arg

# désactive l'interprétation de '!' dans une chaine
set +H

if [ "$1" = "" ]
then
	echo "Erreur, donner votre id 5+3 en argument"
	exit 1
fi
PVUSER=$1

YEARDAY=$(date '+%y%j%H%m')
#echo $YEARDAY
#exit

# read token details
source ../token_20260110

ISOK=$(zenity --question --text "L'inventaire des machines est-il à jour?")
if [ $? != 0 ]; then
	./exportVM.sh PVUSER
fi
echo "ISOK=$ISOK"

NODE=$(zenity --list --text="Choisissez le noeud" --column="nodes" anvers gand bruxelles)
if [ $? != 0 ]; then
	echo "Interruption"; exit 1
fi

echo "NODE=$NODE"

# Afficher la liste des templates dispos sur ce noeud
if ! [ -f template_$NODE.csv ]
then
	echo "Aucun template disponible sur ce noeud"
	exit 1
fi

# construction chaine contenant les noms des templates

declare -a TEMPLATES
IFS=";";while read -a ARR
do
	echo "TEMPLATES=$TEMPLATES ARR[0]=${ARR[0]}"
	x=${ARR[0]}
	TEMPLATES+=($x)
done < template_$NODE.csv


echo "t=${TEMPLATES[@]}"

TEMPLATE=$(zenity --list --text="Quel template à utiliser?" --column="templates" ${TEMPLATES[@]})
if [ $? != 0 ]; then
	echo "Interruption"; exit 1
fi
echo "TEMPLATE=$TEMPLATE"


# récupération du vmid du template
IFS=";";while read -a ARR
do
	if [ ${ARR[0]} = $TEMPLATE ]
	then
		VMID=${ARR[2]}
	fi 
done < template_$NODE.csv

echo "VMID=$VMID"


NB=$(zenity --entry --text "Combien de VM?")
if [ $? != 0 ]; then
	echo "Interruption"; exit 1
fi

echo "NB=$NB"


MOD=$(zenity --entry --text "Donner le nom du module (RXXX, SAETTT)\n(servira pour le nom des VM)")
if [ $? != 0 ]; then
	echo "Interruption"; exit 1
fi
echo "MOD=$MOD"


TAGS=$(zenity --entry --text "Donner les tags a associer aux VMs")
if [ $? != 0 ]; then
	echo "Interruption"; exit 1
fi
echo "TAGS=$TAGS"


START=$(zenity --question --text \
	"Ok pour créer $NB VM, nommées ${MOD}-1 à ${MOD}-${NB}, basées sur le template $TEMPLATE et ayant les tags '$TAGS'?")
if [ $? != 0 ]; then
	echo "Interruption"; exit 1
fi
echo "START=$START"


#-------------------------

set -x
for i in $(seq 1 $NB)
do
echo "CREATION CLONE i=$i"
#curl --silent -k \
response=$(curl -k \
	-H "Authorization: PVEAPIToken=${USER}@${REALM}!${TOK_NAME}=${TOK_VALUE}" \
	"https://anvers.univ-rouen.fr:8006/api2/json/nodes/$NODE/qemu/$VMID/clone?node=$NODE&vmid=$VMID&newid=$YEARDAY&name=${MOD}_$i")
err=$?
echo "response=$response err=$err"

echo "Ajout des tags"

done

