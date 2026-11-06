
## 1.Table categories

| Colonne | Type | Signification | Règles attendues |
|-------|-------|---------------|--------------|
| id | int | Identifiant unique de la categorie | unique, clé primaire, facultatif|
| nom | varchar(50) | Nom de la categorie | facultatif |



## 2.Table clients

| Colonne | Type | Signification | Règles attendues |
|-------|-------|---------------|--------------|
| id | int | Identifiant unique du client | unique, clé primaire, facultatif|
| nom | varchar(50) | Nom du client | facultatif |
| ville | varchar(50) | Ville du client | facultatif |
| telephone| varchar(20) | Numero telephone du client | facultatif |
| date_inscription| date | date d'inscription du client | facultatif |

## 3.Table commandes

| Colonne | Type | Signification | Règles attendues |
|-------|-------|---------------|--------------|
| id | int | Identifiant unique de la commande | unique, clé primaire, facultatif|
| client_id | int | Identifiant unique du client | unique, clé primaire, facultatif|
| date_commande| date | date de la commande | facultatif |
| statut | varchar(20) | Etat de la commande | facultatif |


## 4.Table lignes_commandes

| Colonne | Type | Signification | Règles attendues |
|-------|-------|---------------|--------------|
| id | int | Identifiant unique de la lignes de commandes | unique, clé primaire, facultatif|
| commande_id|  int | Identifiant unique de la commande | unique, clé primaire, facultatif|
| produit_id|  int | Identifiant unique du produit | unique, clé primaire, facultatif|
| quantite | int |quantité du produit commandé | facultatif |
| quantite | decimal(10,2) |prix unitaire du produit commandé | facultatif |

## 5.Table livraisons

| Colonne | Type | Signification | Règles attendues |
|-------|-------|---------------|--------------|
| id | int | Identifiant unique de la livraison | unique, clé primaire, facultatif|
| commande_id|  int | Identifiant unique de la commande | unique, clé primaire, facultatif|
| transporteur | varchar(50) | La personne qui s'occupe de la livraison | facultatif |
| date_expedition | date | date de l'expedition de la commande | facultatif |
| date_livraison| date | date de la livraison | facultatif |
| statut | varchar(20) | Etat de la livraison| facultatif |
