

Colonne	Type	Signification	Règles attendues
id_client	INT	Identifiant unique du client	Obligatoire, unique, clé primaire
nom	VARCHAR(100)	Nom du client	Obligatoire
postnom	VARCHAR(100)	Postnom du client	Obligatoire
email	VARCHAR(150)	Adresse électronique	Facultatif, unique si renseigné
telephone	VARCHAR(20)	Numéro de téléphone	Obligatoire
date_naissance	DATE	Date de naissance	Facultatif