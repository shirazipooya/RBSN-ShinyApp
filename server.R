
shiny::shinyServer(
    func <- function(input, output, session) {
        myDataset <- shiny::reactive(
            {
                stationCode <- infoStation[which(x = infoStation$Name == input$selectStation_DataTableTab),"Station"]
                
                if (input$selectTimePeriod_DataTableTab == "Yearly") 
                {
                    RBSN.YearlyData %>% 
                        dplyr::filter(Site == stationCode) %>% 
                        dplyr::filter(Date >= input$selectDate_DataTableTab[1] & Date <= input$selectDate_DataTableTab[2]) %>% 
                        dplyr::mutate(Year = lubridate::year(Date)) %>% 
                        dplyr::select(-Date) %>% 
                        dplyr::select(Site, Year, dplyr::everything())
                } else
                if (input$selectTimePeriod_DataTableTab == "Monthly")
                {
                    RBSN.MonthlyData %>% 
                        dplyr::filter(Site == stationCode) %>% 
                        dplyr::filter(Date >= input$selectDate_DataTableTab[1] & Date <= input$selectDate_DataTableTab[2]) %>% 
                        dplyr::mutate(Year = lubridate::year(Date), Month = lubridate::month(Date)) %>% 
                        dplyr::select(-Date) %>% 
                        dplyr::select(Site, Year, Month, dplyr::everything())
                } else 
                {
                    RBSN.DailyData %>% 
                        dplyr::filter(Site == stationCode) %>% 
                        dplyr::filter(Date >= input$selectDate_DataTableTab[1] & Date <= input$selectDate_DataTableTab[2]) %>% 
                        dplyr::mutate(Year = lubridate::year(Date), Month = lubridate::month(Date), Day = lubridate::day(Date)) %>% 
                        dplyr::select(-Date) %>% 
                        dplyr::select(Site, Year, Month, Day, dplyr::everything())
                }
            }
        )
        
        mapData <- reactive({
            x <- infoStation
        })
        
        output$map_DataTableTab <- leaflet::renderLeaflet({
            infoStation <- mapData()
            
            m <- leaflet::leaflet(data = infoStation) %>%
                leaflet::addProviderTiles(provider = leaflet::providers$Stamen.Terrain) %>%
                addMarkers(
                    lng   = ~Longitude,
                    lat   = ~Latitude,
                    popup = paste(infoStation$Name, "<pre>",
                                  "Station Code:", infoStation$Station, "<br>",
                                  "Latitude:", infoStation$Latitude, "<br>",
                                  "Longitude:", infoStation$Longitude, "<br>",
                                  "Elevation:", infoStation$Elevation, "m", "<br>"
                                  )
                    )
            m
        })
        
        output$dataTableViwe_DataTableTab <- DT::renderDataTable(
            {
                DT::datatable(
                    data = myDataset(),
                    options = list(
                        lengthMenu = c(25, 50, 100),
                        pageLength = 25
                    )
                )
            }
        )
        
        output$download_DataTableTab <- shiny::downloadHandler(
            filename = function(variables) 
            {
                paste(
                    input$selectStation_DataTableTab, " - ",
                    input$selectTimePeriod_DataTableTab, ".csv",
                    sep = ""
                )
            },
            content = function(file) 
            {
                write.csv(
                    x = myDataset(),
                    file = file,
                    row.names = FALSE
                )
            }
        )
    }
)
