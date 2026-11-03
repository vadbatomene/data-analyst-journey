DATE_FORMAT(date_inscription, '%Y-%m')                       -- le mois de la cohorte
PERIOD_DIFF(DATE_FORMAT(a.date_achat, '%Y%m'),
            DATE_FORMAT(c.date_inscription, '%Y%m'))         -- le décalage en mois

use formation;

SELECT DATE_FORMAT(c.date_inscription, '%Y-%m') AS cohorte,
       DATE_FORMAT(a.date_achat, '%Y-%m') AS mois_achat,
       COUNT(*) AS nb_achats
FROM clients_ana c
INNER JOIN achats a ON a.client_id = c.id
GROUP BY cohorte, mois_achat
ORDER BY cohorte, mois_achat;

-- 1.Taille des cohortes : le mois de la cohorte et le nombre de clients. 
SELECT DATE_FORMAT(c.date_inscription, '%Y-%m') AS cohorte, COUNT(DISTINCT c.id) AS nb_clients
FROM clients_ana c 
INNER JOIN achats a ON c.id=a.client_id
GROUP BY cohorte
ORDER BY cohorte;
-- Résultat : 2026-01 : 5 ; 2026-02 : 4 ; 2026-03 : 3.

-- 2.Activité par décalage : 
-- Pour chaque cohorte et chaque décalage, le nombre de clients actifs, trié par cohorte puis par décalage. 
SELECT DATE_FORMAT(c.date_inscription, '%Y-%m') AS cohorte, 
PERIOD_DIFF(DATE_FORMAT(a.date_achat, '%Y%m'), DATE_FORMAT(c.date_inscription, '%Y%m')) AS decalage, 
COUNT(DISTINCT c.id) AS nb_clients 
FROM clients_ana c 
INNER JOIN achats a ON c.id=a.client_id
GROUP BY cohorte, decalage
ORDER BY cohorte, decalage;
-- SELECT DATE_FORMAT(c.date_inscription, '%Y-%m') AS cohorte, COUNT(DISTINCT c.id) AS nb_clients

-- Résultat (14 lignes) : janvier : 4, 3, 3, 2, 2, 1 (décalages 0 à 5) ; février : 3, 2, 3, 1, 1 (0 à 4) ; mars : 2, 2, 1 (0 à 2).

-- 3.Rétention en % : ajoute la taille de la cohorte et le taux d’activité (2 décimales). 
WITH clients_cohorte as (SELECT DATE_FORMAT(c.date_inscription, '%Y-%m') AS cohorte, COUNT(DISTINCT c.id) AS nb_clients
FROM clients_ana c 
INNER JOIN achats a ON c.id=a.client_id
GROUP BY cohorte
ORDER BY cohorte),

Clients_decalage as (SELECT DATE_FORMAT(c.date_inscription, '%Y-%m') AS cohorte, 
PERIOD_DIFF(DATE_FORMAT(a.date_achat, '%Y%m'), 
DATE_FORMAT(c.date_inscription, '%Y%m')) AS decalage, 
COUNT(DISTINCT c.id) AS nb_clients
FROM clients_ana c 
INNER JOIN achats a ON c.id=a.client_id
GROUP BY cohorte, decalage
ORDER BY cohorte, decalage)
SELECT b.cohorte, b.decalage, b.nb_clients, a.nb_clients AS nb_clients_cohorte, ROUND(b.nb_clients/a.nb_clients*100, 2) as taux_activité
FROM clients_cohorte a
INNER JOIN clients_decalage b ON a.cohorte=b.cohorte;

-- Résultat : janvier : 80,00, 60,00, 60,00, 40,00, 40,00, 20,00 ; février : 75,00, 50,00, 75,00, 25,00, 25,00 ; mars : 66,67, 66,67, 33,33.

-- 4.La matrice : une ligne par cohorte, avec sa taille et les colonnes m0 à m5 (taux en % avec 1 décimale), grâce à l’agrégation conditionnelle. 
WITH clients_cohorte as (SELECT DATE_FORMAT(c.date_inscription, '%Y-%m') AS cohorte, COUNT(DISTINCT c.id) AS nb_clients
FROM clients_ana c 
INNER JOIN achats a ON c.id=a.client_id
GROUP BY cohorte
ORDER BY cohorte),

Clients_decalage as (SELECT DATE_FORMAT(c.date_inscription, '%Y-%m') AS cohorte, 
PERIOD_DIFF(DATE_FORMAT(a.date_achat, '%Y%m'), 
DATE_FORMAT(c.date_inscription, '%Y%m')) AS decalage, 
COUNT(DISTINCT c.id) AS nb_clients
FROM clients_ana c 
INNER JOIN achats a ON c.id=a.client_id
GROUP BY cohorte, decalage
ORDER BY cohorte, decalage),

clients_pourcentage AS (SELECT b.cohorte, b.decalage, b.nb_clients, a.nb_clients AS nb_clients_cohorte, ROUND(b.nb_clients/a.nb_clients*100, 2) as taux_activité
FROM clients_cohorte a
INNER JOIN clients_decalage b ON a.cohorte=b.cohorte)

SELECT cohorte, nb_clients_cohorte,
ROUND(MAX(CASE WHEN decalage=0 THEN taux_activité END),1) as m0,
ROUND(MAX(CASE WHEN decalage=1 THEN taux_activité END),1) as m1,
ROUND(MAX(CASE WHEN decalage=2 THEN taux_activité END),1) as m2,
ROUND(MAX(CASE WHEN decalage=3 THEN taux_activité END),1) as m3,
ROUND(MAX(CASE WHEN decalage=4 THEN taux_activité END),1) as m4,
ROUND(MAX(CASE WHEN decalage=5 THEN taux_activité END),1) as m5
FROM clients_pourcentage
GROUP BY cohorte
ORDER BY cohorte;
-- Résultat : janvier : 80,0, 60,0, 60,0, 40,0, 40,0, 20,0 ; février : 75,0, 50,0, 75,0, 25,0, 25,0, 0,0 ; mars : 66,7, 66,7, 33,3, 0,0, 0,0, 0,0. 
-- Ici, les zéros incluent à tort des mois non observables : voir le défi 6.

-- Chiffre d’affaires par cohorte : le nombre de clients, le chiffre d’affaires total et le chiffre d’affaires moyen par client (2 décimales). 
-- Résultat : 2026-01 : 5, 2145,00, 429,00 ; 2026-02 : 4, 1135,00, 283,75 ; 2026-03 : 3, 545,00, 181,67.

SELECT DATE_FORMAT(c.date_inscription, '%Y-%m') as cohorte, 
COUNT(DISTINCT c.id) as nb_clients, 
SUM(a.montant) as chiffre_affaires, ROUND(SUM(a.montant)/COUNT(DISTINCT c.id),2) as ch_moyen
FROM clients_ana c
INNER JOIN achats a ON c.id=a.client_id
GROUP BY cohorte
ORDER BY cohorte;

-- 6.Défi : cohortes non observables :
--  dans la matrice, remplace par NULL les cases dont le mois est postérieur à juin 2026. 
-- Un décalage k est observable si k <= PERIOD_DIFF(202606, DATE_FORMAT(date_inscription, '%Y%m')). 
WITH clients_cohorte as (SELECT DATE_FORMAT(c.date_inscription, '%Y-%m') AS cohorte, COUNT(DISTINCT c.id) AS nb_clients
FROM clients_ana c 
INNER JOIN achats a ON c.id=a.client_id
GROUP BY cohorte
ORDER BY cohorte),

Clients_decalage as (SELECT DATE_FORMAT(c.date_inscription, '%Y-%m') AS cohorte, 
PERIOD_DIFF(DATE_FORMAT(a.date_achat, '%Y%m'), 
DATE_FORMAT(c.date_inscription, '%Y%m')) AS decalage, 
COUNT(DISTINCT c.id) AS nb_clients
FROM clients_ana c 
INNER JOIN achats a ON c.id=a.client_id
GROUP BY cohorte, decalage
ORDER BY cohorte, decalage),

clients_pourcentage AS (SELECT b.cohorte, b.decalage, b.nb_clients, a.nb_clients AS nb_clients_cohorte, ROUND(b.nb_clients/a.nb_clients*100, 2) as taux_activité
FROM clients_cohorte a
INNER JOIN clients_decalage b ON a.cohorte=b.cohorte)

SELECT cohorte, nb_clients_cohorte,
ROUND(MAX(CASE WHEN decalage=0 THEN taux_activité END),1) as m0,
ROUND(MAX(CASE WHEN decalage=1 THEN taux_activité END),1) as m1,
ROUND(MAX(CASE WHEN decalage=2 THEN taux_activité END),1) as m2,
ROUND(MAX(CASE WHEN decalage=3 THEN taux_activité END),1) as m3,
ROUND(MAX(CASE WHEN decalage=4 THEN taux_activité END),1) as m4,
ROUND(MAX(CASE WHEN decalage=5 THEN taux_activité END),1) as m5
FROM clients_pourcentage
GROUP BY cohorte
ORDER BY cohorte;
-- Résultat : janvier inchangé ; février : m5 devient NULL ; mars : m3 reste 0,0 (juin est observé, personne n’a acheté) et m4 et m5 deviennent NULL.

-- 7.Réflexion (en commentaire, avec tes mots) :
-- (a) Quelle cohorte retient le mieux ses clients au premier mois suivant (M1) ?
-- Mars
-- (b) Pourquoi les cohortes récentes ont-elles moins de colonnes remplies ?
-- Je ne comprends rien
-- (c) Kevin s’est inscrit en mars mais n’a acheté qu’en avril : que montre-t-il sur le décalage 0 de sa cohorte ?
-- L'inactivité
-- (d) Avec 3 à 5 clients par cohorte, que peut-on conclure, et que doit-on préciser dans un rapport ?
-- Nous avons entre 3 à 5 activfs par mois
-- (e) Quelle action proposerais-tu après avoir lu la matrice ?
-- suis pas commercial