
# Script de gestion d'un ensemble de machines

# arg

=$1
NB=$2

echo "Donner le nom du token"
read TOKEN_NAME

echo "Copie la clé"
read TOKEN_SECRET




for a in 
do

curl -k \
	-H 'Authorization: PVEAPIToken=${USER}@UR!${TOKEN_NAME}=${TOKEN_SECRET}' \
	https://anvers.univ-rouen.fr:8006/api2/json/

done

