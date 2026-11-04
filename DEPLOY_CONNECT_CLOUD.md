# Publication gratuite : Posit Connect Cloud

Objectif : déployer le dashboard R Shiny sur l'offre **Free** de Posit Connect Cloud, sans frais d'hébergement.

## Limites du forfait
Le forfait gratuit est limité (actuellement **20 heures actives par mois**, et jusqu'à 5 applications selon la page officielle). Consulter https://connect.posit.cloud/plans avant la publication ; les conditions peuvent changer. Quand le quota est atteint, le dashboard peut devenir indisponible jusqu'au renouvellement. Le dépôt doit être public sur le forfait gratuit.

## Préparer le dépôt
Pour publier une application Shiny R depuis GitHub, Connect Cloud exige `manifest.json` ou `renv.lock` en plus de `app.R`.

Le workflow `.github/workflows/connect-cloud-manifest.yml` crée automatiquement le manifeste sur la branche de préparation. Après validation, intégrer `manifest.json` et les fichiers dans la branche `main`.

Si le workflow échoue ou ne peut pas pousser son commit, exécuter localement en R :
```r
install.packages(c("shiny", "quantmod", "rsconnect"))
rsconnect::writeManifest(appDir=".",
                         appFiles=c("app.R", "R/risk.R", "R/scanner.R"),
                         appPrimaryDoc="app.R", appMode="shiny")
```
Puis committer le fichier `manifest.json`.

## Publier (par le propriétaire du compte)
1. Ouvrir https://connect.posit.cloud/ et créer un compte gratuit.
2. Cliquer **Publish** puis sélectionner **Shiny**.
3. Autoriser Connect Cloud à lire le dépôt GitHub public `zustR/ETF-Dashboard-V2`.
4. Choisir la branche **main**, puis **app.R** comme fichier principal.
5. Garder le déploiement automatique activé uniquement si souhaité.
6. Cliquer **Publish** et examiner les logs.
7. Partager le lien public généré par Connect Cloud pour vérifier ensemble.

Aucune clé API n'est nécessaire pour les cours Yahoo Finance chargés par ce prototype. Ne jamais publier d'identifiants financiers ni de clés en clair dans GitHub.

## Important
Le dashboard est un outil pédagogique, sans ordres d'achat ni données garanties en temps réel. Le scanner peut manquer de cours si Yahoo Finance est indisponible.
