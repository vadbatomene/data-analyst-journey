WITH mensuel AS (
    SELECT DATE_FORMAT(date_commande, '%Y-%m') AS mois,
           COUNT(*) AS nb_commandes
    FROM commandes
    GROUP BY mois
)
SELECT mois, nb_commandes,
       ROUND((nb_commandes - LAG(nb_commandes) OVER (ORDER BY mois)) * 100.0
             / LAG(nb_commandes) OVER (ORDER BY mois), 1) AS variation_pct
FROM mensuel
ORDER BY mois;

WITH etapes AS (
    SELECT 1 AS ordre, 'Inscrits' AS etape, COUNT(*) AS nb
    FROM clients
    UNION ALL
    SELECT 2, 'Ont commandé', COUNT(DISTINCT o.client_id)
    FROM commandes o
    INNER JOIN clients c ON c.id = o.client_id
)
SELECT etape, nb,
       ROUND(nb * 100.0 / LAG(nb) OVER (ORDER BY ordre), 1) AS taux_vs_precedent,
       ROUND(nb * 100.0 / FIRST_VALUE(nb) OVER (ORDER BY ordre), 1) AS taux_vs_depart
FROM etapes
ORDER BY ordre;

-- 1.Tableau mensuel : 
-- pour chaque mois (AAAA-MM), le nombre de commandes, le chiffre d’affaires et le panier moyen (arrondi à 2 décimales). 
SELECT DATE_FORMAT(date_commande, '%Y-%m') as mois, COUNT(id) as nb_commandes, SUM(montant) as ca, ROUND(AVG(montant),2) as moyen 
FROM commandes 
GROUP BY DATE_FORMAT(date_commande, '%Y-%m') ;
-- Résultat : 2026-01 : 2, 290, 145,00 ; 2026-02 : 2, 815, 407,50 ; 2026-03 : 2, 330, 165,00 ; 2026-04 : 1, 120, 120,00.

-- 2.Variation du chiffre d’affaires en % par rapport au mois précédent (1 décimale). 
WITH ca_mois AS (SELECT DATE_FORMAT(date_commande, '%Y-%m') as mois, SUM(montant) as ca
FROM commandes 
GROUP BY DATE_FORMAT(date_commande, '%Y-%m'))
SELECT mois, ca, 
ROUND((ca-LAG(ca) OVER (ORDER BY mois))/LAG(ca) OVER (ORDER BY mois)*100,1) AS variation 
FROM ca_mois 
ORDER BY mois;
-- Résultat : NULL, 181,0, -59,5, -63,6.

-- 3.Cumul et part du total : 
-- le chiffre d’affaires cumulé et la part de chaque mois dans le total (2 décimales). 
WITH ca_mois AS (SELECT DATE_FORMAT(date_commande, '%Y-%m') as mois, SUM(montant) as ca
FROM commandes 
GROUP BY DATE_FORMAT(date_commande, '%Y-%m'))
SELECT mois, SUM(ca) OVER (ORDER BY MOIS) AS cumul, ROUND(ca/SUM(ca) OVER()*100,2) as parts
FROM ca_mois
ORDER BY mois;
-- Résultat : cumul 290, 1105, 1435, 1555 ; parts 18,65, 52,41, 21,22, 7,72.

-- 4.Moyenne mobile sur 2 mois du chiffre d’affaires. 
WITH ca_mois AS (SELECT DATE_FORMAT(date_commande, '%Y-%m') as mois, SUM(montant) as ca
FROM commandes 
GROUP BY DATE_FORMAT(date_commande, '%Y-%m'))
SELECT mois, ca, ROUND(AVG(ca) OVER (ORDER BY mois ROWS BETWEEN 1 PRECEDING AND CURRENT ROW),2) as mb 
FROM ca_mois 
ORDER BY mois;
-- Résultat : 290,00, 552,50, 572,50, 225,00.

-- 5.Classement des mois par chiffre d’affaires décroissant (avec RANK), affiché dans l’ordre des mois. 
WITH ca_mois AS (SELECT DATE_FORMAT(date_commande, '%Y-%m') as mois, SUM(montant) as ca
FROM commandes 
GROUP BY DATE_FORMAT(date_commande, '%Y-%m'))
SELECT mois, ca, RANK() OVER (ORDER BY ca DESC) as rang
FROM ca_mois
ORDER BY mois;
-- Résultat : 2026-01 : rang 3, 2026-02 : 1, 2026-03 : 2, 2026-04 : 4.

-- 6.Entonnoir en quatre étapes, avec les deux taux :
-- Inscrits (clients),
WITH etapes AS (SELECT 1 AS ordre, 'Inscrits' AS etape, COUNT(*) as nb FROM clients
-- Ont commandé (clients distincts ayant une commande),
UNION ALL
SELECT 2 AS ordre, 'Ont commandé' AS etape, COUNT(DISTINCT c.id) as nb FROM commandes o
INNER JOIN clients c ON o.client_id=c.id
-- Ont une livraison (clients distincts dont une commande a une livraison)
UNION ALL
SELECT  3 AS ordre, 'Ont une livraison' as etape, COUNT(DISTINCT c.id) as nb FROM livraisons l
INNER JOIN commandes o ON o.id=l.commande_id
INNER JOIN clients c ON o.client_id=c.id
-- Livrés (clients distincts dont une commande a une livraison au statut 'livrée').
UNION ALL
SELECT  4 AS ordre, 'Livrés' as etape, COUNT(DISTINCT c.id) as nb FROM livraisons l 
INNER JOIN commandes o ON o.id=l.commande_id
INNER JOIN clients c ON o.client_id=c.id
WHERE statut='livrée')

SELECT etape, nb,
       ROUND(nb * 100.0 / LAG(nb) OVER (ORDER BY ordre), 1) AS taux_vs_precedent,
       ROUND(nb * 100.0 / FIRST_VALUE(nb) OVER (ORDER BY ordre), 1) AS taux_vs_depart
FROM etapes
ORDER BY ordre;
-- Résultat : Inscrits 8 ; Ont commandé 4 (50,0 et 50,0) ; Ont une livraison 3 (75,0 et 37,5) ; Livrés 2 (66,7 et 25,0). 
-- Indice : prends le modèle à deux étapes et ajoute deux blocs UNION ALL, avec les jointures livraisons, commandes, clients.

-- 7.Réflexion (en commentaire, avec tes mots) :
-- (a) À quelle étape de l’entonnoir perd-on le plus de clients, en nombre et en pourcentage ?
-- la 4e etape, livrées
-- (b) Pourquoi COUNT(DISTINCT client_id) et non COUNT(*) ?
-- Pour ne pas compter un client plusieurs fois
-- (c) Si on ne joignait pas clients, que deviendrait l’étape « Ont commandé », et pourquoi ce chiffre serait-il trompeur ?
-- ça sera 5, car il y a une commande sans client
-- (d) Quelle action proposerais-tu pour l’étape où la perte est la plus forte ?
-- INNER LEFT