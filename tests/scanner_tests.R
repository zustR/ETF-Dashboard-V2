source("R/scanner.R")
d <- data.frame(date=seq(as.Date("2025-01-01"),by="day",length.out=120),
                price=seq(100,120,length.out=120))
s <- scan_price_history(d)
stopifnot(nrow(s)==1, s$Momentum_90>0, abs(s$Baisse_max)<1e-8,
          is.finite(s$Volatilite), s$Score>=0, s$Score<=100)
fall <- d
fall$price[110:120] <- seq(100,70,length.out=11)
f <- scan_price_history(fall)
stopifnot(f$Baisse_max < -30, f$Score < s$Score)
stopifnot(inherits(try(scan_price_history(d[1:20,]),silent=TRUE),"try-error"))
cat("Scanner : tests des indicateurs OK\n")
