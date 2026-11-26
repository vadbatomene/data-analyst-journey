use congo_shop;

-- 1.Clients en double : définis une règle de doublon (par exemple même prénom, même téléphone non vide et même ville), compte les groupes et les lignes concernées, et affiche des exemples.
-- Règle : Les clients qui ont le meme nom, ville, telephone
SELECT count(id) as nb, prenom, ville, telephone FROM clients WHERE telephone IS NOT NULL AND TRIM(telephone)!=''
GROUP BY prenom, ville, telephone
HAVING nb>1;


WITH doublons as (SELECT count(id) as nb, prenom, ville, telephone FROM clients WHERE telephone IS NOT NULL AND TRIM(telephone)!=''
GROUP BY prenom, ville, telephone
HAVING nb>1)
SELECT count(nb) as nb_groupe, sum(nb) as nb_lignes FROM doublons;



-- 2.Téléphones absents : compte les NULL et les chaînes vides, séparément.
SELECT count(id) as nb_phone_null FROM clients WHERE telephone is NULL;
SELECT count(id) as nb_phone_vide FROM clients WHERE telephone='';
select  * from clients;

-- 3.Produits sans catégorie : la liste complète, avec leur prix.
SELECT id, nom, prix, categorie_id FROM produits WHERE categorie_id is NULL OR categorie_id="";

-- 4.Commandes non annulées sans livraison : compte-les,

SELECT count(o.id) FROM commandes o
LEFT JOIN livraisons l ON o.id=l.commande_id
 WHERE o.statut != 'annulée' and l.id is NULL;
 
-- et regarde si elles se concentrent sur un mois, 
SELECT DATE_FORMAT(o.date_commande, '%m-%Y') as mois_commande, COUNT(o.id) as nb_commande
FROM commandes o LEFT JOIN clients c ON o.client_id=c.id
LEFT JOIN livraisons l ON o.id=l.commande_id
WHERE o.statut != 'annulée' and l.id is NULL
GROUP BY DATE_FORMAT(o.date_commande, '%m-%Y')
ORDER BY COUNT(o.id) DESC ;

-- un statut 
SELECT o.statut, COUNT(o.id) as nb_commande
FROM commandes o LEFT JOIN clients c ON o.client_id=c.id
LEFT JOIN livraisons l ON o.id=l.commande_id
WHERE o.statut != 'annulée' and l.id is NULL
GROUP BY o.statut
ORDER BY COUNT(o.id) DESC ;

-- ou une ville.
SELECT c.ville, COUNT(o.id) as nb_commande 
FROM commandes o LEFT JOIN clients c ON o.client_id=c.id
LEFT JOIN livraisons l ON o.id=l.commande_id
WHERE o.statut != 'annulée' and l.id is NULL
GROUP BY c.ville 
ORDER BY COUNT(o.id) DESC ;

-- 5.Livraisons incohérentes : 
-- (a) livraison datée avant la commande (jointure avec commandes), 
SELECT l.id as id_livraison, l.commande_id, o.date_commande, l.date_livraison
FROM livraisons l LEFT JOIN commandes o ON l.commande_id=o.id 
WHERE l.date_livraison < o.date_commande;

-- (b) livraison avant son expédition, 
SELECT * FROM livraisons WHERE date_livraison < date_expedition;

-- (c) statut incohérent avec la date (livrée sans date, en transit avec une date).
SELECT * FROM livraisons WHERE statut='livrée' and date_livraison is null;
SELECT * FROM livraisons WHERE statut='en transit' and date_livraison is not null;

-- 6.Lignes de commande anormales : 
-- quantités et prix négatifs ou nuls ; 
SELECT * FROM lignes_commande WHERE quantite <=0 or prix_unitaire <=0;

-- calcule aussi leur effet sur le chiffre d’affaires (la somme quantite * prix_unitaire de ces lignes).
SELECT SUM(quantite*prix_unitaire) as SUM FROM lignes_commande WHERE quantite <=0 or prix_unitaire <=0;

-- 7.Orphelins : 
-- commandes sans client, 
SELECT o.id, o.client_id, o.date_commande
FROM commandes o
LEFT JOIN clients c ON c.id = o.client_id
WHERE c.id IS NULL;

-- lignes sans commande ou sans produit, 
SELECT l.id, l.commande_id, l.produit_id, l.quantite, l.prix_unitaire
FROM lignes_commande l
LEFT JOIN commandes c ON c.id=l.commande_id
WHERE c.id is NULL ;

-- livraisons sans commande.
SELECT l.id, l.commande_id, l.transporteur, l.date_expedition, l.date_livraison, l.statut
FROM livraisons l
LEFT JOIN commandes c ON c.id=l.commande_id
WHERE c.id is NULL ;

-- 8.Cohérence des dates : 
-- commandes avant l’inscription du client, 
SELECT o.*, c.date_inscription FROM commandes o 
LEFT JOIN clients c ON o.client_id=c.id
WHERE o.date_commande < c.date_inscription;

-- dates hors de l’année 2025.
SELECT * FROM clients WHERE DATE_FORMAT(date_inscription, '%Y') !=2025;
SELECT * FROM commandes WHERE DATE_FORMAT(date_commande, '%Y') !=2025;
SELECT * FROM livraisons WHERE DATE_FORMAT(date_expedition, '%Y') !=2025 OR DATE_FORMAT(date_livraison, '%Y') !=2025;

-- 9.Textes douteux : prénoms vides, espaces en début ou en fin de texte, villes ou statuts hors des valeurs attendues.
SELECT LENGTH('  abc ') <> LENGTH(TRIM('  abc '));

SELECT *
FROM clients
WHERE prenom IS NULL
   OR TRIM(prenom) = ''
   OR prenom <> TRIM(prenom)
   OR ville IS NULL
   OR TRIM(ville) = ''
   OR ville <> TRIM(ville)
   OR ville NOT IN (SELECT DISTINCT ville FROM villes);
   
SELECT * FROM commandes WHERE statut IS NULL OR TRIM(statut) = '' OR statut != TRIM(statut);
SELECT * FROM livraisons WHERE transporteur is NULL
OR TRIM(transporteur)='' OR transporteur != TRIM(transporteur)
OR statut IS NULL OR TRIM(statut) = '' OR statut != TRIM(statut);
   
