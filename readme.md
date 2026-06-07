# Documenation des scripts

Auteur: S. Kramm
Date: 2026/06

## Items

### Numérotation des clones

Avec l'API, il n'y a pas génération automatique d'un ID, il faut en donner un dans la requete, et il doit être unique sur tout le cluster.

valeur max: 999999999 (9 chiffres)

Solution retenue:
```
123456789
YYDDDHHMM
```
Avec:
- `YY`: 2 derniers chiffres de l'année
- `DDD`: jour de l'année (1 - 365 )
- `HH`: Heure de création
- `MM`: Minutes de création



