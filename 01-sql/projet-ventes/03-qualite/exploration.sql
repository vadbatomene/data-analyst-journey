-- 1. Le nombre de lignes de chaque table (contrôle ci-dessus).

SELECT 'categories' AS 'table', COUNT(*) AS nb_lignes FROM categories
UNION ALL
SELECT 'villes', COUNT(*) FROM villes
UNION ALL
SELECT 'clients', COUNT(*) FROM clients
UNION ALL
SELECT 'produits', COUNT(*) FROM produits
UNION ALL
SELECT 'commandes', COUNT(*) FROM commandes
UNION ALL
SELECT 'lignes_commande', COUNT(*) FROM lignes_commande
UNION ALL
SELECT 'livraisons', COUNT(*) FROM livraisons;

-- 2.Les dates minimale et maximale de commandes.date_commande et de clients.date_inscription.

SELECT 'date_commande' as date_type, MIN(date_commande) as date_min,  MAX(date_commande) as date_max FROM commandes
UNION ALL
SELECT 'date_inscription', MIN(date_inscription), MAX(date_inscription) FROM clients;

-- 3.Les valeurs distinctes et leurs effectifs pour commandes.statut, livraisons.statut et livraisons.transporteur. 
-- Attendu : 3 statuts pour les commandes, 2 pour les livraisons, 3 transporteurs.

SELECT statut, COUNT(*) as effectit FROM commandes GROUP BY statut;
SELECT statut, COUNT(*) as effectit FROM livraisons GROUP BY statut;
SELECT transporteur, COUNT(*) as effectit FROM livraisons GROUP BY transporteur ;

-- 4.Le nombre de clients par ville, avec leur part en %.

SELECT ville, COUNT(id) as nb_client, ROUND(COUNT(id)/(SELECT COUNT(*) FROM clients)*100,2) as Pourcentage FROM clients GROUP BY ville;

-- 5.Le nombre de produits par catégorie, avec le prix minimum, moyen et maximum, en incluant les produits qui n’ont pas de catégorie.

SELECT c.id, c.nom, COUNT(p.id) as nb_produits, MIN(p.prix) AS prix_min, ROUND(AVG(p.prix),2) AS prix_moyen, MAX(p.prix) AS prix_max FROM produits p  
LEFT JOIN categories c ON p.categorie_id=c.id
GROUP by c.id, c.nom;

-- 6.La répartition du nombre de lignes par commande.

SELECT nb_lignes, COUNT(*) AS nb_commandes
FROM (SELECT commande_id, COUNT(*) AS nb_lignes
      FROM lignes_commande GROUP BY commande_id) t
GROUP BY nb_lignes
ORDER BY nb_lignes;

-- 7. Pour chaque table, le nombre de valeurs vides (NULL) de chaque colonne (COUNT(*) - COUNT(colonne)).

-- categories aucun
SELECT
    COUNT(*) - COUNT(id) AS null_id,
    COUNT(*) - COUNT(nom) AS null_nom
FROM categories;

-- clients 30 telephones null
SELECT
    COUNT(*) - COUNT(id) AS null_id,
    COUNT(*) - COUNT(prenom) AS null_prenom,
    COUNT(*) - COUNT(ville) AS null_ville,
    COUNT(*) - COUNT(telephone) AS null_telephone,
    COUNT(*) - COUNT(date_inscription) AS null_date_inscription
FROM clients ;

-- commandes  aucun
SELECT
    COUNT(*) - COUNT(id) AS null_id,
    COUNT(*) - COUNT(client_id) AS null_client_id,
    COUNT(*) - COUNT(statut) AS null_statut,
    COUNT(*) - COUNT(date_commande) AS null_prenom
FROM commandes ;

-- lignes_commande  aucun
SELECT
    COUNT(*) - COUNT(id) AS null_id,
    COUNT(*) - COUNT(commande_id) AS null_commande_id,
	COUNT(*) - COUNT(produit_id) AS null_produit_id,
    COUNT(*) - COUNT(quantite) AS null_quantite,
    COUNT(*) - COUNT(prix_unitaire) AS null_prix_unitaire
FROM lignes_commande ;

-- livraisons 391 date_livraison null
SELECT
    COUNT(*) - COUNT(id) AS null_id,
    COUNT(*) - COUNT(commande_id) AS null_commande_id,
	COUNT(*) - COUNT(transporteur) AS null_transporteur,
    COUNT(*) - COUNT(date_expedition) AS null_date_expedition,
    COUNT(*) - COUNT(date_livraison) AS null_date_livraiso,
    COUNT(*) - COUNT(statut) AS null_statut
FROM livraisons ;

-- produits 2 categorie_id null
SELECT
    COUNT(*) - COUNT(id) AS null_id,
    COUNT(*) - COUNT(nom) AS null_nom,
	COUNT(*) - COUNT(categorie_id) AS null_categorie_id,
    COUNT(*) - COUNT(prix) AS null_prix
FROM produits ;

-- villes  aucun
SELECT
    COUNT(*) - COUNT(ville) AS null_ville,
    COUNT(*) - COUNT(province) AS null_province
FROM villes ;

-- 8.L’unicité des identifiants : COUNT(*) comparé à COUNT(DISTINCT id) pour chaque table qui a une colonne id.
-- categorie
SELECT
    COUNT(*) AS total_lignes,
    COUNT(DISTINCT id) AS identifiants_distincts
FROM categories;

-- clients
SELECT
    COUNT(*) AS total_lignes,
    COUNT(DISTINCT id) AS identifiants_distincts
FROM clients;

-- commandes
SELECT
    COUNT(*) AS total_lignes,
    COUNT(DISTINCT id) AS identifiants_distincts
FROM commandes;

-- lignes_commande
SELECT
    COUNT(*) AS total_lignes,
    COUNT(DISTINCT id) AS identifiants_distincts
FROM lignes_commande;

-- livraisons
SELECT
    COUNT(*) AS total_lignes,
    COUNT(DISTINCT id) AS identifiants_distincts
FROM livraisons;

-- produits
SELECT
    COUNT(*) AS total_lignes,
    COUNT(DISTINCT id) AS identifiants_distincts
FROM produits;

-- villes
SELECT
    COUNT(ville) AS total_lignes,
    COUNT(DISTINCT ville) AS identifiants_distincts
FROM villes;

-- PAS DE DOUBLONS