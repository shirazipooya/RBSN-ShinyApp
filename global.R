
# Requirement -----------------------------------------------------------------------------------------------------

# Load Requirement R Source (Internet Require)
source(file = "https://raw.githubusercontent.com/shirazipooya/Useful-R-Functions/master/R/installPackages.R") # Check, Install and Load CRAN Packages

# Load Required Packages
# installPackages("shiny", "shinydashboard", "dplyr", "lubridate", "DT", "leaflet")
library(shiny)
library(shinydashboard)
library(dplyr)
library(lubridate)
library(DT)
library(leaflet)

# Get Working Directory
wd <- getwd()

# Load Data -------------------------------------------------------------------------------------------------------

# Load Daily Data
RBSN.DailyData <- readr::read_rds(path = paste(wd, "/data/RBSN-DailyData.RDS", sep = ""))

# Load Monthly Data
RBSN.MonthlyData <- readr::read_rds(path = paste(wd, "/data/RBSN.MonthlyData.RDS", sep = ""))

# Load Yearly Data
RBSN.YearlyData <- readr::read_rds(path = paste(wd, "/data/RBSN.YearlyData.RDS", sep = ""))

# Load Station Information
infoStation <- read.csv(file = paste(wd, "/data/infoStation.csv", sep = ""),
                        header = TRUE,
                        colClasses = c("character", "character", rep(x = "numeric", 3)))
