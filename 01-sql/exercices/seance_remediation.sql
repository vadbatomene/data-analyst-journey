-- ======================================================
-- Séance de remédiation : notions à revoir (SQL)
-- Tables : clients, commandes, produits, villes
-- Une requête par exercice, sous son numéro.
-- ======================================================

USE formation;

-- ------------------------------------------------------
-- Bloc A : fenêtrage, critère et sens du classement
-- ------------------------------------------------------

-- A1 Pour chaque ville, le client le plus jeune.

WITH clients_age AS (SELECT *, RANK() OVER (PARTITION BY ville ORDER BY age) AS rang FROM clients)
SELECT prenom, ville, age FROM clients_age WHERE rang=1;

-- A2 Pour chaque ville, le client le plus âgé.

WITH clients_age AS (SELECT *, RANK() OVER (PARTITION BY ville ORDER BY age DESC) AS rang FROM clients)
SELECT prenom, ville, age FROM clients_age WHERE rang=1;

-- A3 Classe les commandes par montant décroissant dans chaque catégorie de produit (nom du produit, catégorie, montant, rang).

SELECT o.produit, p.categorie, o.montant, 
RANK() OVER (PARTITION BY p.categorie ORDER BY o.montant DESC) AS rang
FROM commandes o 
LEFT JOIN produits p ON o.produit_id=p.id;

-- A4 Pour chaque client ayant commandé, sa commande la plus récente (prénom, nom du produit, date).

WITH commandes_date AS (SELECT c.id, c.prenom, o.produit, o.date_commande, 
RANK() OVER (PARTITION BY c.id ORDER BY o.date_commande DESC) as rang
FROM clients c
INNER JOIN commandes o ON c.id=o.client_id)
SELECT prenom, produit,date_commande FROM commandes_date WHERE rang=1;

-- ------------------------------------------------------
-- Bloc B : part dans un groupe
-- ------------------------------------------------------

-- B1 Pour chaque commande d'un client connu, sa part (%) dans la dépense totale de ce client (2 décimales).

SELECT c.id, c.prenom, o.id, o.produit, o.montant, 
ROUND(o.montant * 100 / SUM(o.montant) OVER (PARTITION BY c.id), 2) AS '%'
FROM commandes o 
INNER JOIN clients c ON o.client_id=c.id;

-- B2 Pour chaque commande d'un client connu, sa part (%) dans le total de sa province (2 décimales).


SELECT c.id, c.prenom, o.id, o.produit, v.province, o.montant, 
ROUND(o.montant * 100 / SUM(o.montant) OVER (PARTITION BY v.province), 2) AS '%'
FROM commandes o 
INNER JOIN clients c ON o.client_id=c.id
INNER JOIN villes v ON c.ville=v.ville;

-- ------------------------------------------------------
-- Bloc C : comptage avec LEFT JOIN
-- ------------------------------------------------------

-- C1 Pour chaque client, même sans commande : nombre de commandes et plus grosse commande (0 si aucune).

SELECT c.id, c.prenom, COUNT(o.id) AS nb_commandes, COALESCE( MAX(o.montant),0) as grosse_commande
FROM clients c 
LEFT JOIN commandes o ON o.client_id=c.id 
GROUP BY c.id, c.prenom;

-- C2 Pour chaque ville de la table villes : nombre de commandes de plus de 100 et leur montant total (0 si aucune).

SELECT c.ville, COUNT(o.id) AS nb_commandes, SUM(o.montant) as total
FROM clients c 
LEFT JOIN commandes o ON o.client_id=c.id 
WHERE o.montant>100
GROUP BY c.ville;

-- ------------------------------------------------------
-- Bloc D : conditions de jointure et contrôle de cohérence
-- ------------------------------------------------------

-- D1 Pour chaque province et chaque catégorie de produit, le nombre de commandes. Vérifie que la somme est correcte.

SELECT v.province, p.categorie, COUNT(o.id) AS nb_commandes
FROM commandes o 
INNER JOIN clients c ON o.client_id=c.id
INNER JOIN villes v ON c.ville=v.ville
INNER JOIN produits p ON o.produit_id=p.id
GROUP BY p.categorie, v.province ;

-- D2 Quel est le montant total des commandes de clients connus ? Compare-le à la somme de tes totaux par province.
WITH tempo as (SELECT (
SELECT SUM(montant)
FROM clients c
INNER JOIN commandes o ON c.id=o.client_id) as sum_client ,

(SELECT SUM(montant)
FROM commandes o
LEFT JOIN clients c ON o.client_id = c.id
LEFT JOIN villes v ON c.ville=v.ville) as sum_prov)
SELECT *, sum_prov-sum_client as difference FROM tempo ; 

-- D3 Cette requête est fausse. Lance-la, explique pourquoi les totaux sont faux, puis corrige-la.
SELECT v.province, SUM(o.montant) AS total
FROM clients c
INNER JOIN commandes o ON c.id = o.client_id
INNER JOIN villes v ON c.ville = c.ville
GROUP BY v.province;

-- La liaison dans villes est c.ville=c.ville au lieu de le lier sur v.ville, voici la bonne requete

SELECT v.province, SUM(o.montant) AS total
FROM clients c
INNER JOIN commandes o ON c.id = o.client_id
INNER JOIN villes v ON c.ville = v.ville
GROUP BY v.province;


-- ------------------------------------------------------
-- Bloc E : respect des consignes
-- ------------------------------------------------------

-- E1 En utilisant exactement deux CTE enchaînés, affiche les provinces ayant des commandes dont le montant total dépasse la moyenne des totaux par province.

WITH 
	prov_tot AS 
	(SELECT v.province, SUM(o.montant) AS total
	FROM clients c
	INNER JOIN commandes o ON c.id = o.client_id
	INNER JOIN villes v ON c.ville = v.ville
	GROUP BY v.province),
	moyen_prov_tot AS 
	(SELECT AVG(total) FROM prov_tot)
SELECT * FROM prov_tot WHERE total > (SELECT * FROM moyen_prov_tot);

-- E2 Affiche les commandes de plus de 30 (strictement), triées de la plus récente à la plus ancienne, avec la date au format JJ/MM/AAAA.

-- En tout cas je ne comprends pas plus de 30

-- ------------------------------------------------------
-- Bloc F : exercices de contrôle (sans regarder la correction)
-- ------------------------------------------------------

-- F1 (variante du 7.1) Pour chaque province : nombre de commandes et montant total, 0 si aucune.

SELECT v.province, COUNT(o.id) AS nb_commandes
	FROM villes v
	LEFT JOIN clients c ON c.ville = v.ville
    LEFT JOIN commandes o ON c.id = o.client_id
	GROUP BY v.province;

-- F2 (variante du 7.4) Pour chaque ville : le client qui a le moins dépensé, parmi ceux qui ont commandé.

WITH commande_range AS (SELECT c.id, c.prenom, c.ville, SUM(o.montant) as total, 
RANK() OVER (PARTITION BY c.ville ORDER BY SUM(o.montant)) as rang
FROM clients c
INNER JOIN commandes o ON c.id=o.client_id
GROUP BY c.id, c.prenom, c.ville)
SELECT ville, Total FROM commande_range WHERE rang=1;

-- F3 (variante du 7.7) Pour chaque catégorie de produit : la part (%) de chaque province dans le total de la catégorie.

WITH prov_cat AS (SELECT v.province, p.categorie, SUM(o.montant) as total
FROM  commandes o
INNER JOIN clients c ON o.client_id=c.id
INNER JOIN villes v ON c.ville=v.ville
INNER JOIN produits p ON p.id=o.produit_id
GROUP BY v.province, p.categorie),
tot_cat as (SELECT categorie, SUM(total) as totcat FROM prov_cat GROUP BY categorie),
tempo AS (SELECT a.province, a.categorie, a.total, b.totcat
FROM prov_cat a 
INNER JOIN tot_cat b ON a.categorie=b.categorie)
SELECT *, ROUND(total / totcat * 100,2) AS '%' FROM tempo;

