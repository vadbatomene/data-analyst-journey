# Projet SQL : analyser les ventes de « Congo Shop »

Projet de fin de la phase 1 (SQL). Il réutilise tout ce que tu as appris, et il sera présenté dans ton portfolio.

## 1. Contexte et mission

**Congo Shop** est une boutique en ligne fictive qui vend de l'électronique et des accessoires à Kinshasa, Lubumbashi, Goma et d'autres villes. Le directeur commercial te demande, en tant qu'analyste, de comprendre l'activité de l'année écoulée et de lui remettre des **recommandations chiffrées**.

## 2. Les questions du directeur

1. Comment évolue le chiffre d'affaires mois par mois ? Quel est le mois record, et quel est le rythme de croissance ?
2. Quels produits et quelles catégories rapportent le plus ? Une petite partie du catalogue fait-elle l'essentiel du chiffre d'affaires ?
3. Quelles villes et quelles provinces pèsent le plus, et lesquelles progressent ?
4. Qui sont les meilleurs clients (segmentation RFM) ? Combien de chiffre d'affaires est « à risque » ?
5. Les nouveaux clients reviennent-ils ? (cohortes d'inscription)
6. Où perd-on des clients entre l'inscription, la commande, la livraison et la livraison réussie ? (entonnoir)
7. Les livraisons sont-elles rapides ? Un transporteur a-t-il plus de retards ?
8. Quelles trois actions recommandes-tu, et sur quels chiffres t'appuies-tu ?

## 3. Les données

Un jeu de données de **plusieurs milliers de commandes**, fourni sous forme d'un script SQL (créé pour le projet) avec ce schéma :

| Table | Contenu |
|-------|---------|
| `villes` | ville, province |
| `clients` | id, prénom, ville, téléphone, date d'inscription |
| `categories` | id, nom |
| `produits` | id, nom, catégorie, prix catalogue |
| `commandes` | id, client, date, statut |
| `lignes_commande` | commande, produit, quantité, prix unitaire |
| `livraisons` | id, commande, transporteur, date d'expédition, date de livraison, statut |

**Des défauts volontaires** (à repérer et documenter) : doublons de clients, téléphones vides, produits sans catégorie, commandes sans livraison, dates de livraison antérieures à la commande, quantités ou prix négatifs.

## 4. Livrables

1. Un **schéma** (clés primaires, clés étrangères, types, contraintes, index) avec son script de création.
2. Un **rapport de qualité des données** : les anomalies trouvées, leur nombre, la décision prise pour chacune.
3. Les **requêtes d'analyse** répondant aux questions 1 à 7, chacune avec un commentaire (ce qu'elle mesure, la liste des colonnes, les hypothèses).
4. Des **objets SQL réutilisables** : au moins trois vues (par exemple un tableau mensuel, un tableau RFM, un suivi des livraisons), une procédure stockée (par exemple un rapport mensuel pour une année et un mois donnés) et un déclencheur d'audit.
5. Une **étude de performance** : au moins deux requêtes comparées avec `EXPLAIN` avant et après un index.
6. Un **README** : contexte, schéma, 5 à 7 constats clés avec leurs chiffres, trois recommandations (question 8), limites de l'analyse.

## 5. Les étapes

| Étape | Contenu | Durée indicative |
|-------|---------|------------------|
| 1. Cadrage et schéma | Relire les questions, écrire le schéma, charger les données | 1 séance |
| 2. Qualité des données | Détecter et traiter les défauts, rapport | 1 séance |
| 3. Analyses A | Questions 1 à 3 (évolution, produits, villes) | 1 séance |
| 4. Analyses B | Questions 4 à 7 (RFM, cohortes, entonnoir, livraisons) | 1 à 2 séances |
| 5. Objets et performance | Vues, procédure, déclencheur, index et `EXPLAIN` | 1 séance |
| 6. Restitution | README, recommandations, relecture, Git | 1 séance |

## 6. Compétences mobilisées

Jointures et sous-requêtes, agrégations, CTE, fenêtrage, `CASE WHEN`, dates et texte, `NULL`, modélisation et intégrité, vues, procédures, déclencheurs, index et `EXPLAIN`, analyses métier (évolution, entonnoir, RFM, cohortes), et la **communication** (recommandations).

## 7. Grille d'évaluation (sur 100)

| Critère | Points |
|---------|--------|
| Schéma et intégrité (clés, types, contraintes) | 15 |
| Qualité des données (détection, décisions documentées) | 15 |
| Requêtes d'analyse (exactitude, lisibilité, respect de l'énoncé) | 30 |
| Objets SQL et performance (vues, procédure, déclencheur, `EXPLAIN`) | 15 |
| Interprétation et recommandations | 15 |
| Documentation et Git (README, structure, historique des commits) | 10 |

## 8. Structure du dépôt

```
01-sql/projet-ventes/
├── README.md
├── BRIEF.md
├── 01-schema.sql
├── 02-donnees.sql
├── 03-qualite.sql
├── 04-analyses/
│   ├── 01-evolution.sql
│   ├── 02-produits.sql
│   ├── 03-villes.sql
│   ├── 04-rfm.sql
│   ├── 05-cohortes.sql
│   ├── 06-entonnoir.sql
│   └── 07-livraisons.sql
├── 05-objets/
│   ├── vues.sql
│   ├── procedures.sql
│   ├── declencheurs.sql
│   └── index-explain.sql
└── docs/
    └── resultats.md
```

## 9. Règles de travail

- **Reproductibilité** : date de référence fixe, scripts qui se relancent d'un bout à l'autre (`DROP ... IF EXISTS`).
- **Avant chaque requête** : écrire en commentaire la liste des colonnes attendues et relire l'énoncé mot à mot.
- **Contrôles de cohérence** : après chaque jointure, compter les lignes ; un total par groupe ne dépasse jamais le total global.
- **Hypothèses** : les écrire. Une analyse sans hypothèse explicite n'est pas défendable.
- **Données personnelles** : le jeu de données est fictif ; ne jamais mettre de vraies données personnelles dans un dépôt public.
- **Historique Git** : un commit par étape, avec un message clair.

## 10. Modèle de README du projet

```markdown
# Projet SQL : analyse des ventes de Congo Shop

## Contexte
(La mission en trois phrases.)

## Données et schéma
(Schéma des tables, volumes, défauts de qualité trouvés.)

## Constats clés
1. ... (avec chiffre)
2. ...

## Recommandations
1. ...

## Limites
(Taille de l'échantillon, hypothèses, ce qu'on ne peut pas conclure.)

## Contenu du dépôt
(Description des dossiers.)
```
