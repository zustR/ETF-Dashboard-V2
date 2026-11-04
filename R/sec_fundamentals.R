# Analyse automatique SEC : données comptables annuelles, sans cotations fictives.
# SEC EDGAR CompanyFacts: https://www.sec.gov/search-filings/edgar-application-programming-interfaces
# Accès limité aux émetteurs avec états financiers us-gaap exploitables.
sec_annual_series <- function(companyfacts, tags, unit="USD") {
  facts <- companyfacts$facts[["us-gaap"]]
  if (is.null(facts)) stop("Aucun jeu us-gaap disponible pour cet émetteur.")
  for (tag in tags) {
    concept <- facts[[tag]]
    if (is.null(concept) || is.null(concept$units[[unit]])) next
    rows <- concept$units[[unit]]
    if (is.data.frame(rows)) rows <- split(rows, seq_len(nrow(rows)))
    candidates <- lapply(rows, function(x) {
      if (is.data.frame(x)) x <- as.list(x[1,,drop=FALSE])
      if (is.null(x$start) || is.null(x$end) || is.null(x$form) ||
          is.null(x$val) || is.null(x$filed)) return(NULL)
      start <- as.Date(as.character(x$start)[1])
      end <- as.Date(as.character(x$end)[1])
      if (is.na(start) || is.na(end) || !as.character(x$form)[1] %in% c("10-K","10-K/A") ||
          as.numeric(end-start) < 330 || as.numeric(end-start) > 400) return(NULL)
      data.frame(end=end, filed=as.Date(as.character(x$filed)[1]),
                 value=as.numeric(x$val)[1], stringsAsFactors=FALSE)
    })
    candidates <- Filter(Negate(is.null), candidates)
    if (!length(candidates)) next
    dat <- do.call(rbind,candidates)
    dat <- dat[is.finite(dat$value) & !is.na(dat$filed),,drop=FALSE]
    if (!nrow(dat)) next
    dat <- dat[order(dat$end, dat$filed, decreasing=TRUE),,drop=FALSE]
    dat <- dat[!duplicated(dat$end),,drop=FALSE]
    if (nrow(dat)>=2) return(list(tag=tag, rows=dat))
  }
  stop("Deux exercices annuels comparables non disponibles pour ce concept.")
}

sec_summary_from_facts <- function(companyfacts, symbol, today=Sys.Date()) {
  revenues <- sec_annual_series(companyfacts, c(
    "RevenueFromContractWithCustomerExcludingAssessedTax",
    "RevenueFromContractWithCustomerIncludingAssessedTax",
    "Revenues", "SalesRevenueNet", "SalesRevenueGoodsNet"))
  income <- sec_annual_series(companyfacts, c("NetIncomeLoss","ProfitLoss"))
  # Retenir uniquement les exercices avec revenus et bénéfice issus de la même date de clôture.
  matched <- merge(revenues$rows, income$rows, by="end", suffixes=c("_rev","_income"))
  matched <- matched[order(matched$end, decreasing=TRUE),,drop=FALSE]
  if (nrow(matched)<2) stop("Deux exercices avec revenus et résultat net comparables sont requis.")
  last <- matched[1,]; prior <- matched[2,]
  if (last$value_rev<=0 || prior$value_rev<=0) stop("Revenus non positifs, calcul non pertinent.")
  growth <- (last$value_rev/prior$value_rev-1)*100
  margin <- last$value_income/last$value_rev*100
  filing <- max(last$filed_rev,last$filed_income)
  if (filing > today) stop("Données datées dans le futur.")
  data.frame(
    Symbole=toupper(symbol), Entreprise=as.character(companyfacts$entityName),
    Exercice=as.character(last$end), Exercice_precedent=as.character(prior$end),
    Revenus_USD=last$value_rev, Revenus_precedents_USD=prior$value_rev,
    Resultat_net_USD=last$value_income, Croissance_pct=round(growth,2),
    Marge_nette_pct=round(margin,2), Dernier_depot=as.character(filing),
    Fraicheur=if(as.numeric(today-filing)>450) "Anciennes données annuelles" else "Données annuelles",
    Source=paste0("https://data.sec.gov/api/xbrl/companyfacts/CIK",
                  sprintf("%010d",as.integer(companyfacts$cik)),".json"),
    Note="P/E et dette/fonds propres non calculés ; aucun score d'achat.",
    stringsAsFactors=FALSE
  )
}

sec_fetch_json <- function(url, agent) {
  if (!requireNamespace("httr2",quietly=TRUE)) stop("Package httr2 indisponible.")
  if (!requireNamespace("jsonlite",quietly=TRUE)) stop("Package jsonlite indisponible.")
  resp <- httr2::request(url) |>
    httr2::req_user_agent(agent) |>
    httr2::req_timeout(25) |>
    httr2::req_retry(max_tries=2) |>
    httr2::req_perform()
  jsonlite::fromJSON(httr2::resp_body_string(resp), simplifyVector=FALSE)
}

sec_get_company <- function(symbol, agent=Sys.getenv("SEC_USER_AGENT")) {
  symbol <- toupper(trimws(symbol))
  if (!grepl("^[A-Z]{1,6}([.-][A-Z]{1,3})?$",symbol))
    stop("Symbole invalide.")
  if (!nzchar(agent) || !grepl("@", agent, fixed=TRUE))
    stop("Configurer SEC_USER_AGENT (nom de projet et courriel de contact) dans l'environnement d'hébergement.")
  if (grepl("\\.(TO|V)$",symbol))
    stop("Ce module SEC ne couvre pas les cotations canadiennes .TO ou .V. Utilisez la saisie documentée.")
  companies <- sec_fetch_json("https://www.sec.gov/files/company_tickers.json",agent)
  matched <- Filter(function(x) identical(toupper(x$ticker),symbol),companies)
  if (!length(matched)) stop("Symbole absent du référentiel des émetteurs SEC.")
  cik <- as.integer(matched[[1]]$cik_str)
  facts <- sec_fetch_json(sprintf("https://data.sec.gov/api/xbrl/companyfacts/CIK%010d.json",cik),agent)
  sec_summary_from_facts(facts,symbol)
}
