-- Modifie la table categorie en mettant les colonnes not nul donc obligations et la clé primaire id en auto increment
ALTER TABLE categories
MODIFY id INT NOT NULL AUTO_INCREMENT, 
MODIFY nom VARCHAR(50) NOT NULL;

-- Modifie la table produits en mettant les colonnes not nul donc obligations et mettre ville clé primaire
ALTER TABLE villes
MODIFY ville VARCHAR(50) NOT NULL,
MODIFY province VARCHAR(50) NOT NULL,

ADD CONSTRAINT pk_villes
PRIMARY KEY (ville);

-- Modifie la table clients en mettant les colonnes not nul donc obligations sauf telephone, la clé primaire id en auto increment, telephone en unique, et liés la ville à la table villes commandes clé secondaire
ALTER TABLE clients
MODIFY id INT NOT NULL AUTO_INCREMENT,
MODIFY prenom VARCHAR(50) NOT NULL,
MODIFY ville VARCHAR(50) NOT NULL,
MODIFY date_inscription date NOT NULL,

ADD CONSTRAINT uq_client_telephone UNIQUE(telephone),
ADD CONSTRAINT fk_clienst_villes
FOREIGN KEY (ville)
REFERENCES villes(ville);

-- Modifie la table commandes en mettant les colonnes not nul donc obligations, la clé primaire id en auto increment, relier avec la table client par clien_id, limiter la valeur autorisé dans statut(livrée, annulée, en cours) et mettre la date du system dans defaule sur date commande

ALTER TABLE commandes
MODIFY id INT NOT NULL AUTO_INCREMENT,
MODIFY client_id INT NOT NULL,
MODIFY statut ENUM('livrée', 'annulée', 'en cours') NOT NULL,
MODIFY date_commande DATE NOT NULL DEFAULT (CURRENT_DATE),

ADD CONSTRAINT fk_commandes_clients
FOREIGN KEY (client_id)
REFERENCES clients(id);

-- Modifie la table lignes_commande en mettant les colonnes not nul donc obligations, la clé primaire id en auto increment, relier avec la table commandes par commande_id et produits par produit_id, checker la quantité superier et prix_unitaire à 0 
ALTER TABLE lignes_commande
MODIFY id INT NOT NULL AUTO_INCREMENT,
MODIFY commande_id INT NOT NULL,
MODIFY produit_id INT NOT NULL,
MODIFY quantite INT NOT NULL,
MODIFY prix_unitaire DECIMAL(10,2) NOT NULL,

ADD CONSTRAINT pk_lignes_com_commandes
FOREIGN KEY (commande_id)
REFERENCES commandes(id),
ADD CONSTRAINT pk_lignes_com_produits
FOREIGN KEY (produit_id)
REFERENCES produits(id),
ADD CONSTRAINT uq_lignes_commande_commande
UNIQUE (commande_id),
ADD CONSTRAINT ch_quantite
check(quantite >0),
ADD CONSTRAINT ch_prix_unitaire
check(prix_unitaire >0.00);

-- Modifie la table livraisons en mettant les colonnes not nul donc obligations sauf date_livraison, la clé primaire id en auto increment, relier avec la table commandes par commande_id, limiter la valeur autorisé dans statut(livrée, en transit))

ALTER TABLE livraisons
MODIFY  id INT NOT NULL AUTO_INCREMENT,
MODIFY commande_id INT NOT NULL,
MODIFY transporteur ENUM('Rapido Express','TransCongo','KivuLogistics') NOT NULL,
MODIFY date_expedition DATE NOT NULL,
MODIFY statut ENUM('livrée','en transit') NOT NULL,

ADD CONSTRAINT uq_livraisons_commande
UNIQUE (commande_id),
ADD CONSTRAINT fk_livraisons_commandes
FOREIGN KEY (commande_id)
REFERENCES commandes(id);

-- Modifie la table produits en mettant les colonnes not nul donc obligations sauf categorie_id, la clé primaire id en auto increment, relier avec la table categorie par categorie_id et checker prix superieur à 0

ALTER TABLE produits
MODIFY id INT NOT NULL AUTO_INCREMENT,
MODIFY nom VARCHAR(50) NOT NULL,
MODIFY prix DECIMAL(10,2) NOT NULL,

ADD CONSTRAINT fk_produits_categories
FOREIGN KEY (categorie_id)
REFERENCES categories(id),
ADD CONSTRAINT ch_prix
check(prix > 0.00);



