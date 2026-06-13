# Documentation du projet

- Auteur: S. Kramm, IUT RT Rouen
- Date: 2026/06
- Statut: alpha
- Licence: ???


## Outils nécessaires
- `bash`
- `curl`
- `zenity`
- `jq`

(devraient être disponible par défaut dans votre distrib)

## TODO:

- gestion des permissions/rôles:  
voir
https://pve.proxmox.com/pve-docs/api-viewer/#/access/acl

- bug: lors de la création par clonage, le template se voit affecté des tags?

## Introduction

Nous disposons dans le département d'un hyperviseur "ProxMox", afin que les étudiants puisse disposer de VM pour des TP.

L'interface web native fournie est assez complète mais dans un cadre pédagogique, nous avons des besoins spécifiques qu'elle ne remplit pas.

Pour des TP, nous avons besoin de pouvoir créer un ensemble de VM toutes identiques, typiquement une ou deux par étudiant, et basées sur un même "template".
Avec l'interface web native, ceci est laborieux: ça implique de cloner les machines une par une, et leur assigner ensuite les permissions ("rôles).
De plus, les VM à créer peuvent être différentes selon les TP, et certains TP peuvent nécessiter aussi de créer 2, voire 3 VM.

Il n'est donc pas envisageable d'utiliser pour cela l'interface web native.

D'autres solutions auraient pu être utilisées (probablement des outils comme Terraform?), l'approche utilisée ici a consisté à utiliser l'API HTTP directement, via `curl` depuis un script bash.


**Objectifs de ce programme**:  
avoir un outil permettant de lister, créer/supprimer, démarrer/éteindre, etc.
un ensemble de VM pour des TPs, en spécifiant les noms des machines et les tags associés.

Pour les collègues de l'URN, une doc générale de type "tuto" sur l'utilisation de Proxmox dans le cadre du dept RT de l'IUT de Rouen est [accessible ici](https://gitlab.univ-rouen.fr/litis-kramm/RT_docs/-/blob/main/proxmox/tuto_proxmox.md)  
(**note**: Implique d'avoir un compte URN et l'accès au gitlab via le CAS URN)

- Référence API: https://pve.proxmox.com/pve-docs/api-viewer/
- wiki: https://pve.proxmox.com/wiki/Proxmox_VE_API

## Items documentés

### Connection à l'API

La connection à l'API implique d'avoir préalablement généré un "token API" via l'interface graphique.

Une fois ce token obtenu, il faut le placer dans un fichier qui devra contenir les définitions suivantes:

```
TOK_NAME=XXX
TOK_VALUE=YYY
REALM=UR
PVUSER=ZZZZ
APINODE=brandon
DOMAIN=mydomain.org
PORT=1234
```
Remplacer `XXX` et `YYY` par nom et valeur du token généré,
`mydomain.org` par votre domaine,
ZZZZ par votre identifiant sur le domaine, 
et donner le bon numéro de port.

L'API n'est accessible que via l'une des machines du cluster, il faut donc spécifier le nom de celle qui sera utilisée dans la variable `APINODE`.
Si ce node tombe, il suffit d'un prendre un autre.
Mais quel que soit le node choisi pour la connexion, l'ensemble du cluster est manipulable via l'API.

Le lancement du programme se fait en donnant le nom (et chemin éventuel) de ce fichier.
Ce fichier sera ensuite lu (avec `source`) pour récupérer les informations de connexion et d'identification.


### Suppression d'un ensemble de VM

En l'état, on ne peut supprimer un ensemble de VM que par les tags.

Attention, une machine peut avoir plusieurs tags (par exemple R123 et R456) et si on demande de supprimer toutes les VM avec le tag R456, alors celle-ci sera supprimée aussi.



### Numérotation des clones

Avec l'API, il n'y a pas génération automatique d'un ID (comme c'est le cas avec l'interface web), il faut en donner un dans la requete à l'API.
Cet identifiant (entier) doit être unique sur tout le cluster.

valeur max: 999999999 (9 chiffres)

Solution retenue:
```
123456789
YYDDDXXNN
```
Avec:
- `YY`: 2 derniers chiffres de l'année
- `DDD`: jour de l'année (1 - 365 )
- `XX`: un identifiant donné dans le script de création (00 à 99), et commun à l'ensemble des VM créées par le script
- `NN`: un identifiant de la machine, lors de la création d'un ensemble de VM (01 à 99)


### Détails technique

Via l'API, un ensemble de requetes va récupérer en JSON les détails sur toutes les machines de chaque node et les convertir en CSV.

Dans l'ordre:
- Après avoir testé la réponse de l'API, on commence par un appel sur le "endpoint" `api2/json/nodes` qui renvoie la liste des nodes du cluster.
- On peut ensuite itérer sur chacun des nodes et via le "endpoint"
`api2/json/nodes/$1/qemu` on obtient tous les détails de chaque VM et template dans un fichier `data_node_NODENAME.csv`.
- On parse ce fichier pour générer un fichier `data_template_NODENAME.csv`, contenant la liste des templates de ce node.


## FAQ

- Q: Pourquoi ne pas avoir construit ceci sous la forme d'une commande CLI?  
R: L'idée était de faire quelque chose de facile et intuitif de prise en main, mais sans imposer de "framework" lourd, donc l'utilisation de zenity, assez courant dans les distrib contemporaines, semblait une bonne idée.
Mais il y avait des alternatives, notamment [dialog](https://linux.die.net/man/1/dialog).

Je suis parti sur `zenity`, mais il y a des limitations:
pas de "checkbox" notamment, contrairement à `dialog`.


- Q: Est-ce que ceci est utilisable sous Windows avec WSL?  
R: Aucune idée, mais je suis preneur de retours!

- Q: Pourquoi des affichages en français?  
R: L'idée initiale était de faciliter l'usage en interne (IUT/URN), mais à terme j'envisage une internationalisation
(mais bon, c'est en bash, donc faut pas trop complexifier non plus...)




