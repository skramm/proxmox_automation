# Documentation du projet

Auteur: S. Kramm, IUT Rouen
Date: 2026/06

!!! WIP !!!


## TODO:

- gestion des permissions

voir
https://pve.proxmox.com/pve-docs/api-viewer/#/access/acl

https://chatgpt.com/c/6a285885-2634-83ed-9ca0-cba201d102ba

## Introduction

Objectif de ces scripts:
avoir des outils permettant de lister, créer/supprimer, démarrer/éteindre, etc.
un ensemble de VM pour des TPs, et s'appuyant sur l'API de Proxmox.

Note: inspiré par la présentation de ?? à l'ACD St Malo, juin 2026

Pour l'utilisation générale de Proxmox,
[voir ici](https://gitlab.univ-rouen.fr/litis-kramm/RT_docs/-/blob/main/proxmox/tuto_proxmox.md)

(**note**: Implique d'avoir un compte URN et l'accès au gitlab via le CAS URN)

- Référence API: https://pve.proxmox.com/pve-docs/api-viewer/
- wiki: https://pve.proxmox.com/wiki/Proxmox_VE_API

## Items documentés

### Connection à l'API

La connection à l'API implique d'avoir préalablement généré un "token API" via l'interface graphique.
(voir section `3.3 - Utilisation de l'API` dans la doc ci-dessus).

Une fois ce token obtenu, il faut le placer dans un fichier qui devra contenir les définitions suivantes:

```
TOK_NAME=XXX
TOK_VALUE=YYY
REALM=UR
PVUSER=ZZZZ
```
Et remplacer `XXX` et `YYY` par nom et valeur du token généré, et ZZZZ par votre id "5+3" URN.

Dans ces scripts, ce fichier sera lu (avec `source`) de façon à récupérer les informations d'identification.


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


### Tags

...



