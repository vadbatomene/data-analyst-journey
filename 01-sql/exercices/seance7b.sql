SET SQL_SAFE_UPDATES = 0;

ALTER TABLE clients ADD COLUMN telephone VARCHAR(20);
UPDATE clients SET telephone = '0812345678' WHERE id = 1;
UPDATE clients SET telephone = '0823456789' WHERE id = 2;
UPDATE clients SET telephone = '0834567890' WHERE id = 4;
UPDATE clients SET telephone = '0845678901' WHERE id = 5;
UPDATE clients SET telephone = '' WHERE id = 7;

CREATE TABLE import_ventes (
    id INT,
    produit VARCHAR(50),
    quantite VARCHAR(10),
    prix_total VARCHAR(10)
);
INSERT INTO import_ventes VALUES (1, 'Telephone', '2', '500');
INSERT INTO import_ventes VALUES (2, 'Casque', '4', '160');
INSERT INTO import_ventes VALUES (3, 'Souris', '0', '0');
INSERT INTO import_ventes VALUES (4, 'Clavier', '3', '90');
INSERT INTO import_ventes VALUES (5, 'Tablette', '', '300');

SELECT * FROM commandes WHERE montant BETWEEN 100 AND 300;
SELECT prenom FROM clients WHERE telephone IS NULL;      -- Marie, David, Eric
SELECT prenom FROM clients WHERE telephone = NULL;       -- aucune ligne : toujours faux

-- 1. Traiter les chaînes vides comme des NULL, puis donner une valeur par défaut
SELECT prenom, COALESCE(NULLIF(telephone, ''), 'inconnu') AS tel FROM clients;

-- 2. Éviter une division par zéro
SELECT 100 / NULLIF(0, 0);        -- NULL au lieu d'une erreur

SELECT CAST('250' AS SIGNED) + 10;                       -- 260
SELECT produit, prix_total FROM import_ventes ORDER BY prix_total;
-- tri texte : 0, 160, 300, 500, 90  (« 90 » arrive en dernier : '9' > '5')
SELECT produit, prix_total FROM import_ventes ORDER BY CAST(prix_total AS SIGNED);
-- tri numérique : 0, 90, 160, 300, 500

-- 1.Affiche les commandes dont le montant est entre 100 et 300 (inclus), avec BETWEEN. Résultat : Telephone, Tablette, Montre.
SELECT produit FROM commandes WHERE montant BETWEEN 100 and 300;

-- 2.Affiche les commandes passées entre le 1er février et le 31 mars 2026, avec BETWEEN. Résultat : Ordinateur, Souris, Clavier, Tablette.
SELECT produit FROM commandes WHERE date_commande BETWEEN '2026-02-01' AND '2026-03-31'; 

-- 3.Affiche les clients sans téléphone : (a) NULL seulement, puis (b) NULL ou vide. Résultat : Marie, David, Eric, puis les mêmes plus Sarah.
SELECT prenom FROM clients WHERE telephone IS NULL;

SELECT prenom FROM clients WHERE telephone IS NULL or telephone='';

-- 4. Affiche chaque client avec son téléphone, et inconnu s’il est NULL ou vide (COALESCE et NULLIF). Résultat : Awa 0812345678, Jean 0823456789, Patrick 0834567890, Grace 0845678901, et inconnu pour Marie, David, Sarah, Eric.
SELECT prenom, COALESCE(NULLIF(telephone, ''), 'Inconnu') as telephone FROM clients;

-- 5.Compte les clients avec et sans numéro (CASE WHEN, en traitant NULL et vide comme « sans »). Résultat : 4 et 4.

SELECT
    CASE
        WHEN telephone IS NULL OR telephone = ''
            THEN 'Sans numéro'
        ELSE 'Avec numéro'
    END AS statut,
    COUNT(*) AS nombre_clients
FROM clients
GROUP BY
    CASE
        WHEN telephone IS NULL OR telephone = ''
            THEN 'Sans numéro'
        ELSE 'Avec numéro'
    END;
    
    -- ou
    SELECT
    SUM(CASE
        WHEN telephone IS NOT NULL AND telephone <> ''
        THEN 1 ELSE 0
    END) AS avec_numero,
    SUM(CASE
        WHEN telephone IS NULL OR telephone = ''
        THEN 1 ELSE 0
    END) AS sans_numero
FROM clients;

-- 6.Dans import_ventes, calcule le prix unitaire (prix_total divisé par quantite) avec CAST en nombres, et NULL (sans erreur) quand la quantité est 0 ou vide. Résultat : Telephone 250, Casque 40, Clavier 30, et NULL pour Souris et Tablette. Indice : NULLIF deux fois (la quantité vide, puis la quantité 0).

SELECT produit, CAST(prix_total as SIGNED) / NULLIF(NULLIF(CAST(quantite AS SIGNED),''),0)  as prix_unitaire FROM import_ventes;

-- 7.Trie import_ventes par prix_total : (a) comme du texte, (b) comme un nombre, et explique la différence. Résultat : (a) 0, 160, 300, 500, 90 ; (b) 0, 90, 160, 300, 500.

SELECT *
FROM import_ventes
ORDER BY prix_total;


SELECT *
FROM import_ventes
ORDER BY CAST(prix_total AS SIGNED);

-- Dans il fait un tri alphabetique donc texte, dans b un tri numerique car on les numerise avec CAST