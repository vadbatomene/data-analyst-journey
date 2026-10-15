SELECT VERSION();

SELECT prenom, age FROM clients  WHERE age>(SELECT AVG(age) FROM clients);
SELECT prenom FROM clients WHERE id IN (SELECT client_id FROM commandes);
WITH depenses as (SELECT client_id, SUM(montant) AS total FROM commandes GROUP BY client_id)
SELECT c.prenom, d.total FROM clients c INNER JOIN depenses d ON c.id=d.client_id;

SELECT * FROM commandes WHERE montant > (SELECT AVG(montant) FROM commandes);
WITH tempo as (SELECT c.id, c.prenom, o.id as id_commande, o.produit, o.montant FROM clients c LEFT JOIN commandes o  ON c.id=o.client_id ) SELECT * FROM tempo WHERE id_commande IS NULL;
SELECT * FROM clients WHERE age<(SELECT AVG(age) FROM clients) ORDER BY age LIMIT 1;
WITH depenses as (SELECT client_id, SUM(montant) as total FROM commandes GROUP BY client_id) SELECT d.client_id, c.prenom, d.total FROM clients c INNER JOIN depenses d ON c.id=d.client_id WHERE total>200;

SELECT o.*, c.prenom FROM commandes o INNER JOIN clients c ON o.client_id=c.id where o.montant = (SELECT MAX(montant) FROM commandes) ;
WITH parville as (SELECT ville, COUNT(id) as nbcli FROM clients GROUP BY ville ORDER BY nbcli DESC LIMIT 1) SELECT c.* FROM clients c INNER JOIN parville p ON c.ville=p.ville;
WITH depenses AS (SELECT client_id, SUM(montant) AS total FROM commandes GROUP BY client_id), moyenne AS (SELECT AVG(total) AS moy FROM depenses) SELECT moy FROM moyenne;

WITH depenses AS (
    SELECT c.id AS client_id, c.prenom, SUM(o.montant) AS total
    FROM clients c
    INNER JOIN commandes o ON c.id = o.client_id
    GROUP BY c.id, c.prenom
),
moyenne AS (
    SELECT AVG(total) AS moy FROM depenses
)
SELECT prenom, total
FROM depenses
WHERE total < (SELECT moy FROM moyenne);


