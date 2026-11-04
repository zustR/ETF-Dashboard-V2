# Tableau de bord d'investissement prudent — prototype v0.1

Cette application Shiny est une **nouvelle proposition** pour le dépôt `zustR/Canada-Exchange-Traded-Fund`. L'ancienne application `EFT_DASHBOARD.R` peut rester dans le dépôt comme archive : aucun de ses calculs n'est repris sans audit.

## Installation et lancement

1. Installer [R](https://cran.r-project.org/) et éventuellement RStudio.
2. Dans R, lancer `install.packages("shiny")`.
3. Ouvrir le dossier contenant `app.R` et lancer `shiny::runApp(".")`.

## Fonctions disponibles

- Simulateur d'épargne sur 12–36 mois avec versements mensuels, capital initial, taux hypothétique et objectif.
- Comparaison **qualitative** de placements prudents et risqués (sans taux commerciaux en direct).
- Liste de surveillance illustrative, **sans prix ni conseil d'achat**.
- Règles de qualité des données financières.

## Hypothèses et restrictions

- Versements en fin de mois, taux annuel divisé par 12, capitalisation mensuelle.
- Taux constant choisi par l'utilisateur, **non garanti** et non représentatif d'une offre.
- Aucun produit n'est recommandé automatiquement ; les garanties dépendent de l'institution et du contrat.
- Aucun accès à Wealthsimple, aucune transaction et aucune donnée boursière en direct.
- L'interface n'est pas encore testée dans un environnement R : faire les tests locaux avant fusion.

## Test de calcul de référence

Pour un versement de 100 $ pendant 12 mois à 0 %, le total projeté doit être 1 200 $.
Pour une épargne initiale de 500 $ et un versement mensuel de 100 $ pendant 12 mois à 0 %, il doit être 1 700 $.

## Intégration GitHub

Créer une branche (par exemple `feat/prudent-investment-dashboard`) à partir de `main`, copier `app.R` à la racine et conserver le fichier historique `EFT_DASHBOARD.R` sans le modifier, puis lancer les tests et ouvrir une pull request.

## Étapes suivantes

1. Tester et fiabiliser l'interface et les calculs sous R.
2. Ajouter une couche de données vérifiables (dates, sources, ajustement pour distributions), sans données aléatoires de secours.
3. Créer un portefeuille virtuel et un scanner de titres explicable.
4. Ajouter frais de change, scénarios de pertes et contrôles adaptés à une échéance fixe.
