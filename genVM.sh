
# Script de gestion d'un ensemble de machines

# !!!!!!!!!!!! WIP !!!!!!!!!!!!

# arg

# désactive l'interprétation de '!' dans une chaine
set +H



# read token details
source ../token_20260110


NODE=$(zenity --list --text="Choisissez le noeud" --column="nodes" anvers gand bruxelles)
if [ $? != 0 ]; then
	echo "Interruption"; exit 1
fi

echo "NODE=$NODE"

# Afficher la liste des templates dispos sur ce noeud

# TODO faire une requete sur le noeud pour lister les machines et en extraire celles qui sont des template

TEMPLATE=$(zenity --list --text="Quel template à utiliser?" --column="templates" $TEMPLATES)
if [ $? != 0 ]; then
	echo "Interruption"; exit 1
fi
echo "TEMPLATE=$TEMPLATE"


NB=$(zenity --scale --text "Combien de VM" --step=1 \
	--value=1 \
	--min-value=1 \
	--max-value=30)
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


START=$(zenity --question --text "Ok pour créer $NB VM, nommées ${MOD}_1 à ${MOD}_NB, basées sur le template $TEMPLATE et ayant les tags $TAGS?")
if [ $? != 0 ]; then
	echo "Interruption"; exit 1
fi
echo "START=$START"

exit

for a in 
do

curl -k \
	-H "Authorization: PVEAPIToken=${USER}@UR!${TOK_NAME}=${TOK_VALUE}" \
	https://anvers.univ-rouen.fr:8006/api2/json/

done

