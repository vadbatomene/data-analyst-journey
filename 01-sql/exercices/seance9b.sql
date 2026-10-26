CREATE VIEW v_commandes_detail AS
SELECT o.id AS id_commande, o.date_commande,
       c.prenom AS client, c.ville,
       p.nom AS produit, p.categorie, o.montant
FROM commandes o
INNER JOIN clients c ON c.id = o.client_id
INNER JOIN produits p ON p.id = o.produit_id;

SELECT * FROM v_commandes_detail;

SELECT categorie, SUM(montant) AS total
FROM v_commandes_detail
GROUP BY categorie;

-- 1.Crée la vue v_commandes_detail avec la requête de l’exemple (écris-la toi-même, sans la recopier), 
-- puis affiche-la triée par id_commande. Résultat : 6 lignes, avec Awa, Jean, Marie, Grace.

CREATE VIEW v_commandes_detail AS 
SELECT o.id AS id_commande, o.date_commande, c.prenom as client, c.ville, o.produit , p.categorie, o.montant 
FROM commandes o
INNER JOIN clients c ON o.client_id=c.id
INNER JOIN produits p ON p.id=produit_id;

SELECT * FROM v_commandes_detail ORDER BY id_commande;

-- 2.Interroge la vue : 
-- (a) le total par ville, 
SELECT ville, SUM(montant) FROM v_commandes_detail GROUP BY ville;
-- (b) le nombre de commandes par client. Résultats : 
SELECT client, count(id_commande) FROM v_commandes_detail GROUP BY client;
-- (a) Kinshasa 635, Lubumbashi 800 ; (b) Awa 2, Jean 1, Marie 2, Grace 1.

-- 3.Une vue qui protège : crée v_clients_public avec seulement id, prenom et ville de clients. 
CREATE VIEW v_clients_public AS
SELECT id as id_client, prenom, ville FROM clients;
-- Vérifie qu’elle affiche 8 lignes et 3 colonnes. 
SELECT * FROM v_clients_public;
-- Écris en commentaire pourquoi cette vue est utile pour partager des données avec une personne qui n’a pas besoin de l’âge ni du téléphone.
-- cela garde les infos personelles du clients confidentielles

-- 4.Une vue avec agrégation : crée v_depenses_client qui donne, pour chaque client, même sans commande, son id, son prenom, son nombre de commandes (nb_commandes) et sa dépense totale (depense_totale, 0 si aucune).
-- Puis interroge-la pour afficher les clients dont la dépense dépasse 250. 
CREATE VIEW v_depenses_client AS 
SELECT c.id AS id_client, c.prenom,  COUNT(o.id) AS nb_commandes, COALESCE(SUM(o.montant),0) as depense_totale
FROM clients c
LEFT JOIN commandes o ON c.id=o.client_id
GROUP BY c.id, c.prenom;
-- Résultats : la vue donne Awa 2 et 290, Jean 1 et 800, Marie 2 et 45, Grace 1 et 300, et 0 et 0 pour Patrick, David, Sarah, Eric ; 
-- ensuite : Awa, Jean, Grace. Indice : LEFT JOIN, COUNT(o.id), COALESCE.

-- 5. Une vue est toujours à jour : sur ta copie, crée la vue puis modifie les données dans une transaction.
CREATE VIEW v_total_bac AS SELECT SUM(montant) AS total FROM commandes_bac;
SELECT * FROM v_total_bac;

START TRANSACTION;
UPDATE commandes_bac SET montant = montant + 100 WHERE id = 1;
SELECT * FROM v_total_bac;
ROLLBACK;
SELECT * FROM v_total_bac;

-- Ce que tu dois constater : le total augmente de 100 dans la transaction, puis revient à sa valeur de départ. 
-- Explique en commentaire pourquoi la vue n’a pas besoin d’être « mise à jour ».
-- La vue n'a pas besoin d'etre mise à jour car elle est une requete sauvegarde qui s'execute avec des données actuelle au moment qu'on en fait appel.

-- 6.Modifier une vue : avec CREATE OR REPLACE VIEW, ajoute à v_commandes_detail la colonne province, en joignant villes.
CREATE OR REPLACE VIEW v_comamndes_detail AS
SELECT o.id AS id_commande, o.date_commande, c.prenom as client, c.ville, v.province, o.produit , p.categorie, o.montant 
FROM commandes o
INNER JOIN clients c ON o.client_id=c.id
INNER JOIN produits p ON p.id=produit_id
INNER JOIN villes v ON c.ville=v.ville;
--  Résultat : 6 lignes, avec Kinshasa pour la plupart et Haut-Katanga pour Jean.

-- 7.Gérer les vues : 
-- (a) affiche la liste de tes vues avec SHOW FULL TABLES WHERE Table_type = 'VIEW'; (attendu : v_commandes_detail, v_clients_public, v_depenses_client, v_total_bac) ; 
SHOW FULL TABLES WHERE Table_type = 'VIEW';
-- (b) supprime v_total_bac avec DROP VIEW ; 
DROP VIEW v_total_bac;
-- (c) écris en commentaire la différence entre une vue et une table copie (CREATE TABLE ... AS SELECT), en pensant à la mise à jour des données et à l’espace utilisé.
-- La vue garde des sql qu'elle execute avec les données d'une table, en tenant compte de futur modification des données, la copie prend les données telle que ça y est sans possibilité de mise à jour automatique.