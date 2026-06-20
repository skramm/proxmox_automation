# pgvm: Programme de Gestion de VM

- Auteur: S. Kramm, IUT RT Rouen
- Date: 2026/06
- Statut: alpha
- Licence: ???
- Home: https://github.com/skramm/proxmox_automation


## Pour qui?

1. vous êtes enseignant dans une structure d'enseignement, et vous avez besoin que vos étudiants aient accès à des VM déjà configurées, sur laquelles ils seront administrateurs, pour des TP réseaux, systèmes, etc...
2. vous et vos étudiants disposez d'un accès à un cluster Proxmox
3. vos étudiants sont déjà inscrits dans le Proxmox (soit directement, soit par l'intermediaire d'une authentification centralisée), et regroupés en "groupes d'utilisateurs".

=> Alors cet outil est pour vous!


## TODO:

- bug: lors de la création par clonage, le template se voit affecté des tags?
- ajouter vérification que le vmid ne correspond pas à un numéro déja existant

## Introduction

Nous disposons dans le département d'un hyperviseur "ProxMox", afin que les étudiants puisse disposer de VM pour des TP.

L'interface web native fournie est assez complète mais dans un cadre pédagogique, nous avons des besoins spécifiques qu'elle ne remplit pas.

Pour des TP, nous avons besoin de pouvoir créer un ensemble de VM toutes identiques, typiquement une ou deux par étudiant, et basées sur un même "template", et auquel seul l'étudiant en question peut avoir accès.
Avec l'interface web native, ceci est laborieux: ça implique de cloner les machines une par une, de les nommer, et leur assigner ensuite les permissions ("rôles").
De plus, les VM à créer peuvent être différentes selon les TP, et certains TP peuvent nécessiter aussi de créer 2, voire 3 VM.

Il n'est donc pas envisageable d'utiliser pour cela l'interface web native.

D'autres solutions auraient pu être utilisées (probablement des outils comme Terraform?), l'approche utilisée ici a consisté à utiliser l'API HTTP directement, via `curl` depuis un script bash qui va itérer la création des clones.

L'outil peut aussi être vu comme une supervision, il affiche le nombre de VM et de template par node, ainsi que le nombre de machines allumées et éteintes.
Il peut aussi en une commande allumer ou éteindre un ensemble de machines identifiées via une tag, indépendamment de leur localisation sur un "node".
Et également les supprimer une fois les TP terminés.



**Objectifs de ce programme**:  
avoir un outil permettant de lister, créer/supprimer, démarrer/éteindre, etc.
un ensemble de VM pour des TPs, et leur associer des tags permettant de la manipuler de façon globale.

Pour les collègues de l'URN, une doc générale de type "tuto" sur l'utilisation de Proxmox dans le cadre du dept RT de l'IUT de Rouen est [accessible ici](https://gitlab.univ-rouen.fr/litis-kramm/RT_docs/-/blob/main/proxmox/tuto_proxmox.md)  
(**note**: Implique d'avoir un compte URN et l'accès au gitlab via le CAS URN)

- Référence API: https://pve.proxmox.com/pve-docs/api-viewer/
- wiki: https://pve.proxmox.com/wiki/Proxmox_VE_API

## Utilisation

### Installation

Il faut simplement s'assurer que vous avez les outils nécessaires (voir ci-dessous), puis soit cloner le dépot et exécuter
```
$ sudo ./INSTALL
```
(qui va copier le script dans `/usr/local/bin`)

soit copier le fichier `pgvm` à un endroit référencé par le "path".


#### Outils nécessaires
- `bash`
- `curl`
- `zenity`
- `jq`

(devraient être disponible par défaut dans votre distrib)


### Connection à l'API

La connection à l'API implique d'avoir préalablement généré un "token API" via l'interface web de Proxmox.
Une fois ce token obtenu, il faut le placer dans un fichier qui devra contenir les 6 définitions suivantes:

```
TOK_NAME=XXX
TOK_VALUE=YYY
REALM=MYREALM
PVUSER=ZZZZ
APINODE=brandon
DOMAIN=mydomain.org
```
Remplacer `XXX` et `YYY` par nom et valeur du token généré,
`mydomain.org` par votre domaine,
`MYREALM` par l'identifiant du serveur d'authentification,
et `ZZZZ` par votre identifiant sur le domaine.

**Numéro de port**  
Proxmox utilise par défaut le 8006, et c'est celui qui est utilisé ici par défaut, mais si jamais le gestionnaire du cluster a modifié ceci, il suffit d'ajouter la définition suivante avec le bon numéro:
```
PORT=1234
```

L'API n'est accessible que via l'une des machines du cluster, il faut donc spécifier le nom de celle qui sera utilisée dans la variable `APINODE`.
Si ce node tombe, il suffit d'un prendre un autre.
Mais quel que soit le node choisi pour la connexion, l'ensemble du cluster est manipulable via l'API.

Le lancement du programme sera fait dans un dossier vide, fait en donnant le nom (et chemin éventuel) de ce fichier.
Ce fichier sera ensuite lu (avec `source`) pour récupérer les informations de connexion et d'identification;

```
$ pgvm chemin/vers/le/fichier
```

Ceci va en premier tester la connection à l'API, et affiche un message d'erreur en cas de problème, qu'il faut donc regler.

Il est recommandé de démarrer à partir d'un dossier vide parce que l'ensemble des infos extraites de l'API seront placées dans de nombreux fichiers csv qui vont donc remplir ce dossier.

### Fonctionnalités

Si tout est bon, le lancement affiche l'ensemble des informations de façon synthétique dans la console, puis propose un menu:

![dashboard1](img/dash1.png)

On peut afficher la liste des VM et des "templates" d'un node via "Liste VMs par node", qui indique également leur état (vert: en fonctionnement, rouge: éteint).

![ListeVMparnode](img/listevmnode.png)



#### Création d'un ensemble de machines

**Note 1**: il faut avoir préalablement construit une machine fonctionnelle et la convertir en template.
Ceci se fait depuis l'interface web et n'est pas pris en charge ici.

**Note 2**: les machines seront clonées sur le même node que celui où se trouve le template.

Les VM créées seront obligatoirement associées à un **groupe** d'utilisateurs:
il y aura autant de clones créés que d'utilisateurs dans ce groupe.

Il faut d'abord choisir le node choisi, puis le template.

ICI IMAGE

On donne ensuite un identifiant symbolique pour le nom du cours en question, par exemple `R123`.
Les VM créées auront pour nom cette chaine suivie de l'identifiant de l'étudiant, tels qu'ils sont définis dans l'authentification.

Par exemple: `R123-paul2ch`, `R123-faye7sim`, ...

Attention: pas de underscore (`_`) dans les noms des VM.

Si le TP demande deux VM par étudiant, il faudra répéter la procédure de création et il faudra donner deux identifiants différents.
Par exemple `R123A` et `R123B`.


**Numérotation des clones**

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
- `XX`: un identifiant généré dans le script de création (00 à 99), et commun à l'ensemble des VM créées par la procédure de création.
- `NN`: un identifiant de la machine parmi le lot, généré automatiquement lors de la création du lot (01 à 99)

> [!CAUTION]
> Cette solution implique que la taille des groupes d'étudiants ne peus pas dépasser 99.

#### Suppression d'un ensemble de VM

En l'état, on ne peut supprimer un ensemble de VM que par les tags.

Attention, une machine peut avoir plusieurs tags (par exemple R123 et R456) et si on demande de supprimer toutes les VM avec le tag R456, alors celle-ci sera supprimée aussi.


## Détails technique

Via l'API, un ensemble de requetes va récupérer en JSON les détails sur toutes les machines de chaque node et les convertir en CSV.

Dans l'ordre:
- Après avoir testé la réponse de l'API, on commence par un appel sur le "endpoint" `api2/json/nodes` qui renvoie la liste des nodes du cluster.
- On peut ensuite itérer sur chacun des nodes et via le "endpoint"
`api2/json/nodes/$1/qemu` on obtient tous les détails de chaque VM et template dans un fichier `data_node_NODENAME.csv`.
- On parse ce fichier pour générer un fichier `data_template_NODENAME.csv`, contenant la liste des templates de ce node.


## FAQ

- Q: Pourquoi ne pas avoir construit ceci sous la forme d'une commande CLI?  
R: L'idée était de faire quelque chose de facile et intuitif de prise en main, mais sans imposer de "framework" lourd, donc l'utilisation de zenity, assez courant dans les distrib contemporaines, semblait une bonne idée.
Mais il y avait des alternatives, notamment [dialog](https://linux.die.net/man/1/dialog), mais plus complexe à mettre en oeuvre.
Je suis parti sur `zenity`, mais il y a des limitations:
pas de "checkbox" notamment, contrairement à `dialog`.


- Q: Est-ce que ceci est utilisable sous Windows avec WSL?  
R: Aucune idée, mais je suis preneur de retours!

- Q: Pourquoi des affichages en français?  
R: L'idée initiale était de faciliter l'usage en interne (IUT Rouen/URN), mais à terme j'envisage une internationalisation
(mais bon, c'est en bash, donc faut pas trop complexifier non plus...)




