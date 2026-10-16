-- ======================================================
-- Révision SQL 1 (séances 1 à 6) : mes réponses
-- Une requête par exercice, sous son numéro.
-- ======================================================

USE formation;

-- ------------------------------------------------------
-- Partie 1 : les bases (séance 1)
-- ------------------------------------------------------

-- 1.1 [facile] Affiche tous les clients.



-- 1.2 [facile] Affiche uniquement le prénom et l'âge de chaque client.



-- 1.3 [facile] Affiche les clients qui habitent à Goma.



-- 1.4 [facile] Affiche les clients de plus de 30 ans, du plus âgé au plus jeune.



-- 1.5 [moyen] Affiche les clients de Kinshasa qui ont moins de 30 ans.



-- 1.6 [moyen] Affiche les clients de Goma ou de Lubumbashi, triés par prénom.



-- 1.7 [moyen] Affiche les 3 commandes les moins chères.



-- ------------------------------------------------------
-- Partie 2 : agrégations (séance 2)
-- ------------------------------------------------------

-- 2.1 [facile] Compte le nombre total de commandes.



-- 2.2 [facile] Affiche en une seule requête le montant total, moyen, minimum et maximum des commandes.



-- 2.3 [moyen] Affiche le nombre de clients par ville.



-- 2.4 [moyen] Affiche l'âge moyen par ville, arrondi à 1 décimale, de la ville la plus âgée à la plus jeune.



-- 2.5 [moyen] Affiche les villes qui comptent au moins 3 clients.



-- 2.6 [moyen] Affiche, par ville, le nombre de clients de plus de 30 ans.



-- 2.7 [difficile] Affiche la ville dont l'âge moyen est le plus élevé (une seule ligne).



-- ------------------------------------------------------
-- Partie 3 : jointures (séance 3)
-- ------------------------------------------------------

-- 3.1 [facile] Affiche le prénom du client et le produit de chaque commande.



-- 3.2 [moyen] Affiche tous les clients avec leurs commandes, y compris ceux qui n'en ont pas.



-- 3.3 [moyen] Affiche les clients qui n'ont passé aucune commande.



-- 3.4 [moyen] Affiche la dépense totale de chaque client (prénom et total), du plus gros dépensier au plus petit.



-- 3.5 [moyen] Affiche le montant total des commandes par ville.



-- 3.6 [difficile] Affiche tous les clients avec leur dépense totale, avec 0 pour ceux qui n'ont rien commandé.



-- 3.7 [difficile] Affiche les commandes qui n'appartiennent à aucun client.



-- 3.8 [difficile] Affiche, pour chaque client (même sans commande), le nombre de commandes passées.



-- ------------------------------------------------------
-- Partie 4 : sous-requêtes et CTE (séance 4)
-- ------------------------------------------------------

-- 4.1 [facile] Affiche les clients plus jeunes que l'âge moyen de tous les clients.



-- 4.2 [moyen] Affiche les commandes dont le montant dépasse la moyenne des montants.



-- 4.3 [moyen] Avec IN, affiche les prénoms des clients qui ont passé au moins une commande.



-- 4.4 [moyen] Avec NOT IN, affiche les prénoms des clients qui n'ont passé aucune commande.



-- 4.5 [moyen] Affiche le ou les clients les plus âgés, avec MAX dans une sous-requête.



-- 4.6 [difficile] Avec un CTE, affiche les clients dont la dépense totale dépasse 250.



-- 4.7 [difficile] Avec deux CTE enchaînés, affiche les clients dont la dépense totale est inférieure à la dépense moyenne par client (parmi ceux qui ont commandé).



-- ------------------------------------------------------
-- Partie 5 : fonctions de fenêtrage (séance 5)
-- ------------------------------------------------------

-- 5.1 [facile] Numérote les clients du plus âgé au plus jeune.



-- 5.2 [moyen] Classe les clients par âge décroissant dans chaque ville.



-- 5.3 [moyen] Affiche chaque client avec l'âge moyen de sa ville.



-- 5.4 [moyen] Affiche chaque commande avec le cumul des montants, par date de commande croissante.



-- 5.5 [difficile] Affiche chaque commande avec le montant de la commande précédente (par date) et la différence entre les deux.



-- 5.6 [difficile] Affiche la commande la plus chère de chaque client ayant commandé (CTE et ROW_NUMBER).



-- 5.7 [moyen] Affiche chaque commande avec son pourcentage du total des commandes, arrondi à 2 décimales.



-- 5.8 [difficile] Répartis les clients en 2 groupes d'âge avec NTILE(2) et affiche le groupe de chaque client.



-- ------------------------------------------------------
-- Partie 6 : CASE WHEN, dates et texte (séance 6)
-- ------------------------------------------------------

-- 6.1 [moyen] Ajoute à chaque commande une catégorie : moins de 100 = 'Petite', de 100 à 299 = 'Moyenne', 300 et plus = 'Grande'.



-- 6.2 [difficile] Affiche le nombre de commandes et le montant total par catégorie (mêmes seuils qu'en 6.1).



-- 6.3 [moyen] Affiche le montant total des commandes par mois, au format AAAA-MM.



-- 6.4 [moyen] Calcule le nombre de jours entre la première et la dernière commande.



-- 6.5 [moyen] Affiche les commandes passées en février 2026.



-- 6.6 [moyen] Affiche les clients dont le prénom se termine par la lettre e.



-- 6.7 [moyen] Affiche chaque client sous la forme PRENOM - ville (prénom en majuscules, ville en minuscules).



-- 6.8 [difficile] Affiche les prénoms de exactement 4 lettres, avec leur ville.



-- ------------------------------------------------------
-- Partie 7 : synthèse (questions métier)
-- ------------------------------------------------------

-- 7.1 [difficile] Affiche, pour chaque ville, le nombre de commandes et le montant total, avec 0 pour une ville sans commande.



-- 7.2 [difficile] Classe les clients ayant commandé selon leur dépense totale, avec leur rang (RANK).



-- 7.3 [difficile] Affiche, pour chaque mois, le total des commandes et son pourcentage du total de toutes les commandes (2 décimales).



-- 7.4 [difficile] Affiche, pour chaque ville, le prénom du client qui a le plus dépensé (parmi ceux qui ont commandé).


