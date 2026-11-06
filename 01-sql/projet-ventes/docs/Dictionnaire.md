
## 1.Table categories

| Colonne | Type | Signification | Règles attendues |
|-------|-------|---------------|--------------|
| id | int | Identifiant unique de la categorie | unique, clé primaire, obligatoire|
| nom | varchar(50) | Nom de la categorie | obligatoire|

## 2.Table clients

| Colonne | Type | Signification | Règles attendues |
|-------|-------|---------------|--------------|
| id | int | Identifiant unique du client | unique, clé primaire, obligatoire|
| prenom | varchar(50) | Prenom du client | obligatoire|
| ville | varchar(50) | Ville du client | lié à villes, obligatoire |
| telephone| varchar(20) | Numero telephone du client | unique, facultatif |
| date_inscription| date | date d'inscription du client | obligatoire, date du jour par defaut |

## 3.Table commandes

| Colonne | Type | Signification | Règles attendues |
|-------|-------|---------------|--------------|
| id | int | Identifiant unique de la commande | unique, clé primaire, obligatoire |
| client_id | int | Identifiant du client | lié à clients, obligatoire |
| date_commande| date | date de la commande | obligatoire, date du jour par defaut  |
| statut | varchar(20) | Etat de la commande | obligatoire, à choisir entre livrée, en cours et annulée |

## 4.Table lignes_commande

| Colonne | Type | Signification | Règles attendues |
|-------|-------|---------------|--------------|
| id | int | Identifiant unique de la lignes de commandes | unique, clé primaire, obligatoir |
| commande_id|  int |  Identifiant de la commande | lié à commandes, obligatoire |
| produit_id|  int |  Identifiant du produit | lié à produits, obligatoire |
| quantite | int |quantité du produit commandé | obligatoire, superieur à 0 |
| prix_unitaire| decimal(10,2) |prix unitaire du produit commandé | obligatoire, superieur à 0  |

## 5.Table livraisons

| Colonne | Type | Signification | Règles attendues |
|-------|-------|---------------|--------------|
| id | int | Identifiant unique de la livraison | unique, clé primaire,  obligatoire |
| commande_id|  int |  Identifiant de la commande | lié à commandes, obligatoire |
| transporteur | varchar(50) | La personne qui s'occupe de la livraison | obligatoire, à choisir entre Rapido Express,bTransCongo et KivuLogistics |
| date_expedition | date | date de l'expedition de la commande | lié à commandes, obligatoire |
| date_livraison| date | date de la livraison | facultatif |
| statut | varchar(20) | Etat de la livraison| obligatoire, à choisir entre livrée et en transit |

## 6.Table produits

| Colonne | Type | Signification | Règles attendues |
|-------|-------|---------------|--------------|
| id | int | Identifiant unique du produit | unique, clé primaire, obligatoire |
| nom | varchar(50) | Nom du produit | obligatoire |
| categorie_id |  Identifiant de la categorie | lié à categories, facultatif |
| prix| decimal(10,2) |prix unitaire du produit | oblgatoire superieur à 0 |


## 7.Table villes

| Colonne | Type | Signification | Règles attendues |
|-------|-------|---------------|--------------|
| ville | varchar(50) | nom de la ville | unique, clé primaire, obligatoire |
| province | varchar(50) | nom de la province de la ville| obligatoire |
