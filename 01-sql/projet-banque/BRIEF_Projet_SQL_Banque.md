# Projet SQL n°2 : analyser les activités de « Banque Horizon »

Deuxième projet SQL de ton portfolio, à réaliser **après le projet Congo Shop**. Il est plus exigeant : volumes plus gros, deux devises, notions de risque, et des opérations qui doivent être **sûres** (un virement ne peut pas être fait à moitié).

## 1. Contexte et mission

**Banque Horizon** est une banque fictive implantée dans huit villes de la RDC. Elle gère des comptes courants et des comptes d'épargne en **dollars (USD)** et en **francs congolais (CDF)**, accorde des crédits, et ses clients opèrent par l'agence, le distributeur (DAB), le mobile et le web.

La direction t'engage comme analyste pour trois missions :
1. **Comprendre l'activité** : clients, comptes, volumes, agences, canaux.
2. **Protéger la banque** : repérer les opérations suspectes et mesurer le risque de crédit.
3. **Fiabiliser la base** : vérifier que les chiffres sont cohérents et rendre les opérations sensibles sûres.

## 2. Vocabulaire à connaître

| Terme | Sens |
|-------|------|
| Encours | Somme des soldes (épargne ou dépôts) ou du capital restant dû (crédits) |
| Solde | Montant disponible sur un compte à un instant donné |
| Échéance | Mensualité d'un crédit : date limite et montant à payer |
| Impayé, retard | Échéance non payée après sa date limite |
| PAR 30, PAR 90 | Part de l'encours de crédits en retard de plus de 30 ou de 90 jours (indicateur de risque) |
| Compte dormant | Compte sans mouvement depuis longtemps |
| Rapprochement | Vérification que le solde enregistré correspond à la somme des opérations |
| Rafale | Série d'opérations très rapprochées dans le temps (signal d'alerte possible) |
| Atomicité | Une opération composée (un virement) réussit entièrement ou échoue entièrement |

## 3. Les questions de la direction

1. Combien de clients et de comptes la banque a-t-elle ? Quelle est la part de comptes actifs et dormants, par agence et par devise ?
2. Comment évoluent les dépôts, les retraits et le flux net mois par mois ? Quels canaux progressent (mobile, web, agence, DAB) ?
3. Quelles agences sont les plus performantes (encours, nombre d'opérations, nouveaux clients) ?
4. Qui sont les clients à fort potentiel, les clients dormants et les clients à réactiver ? (segmentation inspirée du RFM)
5. Quelles opérations sont **anormales** (montant très supérieur à l'habitude du compte, rafales en quelques minutes, retraits de nuit) ? Quels comptes faut-il vérifier en priorité ?
6. Quel est le niveau de risque du portefeuille de crédits (PAR 30 et PAR 90) ? Où se concentre-t-il (ville, segment, durée du crédit) ?
7. Les soldes enregistrés sont-ils cohérents avec les opérations ? Quels comptes présentent un écart ?
8. Quel est l'encours total **en dollars**, en convertissant les francs congolais au taux du jour ?
9. Quels clients pourraient recevoir une offre (compte courant sans épargne, revenus réguliers, aucun crédit) ?
10. Quelles trois actions recommandes-tu à la direction, et avec quels chiffres ?

## 4. Les données (jeu fictif, fourni par script)

| Table | Contenu | Volume approximatif |
|-------|---------|---------------------|
| `agences` | nom, ville, province, date d'ouverture | 12 |
| `clients` | prénom, nom, date de naissance, ville, téléphone, segment (particulier ou PME), date d'entrée | 3 000 |
| `comptes` | client, agence, type (courant ou épargne), devise, date d'ouverture, statut (actif, dormant, clos), solde | 4 200 |
| `transactions` | compte, date et heure, type (dépôt, retrait, virement, paiement, frais), montant, canal, compte en face (virements) | 180 000 |
| `credits` | client, compte, montant, taux, durée en mois, date d'octroi, statut | 900 |
| `echeances` | crédit, date limite, montant dû, date de paiement, montant payé | 11 000 |
| `taux_change` | date, devise, taux vers le dollar | 365 |

**Des défauts volontaires** (à repérer, compter et traiter) : clients en double, dates de naissance impossibles, comptes sans client, transactions de montant nul ou négatif, transactions antérieures à l'ouverture du compte, comptes « clos » avec des mouvements récents, soldes qui ne correspondent pas à la somme des transactions, jours sans taux de change.

**Des tendances cachées** à faire ressortir : saisonnalité des dépôts, écarts entre agences, progression du mobile, comptes dormants, quelques comptes avec des rafales nocturnes, retards de remboursement concentrés sur un segment, une ville et les crédits longs.

> Les données sont **entièrement fictives**. Dans un vrai projet bancaire, ces informations sont confidentielles : on n'en publie jamais d'exemples réels, on n'en donne l'accès qu'aux personnes qui en ont besoin, et on garde la trace des consultations.

## 5. Ce qui est nouveau par rapport à Congo Shop

- **Deux devises** : additionner du CDF et de l'USD est une erreur ; il faut convertir avec le taux de la bonne date (et choisir quoi faire les jours sans taux : prendre le dernier taux connu).
- **Un gros volume** : 180 000 transactions rendent les index et `EXPLAIN` utiles pour de bon.
- **Des opérations sûres** : un virement débite un compte et en crédite un autre. Il doit être **atomique** (transaction, `SIGNAL`, `HANDLER`) et refuser les cas invalides (solde insuffisant, devises différentes, compte clos).
- **Des statistiques simples** : moyenne, écart-type, seuil à trois écarts-types pour détecter un montant anormal ; écart de temps entre deux opérations pour détecter les rafales.
- **Le risque** : taux de retard, encours à risque, concentration.

## 6. Livrables

1. Le **schéma** avec son script : clés primaires et étrangères, types, contraintes (`CHECK`, `NOT NULL`), index justifiés.
2. Le **rapport de qualité et de rapprochement** : chaque défaut trouvé, son nombre, la décision prise ; la liste des comptes dont le solde ne correspond pas aux opérations.
3. Les **requêtes d'analyse** (questions 1 à 9), commentées : ce qu'elles mesurent, la liste des colonnes, les hypothèses.
4. Les **objets SQL** :
   - au moins trois vues (relevé de compte, tableau de bord mensuel, portefeuille de crédits à risque) ;
   - une procédure **`p_virement`** : transaction, contrôles (solde suffisant, comptes actifs, même devise), erreurs personnalisées, retour en arrière en cas de problème ;
   - un déclencheur d'**audit** des changements de solde et un déclencheur qui **empêche** un solde négatif non autorisé ;
   - un événement planifié qui marque les comptes dormants (sans mouvement depuis 180 jours).
5. Une **étude de performance** : au moins trois requêtes sur `transactions` comparées avec `EXPLAIN` avant et après index.
6. Un **README** : contexte, schéma, constats chiffrés, trois recommandations, limites.

## 7. Les étapes

| Étape | Contenu | Durée indicative |
|-------|---------|------------------|
| 1. Cadrage et schéma | Vocabulaire, schéma, chargement des données | 1 séance |
| 2. Qualité et rapprochement | Défauts, soldes, décisions | 1 à 2 séances |
| 3. Activité | Questions 1 à 3 (comptes, flux, agences) | 1 séance |
| 4. Clients | Questions 4 et 9 (segments, dormants, ventes croisées) | 1 séance |
| 5. Devises | Question 8 (conversion avec taux datés) | 1 séance |
| 6. Anomalies | Question 5 (montants anormaux, rafales, nuit) | 1 à 2 séances |
| 7. Crédit | Question 6 (retards, PAR 30 et PAR 90, concentration) | 1 à 2 séances |
| 8. Objets sûrs | `p_virement`, déclencheurs, événement | 1 à 2 séances |
| 9. Performance | Index et `EXPLAIN` | 1 séance |
| 10. Restitution | README, recommandations, relecture, Git | 1 séance |

## 8. Compétences mobilisées

Tout ce que tu as appris en phase 1, avec en plus : fenêtrage avancé (solde courant avec `SUM ... OVER`, écart de temps avec `LAG`), statistiques en SQL (`AVG`, `STDDEV`), jointures sur des dates, transactions et atomicité, intégrité, audit, performance sur un gros volume, et la **rigueur** propre à la finance (rapprochements, traçabilité).

## 9. Grille d'évaluation (sur 100)

| Critère | Points |
|---------|--------|
| Schéma et intégrité | 10 |
| Qualité des données et rapprochement | 15 |
| Requêtes d'analyse (exactitude, lisibilité, respect de l'énoncé) | 30 |
| Objets SQL sûrs (virement atomique, déclencheurs, événement) | 20 |
| Performance (index, `EXPLAIN`) | 5 |
| Interprétation et recommandations | 15 |
| Documentation et Git | 5 |

## 10. Structure du dépôt

```
01-sql/projet-banque/
├── README.md
├── BRIEF.md
├── 01-schema.sql
├── 02-donnees.sql
├── 03-qualite/
│   ├── defauts.sql
│   └── rapprochement.sql
├── 04-analyses/
│   ├── 01-activite.sql
│   ├── 02-agences.sql
│   ├── 03-clients.sql
│   ├── 04-devises.sql
│   ├── 05-anomalies.sql
│   └── 06-credit.sql
├── 05-objets/
│   ├── vues.sql
│   ├── p_virement.sql
│   ├── declencheurs.sql
│   └── evenements.sql
├── 06-performance/
│   └── index-explain.sql
└── docs/
    └── resultats.md
```

## 11. Règles de travail

- **Reproductibilité** : date de référence fixe, scripts relançables d'un bout à l'autre (`DROP ... IF EXISTS`).
- **Avant chaque requête** : écrire la liste des colonnes attendues en commentaire et relire l'énoncé mot à mot.
- **Contrôles de cohérence** : après chaque jointure, compter les lignes ; ne jamais additionner deux devises ; un total par groupe ne dépasse jamais le total global.
- **Ne jamais modifier les données d'origine** pour tester : travailler sur des copies, et protéger toute modification par une transaction.
- **Hypothèses** : toutes écrites. Une alerte de fraude est un **signal à vérifier**, pas une accusation.
- **Confidentialité** : données fictives uniquement dans le dépôt public ; vues restreintes pour tout partage.
- **Historique Git** : un commit par étape, avec un message clair.

## 12. Réutilisation dans la suite de la formation

Ce même jeu de données servira de fil rouge pour ton portfolio :
- **Phase 3 (Python)** : exploration, nettoyage, visualisations, détection d'anomalies avec pandas ;
- **Phase 4 (statistiques)** : distributions, seuils d'alerte, tests ;
- **Phase 5 (BI)** : tableau de bord pour la direction, branché sur tes vues SQL ;
- **Phase 6 (portfolio)** : un projet complet « de la base au tableau de bord ».

## 13. Modèle de README du projet

```markdown
# Projet SQL : analyse de Banque Horizon

## Contexte
(La mission en trois phrases.)

## Données et schéma
(Schéma, volumes, défauts de qualité trouvés, écarts de rapprochement.)

## Constats clés
1. ... (avec chiffre et devise)
2. ...

## Risques et alertes
(Crédit, anomalies, limites des alertes.)

## Recommandations
1. ...

## Objets SQL livrés
(Vues, procédure p_virement, déclencheurs, événement, index.)

## Limites
(Données fictives, hypothèses, ce qu'on ne peut pas conclure.)
```
