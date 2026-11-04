source("R/sec_fundamentals.R")
mock <- list(cik=1234,entityName="Societe exemple",
  facts=list("us-gaap"=list(
    RevenueFromContractWithCustomerExcludingAssessedTax=list(units=list(USD=list(
      list(start="2024-01-01",end="2024-12-31",form="10-K",filed="2025-02-10",val=1000),
      list(start="2025-01-01",end="2025-12-31",form="10-K",filed="2026-02-10",val=1200)))),
    NetIncomeLoss=list(units=list(USD=list(
      list(start="2024-01-01",end="2024-12-31",form="10-K",filed="2025-02-10",val=100),
      list(start="2025-01-01",end="2025-12-31",form="10-K",filed="2026-02-10",val=180)))))))
s <- sec_summary_from_facts(mock,"TEST",today=as.Date("2026-11-04"))
stopifnot(nrow(s)==1, s$Croissance_pct==20, s$Marge_nette_pct==15,
          grepl("0000001234",s$Source),s$Exercice=="2025-12-31")
stopifnot(inherits(try(sec_get_company("RY.TO", agent="ETF app contact@example.org"),silent=TRUE),"try-error"))
stopifnot(inherits(try(sec_get_company("MSFT", agent=""),silent=TRUE),"try-error"))
cat("SEC annual fact parsing : tests OK\n")
