use formation ;
CREATE TABLE anciens_clients (id INT, prenom VARCHAR(50), ville VARCHAR(50));
INSERT INTO anciens_clients VALUES (101, 'Awa', 'Kinshasa');
INSERT INTO anciens_clients VALUES (102, 'Blaise', 'Kisangani');
INSERT INTO anciens_clients VALUES (103, 'Claire', 'Goma');
INSERT INTO anciens_clients VALUES (104, 'Jean', 'Lubumbashi');

CREATE TABLE equipe (
    id INT,
    prenom VARCHAR(50),
    poste VARCHAR(50),
    manager_id INT
);
INSERT INTO equipe VALUES (1, 'Esther', 'Directrice', NULL);
INSERT INTO equipe VALUES (2, 'Paul', 'Chef analyste', 1);
INSERT INTO equipe VALUES (3, 'Nadine', 'Analyste', 2);
INSERT INTO equipe VALUES (4, 'Kevin', 'Analyste', 2);
INSERT INTO equipe VALUES (5, 'Rachel', 'Stagiaire', 3);

SELECT prenom, ville FROM clients
UNION
SELECT prenom, ville FROM anciens_clients;      -- 10 lignes (doublons supprimés)

SELECT prenom, ville FROM clients
UNION ALL
SELECT prenom, ville FROM anciens_clients;      -- 12 lignes (tout est gardé)

SELECT e.prenom AS employe, m.prenom AS manager
FROM equipe e
LEFT JOIN equipe m ON e.manager_id = m.id;

SELECT a.prenom, b.prenom, a.ville
FROM clients a
INNER JOIN clients b ON a.ville = b.ville AND a.id < b.id;

-- 1.Affiche la liste des prénoms et villes de clients et d’anciens_clients, sans doublon. Résultat : 10 lignes.
SELECT prenom, ville FROM clients
UNION
SELECT prenom, ville FROM anciens_clients;

-- 2.Même liste, en gardant tout. Compare le nombre de lignes avec l’exercice 1. Résultat : 12 lignes. Quelles lignes expliquent l’écart de 2 ?

SELECT prenom, ville FROM clients
UNION ALL
SELECT prenom, ville FROM anciens_clients;

-- Lignes AWA et Jean qui sont dans ces 2 tables

-- 3.Affiche les villes différentes mentionnées dans clients, anciens_clients et villes, triées par ordre alphabétique. Résultat : Goma, Kinshasa, Kisangani, Lubumbashi.

SELECT ville FROM clients
UNION
SELECT ville FROM anciens_clients
UNION
SELECT ville FROM villes
ORDER BY ville;

-- 4.Affiche chaque membre de equipe avec son poste et le prénom de son manager (Aucun s’il n’en a pas). Résultat : Esther Aucun, Paul Esther, Nadine Paul, Kevin Paul, Rachel Nadine.

SELECT m.prenom AS membre, m.poste, COALESCE(n.prenom, 'aucun') AS manager
FROM equipe m
LEFT JOIN equipe n ON m.manager_id=n.id;

-- 5. Pour chaque membre de equipe, même sans collaborateur, le nombre de collaborateurs directs. Résultat : Esther 1, Paul 2, Nadine 1, Kevin 0, Rachel 0.

SELECT c.prenom, COUNT(m.id) as nb_collabo
FROM equipe c 
LEFT JOIN equipe m ON m.manager_id=c.id
GROUP by c.prenom;

-- 6.Affiche toutes les paires de clients qui habitent la même ville, chaque paire une seule fois. Résultat : 8 paires (6 à Kinshasa, 1 à Lubumbashi, 1 à Goma).

SELECT c.prenom, d.prenom, c.ville 
FROM clients c
INNER JOIN clients d ON d.ville=c.ville AND c.id<d.id;

-- 7.Défi : pour chaque client, le nombre de clients de la même ville qui sont plus jeunes que lui. Résultat : Awa 1, Marie 0, Grace 2, Eric 3, Jean 0, Sarah 1, Patrick 1, David 0. Indice : self join avec b.age < a.age, et LEFT JOIN pour garder ceux qui ont 0.

SELECT c.prenom, COUNT(d.age) as moins_age
FROM clients c
LEFT JOIN clients d ON d.ville=c.ville AND c.age>d.age
GROUP BY c.prenom;