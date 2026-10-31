USE formation;
DROP TABLE IF EXISTS achats;
DROP TABLE IF EXISTS clients_ana;

CREATE TABLE clients_ana (
    id INT PRIMARY KEY,
    prenom VARCHAR(50) NOT NULL,
    date_inscription DATE NOT NULL
);
INSERT INTO clients_ana VALUES
(1, 'Awa', '2026-01-05'), (2, 'Jean', '2026-01-12'), (3, 'Marie', '2026-01-20'),
(4, 'Patrick', '2026-01-28'), (5, 'Grace', '2026-01-30'), (6, 'David', '2026-02-03'),
(7, 'Sarah', '2026-02-10'), (8, 'Eric', '2026-02-18'), (9, 'Nadine', '2026-02-25'),
(10, 'Paul', '2026-03-02'), (11, 'Rachel', '2026-03-09'), (12, 'Kevin', '2026-03-20');

CREATE TABLE achats (
    id INT AUTO_INCREMENT PRIMARY KEY,
    client_id INT NOT NULL,
    date_achat DATE NOT NULL,
    montant DECIMAL(10,2) NOT NULL,
    CONSTRAINT fk_achats_client FOREIGN KEY (client_id) REFERENCES clients_ana(id)
);
INSERT INTO achats (client_id, date_achat, montant) VALUES
(1, '2026-01-08', 120), (1, '2026-02-12', 80), (1, '2026-03-15', 150), (1, '2026-05-20', 200),
(2, '2026-01-15', 300), (2, '2026-04-10', 250),
(3, '2026-01-22', 60), (3, '2026-02-25', 45), (3, '2026-03-30', 70),
(3, '2026-04-28', 55), (3, '2026-05-30', 65), (3, '2026-06-20', 50),
(4, '2026-01-30', 500),
(5, '2026-02-05', 90), (5, '2026-03-02', 110),
(6, '2026-02-06', 75), (6, '2026-03-12', 95), (6, '2026-04-18', 85),
(7, '2026-02-14', 200),
(8, '2026-02-20', 40), (8, '2026-04-05', 60),
(9, '2026-03-01', 130), (9, '2026-04-02', 140), (9, '2026-05-03', 150), (9, '2026-06-04', 160),
(10, '2026-03-05', 320),
(11, '2026-03-12', 35), (11, '2026-04-15', 45), (11, '2026-05-16', 55),
(12, '2026-04-01', 90);

SELECT c.prenom,
       MIN(a.date_achat) AS premier_achat,
       MAX(a.date_achat) AS dernier_achat,
       DATEDIFF(MAX(a.date_achat), MIN(a.date_achat)) AS jours_activite
FROM clients_ana c
INNER JOIN achats a ON a.client_id = c.id
GROUP BY c.id, c.prenom;


-- 1.Vérifie la préparation : 
-- SELECT COUNT(*) FROM clients_ana; (12) ; 
SELECT COUNT(*) FROM clients_ana;
-- SELECT COUNT(*), SUM(montant) FROM achats; (30 et 3825,00).
SELECT COUNT(*), SUM(montant) FROM achats;

-- 2.Tableau RFM : 
-- pour chaque client, son prénom, sa récence, sa fréquence et son montant total, dans l’ordre des id. 
SELECT c.id, c.prenom, DATEDIFF('2026-07-01', MAX(a.date_achat)) AS recence, COUNT(a.client_id) as frequence, SUM(a.montant) AS total
FROM clients_ana c INNER JOIN achats a ON c.id=a.client_id 
GROUP BY c.id ORDER BY c.id;
-- Résultat : Awa 42, 4, 550 ; Jean 82, 2, 550 ; Marie 11, 6, 345 ; Patrick 152, 1, 500 ; Grace 121, 2, 200 ; David 74, 3, 255 ; Sarah 137, 1, 200 ; Eric 87, 2, 100 ; Nadine 27, 4, 580 ; Paul 118, 1, 320 ; Rachel 46, 3, 135 ; Kevin 91, 1, 90.

-- 3.Les segments : 
-- ajoute à ce tableau le segment, avec un CASE et les règles ci-dessus (dans un CTE). 
WITH tableau AS (SELECT c.id, c.prenom, DATEDIFF('2026-07-01', MAX(a.date_achat)) AS recence, COUNT(a.client_id) as frequence, SUM(a.montant) AS total
FROM clients_ana c INNER JOIN achats a ON c.id=a.client_id 
GROUP BY c.id ORDER BY c.id)
SELECT prenom, CASE 
    WHEN recence<=45 and frequence>=3 THEN 'Champion'
    WHEN frequence>=3 THEN 'Fidèle'
    WHEN recence>90 THEN 'A relancer'
    ELSE 'Occasionnel' 
    END AS segment

FROM tableau
ORDER BY segment;

-- Résultat : Champion : Awa, Marie, Nadine ; Fidèle : David, Rachel ; 
-- À relancer : Patrick, Grace, Sarah, Paul, Kevin ; Occasionnel : Jean, Eric.

-- 4.Synthèse par segment : 
-- pour chaque segment, le nombre de clients, le chiffre d’affaires et sa part du total (2 décimales), du plus gros chiffre d’affaires au plus petit.
WITH tableau AS (SELECT c.id, c.prenom, DATEDIFF('2026-07-01',MAX(a.date_achat)) AS recence, COUNT(a.client_id) as frequence, SUM(a.montant) AS montant
FROM clients_ana c INNER JOIN achats a ON c.id=a.client_id 
GROUP BY c.id ORDER BY c.id),
segments AS (SELECT prenom, SUM(montant) AS montant, CASE 
    WHEN recence<=45 and frequence>=3 THEN 'Champion'
    WHEN frequence>=3 THEN 'Fidèle'
    WHEN recence>90 THEN 'A relancer'
    ELSE 'Occasionnel' 
    END AS segment

FROM tableau
GROUP BY id
ORDER BY segment)
SELECT segment, COUNT(*) AS nb, SUM(montant) as totat, ROUND(SUM(montant)/SUM(SUM(montant)) OVER() * 100,2) as part 
FROM segments 
GROUP BY segment;
--  Résultat : Champion 3, 1475,00, 38,56 ; À relancer 5, 1310,00, 34,25 ; Occasionnel 2, 650,00, 16,99 ; Fidèle 2, 390,00, 10,20.

-- 5.Quartiles de dépense : 
-- avec NTILE(4), le quartile de chaque client selon son montant total, du plus petit au plus grand montant.
WITH chiffres AS (SELECT c.id, c.prenom, SUM(a.montant) as total FROM clients_ana c
INNER JOIN achats a ON c.id=a.client_id
GROUP BY c.id, c.prenom)
SELECT prenom, total, NTILE(4) OVER (ORDER BY total) ordre FROM chiffres; 
-- Résultat : quartile 1 : Kevin 90, Eric 100, Rachel 135 ; quartile 2 : Grace 200, Sarah 200, David 255 ; quartile 3 : Paul 320, Marie 345, Patrick 500 ; quartile 4 : Awa 550, Jean 550, Nadine 580.

-- 6.Le chiffre d’affaires à risque : 
-- affiche les clients du segment À relancer, avec leur montant, du plus gros au plus petit.
WITH tableau AS (SELECT c.id, c.prenom, DATEDIFF('2026-07-01', MAX(a.date_achat)) AS recence, COUNT(a.client_id) as frequence, SUM(a.montant) AS montant
FROM clients_ana c INNER JOIN achats a ON c.id=a.client_id 
GROUP BY c.id ORDER BY c.id),
segments as (SELECT prenom, SUM(montant) AS montant, CASE 
    WHEN recence<=45 and frequence>=3 THEN 'Champion'
    WHEN frequence>=3 THEN 'Fidèle'
    WHEN recence>90 THEN 'A relancer'
    ELSE 'Occasionnel' 
    END AS segment

FROM tableau
GROUP BY id
ORDER BY segment)

SELECT prenom, montant, SUM(montant) OVER() as tot_ensemble FROM segments WHERE segment='A relancer'; 
-- Résultat : Patrick 500, Paul 320, Grace 200, Sarah 200, Kevin 90 ; ensemble : 1310,00, soit 34,25 % du chiffre d’affaires.

-- 7.Réflexion (en commentaire, avec tes mots) :
-- (a) Pour chacun des quatre segments, propose une action commerciale.
-- 10% de reduction pour CHAMPION, 5% pour fidele, 3 pour à relancer et 1 pour occassionel
-- (b) Pourquoi fixer la date de référence à '2026-07-01' plutôt que d’utiliser CURDATE() dans cet exercice ?
-- Pour respect les conditions de segments
-- (c) Les seuils (45 jours, 3 achats, 90 jours) sont arbitraires : donne un risque de les choisir sans en parler avec le métier.
-- Je ne suis pas commercial, dommage
-- (d) Patrick a un seul achat de 500 et plus aucune nouvelle depuis 152 jours : qu’est-ce que ce cas t’apprend sur la lecture du montant seul ?
-- il est occasionnel