USE formation;
DROP TABLE IF EXISTS commandes_lab;
DROP TABLE IF EXISTS livraisons_lab;
DROP TABLE IF EXISTS livraisons_archive;
CREATE TABLE commandes_lab LIKE commandes;
INSERT INTO commandes_lab SELECT * FROM commandes;
CREATE TABLE livraisons_lab LIKE livraisons;
INSERT INTO livraisons_lab SELECT * FROM livraisons;
CREATE TABLE livraisons_archive LIKE livraisons;

SELECT COUNT(*) FROM commandes_lab;       -- 7
SELECT COUNT(*) FROM livraisons_lab;      -- 3
SELECT COUNT(*) FROM livraisons_archive;  -- 0

DROP FUNCTION IF EXISTS f_niveau;
DELIMITER $$
CREATE FUNCTION f_niveau(p_total INT) RETURNS VARCHAR(10)
DETERMINISTIC
BEGIN
    DECLARE v_niveau VARCHAR(10);
    IF p_total >= 500 THEN
        SET v_niveau = 'Or';
    ELSEIF p_total >= 100 THEN
        SET v_niveau = 'Argent';
    ELSE
        SET v_niveau = 'Bronze';
    END IF;
    RETURN v_niveau;
END$$
DELIMITER ;

SELECT f_niveau(45), f_niveau(290), f_niveau(800);

DROP FUNCTION IF EXISTS f_total_client;
DELIMITER $$
CREATE FUNCTION f_total_client(p_client_id INT) RETURNS INT
READS SQL DATA
BEGIN
    DECLARE v_total INT;
    SELECT COALESCE(SUM(montant), 0) INTO v_total
    FROM commandes_lab WHERE client_id = p_client_id;
    RETURN v_total;
END$$
DELIMITER ;

SELECT prenom, f_total_client(id) AS total FROM clients;

DROP PROCEDURE IF EXISTS p_ajouter_livraison;
DELIMITER $$
CREATE PROCEDURE p_ajouter_livraison(IN p_commande_id INT, IN p_cout DECIMAL(8,2))
BEGIN
    IF NOT EXISTS (SELECT 1 FROM commandes_lab WHERE id = p_commande_id) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Commande inexistante';
    END IF;
    IF p_cout < 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Le coût ne peut pas être négatif';
    END IF;
    INSERT INTO livraisons_lab (commande_id, cout) VALUES (p_commande_id, p_cout);
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS p_archiver_livraison;
DELIMITER $$
CREATE PROCEDURE p_archiver_livraison(IN p_id INT)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SELECT 'Erreur : opération annulée' AS message;
    END;

    START TRANSACTION;
    INSERT INTO livraisons_archive SELECT * FROM livraisons_lab WHERE id = p_id;
    DELETE FROM livraisons_lab WHERE id = p_id;
    COMMIT;
    SELECT 'Livraison archivée' AS message;
END$$
DELIMITER ;

-- 1.Fonction : 
-- crée f_niveau(p_total INT) 
-- (Or à partir de 500, Argent à partir de 100, sinon Bronze) et teste SELECT f_niveau(45), f_niveau(290), f_niveau(800);. 
DROP FUNCTION IF EXISTS f_niveau;
DELIMITER $$
CREATE FUNCTION f_niveau(p_total INT) RETURNS VARCHAR(10)
DETERMINISTIC
BEGIN
	DECLARE v_niveau VARCHAR(10);
    IF p_total >= 500 THEN
		SET v_niveau='Or';
	ELSEIF p_total >= 100 THEN
		SET v_niveau='Argent';
	ELSE
		SET v_niveau='Bronze';
	END IF;
    RETURN v_niveau;
END $$
DELIMITER ;

SELECT f_niveau(45), f_niveau(290), f_niveau(800);
	
-- Résultat : Bronze, Argent, Or.

-- 2.Utilisation dans une requête : 
-- affiche, pour chaque client même sans commande, son prénom, son total et son niveau, 
-- avec les vraies tables clients et commandes (LEFT JOIN, GROUP BY c.id, c.prenom, COALESCE). 
SELECT c.id, c.prenom, COALESCE(SUM(o.montant),0) as total, f_niveau(COALESCE(SUM(o.montant),0)) AS niveau
FROM clients c
LEFT JOIN commandes o ON c.id=o.client_id
GROUP BY c.id, c.prenom;
-- Résultat : Awa 290 Argent, Jean 800 Or, Marie 45 Bronze, Patrick 0 Bronze, Grace 300 Argent, David, Sarah et Eric 0 Bronze.

-- 3.Fonction qui lit une table : 
-- crée f_total_client(p_client_id INT) RETURNS INT sur commandes_lab, avec COALESCE, 
DROP FUNCTION IF EXISTS f_total_client;
DELIMITER $$
CREATE FUNCTION f_total_client(p_client_id INT) RETURNS INT
READS SQL DATA
BEGIN
	DECLARE v_total INT DEFAULT 0;
    SELECT COALESCE(SUM(montant),0) INTO v_total FROM commandes_lab 
	WHERE client_id=p_client_id;
	RETURN v_total;
END $$
DELIMITER ;
-- puis affiche SELECT prenom, f_total_client(id) AS total FROM clients; 
SELECT prenom, f_total_client(id) AS total FROM clients;
-- et la version combinée avec f_niveau. 
SELECT prenom, f_total_client(id) AS total, f_niveau(f_total_client(id)) AS niveau FROM clients;
-- Résultats : comme ci-dessus.

-- 4.Erreur 1418 (en commentaire) : 
-- pourquoi MySQL demande-t-il DETERMINISTIC ou READS SQL DATA ? 
-- C'est pour lui permettre de comprendre le tyoe de fonction, s'il doit traiter des variables et lire des sql
-- Quelle est la différence entre les deux ? 
-- DETERMINISTIC utilise les variables avec des resultats fixes, READS SQL DATA lit des tables
-- Indice : l’une des deux fonctions lit des tables, l’autre pas.

-- 5.SIGNAL : 
-- crée p_ajouter_livraison 
DROP PROCEDURE IF EXISTS p_ajouter_livraison;
DELIMITER $$
CREATE PROCEDURE p_ajouter_livraison(IN p_commande_id INT, IN p_cout DECIMAL(10,2))
BEGIN
	IF NOT EXISTS (SELECT 1 FROM commandes_lab WHERE id=p_commande_id) THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Commande Inexistante';
	END IF;
    IF p_cout < 0 THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Le coût ne peut pas être inferieur à zéro';
	END IF;
    INSERT INTO livraisons_lab (commande_id, cout) VALUES (p_commande_id, p_cout);
END
$$

DELIMITER ;
-- et teste CALL p_ajouter_livraison(2, 20.00);, 
CALL p_ajouter_livraison(2, 20.00);
-- puis CALL p_ajouter_livraison(99, 10.00);, 
CALL p_ajouter_livraison(99, 10.00);
-- Error Code: 1644. Commande Inexistante
-- puis CALL p_ajouter_livraison(2, -5.00);. 
CALL p_ajouter_livraison(2, -5.00);
-- Error Code: 1644. Le coût ne peut pas être inferieur à zéro
-- Note en commentaire le code et le message de chaque erreur. 
-- Résultats : le premier ajoute une livraison (livraisons_lab passe à 4 lignes, statut en préparation) ; 
-- les deux autres donnent l’erreur 1644 avec leur message.

-- 6.HANDLER : crée p_archiver_livraison et teste :
DROP PROCEDURE IF EXISTS p_archiver_livraison;
DELIMITER $$
CREATE PROCEDURE p_archiver_livraison(IN p_id INT)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SELECT 'Erreur : opération annulée' AS message;
    END;

    START TRANSACTION;
    INSERT INTO livraisons_archive SELECT * FROM livraisons_lab WHERE id = p_id;
    DELETE FROM livraisons_lab WHERE id = p_id;
    COMMIT;
    SELECT 'Livraison archivée' AS message;
END$$
DELIMITER ;
-- (a) CALL p_archiver_livraison(1); 
CALL p_archiver_livraison(1); 
-- Résultat : livraisons_lab 3 lignes, livraisons_archive 1 ligne, message « Livraison archivée ».
-- (b) Provoque une erreur : INSERT INTO livraisons_archive SELECT * FROM livraisons_lab WHERE id = 2; 
INSERT INTO livraisons_archive SELECT * FROM livraisons_lab WHERE id = 2;
-- puis CALL p_archiver_livraison(2);. 
CALL p_archiver_livraison(2);
-- Résultat : le message « Erreur : opération annulée » ; 
-- la livraison 2 est toujours dans livraisons_lab (3 lignes) et livraisons_archive a 2 lignes. 
-- Explique en commentaire pourquoi.
-- Parce qu'on a pas inséré via la procedure, quand on a voulu le faire vu que ça existait déjà après notre insert, ç a produit l'erreur et ça a fait un roll back

-- 7.Réflexion (en commentaire, avec tes mots) : 
-- (a) cite trois différences entre une procédure et une fonction ; 
-- fonction renvoie toujours une valeur, procedure parfois; fonction ne modifie pas la table, procedure oui ; on peut appeler fonction dans un select ou wheren procedure non
-- (b) pourquoi l’archivage utilise-t-il une transaction et un HANDLER ? 
-- Pour avoir la possibilité de retablir une ligne supprimer en cas d'erreur
-- (c) si clients avait un million de lignes, pourquoi SELECT prenom, f_total_client(id) FROM clients; 
-- serait-il lent, 
-- Parce qu'il va parcourure toutes les lignes donc un million de fois
-- et que ferais-tu à la place ? 
-- Je mettrai un index
-- Indice : combien de fois la fonction est-elle appelée ?