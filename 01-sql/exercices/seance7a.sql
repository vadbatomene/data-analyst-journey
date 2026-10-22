SELECT ville FROM clients;            -- 8 lignes, avec des répétitions
SELECT DISTINCT ville FROM clients;   -- 3 lignes : Kinshasa, Lubumbashi, Goma
SELECT DISTINCT client_id FROM commandes;

SELECT COUNT(*) FROM commandes;                       -- 7 commandes
SELECT COUNT(DISTINCT client_id) FROM commandes;      -- 5 clients différents
SELECT COUNT(DISTINCT ville) FROM clients;            -- 3 villes

SELECT v.province,
       COUNT(DISTINCT c.id) AS nb_clients,
       COUNT(o.id)          AS nb_commandes
FROM villes v
INNER JOIN clients c ON c.ville = v.ville
INNER JOIN commandes o ON o.client_id = c.id
GROUP BY v.province;

SELECT DISTINCT p.nom, p.categorie, c.ville
FROM produits p
INNER JOIN commandes o ON o.produit_id = p.id
INNER JOIN clients c ON c.id = o.client_id
WHERE c.ville = 'Kinshasa';

-- 1.Affiche les villes où habitent des clients, sans doublon. Résultat : Kinshasa, Lubumbashi, Goma.
SELECT DISTINCT ville FROM clients;

-- 2.Affiche les catégories de produits commandées par des clients de Kinshasa, sans doublon. Résultat : Electronique, Accessoires.
SELECT DISTINCT p.categorie
FROM clients c
INNER JOIN villes v ON c.ville=v.ville
INNER JOIN commandes o ON c.id=o.client_id
INNER JOIN produits p ON p.id=o.produit_id
WHERE v.ville='Kinshasa';

-- 3.Compte les clients différents qui ont passé au moins une commande : (a) directement dans commandes, puis (b) en joignant clients. Résultat : 5 puis 4. Explique la différence : qu’est-ce qui la provoque ?
SELECT COUNT(DISTINCT client_id) as nb_clients FROM commandes;

SELECT COUNT(DISTINCT client_id) as nb_clients 
FROM commandes o 
INNER JOIN clients c ON c.id=o.client_id;

-- INNER JOIN car le client 9 n'existe pas dans clients malgré sa commande

-- 4.Pour chaque province de la table villes, affiche le nombre de clients, le nombre de clients ayant commandé et le nombre de commandes. Résultat : Haut-Katanga 2, 1 et 1 ; Kinshasa 4, 3 et 5 ; Nord-Kivu 2, 0 et 0. Indice : LEFT JOIN partout, et COUNT(DISTINCT o.client_id) pour les clients acheteurs.

SELECT v.province, COUNT(DISTINCT c.id) AS nb_clients, COUNT(DISTINCT o.client_id) AS nb_clients_cmd, COUNT(DISTINCT o.id) as nb_commandes
FROM villes v
LEFT JOIN clients c ON v.ville=c.ville
LEFT JOIN commandes o ON c.id=o.client_id
GROUP BY v.province;

-- 5.Pour chaque client, même sans commande, le nombre de catégories différentes de produits achetées. Résultat : Awa 2, Jean 1, Marie 1, Grace 1, et 0 pour Patrick, David, Sarah, Eric.

SELECT c.prenom, COUNT(DISTINCT p.categorie) AS nb_categorie
FROM clients c
LEFT JOIN commandes o ON c.id=o.client_id
LEFT JOIN produits p ON p.id=o.produit_id
GROUP BY c.prenom;

-- 6.Refais le 4.9 avec des jointures et DISTINCT (nom et catégorie des produits commandés par des clients de Kinshasa). Résultat : Telephone, Casque, Souris, Clavier, Tablette.

SELECT DISTINCT p.nom, p.categorie
FROM clients c
INNER JOIN commandes o ON c.id=o.client_id
INNER JOIN produits p ON p.id=o.produit_id
INNER JOIN villes v ON c.ville=v.ville
WHERE c.ville='Kinshasa';