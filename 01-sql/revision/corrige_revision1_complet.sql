-- ======================================================
-- Révision SQL 1 : énoncés et réponses de référence (corrigé complet)
-- Parties 1 à 7 + partie 8 (bonus). Tables : clients, commandes, produits, villes.
-- Chaque réponse est la version validée (mes réponses d'origine sont dans
-- reponses_revision1*.sql, les variantes de la partie 1 à 3 dans corrections_parties_1_a_3.sql).
-- ======================================================

USE formation;

-- ------------------------------------------------------
-- Partie 1 : les bases (séance 1)
-- ------------------------------------------------------

-- 1.1 [facile] Affiche tous les clients.
SELECT * FROM clients;


-- 1.2 [facile] Affiche uniquement le prénom et l'âge de chaque client.
SELECT prenom, age FROM clients;


-- 1.3 [facile] Affiche les clients qui habitent à Goma.
SELECT * FROM clients WHERE ville = 'Goma';


-- 1.4 [facile] Affiche les clients de plus de 30 ans, du plus âgé au plus jeune.
SELECT * FROM clients WHERE age > 30 ORDER BY age DESC;


-- 1.5 [moyen] Affiche les clients de Kinshasa qui ont moins de 30 ans.
SELECT * FROM clients WHERE age < 30 AND ville = 'Kinshasa';


-- 1.6 [moyen] Affiche les clients de Goma ou de Lubumbashi, triés par prénom.
SELECT * FROM clients WHERE ville = 'Goma' OR ville = 'Lubumbashi' ORDER BY prenom;


-- 1.7 [moyen] Affiche les 3 commandes les moins chères.
SELECT * FROM commandes ORDER BY montant, id LIMIT 3;

-- Variante : garder tous les ex aequo du top 3
WITH classement AS (
    SELECT *, RANK() OVER (ORDER BY montant) AS rang FROM commandes
)
SELECT * FROM classement WHERE rang <= 3;


-- ------------------------------------------------------
-- Partie 2 : agrégations (séance 2)
-- ------------------------------------------------------

-- 2.1 [facile] Compte le nombre total de commandes.
SELECT COUNT(*) AS nb_commandes FROM commandes;


-- 2.2 [facile] Affiche en une seule requête le montant total, moyen, minimum et maximum des commandes.
SELECT SUM(montant) AS total, ROUND(AVG(montant), 2) AS moyenne,
       MIN(montant) AS minimum, MAX(montant) AS maximum
FROM commandes;


-- 2.3 [moyen] Affiche le nombre de clients par ville.
SELECT ville, COUNT(*) AS nb_clients FROM clients GROUP BY ville;


-- 2.4 [moyen] Affiche l'âge moyen par ville, arrondi à 1 décimale, de la ville la plus âgée à la plus jeune.
SELECT ville, ROUND(AVG(age), 1) AS age_moyen
FROM clients
GROUP BY ville
ORDER BY age_moyen DESC;


-- 2.5 [moyen] Affiche les villes qui comptent au moins 3 clients.
SELECT ville, COUNT(*) AS nb_clients
FROM clients
GROUP BY ville
HAVING COUNT(*) >= 3;


-- 2.6 [moyen] Affiche, par ville, le nombre de clients de plus de 30 ans.
SELECT ville, COUNT(*) AS nb_clients_plus_30
FROM clients
WHERE age > 30
GROUP BY ville;


-- 2.7 [difficile] Affiche la ville dont l'âge moyen est le plus élevé (une seule ligne).
SELECT ville, ROUND(AVG(age), 1) AS age_moyen
FROM clients
GROUP BY ville
ORDER BY age_moyen DESC
LIMIT 1;

-- Variante : garder toutes les villes à égalité
WITH moy AS (
    SELECT ville, AVG(age) AS age_moyen FROM clients GROUP BY ville
)
SELECT ville, age_moyen FROM moy
WHERE age_moyen = (SELECT MAX(age_moyen) FROM moy);


-- ------------------------------------------------------
-- Partie 3 : jointures (séance 3)
-- ------------------------------------------------------

-- 3.1 [facile] Affiche le prénom du client et le produit de chaque commande.
SELECT c.prenom, o.produit
FROM clients c
INNER JOIN commandes o ON c.id = o.client_id;


-- 3.2 [moyen] Affiche tous les clients avec leurs commandes, y compris ceux qui n'en ont pas.
SELECT c.prenom, o.produit, o.montant
FROM clients c
LEFT JOIN commandes o ON c.id = o.client_id;


-- 3.3 [moyen] Affiche les clients qui n'ont passé aucune commande.
SELECT c.prenom
FROM clients c
LEFT JOIN commandes o ON c.id = o.client_id
WHERE o.id IS NULL;


-- 3.4 [moyen] Affiche la dépense totale de chaque client (prénom et total), du plus gros dépensier au plus petit.
SELECT c.prenom, COALESCE(SUM(o.montant), 0) AS total
FROM clients c
LEFT JOIN commandes o ON c.id = o.client_id
GROUP BY c.id, c.prenom
ORDER BY total DESC;


-- 3.5 [moyen] Affiche le montant total des commandes par ville.
SELECT c.ville, SUM(o.montant) AS total
FROM clients c
INNER JOIN commandes o ON c.id = o.client_id
GROUP BY c.ville;


-- 3.6 [difficile] Affiche tous les clients avec leur dépense totale, avec 0 pour ceux qui n'ont rien commandé.
SELECT c.prenom, COALESCE(SUM(o.montant), 0) AS depense_totale
FROM clients c
LEFT JOIN commandes o ON c.id = o.client_id
GROUP BY c.id, c.prenom;


-- 3.7 [difficile] Affiche les commandes qui n'appartiennent à aucun client.
SELECT o.id AS id_commande, o.client_id, o.produit, o.montant
FROM commandes o
LEFT JOIN clients c ON o.client_id = c.id
WHERE c.id IS NULL;


-- 3.8 [difficile] Affiche, pour chaque client (même sans commande), le nombre de commandes passées.
SELECT c.prenom, COUNT(o.id) AS nb_commandes
FROM clients c
LEFT JOIN commandes o ON c.id = o.client_id
GROUP BY c.id, c.prenom;


-- ------------------------------------------------------
-- Partie 4 : sous-requêtes et CTE (séance 4)
-- ------------------------------------------------------

-- 4.1 [facile] Affiche les clients plus jeunes que l'âge moyen de tous les clients.
SELECT * FROM clients WHERE age < (SELECT AVG(age) FROM clients);


-- 4.2 [moyen] Affiche les commandes dont le montant dépasse la moyenne des montants.
SELECT * FROM commandes WHERE montant > (SELECT AVG(montant) FROM commandes);


-- 4.3 [moyen] Avec IN, affiche les prénoms des clients qui ont passé au moins une commande.
SELECT prenom FROM clients WHERE id IN (SELECT client_id FROM commandes);


-- 4.4 [moyen] Avec NOT IN, affiche les prénoms des clients qui n'ont passé aucune commande.
SELECT prenom FROM clients WHERE id NOT IN (SELECT client_id FROM commandes);


-- 4.5 [difficile] Avec un CTE, calcule le montant moyen des commandes par catégorie de produit, puis affiche les commandes (id, nom du produit, catégorie, montant) dont le montant dépasse la moyenne de leur catégorie.
WITH moyennes AS (
    SELECT p.categorie, AVG(o.montant) AS montant_moyen
    FROM commandes o
    INNER JOIN produits p ON p.id = o.produit_id
    GROUP BY p.categorie
)
SELECT o.id, p.nom, p.categorie, o.montant
FROM commandes o
INNER JOIN produits p ON p.id = o.produit_id
INNER JOIN moyennes m ON m.categorie = p.categorie
WHERE o.montant > m.montant_moyen;


-- 4.6 [difficile] Avec un CTE, affiche les clients dont la dépense totale dépasse 250.
WITH depenses AS (
    SELECT c.id, c.prenom, SUM(o.montant) AS total
    FROM clients c
    INNER JOIN commandes o ON c.id = o.client_id
    GROUP BY c.id, c.prenom
)
SELECT * FROM depenses WHERE total > 250;


-- 4.7 [difficile] Avec deux CTE enchaînés, affiche les clients dont la dépense totale est inférieure à la dépense moyenne par client (parmi ceux qui ont commandé).
WITH clients_com AS (
    SELECT c.id, c.prenom, SUM(o.montant) AS total
    FROM clients c
    INNER JOIN commandes o ON c.id = o.client_id
    GROUP BY c.id, c.prenom
),
moyenne AS (
    SELECT AVG(total) AS moy FROM clients_com
)
SELECT cc.prenom, cc.total
FROM clients_com cc
CROSS JOIN moyenne m
WHERE cc.total < m.moy;


-- 4.8 [moyen] Avec une sous-requête sur la table villes, affiche les prénoms des clients qui habitent dans une ville de la province Haut-Katanga.
SELECT prenom
FROM clients
WHERE ville IN (SELECT ville FROM villes WHERE province = 'Haut-Katanga');


-- 4.9 [difficile] Avec des sous-requêtes imbriquées (IN dans IN), affiche le nom et la catégorie des produits commandés par des clients de Kinshasa.
SELECT nom, categorie
FROM produits
WHERE id IN (
    SELECT produit_id FROM commandes
    WHERE client_id IN (SELECT id FROM clients WHERE ville = 'Kinshasa')
);


-- ------------------------------------------------------
-- Partie 5 : fonctions de fenêtrage (séance 5)
-- ------------------------------------------------------

-- 5.1 [facile] Numérote les clients du plus âgé au plus jeune.
SELECT *, ROW_NUMBER() OVER (ORDER BY age DESC) AS num_ordre FROM clients;


-- 5.2 [moyen] Classe les clients par âge décroissant dans chaque province (jointure avec la table villes).
SELECT c.id, c.prenom, c.age, v.province,
       RANK() OVER (PARTITION BY v.province ORDER BY c.age DESC) AS rang_province
FROM clients c
INNER JOIN villes v ON c.ville = v.ville;


-- 5.3 [moyen] Affiche chaque client avec l'âge moyen de sa ville.
SELECT prenom, ville, AVG(age) OVER (PARTITION BY ville) AS age_moyen_ville
FROM clients;


-- 5.4 [moyen] Affiche chaque commande avec le cumul des montants, par date de commande croissante.
SELECT id, produit, montant, date_commande,
       SUM(montant) OVER (ORDER BY date_commande, id) AS cumul
FROM commandes;


-- 5.5 [difficile] Affiche chaque commande avec le montant de la commande précédente (par date) et la différence entre les deux.
SELECT id, montant, date_commande,
       LAG(montant) OVER (ORDER BY date_commande, id) AS montant_precedent,
       montant - LAG(montant) OVER (ORDER BY date_commande, id) AS difference
FROM commandes;


-- 5.6 [difficile] Affiche la commande la plus chère de chaque client ayant commandé, avec le prénom du client, le nom et la catégorie du produit (CTE et ROW_NUMBER).
WITH client_com AS (
    SELECT c.prenom, p.nom, p.categorie, o.montant,
           ROW_NUMBER() OVER (PARTITION BY c.id ORDER BY o.montant DESC) AS rang
    FROM clients c
    INNER JOIN commandes o ON c.id = o.client_id
    INNER JOIN produits p ON o.produit_id = p.id
)
SELECT prenom, nom, categorie, montant FROM client_com WHERE rang = 1;


-- 5.7 [difficile] Affiche chaque commande avec son pourcentage du total de sa catégorie de produit, arrondi à 2 décimales (PARTITION BY la catégorie).
SELECT o.id, p.nom, p.categorie, o.montant,
       ROUND(o.montant * 100.0 / SUM(o.montant) OVER (PARTITION BY p.categorie), 2) AS pourcentage
FROM commandes o
INNER JOIN produits p ON p.id = o.produit_id;


-- 5.8 [difficile] Répartis les clients en 2 groupes d'âge avec NTILE(2) et affiche le groupe de chaque client.
SELECT *, NTILE(2) OVER (ORDER BY age) AS groupe_age FROM clients;


-- 5.9 [difficile] Pour chaque province, classe les clients selon leur dépense totale (0 pour ceux qui n'ont rien commandé) avec RANK. Que se passe-t-il pour les deux clients de Nord-Kivu ?
WITH cli_prov AS (
    SELECT c.id, c.prenom, v.province, COALESCE(SUM(o.montant), 0) AS total
    FROM clients c
    LEFT JOIN commandes o ON c.id = o.client_id
    LEFT JOIN villes v ON c.ville = v.ville
    GROUP BY c.id, c.prenom, v.province
)
SELECT *, RANK() OVER (PARTITION BY province ORDER BY total DESC) AS rang
FROM cli_prov;
-- Les deux clients de Nord-Kivu ont la même dépense (0) : RANK leur donne le même rang 1.


-- ------------------------------------------------------
-- Partie 6 : CASE WHEN, dates et texte (séance 6)
-- ------------------------------------------------------

-- 6.1 [moyen] Ajoute à chaque commande une catégorie : moins de 100 = 'Petite', de 100 à 299 = 'Moyenne', 300 et plus = 'Grande'.
SELECT *, CASE WHEN montant < 100 THEN 'Petite'
                WHEN montant < 300 THEN 'Moyenne'
                ELSE 'Grande' END AS categorie
FROM commandes;


-- 6.2 [difficile] Affiche le nombre de commandes et le montant total par catégorie (mêmes seuils qu'en 6.1).
WITH cat AS (
    SELECT *, CASE WHEN montant < 100 THEN 'Petite'
                WHEN montant < 300 THEN 'Moyenne'
                ELSE 'Grande' END AS categorie
    FROM commandes
)
SELECT categorie, COUNT(*) AS nb_commandes, SUM(montant) AS total
FROM cat
GROUP BY categorie;


-- 6.3 [moyen] Affiche le montant total des commandes par mois, au format AAAA-MM.
SELECT DATE_FORMAT(date_commande, '%Y-%m') AS mois, SUM(montant) AS total
FROM commandes
GROUP BY mois
ORDER BY mois;


-- 6.4 [moyen] Calcule le nombre de jours entre la première et la dernière commande.
SELECT DATEDIFF(MAX(date_commande), MIN(date_commande)) AS nb_jours FROM commandes;


-- 6.5 [moyen] Affiche les commandes passées en février 2026.
SELECT * FROM commandes
WHERE date_commande >= '2026-02-01' AND date_commande < '2026-03-01';


-- 6.6 [moyen] Affiche les clients dont le prénom se termine par la lettre e.
SELECT * FROM clients WHERE prenom LIKE '%e';


-- 6.7 [moyen] Affiche chaque client sous la forme PRENOM - ville (prénom en majuscules, ville en minuscules).
SELECT CONCAT(UPPER(prenom), ' - ', LOWER(ville)) AS client FROM clients;


-- 6.8 [difficile] Affiche les prénoms de exactement 4 lettres, avec leur ville.
SELECT prenom, ville FROM clients WHERE CHAR_LENGTH(prenom) = 4;


-- 6.9 [difficile] Affiche le montant total des commandes par mois (AAAA-MM) et par catégorie de produit.
SELECT DATE_FORMAT(o.date_commande, '%Y-%m') AS mois, p.categorie, SUM(o.montant) AS total
FROM commandes o
INNER JOIN produits p ON o.produit_id = p.id
GROUP BY mois, p.categorie
ORDER BY mois, p.categorie;


-- 6.10 [moyen] Affiche chaque produit sous la forme NOM (categorie), avec le nom en majuscules. Exemple : TELEPHONE (Electronique).
SELECT CONCAT(UPPER(nom), ' (', categorie, ')') AS libelle FROM produits;


-- ------------------------------------------------------
-- Partie 7 : synthèse (questions métier, 4 tables)
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
SELECT c.id, c.prenom, SUM(o.montant) AS total,
       RANK() OVER (ORDER BY SUM(o.montant) DESC) AS rang
FROM clients c
INNER JOIN commandes o ON c.id = o.client_id
GROUP BY c.id, c.prenom
ORDER BY rang;


-- 7.3 [difficile] Affiche, pour chaque mois, le total des commandes et son pourcentage du total de toutes les commandes (2 décimales).
WITH moistot AS (
    SELECT DATE_FORMAT(date_commande, '%Y-%m') AS mois, SUM(montant) AS total
    FROM commandes
    GROUP BY mois
)
SELECT mois, total,
       ROUND(total * 100.0 / SUM(total) OVER (), 2) AS pourcentage
FROM moistot
ORDER BY mois;


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
SELECT ville, prenom, total FROM classement WHERE rang = 1;


-- 7.5 [difficile] Affiche, pour chaque catégorie de produit, le prénom du client qui a le plus dépensé dans cette catégorie (clients connus uniquement).
WITH tri_categorie AS (
    SELECT c.id, c.prenom, p.categorie, SUM(o.montant) AS total
    FROM clients c
    INNER JOIN commandes o ON c.id = o.client_id
    INNER JOIN produits p ON o.produit_id = p.id
    GROUP BY c.id, c.prenom, p.categorie
),
classement AS (
    SELECT *, RANK() OVER (PARTITION BY categorie ORDER BY total DESC) AS rang
    FROM tri_categorie
)
SELECT categorie, prenom, total FROM classement WHERE rang = 1;


-- 7.6 [difficile] Tableau de bord mensuel : pour chaque mois (AAAA-MM), le chiffre d'affaires, le nombre de commandes et la variation du chiffre d'affaires par rapport au mois précédent.
WITH sitglobal AS (
    SELECT DATE_FORMAT(date_commande, '%Y-%m') AS mois,
           SUM(montant) AS chiffre_affaires, COUNT(*) AS nb_commandes
    FROM commandes
    GROUP BY mois
)
SELECT *, chiffre_affaires - LAG(chiffre_affaires) OVER (ORDER BY mois) AS variation
FROM sitglobal
ORDER BY mois;


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


-- ------------------------------------------------------
-- Partie 8 : bonus, jointures multiples (note complémentaire)
-- ------------------------------------------------------

-- 8.1 [moyen] Montant total par catégorie de produit, pour toutes les commandes.
SELECT p.categorie, SUM(o.montant) AS total
FROM produits p
INNER JOIN commandes o ON p.id = o.produit_id
GROUP BY p.categorie;


-- 8.2 [moyen] Montant total par province.
SELECT v.province, SUM(o.montant) AS total
FROM clients c
INNER JOIN commandes o ON c.id = o.client_id
INNER JOIN villes v ON c.ville = v.ville
GROUP BY v.province;


-- 8.3 [moyen] Pour chaque commande de client connu : prénom, province, produit et montant (4 tables).
SELECT c.prenom, v.province, p.nom AS produit, o.montant
FROM clients c
INNER JOIN villes v ON c.ville = v.ville
INNER JOIN commandes o ON c.id = o.client_id
INNER JOIN produits p ON p.id = o.produit_id;


-- 8.4 [difficile] Tous les clients, même sans commande, avec leur province et leur nombre de commandes.
SELECT c.id, c.prenom, v.province, COUNT(o.id) AS nb_commandes
FROM clients c
LEFT JOIN villes v ON c.ville = v.ville
LEFT JOIN commandes o ON c.id = o.client_id
GROUP BY c.id, c.prenom, v.province;


-- 8.5 [difficile] Pour chaque province, la catégorie la plus vendue en montant.
WITH classement AS (
    SELECT v.province, p.categorie, SUM(o.montant) AS total_vendu
    FROM villes v
    INNER JOIN clients c ON v.ville = c.ville
    INNER JOIN commandes o ON c.id = o.client_id
    INNER JOIN produits p ON p.id = o.produit_id
    GROUP BY v.province, p.categorie
),
classement_final AS (
    SELECT province, categorie, total_vendu,
           RANK() OVER (PARTITION BY province ORDER BY total_vendu DESC) AS rang
    FROM classement
)
SELECT * FROM classement_final WHERE rang = 1;

