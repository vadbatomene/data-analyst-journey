INSERT INTO clients VALUES (5, 'Grace', 'Kinshasa', 31);
INSERT INTO clients VALUES (6, 'David', 'Goma', 26);
INSERT INTO clients VALUES (7, 'Sarah', 'Lubumbashi', 38);
INSERT INTO clients VALUES (8, 'Eric', 'Kinshasa', 45);

SELECT COUNT(*) FROM clients;
SELECT AVG(age) FROM clients;
SELECT MIN(age), MAX(age) FROM clients;

SELECT ville, COUNT(*) FROM clients GROUP BY ville;

Select COUNT(*) from clients;
Select AVG(age) from clients;
Select ville, AVG(age) as moyen_age from clients GROUP BY ville;
Select ville, COUNT(*) as nb_clients from clients GROUP BY ville ORDER BY nb_clients DESC;

SELECT ville, AVG(age) as moy_age from clients GROUP BY ville HAVING moy_age>33;
SELECT ville, COUNT(*) as nb_client from clients WHERE age>30 GROUP BY ville;
SELECT ville, COUNT(*) as nb_client from clients GROUP BY ville ORDER BY nb_client DESC LIMIT 1;