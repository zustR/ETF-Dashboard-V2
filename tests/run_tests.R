# Executer depuis la racine : Rscript tests/run_tests.R
source("R/risk.R")
stopifnot(abs(required_monthly_saving(1200, 0, 12, 0)-100)<1e-8)
stopifnot(required_monthly_saving(1000, 2000, 12, 0)==0)
stopifnot(abs(required_monthly_saving(1700, 500, 12, 0)-100)<1e-8)
s <- risk_scenario(10000, 10, 40)
stopifnot(s$Part_risquee==1000, s$Perte_simulee==400, s$Capital_restant==9600)
stopifnot(risk_scenario(10000,0,100)$Capital_restant==10000)
cat("Tests de calcul du risque et de l'objectif : OK\\n")
