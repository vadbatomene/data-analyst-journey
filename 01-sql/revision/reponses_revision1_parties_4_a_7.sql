-- ======================================================
-- Révision SQL 1 (version 2, parties 4 à 7) : mes réponses
-- Une requête par exercice, sous son numéro.
-- Tables : clients, commandes, produits, villes
-- ======================================================

USE formation;

-- ------------------------------------------------------
-- Partie 4 : sous-requêtes et CTE (séance 4)
-- ------------------------------------------------------

-- 4.1 [facile] Affiche les clients plus jeunes que l'âge moyen de tous les clients.

SELECT * FROM clients WHERE age<(SELECT AVG(age) FROM clients);

-- 4.2 [moyen] Affiche les commandes dont le montant dépasse la moyenne des montants.

SELECT * FROM commandes WHERE montant>(SELECT AVG(montant) FROM commandes);

-- 4.3 [moyen] Avec IN, affiche les prénoms des clients qui ont passé au moins une commande.

SELECT prenom FROM clients WHERE id IN (SELECT client_id FROM commandes);

-- 4.4 [moyen] Avec NOT IN, affiche les prénoms des clients qui n'ont passé aucune commande.

SELECT prenom FROM clients WHERE id NOT IN (SELECT client_id FROM commandes);

-- 4.5 [difficile] Avec un CTE, calcule le montant moyen des commandes par catégorie de produit, puis affiche les commandes (id, nom du produit, catégorie, montant) dont le montant dépasse la moyenne de leur catégorie.

WITH moyen_cat AS (SELECT p.categorie, AVG(o.montant) as total
	FROM produits p INNER JOIN commandes o ON p.id=o.produit_id
    GROUP BY p.categorie)
SELECT o.id, o.produit, p.categorie, o.montant, m.total
	FROM commandes o 
    INNER JOIN produits p ON o.produit_id=p.id
    INNER JOIN moyen_cat m ON p.categorie=m.categorie
    WHERE o.montant>m.total;

-- 4.6 [difficile] Avec un CTE, affiche les clients dont la dépense totale dépasse 250.

WITH depenses AS (
	SELECT c.id, c.prenom, SUM(o.montant) as total
		FROM clients c LEFT JOIN commandes o ON c.id=o.client_id
        GROUP by c.id, c.prenom)
	SELECT * FROM depenses WHERE total>250;

-- 4.7 [difficile] Avec deux CTE enchaînés, affiche les clients dont la dépense totale est inférieure à la dépense moyenne par client (parmi ceux qui ont commandé).

WITH clients_com as (
		SELECT c.id, c.prenom, SUM(o.montant) as total
		FROM clients c INNER JOIN commandes o ON c.id=o.client_id
        GROUP by c.id, c.prenom),
	moyennes AS (
    SELECT AVG(total) AS moy FROM clients_com)
SELECT cm.* FROM clients_com cm 
CROSS JOIN moyennes m
WHERE cm.total < m.moy;

-- 4.8 [moyen] Avec une sous-requête sur la table villes, affiche les prénoms des clients qui habitent dans une ville de la province Haut-Katanga.

SELECT prenom, ville
FROM clients
WHERE ville IN (SELECT ville FROM villes WHERE province='Haut-Katanga');

-- 4.9 [difficile] Avec des sous-requêtes imbriquées (IN dans IN), affiche le nom et la catégorie des produits commandés par des clients de Kinshasa.
SELECT nom, categorie FROM produits WHERE id IN (
	SELECT id FROM commandes WHERE client_id IN (
    SELECT id FROM clients WHERE ville='Kinshasa'));

-- ------------------------------------------------------
-- Partie 5 : fonctions de fenêtrage (séance 5)
-- ------------------------------------------------------

-- 5.1 [facile] Numérote les clients du plus âgé au plus jeune.

SELECT *, ROW_NUMBER() OVER (ORDER BY age DESC) AS num_ordre FROM clients;

-- 5.2 [moyen] Classe les clients par âge décroissant dans chaque province (jointure avec la table villes).

SELECT c.id, c.prenom, c.age, v.province, RANK() OVER (PARTITION BY v.province ORDER BY c.age DESC) AS PROV_RANK FROM clients c INNER JOIN villes v ON c.ville=v.ville;

-- 5.3 [moyen] Affiche chaque client avec l'âge moyen de sa ville.

SELECT prenom, ville, AVG(age) OVER (PARTITION BY ville ORDER BY ville) AS age_moyen FROM clients;

-- 5.4 [moyen] Affiche chaque commande avec le cumul des montants, par date de commande croissante.

SELECT id, produit, montant, date_commande,
       SUM(montant) OVER (ORDER BY date_commande, id) AS cumul
FROM commandes;

-- 5.5 [difficile] Affiche chaque commande avec le montant de la commande précédente (par date) et la différence entre les deux.

SELECT *, LAG(montant) OVER (ORDER BY date_commande,id) AS mont_prec, montant-LAG(montant) OVER (ORDER BY date_commande,id) AS diff FROM commandes;

-- 5.6 [difficile] Affiche la commande la plus chère de chaque client ayant commandé, avec le prénom du client, le nom et la catégorie du produit (CTE et ROW_NUMBER).

WITH client_com AS (SELECT c.prenom, p.nom, p.categorie, o.montant, ROW_NUMBER() OVER (PARTITION BY c.id ORDER BY o.montant DESC) AS num_ordre
FROM clients c INNER JOIN commandes o ON c.id=o.client_id
INNER JOIN produits p ON o.produit_id=p.id)
SELECT * FROM client_com WHERE num_ordre=1;

-- 5.7 [difficile] Affiche chaque commande avec son pourcentage du total de sa catégorie de produit, arrondi à 2 décimales (PARTITION BY la catégorie).

SELECT o.id, p.nom, p.categorie, ROUND(o.montant * 100.00 / SUM(o.montant) OVER (PARTITION BY p.categorie) ,2) AS total FROM commandes o INNER JOIN  produits p ON p.id=o.produit_id ORDER BY o.id;


-- 5.8 [difficile] Répartis les clients en 2 groupes d'âge avec NTILE(2) et affiche le groupe de chaque client.

SELECT *, NTILE(2) OVER (ORDER BY age) AS groupe_age FROM clients;

-- 5.9 [difficile] Pour chaque province, classe les clients selon leur dépense totale (0 pour ceux qui n'ont rien commandé) avec RANK. Que se passe-t-il pour les deux clients de Nord-Kivu ?

WITH cli_prov AS (SELECT c.prenom, v.province, coalesce(SUM(o.montant),0) AS total
FROM clients c LEFT JOIN commandes o ON c.id=o.client_id
LEFT JOIN villes v ON c.ville=v.ville GROUP BY c.prenom, v.province)
SELECT *, RANK() OVER (PARTITION BY province ORDER BY total DESC) FROM cli_prov;

-- ------------------------------------------------------
-- Partie 6 : CASE WHEN, dates et texte (séance 6)
-- ------------------------------------------------------

-- 6.1 [moyen] Ajoute à chaque commande une catégorie : moins de 100 = 'Petite', de 100 à 299 = 'Moyenne', 300 et plus = 'Grande'.

SELECT *, CASE
		WHEN montant<100 THEN 'Petite'
        WHEN montant <300 THEN 'Moyenne'
        ELSE 'Grande'
        END AS categorie
FROM commandes;

-- 6.2 [difficile] Affiche le nombre de commandes et le montant total par catégorie (mêmes seuils qu'en 6.1).

WITH cat AS (SELECT *, CASE
		WHEN montant<100 THEN 'Petite'
        WHEN montant <300 THEN 'Moyenne'
        ELSE 'Grande'
        END AS categorie
FROM commandes)
SELECT categorie, SUM(montant) as total, COUNT(*) as nb FROM cat GROUP BY categorie;

-- 6.3 [moyen] Affiche le montant total des commandes par mois, au format AAAA-MM.

SELECT DATE_FORMAT(date_commande, '%Y-%m') AS date_form, SUM(montant) as total FROM commandes GROUP BY date_form;

-- 6.4 [moyen] Calcule le nombre de jours entre la première et la dernière commande.

SELECT datediff(max(date_commande),min(date_commande)) FROM commandes;

-- 6.5 [moyen] Affiche les commandes passées en février 2026.

SELECT * FROM commandes WHERE DATE_FORMAT(date_commande, '%Y-%m')='2026-02';

-- 6.6 [moyen] Affiche les clients dont le prénom se termine par la lettre e.

SELECT * FROM clients WHERE prenom LIKE '%e';

-- 6.7 [moyen] Affiche chaque client sous la forme PRENOM - ville (prénom en majuscules, ville en minuscules).

SELECT CONCAT(UPPER(prenom),' - ',LOWER(ville)) FROM clients;

-- 6.8 [difficile] Affiche les prénoms de exactement 4 lettres, avec leur ville.

SELECT prenom, ville FROM clients WHERE LENGTH(prenom)=4;

-- 6.9 [difficile] Affiche le montant total des commandes par mois (AAAA-MM) et par catégorie de produit.

SELECT DATE_FORMAT(o.date_commande, '%Y-%m') as datform, p.categorie, SUM(o.montant) AS total 
FROM commandes o INNER JOIN produits p ON o.produit_id=p.id GROUP BY datform, categorie ORDER BY datform, categorie;

-- 6.10 [moyen] Affiche chaque produit sous la forme NOM (categorie), avec le nom en majuscules. Exemple : TELEPHONE (Electronique).

SELECT CONCAT(UPPER(nom),' (', categorie, ')') FROM produits;

-- ------------------------------------------------------
-- Partie 7 : synthèse (questions métier avec les 4 tables)
-- ------------------------------------------------------

-- 7.1 [difficile] Affiche, pour chaque ville de la table villes, le nombre de commandes et le montant total, avec 0 pour une ville sans commande.

SELECT v.ville,
       COUNT(o.id) AS nb_commandes,
       COALESCE(SUM(o.montant), 0) AS montant_total
FROM villes v
LEFT JOIN clients c ON c.ville = v.ville
LEFT JOIN commandes o ON o.client_id = c.id
GROUP BY v.ville;

-- 7.2 [difficile] Classe les clients ayant commandé selon leur dépense totale, avec leur rang (RANK).

SELECT c.prenom, SUM(o.montant) as total, RANK() OVER (ORDER BY SUM(o.montant) DESC) as RANG 
FROM clients c INNER JOIN commandes o ON c.id=o.client_id 
GROUP BY c.prenom; 

-- 7.3 [difficile] Affiche, pour chaque mois, le total des commandes et son pourcentage du total de toutes les commandes (2 décimales).

WITH moistot AS (SELECT DATE_FORMAT(date_commande, '%Y-%m') AS mois, SUM(montant) as total FROM commandes GROUP BY mois)
SELECT *, ROUND(total * 100/(SELECT SUM(total) FROM moistot),2) as pourcentage FROM moistot;

-- 7.4 [difficile] Affiche, pour chaque ville, le prénom du client qui a le plus dépensé (parmi ceux qui ont commandé).

WITH groupville AS (
    SELECT c.id, c.prenom, c.ville, SUM(o.montant) AS total
    FROM clients c
    INNER JOIN commandes o ON c.id = o.client_id
    GROUP BY c.id, c.prenom, c.ville
),
classement AS (
    SELECT *, RANK() OVER (PARTITION BY ville ORDER BY total DESC) AS rang
    FROM groupville
)
SELECT ville, prenom, total
FROM classement
WHERE rang = 1;

-- 7.5 [difficile] Affiche, pour chaque catégorie de produit, le prénom du client qui a le plus dépensé dans cette catégorie (clients connus uniquement).

WITH tri_categorie as (SELECT c.prenom, p.categorie, SUM(o.montant) as total FROM clients c
INNER JOIN commandes o ON c.id=o.client_id
INNER JOIN produits p ON o.produit_id=p.id
GROUP BY  c.prenom, p.categorie ORDER BY categorie) 
SELECT * FROM (SELECT categorie, prenom, total, RANK() OVER (PARTITION BY categorie ORDER BY total DESC) RANG FROM tri_categorie) as arrangement WHERE rang=1;

-- 7.6 [difficile] Tableau de bord mensuel : pour chaque mois (AAAA-MM), le chiffre d'affaires, le nombre de commandes et la variation du chiffre d'affaires par rapport au mois précédent.

WITH sitglobal AS (SELECT DATE_FORMAT(date_commande, '%Y-%m') AS mois, SUM(montant) AS chiffre_d_affaires, COUNt(*) AS nb_commandes FROM commandes GROUP BY mois)
SELECT *, chiffre_d_affaires-LAG(chiffre_d_affaires) OVER (ORDER BY mois) AS variation FROM sitglobal ORDER BY mois ;

-- 7.7 [difficile] Pour chaque province et chaque catégorie de produit, affiche le montant total et sa part (en %, 2 décimales) dans le total de la province.
WITH provcat AS (
    SELECT v.province, p.categorie, SUM(o.montant) AS total
    FROM commandes o
    INNER JOIN clients c ON o.client_id = c.id
    INNER JOIN villes v ON c.ville = v.ville
    INNER JOIN produits p ON p.id = o.produit_id
    GROUP BY v.province, p.categorie
)
SELECT province, categorie, total,
       ROUND(total * 100.0 / SUM(total) OVER (PARTITION BY province), 2) AS pct_province
FROM provcat;