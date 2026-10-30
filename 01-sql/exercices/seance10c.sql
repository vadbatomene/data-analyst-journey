USE formation;
DROP TABLE IF EXISTS commandes_lab;
DROP TABLE IF EXISTS journal_commandes_lab;
DROP TABLE IF EXISTS historique_total;
CREATE TABLE commandes_lab LIKE commandes;
INSERT INTO commandes_lab SELECT * FROM commandes;

CREATE TABLE journal_commandes_lab (
    id INT AUTO_INCREMENT PRIMARY KEY,
    action VARCHAR(10) NOT NULL,
    commande_id INT NOT NULL,
    ancien_montant INT,
    nouveau_montant INT,
    date_action DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE historique_total (
    id INT AUTO_INCREMENT PRIMARY KEY,
    date_mesure DATETIME NOT NULL,
    nb_commandes INT NOT NULL,
    ca INT NOT NULL
);

SELECT COUNT(*) FROM commandes_lab;          -- 7
SELECT COUNT(*) FROM journal_commandes_lab;  -- 0

DROP TRIGGER IF EXISTS trg_commandes_lab_ai;
DELIMITER $$
CREATE TRIGGER trg_commandes_lab_ai
AFTER INSERT ON commandes_lab
FOR EACH ROW
BEGIN
    INSERT INTO journal_commandes_lab (action, commande_id, ancien_montant, nouveau_montant)
    VALUES ('INSERT', NEW.id, NULL, NEW.montant);
END$$
DELIMITER ;


INSERT INTO commandes_lab (id, client_id, produit, montant, date_commande, produit_id)
VALUES (8, 4, 'Imprimante', 180, '2026-05-10', 1);
SELECT * FROM journal_commandes_lab;

DROP TRIGGER IF EXISTS trg_commandes_lab_bi;
DELIMITER $$
CREATE TRIGGER trg_commandes_lab_bi
BEFORE INSERT ON commandes_lab
FOR EACH ROW
BEGIN
    IF NEW.montant IS NULL OR NEW.montant <= 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Montant invalide';
    END IF;
    SET NEW.produit = TRIM(NEW.produit);
    IF NEW.date_commande IS NULL THEN
        SET NEW.date_commande = CURDATE();
    END IF;
END$$
DELIMITER ;

SHOW VARIABLES LIKE 'event_scheduler';
SET GLOBAL event_scheduler = ON;

CREATE EVENT ev_snapshot_total
ON SCHEDULE EVERY 1 MINUTE
STARTS CURRENT_TIMESTAMP
ENDS CURRENT_TIMESTAMP + INTERVAL 4 MINUTE
DO
    INSERT INTO historique_total (date_mesure, nb_commandes, ca)
    SELECT NOW(), COUNT(*), COALESCE(SUM(montant), 0) FROM commandes_lab;

-- 1.Préparation : lance le script ci-dessus. Attendu : 7 commandes, 0 ligne dans le journal.
DROP TABLE IF EXISTS commandes_lab;
DROP TABLE IF EXISTS journal_commandes_lab;
DROP TABLE IF EXISTS historique_total;
CREATE TABLE commandes_lab LIKE commandes;
INSERT INTO commandes_lab SELECT * FROM commandes;

CREATE TABLE journal_commandes_lab (
    id INT AUTO_INCREMENT PRIMARY KEY,
    action VARCHAR(10) NOT NULL,
    commande_id INT NOT NULL,
    ancien_montant INT,
    nouveau_montant INT,
    date_action DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE historique_total (
    id INT AUTO_INCREMENT PRIMARY KEY,
    date_mesure DATETIME NOT NULL,
    nb_commandes INT NOT NULL,
    ca INT NOT NULL
);

SELECT COUNT(*) FROM commandes_lab;          -- 7
SELECT COUNT(*) FROM journal_commandes_lab;  -- 0

-- 2.AFTER INSERT : 
-- crée trg_commandes_lab_ai 
DROP TRIGGER IF EXISTS trg_commandes_lab_ai;
DELIMITER $$
CREATE TRIGGER trg_commandes_lab_ai
AFTER INSERT ON commandes_lab
FOR EACH ROW
BEGIN
	INSERT INTO journal_commandes_lab(action, commande_id, ancien_montant, nouveau_montant)
    VALUES ('INSERT',NEW.id, NULL, NEW.montant);
END$$
DELIMITER ;
-- et insère la commande 8 (client 4, produit 'Imprimante', montant 180, date '2026-05-10', produit_id 1). 
INSERT INTO commandes_lab(id, client_id, produit, montant, date_commande, produit_id)
VALUES (8, 4, 'Imprimante', 180, '2026-05-10', 1);
-- Résultat : le journal contient INSERT, 8, NULL, 180.
-- 3.AFTER UPDATE : 
-- crée trg_commandes_lab_au, qui journalise seulement si le montant change. 
DROP TRIGGER IF EXISTS trg_commandes_lab_au;
DELIMITER $$
CREATE TRIGGER trg_commandes_lab_au
AFTER UPDATE ON commandes_lab
FOR EACH ROW
BEGIN
	IF NEW.montant <> OLD.montant THEN
		INSERT INTO journal_commandes_lab(action, commande_id, ancien_montant, nouveau_montant)
    VALUES ('UPDATE',NEW.id, OLD.montant, NEW.montant);
	END IF;
END $$
DELIMITER ;
-- Teste deux modifications : UPDATE commandes_lab SET montant = 200 WHERE id = 8; 
UPDATE commandes_lab SET montant = 200 WHERE id = 8; 
-- puis UPDATE commandes_lab SET produit = 'Imprimante laser' WHERE id = 8;. 
UPDATE commandes_lab SET produit = 'Imprimante laser' WHERE id = 8;
-- Résultat : une seule nouvelle ligne : UPDATE, 8, 180, 200. 
-- Explique en commentaire pourquoi la deuxième modification n’a rien journalisé.
-- Elle n'a rien journalisé car NEW.montant est égale à OLD.montant.

-- 4.AFTER DELETE : 
-- crée trg_commandes_lab_ad (avec OLD), 
DROP TRIGGER IF EXISTS trg_commandes_lab_ad;
DELIMITER $$
CREATE TRIGGER trg_commandes_lab_ad
AFTER DELETE ON commandes_lab
FOR EACH ROW
BEGIN
	INSERT INTO journal_commandes_lab(action, commande_id, ancien_montant, nouveau_montant)
    VALUES ('DELETE',OLD.id, OLD.montant, NULL);
END$$
DELIMITER $$ ;
-- supprime la commande 8, puis affiche le journal. 
DELETE FROM commandes_lab WHERE id=8;
-- Résultat : 3 lignes en tout : INSERT 8 NULL 180 ; UPDATE 8 180 200 ; DELETE 8 200 NULL.

-- 5.BEFORE INSERT : crée trg_commandes_lab_bi comme ci-dessus, puis teste :
DROP TRIGGER IF EXISTS trg_commandes_lab_bi;
DELIMITER $$
CREATE TRIGGER trg_commandes_lab_bi
BEFORE INSERT ON commandes_lab
FOR EACH ROW 
BEGIN
	IF NEW.montant IS NULL OR NEW.montant <=0 THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Montant invalide';
	END IF;
    SET NEW.produit = TRIM(NEW.produit);
    IF NEW.date_commande IS NULL THEN
		SET NEW.date_commande = CURDATE();
	END IF;
END $$
DELIMITER ;
-- (a) INSERT INTO commandes_lab (id, client_id, produit, montant, produit_id) VALUES (9, 1, ' Câble ', 25, 1); 
INSERT INTO commandes_lab (id, client_id, produit, montant, produit_id) VALUES (9, 1, ' Câble ', 25, 1); 
-- puis SELECT id, produit, date_commande FROM commandes_lab WHERE id = 9;. 
SELECT id, produit, date_commande FROM commandes_lab WHERE id = 9; 
-- Résultat : produit Câble sans espaces, date du jour.
-- (b) INSERT INTO commandes_lab (id, client_id, produit, montant, produit_id) VALUES (10, 1, 'Test', -5, 1);. 
INSERT INTO commandes_lab (id, client_id, produit, montant, produit_id) VALUES (10, 1, 'Test', -5, 1);
-- Résultat : erreur 1644 « Montant invalide », aucune ligne ajoutée.
-- (c) SELECT COUNT(*) FROM commandes_lab; (attendu : 8) 
SELECT COUNT(*) FROM commandes_lab;
-- et SELECT COUNT(*) FROM journal_commandes_lab; 
SELECT COUNT(*) FROM journal_commandes_lab; 
-- (attendu : 4, avec le INSERT de la commande 9 journalisé, et aucune ligne pour la commande refusée).

-- 6.Gérer les déclencheurs : 
-- (a) liste-les avec SHOW TRIGGERS LIKE 'commandes_lab'; (attendu : 4) ; 
SHOW TRIGGERS LIKE 'commandes_lab';
-- (b) supprime trg_commandes_lab_bi avec DROP TRIGGER ; 
DROP TRIGGER trg_commandes_lab_bi;
-- (c) insère maintenant la commande 11 avec un montant de -5 : elle est acceptée.
INSERT INTO commandes_lab (id, client_id, produit, montant, produit_id) VALUES (11, 1, 'Test', -5, 1); 
-- Écris en commentaire pourquoi, pour ce type de règle simple, une contrainte CHECK (montant > 0) serait préférable à un déclencheur.
-- le check s'attache à la table, un déclencher peut etre supprimer

-- 7. Événement : active le planificateur, 
-- crée ev_snapshot_total, attends environ 3 minutes,
DROP EVENT IF EXISTS ev_snapshot_total;
CREATE EVENT ev_snapshot_total
ON SCHEDULE EVERY 1 MINUTE
STARTS CURRENT_TIMESTAMP
ENDS CURRENT_TIMESTAMP + INTERVAL 3 MINUTE
DO
    INSERT INTO historique_total (date_mesure, nb_commandes, ca)
    SELECT NOW(), COUNT(*), COALESCE(SUM(montant), 0) FROM commandes_lab; 
-- puis affiche SELECT * FROM historique_total;. 
SELECT * FROM historique_total;
-- Résultat : au moins 3 lignes, avec le même nombre de commandes (celui de ta table à ce moment-là). 
-- Ensuite, vérifie avec SHOW EVENTS; 
SHOW EVENTS; 
-- puis nettoie avec DROP EVENT IF EXISTS ev_snapshot_total;.
DROP EVENT IF EXISTS ev_snapshot_total;

-- 8. Réflexion (en commentaire, avec tes mots) : 
-- (a) cite deux avantages d’un déclencheur pour tenir un journal d’audit ; 
-- Avoir la vue sur toutes les operations dans la bdd, controler la saisie d'informations
-- (b) cite deux risques ; 
-- Modification des infos, impossible de voir le code
-- (c) quelle est la différence entre un déclencheur et un événement ? 
-- declencheur depend des mouvements dans la base pour se declancher à tout moment, l'evenement est chonometré
-- (d) quand préfères-tu une contrainte CHECK à un déclencheur BEFORE INSERT ?
-- Lorsque il faut controler la saisie d'une information basique