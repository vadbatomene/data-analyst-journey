SHOW INDEX FROM clients;

USE formation;
SET SESSION cte_max_recursion_depth = 100000;

DROP TABLE IF EXISTS commandes_test;
CREATE TABLE commandes_test (
    id INT PRIMARY KEY,
    client_id INT NOT NULL,
    montant DECIMAL(10,2) NOT NULL,
    date_commande DATE NOT NULL
);

INSERT INTO commandes_test
WITH RECURSIVE n AS (
    SELECT 1 AS i
    UNION ALL
    SELECT i + 1 FROM n WHERE i < 100000
)
SELECT i,
       1 + (i * 7) % 5000,
       10 + (i * 13) % 990,
       DATE_ADD('2025-01-01', INTERVAL (i % 365) DAY)
FROM n;

-- 1.Les index que tu as déjà : lance SHOW INDEX FROM livraisons; et SHOW INDEX FROM commandes;.
SHOW INDEX FROM livraisons;
SHOW INDEX FROM commandes;
-- Note en commentaire : quels index tu n’as pas créés toi-même et pourquoi ils existent ; 
-- pour chaque table, les deux index sont la clé primaire et la clé de liaisons parce que ce sont des identifiants des tables
-- et quelle colonne de jointure de commandes n’est pas indexée. 
-- client_id
-- Indice : tu as ajouté des clés primaires et des clés étrangères à la séance 8, mais une clé étrangère n’a pas pu être créée.

-- 2.Vérifie la table de test : SELECT COUNT(*) FROM commandes_test; (attendu : 100000) 
SELECT COUNT(*) FROM commandes_test;
-- puis SELECT COUNT(*) FROM commandes_test WHERE client_id = 1234; (attendu : 20).
SELECT COUNT(*) FROM commandes_test WHERE client_id = 1234;

-- 3.Sans index : lance EXPLAIN SELECT * FROM commandes_test WHERE client_id = 1234;
EXPLAIN SELECT * FROM commandes_test WHERE client_id = 1234; 
-- et note en commentaire type, key et rows. 
-- type : ALL, key : NULL, rows : 10320
-- Résultat attendu : type ALL, key NULL, rows autour de 100 000.

-- 4.Avec index : crée idx_test_client sur client_id, refais l’EXPLAIN, puis relance le COUNT de l’exercice 2. 
CREATE INDEX idx_test_client
ON commandes_test(client_id);
EXPLAIN SELECT * FROM commandes_test WHERE client_id = 1234; 
SELECT COUNT(*) FROM commandes_test WHERE client_id = 1234;
-- Résultat attendu : type ref, key idx_test_client, rows autour de 20 ; le COUNT donne toujours 20. 
-- L’index change la manière de chercher, pas le résultat.

-- 5.Le piège de la fonction : crée idx_test_date sur date_commande, 
CREATE INDEX idx_test_date
ON commandes_test(date_commande);
-- puis compare deux EXPLAIN :
-- (a) WHERE MONTH(date_commande) = 3
EXPLAIN SELECT * FROM commandes_test WHERE MONTH(date_commande) = 3; 
-- (b) WHERE date_commande >= '2025-03-01' AND date_commande < '2025-04-01'
EXPLAIN SELECT * FROM commandes_test WHERE date_commande >= '2025-03-01' AND date_commande < '2025-04-01'; 
-- Résultat attendu : 
-- (a) type ALL, rows autour de 100 000 ; 
-- (b) type range, rows autour de 8 500. 
-- Les deux requêtes donnent le même nombre de lignes (8494 avec un COUNT(*)) : fais le test. 
SELECT COUNT(*) FROM commandes_test WHERE MONTH(date_commande) = 3; 
SELECT COUNT(*) FROM commandes_test WHERE date_commande >= '2025-03-01' AND date_commande < '2025-04-01'; 
-- Explique en commentaire pourquoi (a) ne peut pas utiliser l’index.
-- Parce on a filtre avec une valeur extrait qui est mois et non l'index c'est date_commande

-- 6.Clé primaire et colonne non indexée : lance EXPLAIN SELECT * FROM commandes_test WHERE id = 500; 
EXPLAIN SELECT * FROM commandes_test WHERE id = 500;
-- puis EXPLAIN SELECT * FROM commandes_test WHERE montant = 500;. 
EXPLAIN SELECT * FROM commandes_test WHERE montant = 500;
-- Résultat attendu : le premier est const avec 1 ligne ; le second est ALL, car montant n’a pas d’index.

-- 7. Réflexion (en commentaire, sans exécuter) : 
-- (a) pourquoi ne pas indexer toutes les colonnes d’une table ? 
-- L'index n'aura plus de sens car les recherches se feront sur toute la table
-- (b) quelles colonnes de ta base (clients, commandes, livraisons) indexerais-tu en priorité ? 
-- clients : id et telephone, commandes : id, client_id, produit_id, livraisons : id, commande_id, transporteur
-- (c) sur une colonne texte indexée, WHERE nom LIKE 'Ka%' et WHERE nom LIKE '%Ka' peuvent-ils utiliser l’index ? Pourquoi ?
-- Non, parce qu'on a créé une chaine de caracteur pas pris la valeur de la colonne.

-- 8.Nettoyage : supprime la table de test avec DROP TABLE commandes_test;.
DROP TABLE commandes_test;