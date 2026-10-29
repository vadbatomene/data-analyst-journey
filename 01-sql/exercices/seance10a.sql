USE formation;
DROP TABLE IF EXISTS commandes_lab;
DROP TABLE IF EXISTS livraisons_lab;
CREATE TABLE commandes_lab LIKE commandes;
INSERT INTO commandes_lab SELECT * FROM commandes;
CREATE TABLE livraisons_lab LIKE livraisons;
INSERT INTO livraisons_lab SELECT * FROM livraisons;

SELECT COUNT(*) FROM commandes_lab;      -- doit afficher 7
SELECT COUNT(*) FROM livraisons_lab;     -- doit afficher 3

SET @seuil = 100;
SELECT id, produit, montant FROM commandes_lab WHERE montant > @seuil;

SELECT COUNT(*) INTO @nb FROM commandes_lab;
SELECT @nb;

DROP PROCEDURE IF EXISTS p_resume_commandes;
DELIMITER $$
CREATE PROCEDURE p_resume_commandes()
BEGIN
    SELECT COUNT(*) AS nb_commandes, SUM(montant) AS ca, MAX(montant) AS plus_grosse
    FROM commandes_lab;
END$$
DELIMITER ;

CALL p_resume_commandes();

DROP PROCEDURE IF EXISTS p_commandes_client;
DELIMITER $$
CREATE PROCEDURE p_commandes_client(IN p_client_id INT)
BEGIN
    SELECT id, produit, montant
    FROM commandes_lab
    WHERE client_id = p_client_id
    ORDER BY id;
END$$
DELIMITER ;

CALL p_commandes_client(1);

DROP PROCEDURE IF EXISTS p_total_client;
DELIMITER $$
CREATE PROCEDURE p_total_client(IN p_client_id INT, OUT p_total INT)
BEGIN
    SELECT COALESCE(SUM(montant), 0) INTO p_total
    FROM commandes_lab
    WHERE client_id = p_client_id;
END$$
DELIMITER ;

CALL p_total_client(1, @total_awa);
SELECT @total_awa;

DROP PROCEDURE IF EXISTS p_niveau_client;
DELIMITER $$
CREATE PROCEDURE p_niveau_client(IN p_client_id INT)
BEGIN
    DECLARE v_total INT DEFAULT 0;
    DECLARE v_niveau VARCHAR(10);

    SELECT COALESCE(SUM(montant), 0) INTO v_total
    FROM commandes_lab WHERE client_id = p_client_id;

    IF v_total >= 500 THEN
        SET v_niveau = 'Or';
    ELSEIF v_total >= 100 THEN
        SET v_niveau = 'Argent';
    ELSE
        SET v_niveau = 'Bronze';
    END IF;

    SELECT p_client_id AS client_id, v_total AS total, v_niveau AS niveau;
END$$
DELIMITER ;

CALL p_niveau_client(2);

-- 1.Variables : avec SET @seuil = 100, affiche les commandes de commandes_lab au-dessus du seuil, 
SET @seuil=100;
SELECT * FROM commandes_lab WHERE montant>@seuil;
-- puis range le nombre de commandes dans @nb et affiche-le. 
SELECT COUNT(montant) INTO @nb FROM commandes_lab;
SELECT @nb;
-- Résultat : Telephone, Ordinateur, Tablette, Montre, puis 7.

-- 2.Procédure sans paramètre : 
-- crée p_resume_commandes() qui affiche le nombre de commandes, le chiffre d’affaires et le panier moyen arrondi à 2 décimales. 
DROP PROCEDURE IF EXISTS p_resume_commandes;
DELIMITER $$
CREATE PROCEDURE p_resume_commandes()
BEGIN
	SELECT COUNT(id) AS nb_commandes, SUM(montant) AS total, ROUND(AVG(montant),2) FROM commandes_lab;
END$$

DELIMITER ;

CALL p_resume_commandes();
-- Résultat : 7, 1555, 222,14.

-- 3. Paramètre IN : 
-- crée p_commandes_client(IN p_client_id INT). 
DROP PROCEDURE IF EXISTS p_commandes_client;
DELIMITER $$
CREATE PROCEDURE p_commandes_client(IN p_client_id INT)
BEGIN
	SELECT client_id, produit FROM commandes_lab WHERE client_id=p_client_id;
END $$
DELIMITER ;
-- Appelle-la pour les clients 1, 3 et 4. 
CALL p_commandes_client(1);
CALL p_commandes_client(3);
CALL p_commandes_client(4);
-- Résultats : client 1 : Telephone et Casque ; client 3 : Souris et Clavier ; client 4 : aucune ligne.

-- 4.Paramètre OUT : 
-- crée p_total_client(IN p_client_id INT, OUT p_total INT) 
DROP PROCEDURE IF EXISTS p_total_client;
DELIMITER $$
CREATE PROCEDURE p_total_client(IN p_client_id INT, OUT p_total INT)
BEGIN
	SELECT SUM(montant) INTO p_total FROM commandes_lab WHERE client_id=p_client_id;
END $$
DELIMITER ;
-- et appelle-la pour les clients 1, 2 et 4. 
CALL p_total_client(1, @client1);
SELECT @client1;
CALL p_total_client(2, @client2);
SELECT @client2;
CALL p_total_client(4, @client4);
SELECT @client4;
-- Résultats : 290, 800 et 0.

-- 5.IF : 
-- crée p_niveau_client (Or à partir de 500, Argent à partir de 100, sinon Bronze)
DROP PROCEDURE IF EXISTS p_niveau_client;
DELIMITER $$
CREATE PROCEDURE p_niveau_client(IN p_client_id INT)
BEGIN
	DECLARE v_total INT DEFAULT 0;
    DECLARE v_niveau VARCHAR(10);
    
    SELECT SUM(montant) INTO v_total FROM commandes_lab WHERE client_id=p_client_id;
    
    IF v_total >=500 THEN
		SET v_niveau = 'Or';
	ELSEIF v_total>=100 THEN
		SET v_niveau = 'Argent';
	ELSE 
		SET v_niveau = 'Bronze';
	END IF;
    
    SELECT p_client_id AS id_client, v_total AS total, v_niveau AS niveau;
    
END$$

DELIMITER ;
-- et appelle-la pour les clients 1, 2, 3, 4 et 5. 
CALL p_niveau_client(1);
CALL p_niveau_client(2);
CALL p_niveau_client(3);
CALL p_niveau_client(4);
CALL p_niveau_client(5);
-- Résultats : Argent, Or, Bronze, Bronze, Argent.

-- 6.Procédure qui modifie : 
-- crée p_appliquer_remise(IN p_seuil INT, IN p_pct INT) 
-- qui baisse de p_pct % le montant des commandes de commandes_lab dont le montant est supérieur ou égal à p_seuil (ROUND(...)),
DROP PROCEDURE IF EXISTS p_appliquer_remise;
DELIMITER $$
CREATE PROCEDURE p_appliquer_remise(IN p_seuil INT, IN p_pct INT)
BEGIN
	UPDATE commandes_lab SET montant=montant-ROUND(montant/100*p_pct) WHERE montant>=p_seuil;
     --  puis affiche le nombre de lignes modifiées avec ROW_COUNT().
    SELECT ROW_COUNT();
    
END$$;
DELIMITER ;
-- Teste dans une transaction :
START TRANSACTION;
CALL p_appliquer_remise(300, 10);
SELECT id, produit, montant FROM commandes_lab WHERE montant >= 270;
ROLLBACK;

-- 7.7. Gérer ses procédures : 
-- (a) liste-les avec SHOW PROCEDURE STATUS WHERE Db = 'formation'; 
SHOW PROCEDURE STATUS WHERE Db = 'formation';
-- (b) affiche la définition de p_niveau_client avec SHOW CREATE PROCEDURE p_niveau_client; 
SHOW CREATE PROCEDURE p_niveau_client; 
-- (c) modifie p_niveau_client pour que le niveau Or commence à 1000 (suppression puis recréation), et rappelle-la pour le client 2. 

DROP PROCEDURE IF EXISTS p_niveau_client;
DELIMITER $$
CREATE PROCEDURE p_niveau_client(IN p_client_id INT)
BEGIN
	DECLARE v_total INT DEFAULT 0;
    DECLARE v_niveau VARCHAR(10);
    SELECT SUM(montant) INTO v_total FROM commandes_lab WHERE client_id=p_client_id;
    IF v_total >=1000 THEN
		SET v_niveau = 'Or';
	ELSEIF v_total>=100 THEN
		SET v_niveau = 'Argent';
	ELSE 
		SET v_niveau = 'Bronze';
	END IF;
    SELECT p_client_id AS id_client, v_total AS total, v_niveau AS niveau;
    
END$$
DELIMITER ;

CALL p_niveau_client(2);
-- Résultat : (c) le client 2 passe de Or à Argent.


-- 8.8. Bonus : une boucle : 
-- crée p_generer_commandes_test(IN p_n INT) qui ajoute p_n commandes de test 
-- à commandes_lab (client 1, produit 'Test', montant 10 multiplié par le numéro du tour, date du jour, produit_id 1), 
-- avec un id égal au plus grand id existant plus 1 à chaque tour. Appelle-la avec 5. 
DROP PROCEDURE IF EXISTS p_generer_commandes_test;
DELIMITER $$
CREATE PROCEDURE p_generer_commandes_test(IN p_n INT)
BEGIN
DECLARE i INT DEFAULT 1;
DECLARE v_id INT;
SELECT COALESCE(MAX(id), 0)
INTO v_id
FROM commandes_lab;
WHILE i<=p_n DO
	SET v_id=v_id+1;
	INSERT INTO commandes_lab(id, client_id, produit, montant, date_commande, produit_id)
    VALUES (v_id, 1, 'test', 10*i, curdate(), 1);
	SET i=i+1;
END WHILE;
END$$
DELIMITER ;

CALL p_generer_commandes_test(5);
SELECT COUNT(*) FROM commandes_lab;
-- Résultat : SELECT COUNT(*) FROM commandes_lab; donne 12 et SELECT MAX(id) FROM commandes_lab; donne 12.

-- 9.9. Réflexion (en commentaire, avec tes mots) :

-- (a) Pourquoi DELIMITER est-il nécessaire pour créer une procédure ?
-- Il montre le debut et la fin du sql de la procedure.
-- (b) Cite deux avantages d’une procédure par rapport à un SQL recopié dans chaque rapport.
-- Ajout de differentes variables, faible possibilité d'erreur.
-- (c) Cite un inconvénient. Indice : où se trouve le code, et comment le versionner dans Git ?
-- difficulté de verification