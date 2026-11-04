# Tableau de bord d'investissement prudent — version 0.1
# Installation : install.packages('shiny')
# Lancement : shiny::runApp('.')
# Cette application ne télécharge pas de prix ni ne recommande des titres.

library(shiny)

money <- function(x) {
  paste0(format(round(x, 2), big.mark = ' ', decimal.mark = ',', nsmall = 2,
                scientific = FALSE, trim = TRUE), ' $ CA')
}

# Versements en fin de mois, capitalisation mensuelle.
# Il s'agit d'une hypothèse mathématique, pas d'un rendement garanti.
future_value <- function(monthly, annual_rate, months, initial = 0) {
  stopifnot(is.finite(monthly), monthly >= 0,
            is.finite(annual_rate), annual_rate >= 0,
            is.finite(months), months >= 1,
            is.finite(initial), initial >= 0)
  r <- annual_rate / 100 / 12
  initial * (1 + r)^months + if (r == 0) monthly * months else
    monthly * ((1 + r)^months - 1) / r
}

ui <- fluidPage(
  tags$head(tags$style(HTML('
    body { background: #f5f7fb; color: #172334; font-family: system-ui, sans-serif; }
    .panel-card {background: white; padding: 20px; border-radius: 14px;
                 margin-bottom: 18px; box-shadow: 0 1px 9px #152b4514;}
    .muted {color: #56677d;} .notice {border-left: 4px solid #27786c;
                 padding: 12px; background: #eef7f5; margin-bottom: 16px;}
  '))),
  titlePanel('Investissement prudent | Tableau de bord'),
  p(class = 'muted', 'Objectif : disposer de votre argent dans 1 à 3 ans. Les chiffres ci-dessous sont des simulations.'),
  div(class = 'notice', strong('Protection du capital d’abord. '),
      'Si cet argent est nécessaire à échéance, privilégiez les produits à faible risque et disponibles au bon moment. Les actions et ETF ne garantissent pas le capital.'),
  tabsetPanel(
    tabPanel('Mon objectif', br(),
      fluidRow(
        column(4, div(class = 'panel-card',
          numericInput('initial', 'Épargne initiale ($ CA)', value = 0, min = 0, step = 100),
          sliderInput('monthly', 'Versement mensuel ($ CA)', min = 100, max = 500, value = 300, step = 25),
          sliderInput('months', 'Durée (mois)', min = 12, max = 36, value = 24, step = 1),
          sliderInput('rate', 'Taux annuel hypothétique (%)', min = 0, max = 5, value = 2.5, step = 0.25),
          numericInput('target', 'Objectif à atteindre ($ CA)', value = 8000, min = 0, step = 500)
        )),
        column(8, div(class = 'panel-card',
          h3('Projection d’épargne'), tableOutput('projection'),
          plotOutput('growth', height = '280px'),
          textOutput('goal_message'),
          p(class = 'muted', 'Hypothèses : taux constant, intérêts composés mensuellement, versements en fin de mois, sans impôts ni frais. Le taux peut varier dans la réalité.')
        ))
      )
    ),
    tabPanel('Comparer les options', br(),
      div(class = 'panel-card',
        h3('Comparatif qualitatif (aucun taux commercial en direct)'),
        tableOutput('options'),
        p('Pour un CPG, vérifiez la pénalité de retrait anticipé, la date d’échéance et la garantie applicable. Pour un ETF de trésorerie, le prix et le rendement ne sont pas garantis.'),
        p(class = 'muted', 'La protection SADC/CDIC dépend du produit, de l’établissement membre et de la catégorie de dépôt. Un ETF n’est pas un dépôt assuré par la SADC.')
      )
    ),
    tabPanel('Opportunités (simulation)', br(),
      div(class = 'panel-card',
        h3('Liste de surveillance — sans ordres d’achat'),
        p('L’analyse des actions se fera d’abord dans un portefeuille virtuel. Aucun signal automatique d’achat ne sera affiché sans données fiables et contrôles de risque.'),
        tableOutput('watchlist'),
        tags$hr(),
        checkboxInput('ack', 'Je comprends que les actions et les ETF peuvent perdre de la valeur.', value = FALSE),
        conditionalPanel('input.ack',
          p('Prochaine étape : ajouter des sources de marché identifiées, des historiques ajustés et une simulation de portefeuille virtuel.'))
      )
    ),
    tabPanel('Méthode', br(),
      div(class = 'panel-card',
        h3('Règles de qualité des données'),
        tags$ul(
          tags$li('Ne jamais remplacer une donnée réelle indisponible par un prix aléatoire présenté comme réel.'),
          tags$li('Afficher la date de mise à jour et la source de chaque donnée financière.'),
          tags$li('Séparer rendement passé, hypothèses de simulation et prévisions.'),
          tags$li('Calculer les coûts de conversion CAD/USD lorsque le portefeuille sera connecté aux cotations.'),
          tags$li('Ne pas utiliser de prévisions horaires extrapolées à partir de clôtures quotidiennes.')
        ),
        p('Ce tableau de bord est un outil pédagogique et de planification, pas un conseil financier individualisé.')
      )
    )
  )
)

server <- function(input, output, session) {
  valid_inputs <- reactive({
    validate(need(is.finite(input$initial) && input$initial >= 0, 'Épargne initiale invalide.'),
             need(is.finite(input$target) && input$target >= 0, 'Objectif invalide.'))
    TRUE
  })
  timeline <- reactive({
    req(valid_inputs())
    m <- 0:input$months
    invested <- input$initial + input$monthly * m
    value <- vapply(m, function(i) {
      if (i == 0) input$initial else future_value(input$monthly, input$rate, i, input$initial)
    }, numeric(1))
    data.frame(mois = m, versements = invested, projection = value)
  })
  output$projection <- renderTable({
    x <- tail(timeline(), 1)
    data.frame(Indicateur = c('Total versé', 'Intérêts hypothétiques', 'Valeur finale estimée'),
               `Montant` = vapply(c(x$versements, x$projection - x$versements, x$projection), money, character(1)),
               check.names = FALSE)
  }, striped = TRUE)
  output$growth <- renderPlot({
    x <- timeline()
    plot(x$mois, x$projection, type = 'l', lwd = 3, col = '#27786c',
         xlab = 'Mois', ylab = 'Montant ($ CA)', ylim = c(0, max(x$projection, 1)))
    lines(x$mois, x$versements, lwd = 2, lty = 2, col = '#4f719e')
    legend('topleft', c('Projection', 'Versements'), lty = c(1, 2),
           col = c('#27786c', '#4f719e'), bty = 'n')
  })
  output$goal_message <- renderText({
    final <- tail(timeline()$projection, 1)
    if (final >= input$target) paste('Objectif atteint dans cette simulation :', money(final), 'pour', money(input$target), 'visés.')
    else paste('Écart à l’objectif dans cette simulation :', money(input$target - final), '.')
  })
  output$options <- renderTable({
    data.frame(
      Produit = c('Compte d’épargne admissible', 'CPG encaissable admissible', 'CPG non encaissable admissible', 'ETF de trésorerie', 'Actions individuelles'),
      Capital = c('En principe stable, sous conditions', 'En principe stable, sous conditions', 'En principe stable jusqu’à échéance', 'Non garanti', 'Non garanti'),
      Liquidité = c('Généralement élevée', 'Selon contrat', 'Limitée avant échéance', 'En bourse, selon marché', 'En bourse, selon marché'),
      `Pour l’argent indispensable dans 1 à 3 ans` = c('À examiner', 'À examiner', 'Si échéance adaptée', 'Risque supplémentaire', 'Déconseillé'),
      check.names = FALSE
    )
  }, striped = TRUE)
  output$watchlist <- renderTable({
    data.frame(
      Symbole = c('ZAG.TO', 'XEQT.TO', 'XIC.TO', 'XIU.TO', 'MSFT', 'NVDA'),
      Type = c(rep('ETF', 4), 'Action', 'Action'),
      Statut = rep('Observation seulement — aucune cotation chargée', 6),
      check.names = FALSE
    )
  }, striped = TRUE)
}

shinyApp(ui, server)
