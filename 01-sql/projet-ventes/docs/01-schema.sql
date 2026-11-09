-- ======================================================================
-- Projet Congo Shop : schéma cible (version de référence, à comparer avec le tien)
-- NE PAS LANCER EN BLOC avant le nettoyage des données (étape 2).
-- Ordre : parents d'abord (villes, categories, clients, produits), puis enfants
-- (commandes, lignes_commande, livraisons).
-- Chaque contrainte porte une prédiction : PASSE ou ÉCHOUE sur les données brutes.
-- ======================================================================
USE congo_shop;

-- ---------------------------------------------------------------- villes
ALTER TABLE villes
    MODIFY ville VARCHAR(50) NOT NULL,
    MODIFY province VARCHAR(50) NOT NULL,
    ADD CONSTRAINT pk_villes PRIMARY KEY (ville);
-- PASSE : une ville par ligne.

-- ------------------------------------------------------------ categories
ALTER TABLE categories
    MODIFY nom VARCHAR(50) NOT NULL,
    ADD PRIMARY KEY (id),
    MODIFY id INT NOT NULL AUTO_INCREMENT;
-- PASSE. AUTO_INCREMENT exige que la colonne soit une clé : la clé primaire doit
-- être ajoutée dans la même commande (sinon erreur 1075).

-- --------------------------------------------------------------- clients
ALTER TABLE clients
    MODIFY prenom VARCHAR(50) NOT NULL,
    MODIFY ville VARCHAR(50) NOT NULL,
    MODIFY date_inscription DATE NOT NULL,
    ADD PRIMARY KEY (id),
    MODIFY id INT NOT NULL AUTO_INCREMENT,
    ADD CONSTRAINT fk_clients_villes FOREIGN KEY (ville) REFERENCES villes(ville);
-- PASSE : identifiants uniques, villes toutes connues.

-- Téléphone unique : à décider avec le métier (deux proches peuvent partager un numéro).
ALTER TABLE clients ADD CONSTRAINT uq_clients_telephone UNIQUE (telephone);
-- ÉCHOUERAIT sur les données brutes : des clients en double, et des chaînes vides
-- ('') qui comptent comme des valeurs identiques. Il faudrait d'abord fusionner
-- les doublons et remplacer '' par NULL (NULL est autorisé plusieurs fois).

-- -------------------------------------------------------------- produits
ALTER TABLE produits
    MODIFY nom VARCHAR(100) NOT NULL,
    MODIFY prix DECIMAL(10,2) NOT NULL,
    ADD PRIMARY KEY (id),
    MODIFY id INT NOT NULL AUTO_INCREMENT,
    ADD CONSTRAINT fk_produits_categories FOREIGN KEY (categorie_id) REFERENCES categories(id),
    ADD CONSTRAINT ch_produits_prix CHECK (prix > 0);
-- PASSE : categorie_id peut rester NULL (une clé étrangère accepte NULL) ; prix tous positifs.

-- ------------------------------------------------------------- commandes
ALTER TABLE commandes
    MODIFY client_id INT NOT NULL,
    MODIFY date_commande DATE NOT NULL,
    MODIFY statut ENUM('livrée','annulée','en cours') NOT NULL,
    ADD PRIMARY KEY (id),
    MODIFY id INT NOT NULL AUTO_INCREMENT,
    ADD CONSTRAINT fk_commandes_clients FOREIGN KEY (client_id) REFERENCES clients(id);
-- PASSE : aucune commande orpheline. Pas de DEFAULT sur date_commande : une
-- commande doit avoir sa vraie date, pas celle du jour de la saisie.

CREATE INDEX idx_commandes_date ON commandes (date_commande);
-- Justification : presque toutes les analyses filtrent ou regroupent par période.

-- ------------------------------------------------------- lignes_commande
ALTER TABLE lignes_commande
    MODIFY commande_id INT NOT NULL,
    MODIFY produit_id INT NOT NULL,
    MODIFY quantite INT NOT NULL,
    MODIFY prix_unitaire DECIMAL(10,2) NOT NULL,
    ADD PRIMARY KEY (id),
    MODIFY id INT NOT NULL AUTO_INCREMENT,
    ADD CONSTRAINT fk_lignes_commandes FOREIGN KEY (commande_id) REFERENCES commandes(id),
    ADD CONSTRAINT fk_lignes_produits FOREIGN KEY (produit_id) REFERENCES produits(id);
-- PASSE. Pas de UNIQUE sur commande_id : une commande a plusieurs lignes (relation 1,n).
-- Les index sur commande_id et produit_id sont créés automatiquement par les clés étrangères.

-- Valeurs strictement positives :
ALTER TABLE lignes_commande ADD CONSTRAINT ch_lignes_quantite CHECK (quantite > 0);
ALTER TABLE lignes_commande ADD CONSTRAINT ch_lignes_prix CHECK (prix_unitaire > 0);
-- ÉCHOUERAIENT sur les données brutes : des lignes ont une quantité ou un prix négatif.

-- ----------------------------------------------------------- livraisons
ALTER TABLE livraisons
    MODIFY commande_id INT NOT NULL,
    MODIFY transporteur ENUM('Rapido Express','KivuLogistics','TransCongo') NOT NULL,
    MODIFY date_expedition DATE NOT NULL,
    MODIFY statut ENUM('livrée','en transit') NOT NULL,
    ADD PRIMARY KEY (id),
    MODIFY id INT NOT NULL AUTO_INCREMENT,
    ADD CONSTRAINT uq_livraisons_commande UNIQUE (commande_id),
    ADD CONSTRAINT fk_livraisons_commandes FOREIGN KEY (commande_id) REFERENCES commandes(id),
    ADD CONSTRAINT ch_livraisons_statut CHECK (
        (statut = 'livrée' AND date_livraison IS NOT NULL)
     OR (statut = 'en transit' AND date_livraison IS NULL));
-- PASSE : au plus une livraison par commande (relation 0,1) ; une livraison livrée
-- a une date, une livraison en transit n'en a pas.

ALTER TABLE livraisons ADD CONSTRAINT ch_livraisons_dates
CHECK (date_livraison IS NULL OR date_livraison >= date_expedition);
-- À TESTER à l'étape 2 : peut échouer si des livraisons arrivent avant leur expédition.
-- Une contrainte ne peut pas comparer deux tables : « la livraison est postérieure à la
-- commande » ne peut être vérifiée que par une requête (ou un déclencheur).
