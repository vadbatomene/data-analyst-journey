create table commandes(
id int,
client_id int,
produit varchar(50),
montant int);

INSERT INTO commandes VALUES (1, 1, 'Telephone', 250);
INSERT INTO commandes VALUES (2, 1, 'Casque', 40);
INSERT INTO commandes VALUES (3, 2, 'Ordinateur', 800);
INSERT INTO commandes VALUES (4, 3, 'Souris', 15);
INSERT INTO commandes VALUES (5, 3, 'Clavier', 30);
INSERT INTO commandes VALUES (6, 5, 'Tablette', 300);
INSERT INTO commandes VALUES (7, 9, 'Montre', 120);

SELECT clients.prenom, commandes.produit, commandes.montant FROM clients INNER JOIN commandes ON clients.id=commandes.client_id;
SELECT clients.prenom, commandes.produit, commandes.montant FROM clients LEFT JOIN commandes ON clients.id = commandes.client_id;
SELECT c.prenom, o.produit, o.montant FROM clients c INNER JOIN commandes o ON c.id=o.client_id;

SELECT c.prenom, c.ville, o.produit FROM commandes o INNER JOIN clients c ON o.client_id=c.id;
SELECT c.prenom, o.* FROM clients c LEFT JOIN commandes o ON c.id=o.client_id;
SELECT c.prenom, o.* FROM clients c LEFT JOIN commandes o ON c.id=o.client_id WHERE o.id is NULL;
SELECT c.prenom, SUM(o.montant) as depense FROM clients c INNER JOIN commandes o ON c.id=o.client_id GROUP BY c.prenom;

SELECT c.prenom, SUM(o.montant) AS depense FROM clients c INNER JOIN commandes o ON c.id = o.client_id GROUP BY c.id, c.prenom;

SELECT c.ville, SUM(o.montant) from clients c INNER JOIN commandes o ON c.id=o.client_id GROUP BY c.ville;
SELECT c.id, c.prenom, SUM(o.montant) as depense FROM clients c INNER JOIN commandes o ON c.id=o.client_id GROUP BY c.id, c.prenom ORDER BY depense DESC LIMIT 1;
SELECT c.id, c.prenom, COALESCE(SUM(o.montant), 0) as depense FROM clients c LEFT JOIN commandes o ON c.id=o.client_id GROUP BY c.id, c.prenom;
SELECT c.*, o.* from commandes o LEFT JOIN clients c ON c.id=o.client_id WHERE c.id is NULL;