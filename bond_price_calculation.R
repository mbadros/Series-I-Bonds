######
##


packages <- c('quantmod', 'lubridate', 'rvest', 'dplyr')
lapply(packages, require, character.only = TRUE)


# Load CPI data from FRED
CPIU <- getSymbols('CPIAUCNS', src = 'FRED', return.class = 'zoo', auto.assign = FALSE)

inflation_measuremt_dates <- seq(from = as.Date("1998-03-01"), to = Sys.Date(), by = "6 months")

CPI_levels_semiannually <-  CPIU[inflation_measuremt_dates]

inflation_rate <-  round(CPI_levels_semiannually / Lag(CPI_levels_semiannually) - 1, digits = 4)
index(inflation_rate) <- index(inflation_rate) + months(2)


url <- 'https://www.treasurydirect.gov/indiv/research/indepth/ibonds/res_ibonds_iratesandterms.htm'
info_table = read_html(url) %>% html_table()
raw_fixed_rate <- info_table[[3]]

raw_fixed_rate$rate <- as.numeric(gsub("%", "", raw_fixed_rate[ , 2]))/100

raw_fixed_rate$date <- mdy(raw_fixed_rate[ , 1])
fixed_rate <- raw_fixed_rate %>% select(c("date", "rate")) %>% arrange(date)

ISSUE_DATE <- '2001-10-13'
YEARS_TO_CALC <-  30
DENOMINATION <- 1000
INFLATION_ASSUMED <- 0.013
VALUE_DATE = as.Date('2017-10-01')



adj_issue_date <- as.Date(as.yearmon(ISSUE_DATE), frac = 0)
maturity_date <-  adj_issue_date + years(30)

fixed_component <- fixed_rate$rate[findInterval(adj_issue_date, fixed_rate$date)]

inflation_period <- inflation_rate[index(inflation_rate) > adj_issue_date - months(6)]

composite_rate <- fixed_component + (2 * inflation_period) + (fixed_component * inflation_period)

coredata(composite_rate) <-  pmax(0, round(coredata(composite_rate), digits = 4))

PROJ_COMPOSITE <-  round(fixed_component + (2 * INFLATION_ASSUMED) + (fixed_component * INFLATION_ASSUMED), digits = 4)

redemption <- data.frame(Date = seq(from = adj_issue_date, to = min(VALUE_DATE, maturity_date), by = "1 month"),
                         Bond_value = DENOMINATION,
                         Interest_base = DENOMINATION,
                         Monthly_interest = 0,
                         Unpaid_interest = 0)

g <- seq(adj_issue_date, min(VALUE_DATE, maturity_date), 'month')
monthly_rates <- zoo(rep(composite_rate / 12, each = 6), order.by = g) ## Check Rounding


for(i in 1:(length(g)-1)) {
    redemption$Monthly_interest[i] <- (monthly_rates[i] * redemption$Interest_base[i]) %>% round(digits = 2)
    redemption$Unpaid_interest[i] <- redemption$Unpaid_interest[max(1, i-1)] + redemption$Monthly_interest[i]
    redemption$Bond_value[i+1] <- redemption$Interest_base[i] + redemption$Unpaid_interest[i]

    redemption$Interest_base[i + 1] <- redemption$Interest_base[i]
    
    if(i %% 6 == 0) {
      redemption$Interest_base[i+1] <- redemption$Interest_base[i] + redemption$Unpaid_interest[i]
      redemption$Unpaid_interest[i] <- 0
    }
}

final_value <- redemption$Bond_value[length(g)] + redemption$Unpaid_interest[length(g) - 1]
cat("The bond's value at", format(redemption$Date[length(g)], '%B %Y'), 'is')
paste0('$', prettyNum(final_value, format = 'f', big.mark = ',')
)




