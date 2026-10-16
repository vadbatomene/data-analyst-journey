SET SQL_SAFE_UPDATES = 0;

ALTER TABLE commandes ADD COLUMN date_commande DATE;

UPDATE commandes SET date_commande = '2026-01-15' WHERE id = 1;
UPDATE commandes SET date_commande = '2026-01-28' WHERE id = 2;
UPDATE commandes SET date_commande = '2026-02-10' WHERE id = 3;
UPDATE commandes SET date_commande = '2026-02-22' WHERE id = 4;
UPDATE commandes SET date_commande = '2026-03-05' WHERE id = 5;
UPDATE commandes SET date_commande = '2026-03-18' WHERE id = 6;
UPDATE commandes SET date_commande = '2026-04-02' WHERE id = 7;

SELECT * FROM commandes;

SELECT id, produit, montant,
	CASE
		WHEN montant >= 500 THEN 'Grosse'
        WHEN montant >= 100 THEN 'Moyenne'
        ELSE 'Petite'
	END as categorie
FROM commandes;

SELECT
	CASE
		WHEN montant >= 500 THEN 'Grosse'
        WHEN montant >= 100 THEN 'Moyenne'
        ELSE 'Petite'
	END as categorie,
    COUNT(*) as nb_commandes
FROM commandes GROUP BY categorie;

SELECT *, 
	CASE 
		WHEN age<30 THEN 'Jeune' 
        WHEN age<40 THEN 'Adulte' 
        ELSE 'Vieux'
        END as Categorie_age 
FROM clients;

SELECT 
	CASE 
		WHEN age<30 THEN 'Jeune' 
        WHEN age<40 THEN 'Adulte' 
        ELSE 'Vieux'
        END as categorie_age, 
        COUNT(*) as nb
FROM clients GROUP BY categorie_age;

SELECT
	CASE
		WHEN montant >= 500 THEN 'Grosse'
        WHEN montant >= 100 THEN 'Moyenne'
        ELSE 'Petite'
	END as categorie,
    SUM(montant) as Tot_cat
FROM commandes GROUP BY categorie;

SELECT *,
	YEAR(date_commande) as annee,
    MONTH(date_commande) as mois,
    DAY(date_commande) as jour
FROM commandes;

SELECT id, produit, montant, date_format(date_commande, '%d-%m-%Y') as dd_mm_aaaa FROM commandes;
SELECT DATEDIFF('2026-04-02', '2026-01-15') AS nb_jours;
SELECT id, DATEDIFF(CURDATE(), date_commande) AS jours_depuis_commande
FROM commandes;

SELECT id, produit, DATE_FORMAT(date_commande, '%Y-%m') AS mois_annee FROM commandes;
SELECT DATE_FORMAT(date_commande, '%Y-%m') as mois_annee, SUM(montant) AS total_mois FROM commandes GROUP BY mois_annee;
SELECT DATEDIFF(MAX(date_commande), MIN(date_commande)) AS diff_jours FROM commandes;
WITH result_mois AS
 (SELECT DATE_FORMAT(date_commande, '%Y-%m') AS mois_annee, SUM(montant) AS total_mois FROM commandes GROUP BY mois_annee),
 result_prec AS
 (SELECT *,  LAG(total_mois) OVER (ORDER BY mois_annee) AS total_mois_prec FROM result_mois) 
 SELECT *,  total_mois-total_mois_prec as variation FROM result_prec;
 
SELECT CONCAT(prenom, ' (', ville, ')') AS client FROM clients;
SELECT UPPER(ville), LOWER(prenom), LENGTH(prenom) FROM clients;
SELECT SUBSTRING(prenom, 1, 3) FROM clients;

SELECT * FROM clients WHERE prenom LIKE 'P%' OR prenom LIKE 'M%';
SELECT CONCAT(prenom, ' -  ', UPPER(ville)) AS client_ville FROM clients;
SELECT prenom, UPPER(SUBSTRING(prenom, 1, 3)) as code FROM clients;
SELECT COUNT(*) FROM clients WHERE prenom LIKE '%r%';
SELECT CONCAT(prenom, ' (' , LENGTH(prenom), ') ') FROM clients ORDER BY LENGTH(prenom) DESC, prenom;