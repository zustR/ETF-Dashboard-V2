# Scanner historique : observations descriptives, jamais des recommandations.
scanner_universe <- data.frame(
  Symbole=c("ZAG.TO","XEQT.TO","XIC.TO","XIU.TO","RY.TO","MSFT","NVDA"),
  Categorie=c(rep("ETF",4),rep("Action",3)),
  stringsAsFactors=FALSE
)

# Donnees journalieres ajustees en provenance de Yahoo via quantmod.
# Aucune fabrication de cotations en cas d'echec.
load_adjusted_prices <- function(symbol, from=Sys.Date()-450) {
  if (!requireNamespace("quantmod", quietly=TRUE))
    stop("Le package quantmod doit etre installe (install.packages('quantmod')).")
  x <- suppressWarnings(quantmod::getSymbols(symbol, src="yahoo",
                                              from=from, auto.assign=FALSE,
                                              warnings=FALSE))
  adjusted <- quantmod::Ad(x)
  values <- as.numeric(adjusted)
  dates <- as.Date(zoo::index(adjusted))
  valid <- is.finite(values) & values>0
  data.frame(date=dates[valid], price=values[valid])
}

# Une sequence de prix ajustés, triee chronologiquement.
# Le rendement 90 observations n'est pas un rendement de 90 jours calendaires.
scan_price_history <- function(prices) {
  if (!is.data.frame(prices) || !all(c("date","price") %in% names(prices)))
    stop("Données de prix invalides.")
  prices <- prices[order(prices$date), , drop=FALSE]
  p <- prices$price
  if (length(p)<91 || any(!is.finite(p)) || any(p<=0) ||
      anyDuplicated(prices$date))
    stop("Au moins 91 cours valides, uniques et positifs requis.")
  n <- length(p)
  changes <- diff(log(p))
  peak <- cummax(p)
  max_dd <- min(p/peak-1)*100
  volatility <- stats::sd(changes)*sqrt(252)*100
  momentum <- (p[n]/p[n-90]-1)*100
  # Score descriptif 0-100 : momentum 90 observations (50 points),
  # amplitude des pertes passees (30), volatilite historique (20).
  # Les plafonds sont des choix pedagogiques explicites et non calibres.
  score <- round(
    50*pmin(1,pmax(0,(momentum+20)/40)) +
    30*pmin(1,pmax(0,(50+max_dd)/50)) +
    20*pmin(1,pmax(0,(60-volatility)/60)),0)
  data.frame(Dernier_cours=p[n], Momentum_90=momentum,
             Volatilite=volatility, Baisse_max=max_dd, Score=score,
             Derniere_date=as.character(tail(prices$date,1)),
             stringsAsFactors=FALSE)
}

scan_symbols <- function(symbols) {
  results <- lapply(symbols, function(s) {
    tryCatch({
      p <- load_adjusted_prices(s)
      x <- scan_price_history(p)
      data.frame(Symbole=s, Statut="Donnees disponibles", x,
                 stringsAsFactors=FALSE)
    }, error=function(e) {
      data.frame(Symbole=s, Statut=paste("Indisponible :", conditionMessage(e)),
                 Dernier_cours=NA_real_, Momentum_90=NA_real_,
                 Volatilite=NA_real_, Baisse_max=NA_real_,
                 Score=NA_real_, Derniere_date=NA_character_,
                 stringsAsFactors=FALSE)
    })
  })
  do.call(rbind,results)
}
