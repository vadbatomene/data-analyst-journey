# Notions à revoir : révision SQL 1 (mise à jour après la séance de remédiation)

**Bilan de la révision :** 17,5 / 20 sur les premières réponses, **18,3 / 20 après remédiation** (56,75 points sur 62 exercices).
**Séance de remédiation :** 12,5 / 15 (16,7 / 20) sur les premières réponses, **13,75 / 15 (18,3 / 20) après reprise** ; l'exercice E2 n'est pas noté (énoncé ambigu).
Aucune lacune : toutes les notions sont acquises ou en voie de l'être. Il reste des points de vigilance, surtout sur la lecture des consignes.

## État des notions

| # | Notion | État | Exercices | À retenir |
|---|--------|------|-----------|-----------|
| 1 | Fenêtrage : critère et sens du classement | Acquis | 5.6, 7.4, A1 à A4, F2 | Dans `OVER`, `PARTITION BY` définit les groupes, `ORDER BY` le critère. Sans `DESC`, le rang 1 est la plus petite valeur. |
| 2 | Fenêtrage : `PARTITION BY` | Acquis | 5.9, A3 | Sans `PARTITION BY`, le classement porte sur toute la table. |
| 3 | Part dans un groupe | Acquis | 5.7, 7.7, B1, B2, F3 | `SUM(x) OVER (PARTITION BY groupe)` pour le total du groupe, `OVER ()` pour le total général. |
| 4 | Comptage avec `LEFT JOIN` | Solide, un point à surveiller | 7.1, C1, C2, F1 | `COUNT(o.id)` et non `COUNT(*)`. Condition de filtre dans le `ON`, jamais dans le `WHERE`. Partir de la bonne table (`villes`, pas `clients`). |
| 5 | Conditions de jointure et contrôle de cohérence | Acquis | 8.5, D1 à D3 | Chaque `ON` relie la table ajoutée à une table déjà présente. Contrôler les lignes et les totaux. |
| 6 | Respect des consignes | À surveiller | 2.4, 4.7, 4.8, 5.5, C2, D1, F1, F2 | Avant d'envoyer, lister ce que l'énoncé demande en sortie (colonnes, 0, tri, format, nombre de CTE) et cocher chaque point. |

## Le point qui revient : la liste de sortie

Les oublis se répètent d'un exercice à l'autre : la colonne du client (F2), le montant total (F1), la valeur 0 pour une ville sans commande (C2), la vérification demandée (D1). La technique : avant d'écrire la requête, écrire en commentaire la liste de ce qu'elle doit afficher, puis cocher chaque élément une fois la requête terminée.

## Points forts

- Bases, agrégations, jointures, `CASE WHEN`, dates et texte : acquis.
- Fenêtrage et parts dans un groupe : acquis après remédiation, avec des solutions personnelles (F3 en trois CTE).
- Bon diagnostic d'une jointure fausse (D3) et bons réflexes sur `COUNT(o.id)`, `LEFT JOIN ... IS NULL` et les CTE enchaînés.
