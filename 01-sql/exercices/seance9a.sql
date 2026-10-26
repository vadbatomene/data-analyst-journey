USE formation;
SET SQL_SAFE_UPDATES = 0;

DROP TABLE IF EXISTS commandes_bac;
DROP TABLE IF EXISTS livraisons_bac;
CREATE TABLE commandes_bac LIKE commandes;
INSERT INTO commandes_bac SELECT * FROM commandes;
CREATE TABLE livraisons_bac LIKE livraisons;
INSERT INTO livraisons_bac SELECT * FROM livraisons;

SELECT COUNT(*) FROM commandes_bac;     -- doit afficher 7
SELECT COUNT(*) FROM livraisons_bac;    -- doit afficher 3

UPDATE livraisons_bac SET transporteur = 'FedEx' WHERE id = 2;
SELECT ROW_COUNT();                          -- 1 ligne modifiée
SELECT * FROM livraisons_bac;                -- la livraison 2 a le transporteur FedEx

START TRANSACTION;
UPDATE livraisons_bac SET cout = 1 WHERE id = 2;
SELECT id, cout FROM livraisons_bac;         -- la livraison 2 affiche 0.00
ROLLBACK;
SELECT id, cout FROM livraisons_bac;         -- la livraison 2 retrouve son coût d'origine

ALTER TABLE livraisons_bac ADD COLUMN cout_eleve VARCHAR(3);
UPDATE livraisons_bac
SET cout_eleve = CASE WHEN cout >= 20 THEN 'oui' ELSE 'non' END;
SELECT id, cout, cout_eleve FROM livraisons_bac;

ALTER TABLE livraisons_bac ADD COLUMN montant_commande INT;
UPDATE livraisons_bac l
INNER JOIN commandes c ON l.commande_id = c.id
SET l.montant_commande = c.montant;
SELECT id, commande_id, montant_commande FROM livraisons_bac;

START TRANSACTION;
DELETE FROM livraisons_bac WHERE cout < 20;
SELECT COUNT(*) FROM livraisons_bac;         -- 1 (deux livraisons supprimées)
ROLLBACK;
SELECT COUNT(*) FROM livraisons_bac;         -- 3 (tout est revenu)

-- (a) Lance SET SQL_SAFE_UPDATES = 1; puis UPDATE commandes_bac SET montant = 0; (sans WHERE). Code d’erreur attendu : 1175. Puis remets SET SQL_SAFE_UPDATES = 0;. Note en commentaire le code obtenu.
	SET SQL_SAFE_UPDATES = 1;
    UPDATE commandes_bac SET montant = 0;
    SET SQL_SAFE_UPDATES = 0;
    -- Error Code: 1175. You are using safe update mode and you tried to update a table without a WHERE that uses a KEY column.  To disable safe mode, toggle the option in Preferences -> SQL Editor and reconnect.


-- 1. Affiche les commandes de commandes_bac dont le montant est inférieur à 50. Résultat attendu : Casque 40, Souris 15, Clavier 30.
SELECT * FROM commandes_bac WHERE montant<50;

-- 2. La livraison de la commande 6 est arrivée : passe son statut à 'livrée' et sa date_livraison à '2026-03-20'. Vérifie avec ROW_COUNT() et un SELECT. Résultat attendu : 1 ligne modifiée ; la ligne de la commande 6 affiche livrée et 2026-03-20.

UPDATE livraisons_bac SET statut='livrée', date_livraison='2026-03-20' WHERE commande_id=6;
SELECT * FROM livraisons_bac WHERE commande_id=6;

-- 3. Dans une transaction, augmente de 10 % les montants de commandes_bac inférieurs à 50 (SET montant = montant * 1.1). 
START TRANSACTION;
UPDATE commandes_bac SET montant= montant*1.1 WHERE montant<50;
-- Affiche les trois lignes, puis fais un ROLLBACK et vérifie que tout est revenu. Résultat attendu : 44, 17, 33, puis 40, 15, 30. 
SELECT * FROM commandes_bac WHERE montant < 50;
ROLLBACK;
SELECT * FROM commandes_bac WHERE montant < 50;
-- Explique en commentaire pourquoi 17 et non 16,5 : regarde le type de montant avec DESCRIBE commandes_bac;.
DESCRIBE commandes_bac;
-- le montant est un entier et ça a arrondi 16,5 à 17

-- 4.
-- Lance ALTER TABLE commandes_bac MODIFY montant DECIMAL(10,2) NOT NULL;
	ALTER TABLE commandes_bac MODIFY montant DECIMAL(10,2) NOT NULL;
-- Lance DESCRIBE commandes_bac; : montant est maintenant decimal(10,2).
	DESCRIBE commandes_bac;
-- Refais l’exercice 3 (résultat attendu : 44.00, 16.50, 33.00, puis retour à 40.00, 15.00, 30.00).
START TRANSACTION;
UPDATE commandes_bac SET montant= montant*1.1 WHERE montant<50;
SELECT * FROM commandes_bac WHERE montant < 50;
ROLLBACK;
SELECT * FROM commandes_bac WHERE montant < 50;

-- 5. Dans commandes_bac :
-- ajoute la colonne categorie_montant (VARCHAR(10)) ;
ALTER TABLE commandes_bac ADD COLUMN categorie_montant VARCHAR(10);
-- remplis-la : moins de 100 Petite, de 100 à 299 Moyenne, 300 et plus Grande ;
UPDATE commandes_bac SET categorie_montant =
	CASE WHEN montant<100 THEN 'Petite' 
		 WHEN montant<300 THEN 'Moyenne'
         ELSE 'plusGrande' -- J'ai enlévé l'espace car plus grande fairt plus de 10 caractères
    END;
-- vérifie avec un GROUP BY : SELECT categorie_montant, COUNT(*) FROM commandes_bac GROUP BY categorie_montant;
SELECT categorie_montant, COUNT(*) FROM commandes_bac GROUP BY categorie_montant;
-- Résultat attendu : Petite 3, Moyenne 2, Grande 2.

-- 6. Même principe sur commandes_bac : ajoute ville_client (VARCHAR(50)) 
ALTER TABLE commandes_bac ADD COLUMN ville_client VARCHAR(50);
-- et remplis-la avec la ville du client, en joignant clients. Contrôle avec SELECT ROW_COUNT();
UPDATE commandes_bac o INNER JOIN clients c ON o.client_id=c.id SET o.ville_client=c.ville;
SELECT COUNT(*) FROM commandes_bac;
-- juste après l’UPDATE. Résultat attendu : 6 lignes modifiées. La commande 7 garde NULL : son client n’existe pas.

-- 7. Supprime la commande orpheline de commandes_bac (celle dont le client n’existe pas) :

-- prévisualise-la avec un SELECT (tu connais la méthode : LEFT JOIN clients ... WHERE c.id IS NULL) ;
SELECT * FROM commandes_bac o LEFT JOIN clients c ON o.client_id = c.id WHERE c.id IS NULL;
-- supprime-la avec cette forme à jointure : DELETE o FROM commandes_bac o LEFT JOIN clients c ON o.client_id = c.id WHERE c.id IS NULL;
DELETE o FROM commandes_bac o LEFT JOIN clients c ON o.client_id = c.id WHERE c.id IS NULL;

-- contrôle avec SELECT COUNT(*) FROM commandes_bac;.
SELECT COUNT(*) FROM commandes_bac;
-- Résultat attendu : 1 ligne supprimée, puis 6 commandes.

-- 8.
-- (a) Lance SET SQL_SAFE_UPDATES = 1; puis UPDATE commandes_bac SET montant = 0; (sans WHERE). Code d’erreur attendu : 1175. Puis remets SET SQL_SAFE_UPDATES = 0;. Note en commentaire le code obtenu.
	SET SQL_SAFE_UPDATES = 1;
    UPDATE commandes_bac SET montant = 0;
    SET SQL_SAFE_UPDATES = 0;
    -- Error Code: 1175. You are using safe update mode and you tried to update a table without a WHERE that uses a KEY column.  To disable safe mode, toggle the option in Preferences -> SQL Editor and reconnect.
