CREATE TABLE ventes_plat (
    id_vente INT,
    client VARCHAR(50),
    ville_client VARCHAR(50),
    province_client VARCHAR(50),
    produit VARCHAR(50),
    categorie_produit VARCHAR(50),
    montant DECIMAL(10,2),
    date_vente DATE
);
INSERT INTO ventes_plat VALUES (1, 'Awa', 'Kinshasa', 'Kinshasa', 'Telephone', 'Electronique', 250, '2026-01-15');
INSERT INTO ventes_plat VALUES (2, 'Awa', 'Kinshasa', 'Kinshasa', 'Casque', 'Accessoires', 40, '2026-01-28');
INSERT INTO ventes_plat VALUES (3, 'Jean', 'Lubumbashi', 'Haut-Katanga', 'Ordinateur', 'Electronique', 800, '2026-02-10');
INSERT INTO ventes_plat VALUES (4, 'Marie', 'Kinshasa', 'Kinshasa', 'Souris', 'Accessoires', 15, '2026-02-22');
INSERT INTO ventes_plat VALUES (5, 'Marie', 'Kinshasa', 'Kinshasa', 'Clavier', 'Accessoires', 30, '2026-03-05');
INSERT INTO ventes_plat VALUES (6, 'Grace', 'Kinshasa', 'Kinshasa', 'Tablette', 'Electronique', 300, '2026-03-18');

-- 1.Compte les répétitions : nombre de lignes par ville_client et province_client. Résultat : Kinshasa/Kinshasa 5, Lubumbashi/Haut-Katanga 1.
SELECT ville_client, province_client, COUNT(*) as nb_repetion
FROM ventes_plat GROUP BY province_client, ville_client;

-- 2.Anomalie de mise à jour : lance UPDATE ventes_plat SET province_client = 'Kinshasa-Ville' WHERE id_vente = 1; puis SELECT DISTINCT ville_client, province_client FROM ventes_plat ORDER BY 1, 2;. Résultat : 3 lignes, Kinshasa a deux provinces. Explique le problème, et comment un schéma normalisé l’évite.
SET SQL_SAFE_UPDATES = 0;
UPDATE ventes_plat SET province_client = 'Kinshasa' 
WHERE id_vente = 1; 
SELECT DISTINCT ville_client, province_client FROM ventes_plat ORDER BY 1, 2;

-- Le probleme est qu'on a changé qu'en un seul endroit. Avec la normalisation on pouvait juste changer le nom dans une table qu'on devait relier avec vente_via un id, le changemeant allait etre auto partout

-- 3.Anomalies d’insertion et de suppression (en commentaire) : (
-- a) peut-on enregistrer un nouveau produit « Imprimante » sans vente ? non
--  Qu’est-ce qu’il faudrait inventer ? une table où repertorier tous les produits
-- (b) si on supprime la vente 3, quelles informations disparaissent ?  il y aura le client qui est à lubumbashi, sa province Haut-Katanga et le produit ordinateur qui seront supprimés de données
-- Résultat : (b) le seul client de Lubumbashi, la province Haut-Katanga, le produit Ordinateur.

-- 4.Normalise en créant quatre tables avec clés primaires, clés étrangères et NOT NULL :
-- villes_n : ville (clé primaire), province
CREATE TABLE villes_n (
ville VARCHAR(50) PRIMARY KEY,
province VARCHAR(50) NOT NULL);
-- clients_n : id (numérotation automatique, clé primaire), prenom, ville (clé étrangère)
CREATE TABLE clients_n (
id INT PRIMARY KEY AUTO_INCREMENT,
prenom VARCHAR(50) NOT NULL,
ville VARCHAR(50) NOT NULL,
 
 CONSTRAINT fk_clients_n_ville_n
 FOREIGN KEY (ville)
 REFERENCES villes_n(ville)); 
-- produits_n : id (numérotation automatique, clé primaire), nom, categorie
CREATE TABLE produits_n (
id INT PRIMARY KEY AUTO_INCREMENT,
nom VARCHAR(50) NOT NULL,
categorie VARCHAR(50) NOT NULL);
-- ventes_n : id (clé primaire), client_id et produit_id (clés étrangères), montant (DECIMAL(10,2)), date_vente (DATE)
CREATE TABLE ventes_n (
id INT PRIMARY KEY,
client_id INT NOT NULL,
produit_id INT NOT NULL,
montant DECIMAL(10,2) NOT NULL,
date_vente DATE NOT NULL,

CONSTRAINT fk_ventes_n_clients_n
FOREIGN KEY (client_id)
REFERENCES clients_n(id),

CONSTRAINT fk_ventes_n_produits_n
FOREIGN KEY (produit_id)
REFERENCES produits_n(id));

-- 5.Remplis-les depuis ventes_plat avec INSERT ... SELECT DISTINCT, 
-- dans l’ordre : villes, clients, produits, puis ventes. 
-- Pour les ventes, joins ventes_plat à clients_n sur le prénom et à produits_n sur le nom. 
-- Résultat : 2, 4, 6 et 6 lignes. Ici, joindre sur le prénom ne marche que parce que les prénoms sont uniques : dans la réalité, il faut une clé fiable.

INSERT INTO villes_n (ville, province)
SELECT DISTINCT ville_client, province_client FROM ventes_plat;

INSERT INTO clients_n (prenom, ville)
SELECT DISTINCT client, ville_client FROM ventes_plat;

INSERT INTO produits_n(nom, categorie)
SELECT DISTINCT  produit, categorie_produit FROM ventes_plat;

INSERT INTO ventes_n(id, client_id, produit_id, montant, date_vente)
SELECT v.id_vente, c.id, p.id, v.montant, v.date_vente 
FROM ventes_plat v
INNER JOIN clients_n c ON v.client=c.prenom
INNER JOIN produits_n p ON v.produit=p.nom;

-- 6.Vérifie : reconstitue les 6 lignes de ventes_plat à partir des quatre tables, avec des jointures (mêmes colonnes). Résultat : les 6 lignes, identiques à la table à plat.
SELECT v.id, c.prenom, a.ville, a.province, p.nom AS produit, p.categorie, v.montant, v.date_vente
FROM ventes_n v
INNER JOIN clients_n c ON v.client_id=c.id
INNER JOIN villes_n a ON c.ville=a.ville
INNER JOIN produits_n p ON v.produit_id=p.id;

-- 7.Réflexion + application : 
-- dans ta vraie table commandes, la colonne produit (texte) enfreint quelle forme normale, et pourquoi ? 
-- LA 3FN, car le nom du produit se repète, je dois normalement le lier avec un id produit à la place
-- Sur la copie, retire-la et retrouve les noms par jointure :

DROP TABLE IF EXISTS commandes_copie;
CREATE TABLE commandes_copie LIKE commandes;
INSERT INTO commandes_copie SELECT * FROM commandes;

ALTER TABLE commandes_copie DROP COLUMN produit;
SELECT o.id, p.nom AS produit, o.montant
FROM commandes_copie o
INNER JOIN produits p ON p.id = o.produit_id;

-- VErification table clients
DELETE FROM clients WHERE id = 9;
SELECT COUNT(*) FROM clients;