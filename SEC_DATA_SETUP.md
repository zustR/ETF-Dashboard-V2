# Données fondamentales automatiques SEC (gratuit)

Ce module expérimental utilise **SEC EDGAR CompanyFacts** pour les sociétés publiant des états financiers us-gaap compatibles. Aucun compte, jeton payant ni connexion à Wealthsimple ne sont nécessaires.

## Limites importantes
- Les résultats reposent sur les **rapports annuels 10-K**; ce ne sont pas des données boursières en direct.
- Revenue et bénéfice net sont alignés sur deux exercices clos aux mêmes dates, et affichés avec leur **date de dépôt et source**.
- L'outil **ne calcule pas de P/E, de valorisation, ni de potentiel de hausse** faute de prix et d'unité de mesure comparables. Pas de note automatique d'achat.
- Les émetteurs avec taxonomies atypiques, exercices manquants ou émetteurs canadiens (.TO/.V) peuvent être indisponibles.
- Les valeurs peuvent être révisées, et il faut valider les données avec les rapports SEC.
- Épargne nécessaire dans 1–3 ans : privilégier la protection du capital ; suivre les actions en simulation seulement.

## Configuration du User-Agent SEC sur Posit

La SEC exige de déclarer un User-Agent identifiant l'application et un contact opérationnel, dans le respect des limites de requêtes :
https://www.sec.gov/search-filings/edgar-search-assistance/accessing-edgar-data

Dans la configuration de l'application Posit Connect Cloud, ajoutez la variable d'environnement :
`SEC_USER_AGENT` = `ETF-Dashboard-V2 contact@example.com`

**Remplacez** `contact@example.com` par un véritable courriel de contact que vous contrôlez. Ne placez pas ce courriel dans le code public GitHub si vous souhaitez le garder privé. Cette variable n'est pas une clé secrète, mais doit être une identification honnête de l'application.

L'onglet **Données SEC automatiques** permet ensuite de saisir `MSFT` ou `NVDA` et de cliquer sur **Charger les données financières SEC**.

## Déploiement
Le manifeste `manifest.json` doit être régénéré avec `R/sec_fundamentals.R` et les dépendances `httr2` et `jsonlite` avant fusion. Le workflow `Generate Posit Connect Cloud manifest` le prépare sur la branche de travail. Ensuite republier Posit depuis `main`.
