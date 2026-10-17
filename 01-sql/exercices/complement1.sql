USE formation;
SET SQL_SAFE_UPDATES = 0;

CREATE TABLE produits (
    id INT PRIMARY KEY,
    nom VARCHAR(50),
    categorie VARCHAR(50)
);

INSERT INTO produits VALUES (1, 'Telephone', 'Electronique');
INSERT INTO produits VALUES (2, 'Casque', 'Accessoires');
INSERT INTO produits VALUES (3, 'Ordinateur', 'Electronique');
INSERT INTO produits VALUES (4, 'Souris', 'Accessoires');
INSERT INTO produits VALUES (5, 'Clavier', 'Accessoires');
INSERT INTO produits VALUES (6, 'Tablette', 'Electronique');
INSERT INTO produits VALUES (7, 'Montre', 'Accessoires');

ALTER TABLE commandes ADD COLUMN produit_id INT;

UPDATE commandes o
INNER JOIN produits p ON o.produit = p.nom
SET o.produit_id = p.id;

CREATE TABLE villes (
    ville VARCHAR(50),
    province VARCHAR(50)
);

INSERT INTO villes VALUES ('Kinshasa', 'Kinshasa');
INSERT INTO villes VALUES ('Lubumbashi', 'Haut-Katanga');
INSERT INTO villes VALUES ('Goma', 'Nord-Kivu');

SELECT c.prenom, p.nom AS produit, p.categorie, o.montant
FROM clients c
INNER JOIN commandes o ON c.id = o.client_id
INNER JOIN produits p ON o.produit_id = p.id;

SELECT v.province, p.categorie, SUM(o.montant) AS total
FROM clients c
INNER JOIN villes v ON c.ville = v.ville
INNER JOIN commandes o ON c.id = o.client_id
INNER JOIN produits p ON o.produit_id = p.id
GROUP BY v.province, p.categorie;

SELECT o.categorie, SUM(c.montant) 
FROM produits o 
INNER JOIN commandes c ON o.id=c.produit_id 
GROUP BY o.categorie;

SELECT p.province, SUM(o.montant) 
FROM clients c 
INNER JOIN commandes o ON c.id=o.client_id 
INNER JOIN villes p ON c.ville=p.ville 
GROUP BY p.province;

SELECT a.prenom, b.province, c.nom AS produit, d.montant 
FROM clients a 
INNER JOIN villes b ON a.ville=b.ville 
INNER JOIN commandes d ON a.id=d.client_id 
INNER JOIN produits c ON c.id=d.produit_id;

SELECT a.id, a.prenom, b.province, COUNT(c.id)
FROM clients a 
LEFT JOIN villes b ON a.ville=b.ville
LEFT JOIN commandes c ON a.id=c.client_id
GROUP BY a.id, a.prenom, b.province;

WITH classement as(
SELECT a.province as province, b.categorie as categorie, sum(c.montant) as total_vendu
FROM villes a INNER JOIN clients d ON a.ville=d.ville
INNER JOIN commandes c ON c.client_id=d.id
INNER JOIN produits b ON b.id=c.produit_id
GROUP BY a.province, b.categorie),
classement_final as (SELECT province, categorie, total_vendu, 
RANK() OVER (PARTITION BY province ORDER BY total_vendu DESC) AS rang
FROM classement)
SELECT * FROM classement_final WHERE rang=1;
