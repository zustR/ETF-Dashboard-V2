# Fonctions pures de gestion du risque (montants en CAD).
# Scenarios fictifs : les chocs ne sont pas des probabilites ou des previsions.
risk_scenario <- function(capital, share_pct, loss_pct) {
  stopifnot(length(capital)==1, is.finite(capital), capital>=0,
            length(share_pct)==1, is.finite(share_pct), share_pct>=0, share_pct<=100,
            length(loss_pct)==1, is.finite(loss_pct), loss_pct>=0, loss_pct<=100)
  exposed <- capital*share_pct/100
  loss <- exposed*loss_pct/100
  data.frame(Capital=capital, Part_risquee=exposed,
             Perte_simulee=loss, Capital_restant=capital-loss)
}

required_monthly_saving <- function(target, initial, months, annual_rate=0) {
  stopifnot(length(target)==1, is.finite(target), target>=0,
            length(initial)==1, is.finite(initial), initial>=0,
            length(months)==1, is.finite(months), months>=1,
            length(annual_rate)==1, is.finite(annual_rate), annual_rate>=0)
  r <- annual_rate/100/12
  remaining <- max(0, target - initial*(1+r)^months)
  if (r==0) remaining/months else remaining*r/((1+r)^months-1)
}
