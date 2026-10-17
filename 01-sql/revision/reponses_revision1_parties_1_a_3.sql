-- ======================================================
-- Révision SQL 1 (séances 1 à 6) : mes réponses
-- Une requête par exercice, sous son numéro.
-- ======================================================

USE formation;

-- ------------------------------------------------------
-- Partie 1 : les bases (séance 1)
-- ------------------------------------------------------
-- 1.1 [facile] Affiche tous les clients.
SELECT * FROM clients;


-- 1.2 [facile] Affiche uniquement le prénom et l'âge de chaque client.
SELECT prenom, age FROM clients;


-- 1.3 [facile] Affiche les clients qui habitent à Goma.
SELECT * FROM clients where ville='Goma';


-- 1.4 [facile] Affiche les clients de plus de 30 ans, du plus âgé au plus jeune.
SELECT * FROM clients where age>30 ORDER BY age DESC;


-- 1.5 [moyen] Affiche les clients de Kinshasa qui ont moins de 30 ans.
SELECT * FROM clients WHERE age<30 AND ville='Kinshasa';


-- 1.6 [moyen] Affiche les clients de Goma ou de Lubumbashi, triés par prénom.
SELECT * FROM clients WHERE ville='Goma' OR ville='Lubumbashi' ORDER BY prenom;


-- 1.7 [moyen] Affiche les 3 commandes les moins chères.
SELECT * FROM commandes ORDER BY montant LIMIT 3;


-- ------------------------------------------------------
-- Partie 2 : agrégations (séance 2)
-- ------------------------------------------------------

-- 2.1 [facile] Compte le nombre total de commandes.
SELECT COUNT(*) FROM commandes;


-- 2.2 [facile] Affiche en une seule requête le montant total, moyen, minimum et maximum des commandes.
SELECT SUM(montant) AS total, ROUND(AVG(montant),2) AS moyenne, MIN(montant) AS minimum, MAX(montant) as maximum FROM commandes;


-- 2.3 [moyen] Affiche le nombre de clients par ville.
SELECT ville, COUNT(*) AS nb_cliens FROM clients GROUP BY ville;


-- 2.4 [moyen] Affiche l'âge moyen par ville, arrondi à 1 décimale, de la ville la plus âgée à la plus jeune.
SELECT ville, ROUND(AVG(age), 1) AS age_moyen FROM clients GROUP BY ville ORDER BY ville;


-- 2.5 [moyen] Affiche les villes qui comptent au moins 3 clients.
SELECT ville, COUNT(*) AS nb_client FROM clients GROUP BY ville HAVING nb_client>=3;


-- 2.6 [moyen] Affiche, par ville, le nombre de clients de plus de 30 ans.

SELECT ville, COUNT(*) AS nb_client_pls30 FROM clients WHERE age>30 GROUP BY ville;

-- 2.7 [difficile] Affiche la ville dont l'âge moyen est le plus élevé (une seule ligne).

SELECT ville, AVG(age) AS age_moyen FROM clients GROUP BY ville ORDER BY age_moyen DESC LIMIT 1;

-- ------------------------------------------------------
-- Partie 3 : jointures (séance 3)
-- ------------------------------------------------------

-- 3.1 [facile] Affiche le prénom du client et le produit de chaque commande.

SELECT c.prenom, o.produit FROM clients c INNER JOIN commandes o ON c.id=o.client_id;

-- 3.2 [moyen] Affiche tous les clients avec leurs commandes, y compris ceux qui n'en ont pas.

SELECT c.prenom, o.produit, o.montant FROM clients c LEFT JOIN commandes o ON c.id=o.client_id;

-- 3.3 [moyen] Affiche les clients qui n'ont passé aucune commande.

SELECT c.prenom, o.produit, o.montant FROM clients c LEFT JOIN commandes o ON c.id=o.client_id WHERE produit is null;

-- 3.4 [moyen] Affiche la dépense totale de chaque client (prénom et total), du plus gros dépensier au plus petit.

SELECT c.prenom, SUM(o.montant) AS total FROM clients c LEFT JOIN commandes o ON c.id=o.client_id GROUP BY c.id, c.prenom ORDER BY total DESC;

-- 3.5 [moyen] Affiche le montant total des commandes par ville.
SELECT c.ville, SUM(o.montant) AS total FROM clients c INNER JOIN commandes o ON c.id=o.client_id GROUP BY ville;

-- 3.6 [difficile] Affiche tous les clients avec leur dépense totale, avec 0 pour ceux qui n'ont rien commandé.

SELECT c.prenom, SUM(o.montant) AS depense_total FROM clients c LEFT JOIN commandes o ON c.id=o.client_id GROUP BY c.prenom, c.id;

-- 3.7 [difficile] Affiche les commandes qui n'appartiennent à aucun client.

SELECT c.id, o.id, o.produit, o.montant FROM commandes o LEFT JOIN clients c ON o.client_id=c.id WHERE c.id IS NULL;

-- 3.8 [difficile] Affiche, pour chaque client (même sans commande), le nombre de commandes passées.

SELECT c.prenom, COALESCE(count(o.id), 0) as nb_commandes FROM clients c LEFT JOIN commandes o ON c.id=o.client_id GROUP BY c.id, c.prenom;
