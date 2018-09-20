
# Create ShinyApp Version of RBSN-3Hourly-*.RDS

# Requirement -----------------------------------------------------------------------------------------------------

# Load Requirement R Source (Internet Require)
source(file = "https://raw.githubusercontent.com/shirazipooya/Useful-R-Functions/master/R/installPackages.R")

# Load Required Packages
installPackages("shiny", "shinydashboard", "ggplot2", "dplyr", "lubridate", "openair")

# Get Working Directory
wd <- getwd()

# Convert Hourly Data to Daily Data -------------------------------------------------------------------------------

# Load RBSN-3Hourly-*.RDS Data
RBSN.3HourlyData <- readr::read_rds(path = choose.files(caption = "Select RBSN-3Hourly-*.RDS:"))

# Select Parameter
RBSN.3HourlyData <- RBSN.3HourlyData %>%
    select(date, station_i, dd, ff, t, td, tmin, tmax, p0, p, rrr)

# Change Column Name
colnames(RBSN.3HourlyData) <- c("date", "Site", "Wind Direction", "Wind Speed", "Temperature", "Dew Point", "Minimum Temperature",
                                "Maximum Temperature", "Station Pressure", "Sea Level Pressure", "Precipitation")

# Convert Class Site to Character
RBSN.3HourlyData$Site <- as.character(x = RBSN.3HourlyData$Site)

# Convert Hourly Data to Daily Data
RBSN.DailyData <- RBSN.3HourlyData %>%
    dplyr::select(-Precipitation) %>%
    base::split(f = .$Site) %>%
    base::lapply(FUN = timeAverage, avg.time = "day", statistic = "mean") %>%
    dplyr::bind_rows(.id = "Site") %>%
    mutate(`Relative Humidity` = (0.61078 * exp((17.2694 * (`Dew Point`)) / ((`Dew Point`) + 237.3))) / (0.61078 * exp((17.2694 * (Temperature)) / ((Temperature) + 237.3))) * 100)

# Replace NaN with NA
RBSN.DailyData[do.call(what = cbind, args = lapply(X = RBSN.DailyData, FUN = is.nan))] <- NA

# Function for Convert Hourly Precipitation to Daily Precipitation
hourlyTOdailyPrecipitation <- function(x)
{
    data <- x %>%
        dplyr::group_by(date = as.POSIXct.Date(x = date(x = date))) %>%
        dplyr::summarise(Precipitation = ifelse(test = all(is.na(Precipitation)), yes = NA, no = sum(Precipitation, na.rm = TRUE)))
}

# Convert Hourly Precipitation to Daily Precipitation
RBSN.DailyData <- RBSN.3HourlyData %>%
    dplyr::select(Site, date, Precipitation) %>%
    base::split(f = .$Site) %>%
    base::lapply(FUN = hourlyTOdailyPrecipitation) %>%
    dplyr::bind_rows(.id = "Site") %>%
    dplyr::left_join(y = RBSN.DailyData, by = c("Site" = "Site", "date" = "date")) %>%
    dplyr::select(Site, date, `Wind Direction`, `Wind Speed`, `Minimum Temperature`, Temperature, `Maximum Temperature`,
                  `Dew Point`, `Relative Humidity`, `Station Pressure`, `Sea Level Pressure`, Precipitation)

# Change Date Column Name
colnames(RBSN.DailyData)[2] <- "Date"

# Round All Number
RBSN.DailyData[,3:12] <- as.data.frame(x = do.call(what = cbind, args = lapply(X = dplyr::select(.data = RBSN.DailyData, -Site, -Date), FUN = round, digits = 2)))

# Save RBSN.DailyData Data
saveRDS(object = RBSN.DailyData, file = paste(wd, "/data/RBSN-DailyData.RDS", sep = ""))

# Convert Daily Data to Monthly Data ------------------------------------------------------------------------------

# Change Date Column Name
colnames(RBSN.DailyData)[2] <- "date"

# Convert Daily Data to Monthly Data
RBSN.MonthlyData <- RBSN.DailyData %>%
    dplyr::select(-Precipitation) %>%
    base::split(f = .$Site) %>%
    base::lapply(FUN = timeAverage, avg.time = "month", statistic = "mean") %>%
    dplyr::bind_rows(.id = "Site")

# Replace NaN with NA
RBSN.MonthlyData[do.call(what = cbind, args = lapply(X = RBSN.MonthlyData, FUN = is.nan))] <- NA

# Function for Convert Daily Precipitation to Monthly Precipitation
dailyTOmonthlyPrecipitation <- function(x)
{
    data <- x %>%
        dplyr::group_by(year = year(x = date), month = month(x = date)) %>%
        dplyr::summarise(Precipitation = ifelse(test = all(is.na(Precipitation)), yes = NA, no = sum(Precipitation, na.rm = TRUE)))
}

# Convert Daily Precipitation to Monthly Precipitation
RBSN.MonthlyData$Precipitation <- RBSN.DailyData %>%
    dplyr::select(Site, date, Precipitation) %>%
    base::split(f = .$Site) %>%
    base::lapply(FUN = dailyTOmonthlyPrecipitation) %>%
    dplyr::bind_rows(.id = "Site") %>%
    dplyr::pull(Precipitation)

# Change Date Column Name
colnames(RBSN.MonthlyData)[2] <- "Date"

# Round All Number
RBSN.MonthlyData[,3:12] <- as.data.frame(x = do.call(what = cbind, args = lapply(X = dplyr::select(.data = RBSN.MonthlyData, -Site, -Date), FUN = round, digits = 2)))

# Save RBSN.DailyData Data
saveRDS(object = RBSN.MonthlyData, file = paste(wd, "/data/RBSN.MonthlyData.RDS", sep = ""))

# Convert Monthly Data to Yearly Data -----------------------------------------------------------------------------

# Change Date Column Name
colnames(RBSN.MonthlyData)[2] <- "date"

# Convert Monthly Data to Yearly Data
RBSN.YearlyData <- RBSN.MonthlyData %>%
    dplyr::select(-Precipitation) %>%
    base::split(f = .$Site) %>%
    base::lapply(FUN = timeAverage, avg.time = "year", statistic = "mean") %>%
    dplyr::bind_rows(.id = "Site")

# Replace NaN with NA
RBSN.YearlyData[do.call(what = cbind, args = lapply(X = RBSN.YearlyData, FUN = is.nan))] <- NA

# Function for Convert Monthly Precipitation to Yearly Precipitation
monthlyTOyearlyPrecipitation <- function(x)
{
    data <- x %>%
        dplyr::group_by(year = year(x = date)) %>%
        dplyr::summarise(Precipitation = ifelse(test = all(is.na(Precipitation)), yes = NA, no = sum(Precipitation, na.rm = TRUE)))
}

# Convert Monthly Precipitation to Yearly Precipitation
RBSN.YearlyData$Precipitation <- RBSN.MonthlyData %>%
    dplyr::select(Site, date, Precipitation) %>%
    base::split(f = .$Site) %>%
    base::lapply(FUN = monthlyTOyearlyPrecipitation) %>%
    dplyr::bind_rows(.id = "Site") %>%
    dplyr::pull(Precipitation)

# Change Date Column Name
colnames(RBSN.YearlyData)[2] <- "Date"

# Round All Number
RBSN.YearlyData[,3:12] <- as.data.frame(x = do.call(what = cbind, args = lapply(X = dplyr::select(.data = RBSN.YearlyData, -Site, -Date), FUN = round, digits = 2)))

# Save RBSN.DailyData Data
saveRDS(object = RBSN.YearlyData, file = paste(wd, "/data/RBSN.YearlyData.RDS", sep = ""))
