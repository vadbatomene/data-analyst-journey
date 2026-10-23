CREATE TABLE fournisseurs (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nom VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE,
    telephone VARCHAR(20),
    ville VARCHAR(50) NOT NULL DEFAULT 'Kinshasa',
    note DECIMAL(3,1) CHECK (note BETWEEN 0 AND 10),
    date_creation DATE NOT NULL
);

INSERT INTO fournisseurs (nom, email, date_creation)
VALUES ('Congo Tech', 'contact@congotech.cd', '2026-10-01');

-- 1. Crée la table livraisons avec ces colonnes :

-- id : entier, numérotation automatique, clé primaire
-- commande_id : entier, obligatoire
-- date_livraison : date, facultative (pas encore livrée)
-- statut : texte de 20 caractères maximum, obligatoire, valeur par défaut en préparation
-- cout : montant avec 2 décimales (8 chiffres au total), obligatoire, qui doit être supérieur ou égal à 0
-- transporteur : texte de 50 caractères maximum, facultatif


CREATE TABLE livraisons (
	id INT PRIMARY KEY AUTO_INCREMENT,
    commande_id INT NOT NULL,
    date_livraison DATE,
    statut VARCHAR(20) NOT NULL DEFAULT 'en preparation',
    cout DECIMAL(8,2) NOT NULL CHECK(cout >= 0),
    transporteur VARCHAR(50)
);

-- 2. 2. Insère ces trois livraisons, en précisant les colonnes (le troisième cas utilise les valeurs par défaut) :
-- commande 1, livrée le 16 janvier 2026, statut livrée, coût 12.50, transporteur DHL
-- commande 3, livrée le 12 février 2026, statut livrée, coût 40.00, transporteur DHL
-- commande 6, coût 15.75, rien d’autre

INSERT INTO livraisons (commande_id, date_livraison, statut, cout, transporteur)
VALUES (1, '2026-01-16', 'livrée', 12.50, 'DHL');
INSERT INTO livraisons (commande_id, date_livraison, statut, cout, transporteur)
VALUES (3, '2026-02-12', 'livrée', 40.50, 'DHL');
INSERT INTO livraisons (commande_id, cout)
VALUES (6, 15.75);

SELECT * FROM livraisons;

-- 3. Tente une par une ces quatre insertions invalides, et note en commentaire le code d’erreur de chacune :

-- (a) un coût NULL

INSERT INTO livraisons (commande_id, date_livraison, statut, cout, transporteur)
VALUES (2, '2026-01-17', 'livrée', NULL , 'DHL');

-- code erreur 1048

-- (b) une date de livraison '2026-13-45'
INSERT INTO livraisons (commande_id, date_livraison, statut, cout, transporteur)
VALUES (2, '2026-13-45', 'livrée', 12.50, 'DHL');

-- code erreur 1292

-- (c) un coût 'abc'
INSERT INTO livraisons (commande_id, date_livraison, statut, cout, transporteur)
VALUES (2, '2026-06-15', 'livrée', 'abc', 'DHL');

-- code erreur 1366

-- (d) un coût de -5
INSERT INTO livraisons (commande_id, date_livraison, statut, cout, transporteur)
VALUES (2, '2026-06-15', 'livrée', -5, 'DHL');

-- code erreur 3819

-- 4. Pourquoi le téléphone est-il en VARCHAR ? Teste avec une table temporaire :

CREATE TEMPORARY TABLE test_tel (tel INT);
INSERT INTO test_tel VALUES ('0812345678');
SELECT * FROM test_tel;

-- Il donne 812345678 parce tel est de type int

-- 5. Précision des nombres : lance

SELECT 0.1 + 0.2 = 0.3;
SELECT 0.1e0 + 0.2e0 = 0.3e0;

-- On evit les doubles et Float parce qu'ils donnent des reponses approximatives contrairement à decimal qui donne l'exactitude

-- 6. Lance DESCRIBE livraisons; et explique, pour id et statut, ce que disent les colonnes Null, Key, Default et Extra.

DESCRIBE livraisons;

-- Null : les deux colonnes ne peuvent pas etre vide
-- Key : ID est la clé primaire, statut non
-- Default : Id n'a pas une valeur par defaut en d'absence de valeur lors de l'insertion, statut met en prepartion en cas d'abscence
-- Extra : ID s'accroit de +1 à chaque enregistrement statut non

-- 7. Réflexion (à écrire en commentaire, sans exécuter) : pour ta table commandes actuelle, quels types et quelles contraintes choisirais-tu pour chaque colonne (id, client_id, produit, montant, date_commande, produit_id) ? Une colonne te semble-t-elle superflue ? Indice : compare produit et produit_id.

-- id INT PRIMARY KEY AUTO_INCREMENT
-- client_id type INT NOT NULL
-- produit VARCHAR(40) NOT NULL
-- montant DECIMAL(10,2) NOT NULL CHECK (montant > 0)
-- date_commande DATE NOT NULL
-- produit_id INT NOT NULL
-- C'est la table produit_id