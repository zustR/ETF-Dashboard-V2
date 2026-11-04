# Analyse fondamentale pédagogique, fondée uniquement sur les chiffres fournis
# explicitement par l'utilisateur et accompagnés d'une source vérifiable.
# Le score n'est PAS une probabilité de gain, une juste valeur ou un signal d'achat.

validate_fundamentals <- function(symbol, growth, margin, pe, debt_equity,
                                  source, as_of, today=Sys.Date()) {
  scalar <- function(x) length(x)==1 && is.numeric(x) && is.finite(x)
  if (length(symbol)!=1 || is.na(symbol) || !grepl("^[A-Za-z0-9.\\-]{1,16}$",symbol))
    stop("Symbole invalide.")
  if (length(source)!=1 || is.na(source) ||
      !grepl("^https://[^[:space:]]+$",source))
    stop("Ajouter un lien de source HTTPS pour les chiffres financiers.")
  date <- as.Date(as_of)
  if (length(date)!=1 || is.na(date) || date>today)
    stop("Date de publication invalide ou future.")
  if (!scalar(growth) || growth < -100 || growth > 500)
    stop("Croissance du chiffre d'affaires hors limites (-100 a 500 %).")
  if (!scalar(margin) || margin < -100 || margin > 100)
    stop("Marge nette hors limites (-100 a 100 %).")
  if (!scalar(pe) || pe <= 0 || pe > 1000)
    stop("P/E doit etre positif : une entreprise en pertes doit etre evaluee autrement.")
  if (!scalar(debt_equity) || debt_equity < 0 || debt_equity > 1000)
    stop("Dette/fonds propres hors limites (0 a 1000 %).")
  age_days <- as.numeric(today - date)
  list(age_days=age_days, outdated=age_days>180)
}

fundamental_score <- function(symbol, growth, margin, pe, debt_equity,
                              source, as_of, today=Sys.Date()) {
  check <- validate_fundamentals(symbol, growth, margin, pe, debt_equity,
                                 source, as_of, today)
  # Poids explicites non calibres : croissance 30, marge 30,
  # dette/fonds propres 20, valorisation P/E 20.
  # Comparaison pedagogique uniquement entre societes similaires.
  growth_points <- 30 * pmin(1,pmax(0,(growth+10)/40))
  margin_points <- 30 * pmin(1,pmax(0,(margin+5)/30))
  debt_points <- 20 * pmin(1,pmax(0,(250-debt_equity)/250))
  valuation_points <- 20 * pmin(1,pmax(0,(60-pe)/50))
  score <- round(growth_points+margin_points+debt_points+valuation_points)
  data.frame(
    Symbole=toupper(symbol), Score=score,
    Croissance=growth, Marge_nette=margin, PE=pe,
    Dette_fonds_propres=debt_equity,
    Date_source=as.character(as.Date(as_of)), Source=source,
    Statut=if (check$outdated) "Donnees anciennes (> 180 jours)" else "Saisie a verifier",
    stringsAsFactors=FALSE)
}
