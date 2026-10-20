# Notions à revoir : révision SQL 1 (mise à jour après remédiation)

**Bilan :** 17,5 / 20 sur les premières réponses, **18,1 / 20 après remédiation** (56 points sur 62 exercices).
Aucune partie sous 75 %, donc **pas de lacune grave**. Les parties 1, 2, 3 et 6 sont acquises.
Les points à travailler se concentrent sur le fenêtrage, les comptages avec jointure et les conditions de jointure.

## Les 6 notions, par priorité

| # | Notion | État | Exercices | À retenir |
|---|--------|------|-----------|-----------|
| 1 | Fenêtrage : critère et sens du classement | En progrès (5.6 refait correct, 7.4 à confirmer) | 5.6, 7.4 | Dans `OVER`, `PARTITION BY` définit les groupes et `ORDER BY` le critère de classement. Sans `DESC`, le rang 1 est la plus petite valeur. |
| 2 | Fenêtrage : `PARTITION BY` | Acquis (5.9 refait correct) | 5.9 | Sans `PARTITION BY`, le classement porte sur toute la table. Penser à nommer la colonne de rang. |
| 3 | Part dans un groupe | À confirmer (7.7) | 5.7, 7.7 | `SUM(x) OVER (PARTITION BY groupe)` donne le total du groupe sur chaque ligne. Une sous-requête sans `PARTITION BY` donne le total général. |
| 4 | Comptage avec `LEFT JOIN` | À confirmer (7.1) | 7.1 | `COUNT(o.id)` et non `COUNT(*)` ; ne jamais regrouper sur une valeur mesurée (un montant). |
| 5 | Conditions de jointure et contrôle de cohérence | À renforcer | 8.5 | Chaque `ON` relie la table ajoutée à une table déjà présente. Après chaque jointure, compter les lignes et comparer un total par groupe au total global. |
| 6 | Respect des consignes et rigueur d'écriture | Détail | 2.4, 4.7, 4.8, 5.5 | Relire l'énoncé mot à mot. Penser au `ORDER BY` final, aux alias, au `GROUP BY c.id` en plus du prénom, au point-virgule. |

## Exercices de contrôle (à réussir sans regarder la correction)

Les réponses de 7.1, 7.4 et 7.7 sont identiques à ma correction : elles comptent 0,5 point. Chaque variante réussie seule les fait passer à 0,75.

| Exercice | Variante | Résultat attendu |
|----------|----------|------------------|
| 7.1 | Pour chaque province : nombre de commandes et montant total, 0 si aucune | Haut-Katanga 1 et 800, Kinshasa 5 et 635, Nord-Kivu 0 et 0 |
| 7.4 | Pour chaque ville : le client qui a le moins dépensé (parmi ceux qui ont commandé) | Kinshasa Marie (45), Lubumbashi Jean (800) |
| 7.7 | Pour chaque catégorie : la part (%) de chaque province dans le total de la catégorie | Accessoires Kinshasa 100 % ; Electronique Haut-Katanga 59,26 %, Kinshasa 40,74 % |

## Exercices d'entraînement complémentaires

1. Pour chaque ville, le client le plus jeune puis le plus âgé. Résultat : plus jeune Marie (Kinshasa), Jean (Lubumbashi), David (Goma) ; plus âgé Eric, Sarah, Patrick.
2. Classer les commandes par montant décroissant dans chaque catégorie de produit. Résultat : Accessoires Montre, Casque, Clavier, Souris ; Electronique Ordinateur, Tablette, Telephone.
3. Pour chaque commande d'un client, sa part dans la dépense totale de ce client. Résultat : Awa 86,21 % et 13,79 %, Marie 33,33 % et 66,67 %, Jean 100 %, Grace 100 %.
4. Pour chaque client, même sans commande : nombre de commandes et plus grosse commande (0 si aucune).
5. Pour chaque province et chaque catégorie, le nombre de commandes. Résultat : Kinshasa Accessoires 3, Kinshasa Electronique 2, Haut-Katanga Electronique 1 (somme : 6).

## Points forts

- Bases, agrégations, jointures, `CASE WHEN`, dates et texte : acquis.
- Bons réflexes sur `COUNT(o.id)` (3.8), `LEFT JOIN ... IS NULL` (3.3, 3.7) et les CTE enchaînés.
- 5.6 et 5.9 refaits correctement.
