######################### Initial Stock Download ################################
# Set working directory
setwd(dirname(rstudioapi::getActiveDocumentContext()$path)) # Set working directory to where R script is saved

# Load required packages
library(quantmod)
library(DBI)
library(RSQLite)

# Stock tickers
tickers <- c('AAPL', 'BAC', 'CMRE-PD', 'CPLP', 'EPD') #Stock tickers as given on Google finance

# Dates to update stock data 
ipo_date <- c('1980-12-12', '1978-01-13', '2015-05-15', '2007-03-30', '1998-07-07')

# Get stock data from yahoo api
stock_List<- mapply(FUN=function(x,y){getSymbols(x, src='yahoo', from=y, auto.assign=FALSE)}, 
                          tickers, ipo_date)
names(stock_List) <- tickers
stock_List$`CMRE-PD` <- na.approx(stock_List$`CMRE-PD`)   # Clean data (for now)


# Create SQLite DB
create_DB <- function(x,y){
  db_Name <- paste0(x, '.sqlite')
  mydb <- dbConnect(RSQLite::SQLite(), db_Name)
  
  strDates <- as.character(index(y))
  stock_data <- data.frame(Date=strDates, coredata(y))
  DBI::dbWriteTable(mydb, x, stock_data, overwrite=TRUE)
}
mapply(create_DB, tickers, stock_List)
