source("R/fundamentals.R")
result <- fundamental_score("MSFT",12,22,28,40,
 "https://example.org/sample", "2026-10-01", today=as.Date("2026-11-04"))
stopifnot(result$Score >= 0, result$Score <= 100,
          result$Statut=="Saisie a verifier")
old <- fundamental_score("MSFT",12,22,28,40,
 "https://example.org/sample","2025-01-01",today=as.Date("2026-11-04"))
stopifnot(grepl("anciennes",old$Statut))
stopifnot(inherits(try(fundamental_score("NVDA",10,15,-3,30,
  "https://example.org", "2026-10-01"),silent=TRUE),"try-error"))
stopifnot(inherits(try(fundamental_score("NVDA",10,15,40,30,
  "", "2026-10-01"),silent=TRUE),"try-error"))
stopifnot(inherits(try(fundamental_score("NVDA",10,15,40,30,
  "https://example.org", "2030-01-01",today=as.Date("2026-11-04")),
  silent=TRUE),"try-error"))
cat("Analyses fondamentales : tests OK\n")
