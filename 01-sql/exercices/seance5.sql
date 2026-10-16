use formation;

SELECT prenom, age,
       ROW_NUMBER() OVER (ORDER BY age DESC) AS numero
FROM clients;

SELECT prenom, ville, age,
       RANK() OVER (PARTITION BY ville ORDER BY age DESC) AS rang
FROM clients;

SELECT prenom, ville, age,
       AVG(age) OVER (PARTITION BY ville) AS age_moyen_ville
FROM clients;

SELECT id, produit, montant,
       SUM(montant) OVER (ORDER BY id) AS cumul
FROM commandes;

SELECT *, SUM(montant) OVER (ORDER BY id DESC) as cumul FROM commandes;

SELECT *, ROW_NUMBER() OVER (ORDER BY montant DESC) AS numero FROM commandes;
SELECT prenom, age, ville, age-AVG(age) OVER (PARTITION BY ville) FROM clients;
SELECT *, RANK() OVER (PARTITION BY ville ORDER BY age) as numero_age FROM clients;

WITH ageville as (SELECT id, prenom, age, ville, ROW_NUMBER() OVER (PARTITION BY ville ORDER BY age DESC) as rang FROM clients) SELECT * FROM ageville where rang=1;
SELECT *,  ROUND(montant * 100 / SUM(montant) OVER (), 2 ) as pourcentage FROM commandes;
WITH com as (SELECT *, LAG(montant) OVER (ORDER BY id) as montprec FROM commandes) SELECT *, montant-montprec as difference FROM com;

-- LEAD : la commande suivante (l'inverse de LAG)
SELECT id, montant, LEAD(montant) OVER (ORDER BY id) AS montant_suivant
FROM commandes;

-- NTILE : découper en groupes égaux, ici 3 tranches de dépense
SELECT id, montant, NTILE(3) OVER (ORDER BY montant DESC) AS tranche
FROM commandes;