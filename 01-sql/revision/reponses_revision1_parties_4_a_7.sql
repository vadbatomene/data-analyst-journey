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



-- 5.2 [moyen] Classe les clients par âge décroissant dans chaque province (jointure avec la table villes).



-- 5.3 [moyen] Affiche chaque client avec l'âge moyen de sa ville.



-- 5.4 [moyen] Affiche chaque commande avec le cumul des montants, par date de commande croissante.



-- 5.5 [difficile] Affiche chaque commande avec le montant de la commande précédente (par date) et la différence entre les deux.



-- 5.6 [difficile] Affiche la commande la plus chère de chaque client ayant commandé, avec le prénom du client, le nom et la catégorie du produit (CTE et ROW_NUMBER).



-- 5.7 [difficile] Affiche chaque commande avec son pourcentage du total de sa catégorie de produit, arrondi à 2 décimales (PARTITION BY la catégorie).



-- 5.8 [difficile] Répartis les clients en 2 groupes d'âge avec NTILE(2) et affiche le groupe de chaque client.



-- 5.9 [difficile] Pour chaque province, classe les clients selon leur dépense totale (0 pour ceux qui n'ont rien commandé) avec RANK. Que se passe-t-il pour les deux clients de Nord-Kivu ?



-- ------------------------------------------------------
-- Partie 6 : CASE WHEN, dates et texte (séance 6)
-- ------------------------------------------------------

-- 6.1 [moyen] Ajoute à chaque commande une catégorie : moins de 100 = 'Petite', de 100 à 299 = 'Moyenne', 300 et plus = 'Grande'.



-- 6.2 [difficile] Affiche le nombre de commandes et le montant total par catégorie (mêmes seuils qu'en 6.1).



-- 6.3 [moyen] Affiche le montant total des commandes par mois, au format AAAA-MM.



-- 6.4 [moyen] Calcule le nombre de jours entre la première et la dernière commande.



-- 6.5 [moyen] Affiche les commandes passées en février 2026.



-- 6.6 [moyen] Affiche les clients dont le prénom se termine par la lettre e.



-- 6.7 [moyen] Affiche chaque client sous la forme PRENOM - ville (prénom en majuscules, ville en minuscules).



-- 6.8 [difficile] Affiche les prénoms de exactement 4 lettres, avec leur ville.



-- 6.9 [difficile] Affiche le montant total des commandes par mois (AAAA-MM) et par catégorie de produit.



-- 6.10 [moyen] Affiche chaque produit sous la forme NOM (categorie), avec le nom en majuscules. Exemple : TELEPHONE (Electronique).



-- ------------------------------------------------------
-- Partie 7 : synthèse (questions métier avec les 4 tables)
-- ------------------------------------------------------

-- 7.1 [difficile] Affiche, pour chaque ville de la table villes, le nombre de commandes et le montant total, avec 0 pour une ville sans commande.



-- 7.2 [difficile] Classe les clients ayant commandé selon leur dépense totale, avec leur rang (RANK).



-- 7.3 [difficile] Affiche, pour chaque mois, le total des commandes et son pourcentage du total de toutes les commandes (2 décimales).



-- 7.4 [difficile] Affiche, pour chaque ville, le prénom du client qui a le plus dépensé (parmi ceux qui ont commandé).



-- 7.5 [difficile] Affiche, pour chaque catégorie de produit, le prénom du client qui a le plus dépensé dans cette catégorie (clients connus uniquement).



-- 7.6 [difficile] Tableau de bord mensuel : pour chaque mois (AAAA-MM), le chiffre d'affaires, le nombre de commandes et la variation du chiffre d'affaires par rapport au mois précédent.



-- 7.7 [difficile] Pour chaque province et chaque catégorie de produit, affiche le montant total et sa part (en %, 2 décimales) dans le total de la province.


