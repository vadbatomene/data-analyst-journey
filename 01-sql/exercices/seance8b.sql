ALTER TABLE commandes ADD PRIMARY KEY (id);
ALTER TABLE livraisons
    ADD CONSTRAINT fk_livraisons_commande
    FOREIGN KEY (commande_id) REFERENCES commandes(id);
    
-- 1. Ajoute les clés primaires : clients(id), commandes(id) et villes(ville). (produits en a déjà une.) Vérifie avec SHOW CREATE TABLE clients; et les deux autres. Résultat : PRIMARY KEY visible dans chacune.

ALTER TABLE clients ADD PRIMARY KEY (id);
SHOW CREATE TABLE clients;
ALTER TABLE commandes ADD PRIMARY KEY (id);
SHOW CREATE TABLE commandes;
ALTER TABLE villes ADD PRIMARY KEY (ville);
SHOW CREATE TABLE villes;

-- 2. Ajoute trois clés étrangères sur les vraies tables, avec ces noms :
-- fk_commandes_produit : commandes.produit_id vers produits.id
ALTER TABLE commandes
    ADD CONSTRAINT fk_commandes_produit
    FOREIGN KEY (produit_id) REFERENCES produits(id);
-- fk_clients_ville : clients.ville vers villes.ville
ALTER TABLE clients
    ADD CONSTRAINT fk_clients_ville
    FOREIGN KEY (ville) REFERENCES villes(ville);
-- fk_livraisons_commande : livraisons.commande_id vers commandes.id
ALTER TABLE livraisons
    ADD CONSTRAINT fk_livraisons_commande
    FOREIGN KEY (commande_id) REFERENCES commandes(id);
    
    -- 3. Teste l’intégrité sur la vraie base :

-- (a) Insère une livraison pour la commande 99. Code attendu : 1452.
INSERT INTO livraisons (commande_id, date_livraison, statut, cout, transporteur)
VALUES (99, '2026-12-01', 'livrée', 12.50, 'DHL');
-- Oui code 1452 car dans commandes ID 99 n'existe pas
-- (b) Tente de supprimer la commande 1, qui a une livraison, en te protégeant :

START TRANSACTION;
DELETE FROM commandes WHERE id = 1;
ROLLBACK;
-- code error 1451
SELECT COUNT(*) FROM commandes;
-- 7 commandes

-- 4. La commande orpheline, sur une copie (pour ne pas toucher à tes données d’exercice) :

CREATE TABLE commandes_copie LIKE commandes;
INSERT INTO commandes_copie SELECT * FROM commandes;

-- (a) Essaie d’ajouter commandes_copie.client_id → clients.id comme clé étrangère. Code attendu : 1452. Explique pourquoi.
ALTER TABLE commandes_copie 
	ADD CONSTRAINT fk_commandes_copie_clients
    FOREIGN KEY (client_id) REFERENCES clients(id);
-- Un client n'existe pas dans clients precisement le 9

-- (b) Retrouve la ligne fautive avec une requête (tu la connais : LEFT JOIN ... IS NULL).
SELECT o.client_id, c.prenom
FROM commandes o
LEFT JOIN clients c ON o.client_id=c.id
WHERE c.prenom IS NULL;

-- (c) Corrige la copie avec l’une de ces trois solutions, puis ajoute la clé étrangère avec succès : supprimer la commande, mettre client_id à NULL, ou créer le client 9. Laquelle choisirais-tu dans une vraie entreprise, et pourquoi ? Indice : une donnée supprimée en silence est une information perdue.

INSERT INTO clients (id, prenom, ville, age, telephone)
VALUES (9, 'Vad', 'Kinshasa', 29, '0812229495');

-- 5. Réflexion (en commentaire) :

-- Pour livraisons.commande_id, quelle règle ON DELETE choisirais-tu : RESTRICT, CASCADE ou SET NULL ? Justifie.
-- CASCADE car une livraison existe sur bas de commandes
-- Quelle autre relation de ta base mériterait une clé étrangère ? Indice : equipe.manager_id renvoie vers une autre ligne de la même table.
-- equipe.manager_id vers manager.id
-- Et anciens_clients : pourquoi une clé étrangère vers villes y poserait-elle problème ? Indice : la ville Kisangani.
-- La ville de kisangani n'existe pas dans villes