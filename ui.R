
# Create Header for My Dashboard Page -----------------------------------------------------------------------------

dashboard_Header <- shinydashboard::dashboardHeader(
    title = "Meteorological Data from 77 Synoptic Stations in Iran"
)

# Create Dashboard Sidebar for Use in My Shiny App ----------------------------------------------------------------

dashboard_Sidebar <- shinydashboard::dashboardSidebar(
    shinydashboard::sidebarMenu(
        shinydashboard::menuItem(
            text = "Data Table",
            icon = shiny::icon(name = "download"),
            tabName = "DataTableTab"
        )
    )
)

# Create Main Body of My Dashboard Page for Use in My Shiny App ---------------------------------------------------

dashboard_Body <- shinydashboard::dashboardBody(
    shinydashboard::tabItems(
        shinydashboard::tabItem(
            tabName = "DataTableTab",
            shiny::fluidRow(
                shinydashboard::box(
                    title = "Controls",
                    status = "primary",
                    solidHeader = TRUE,
                    width = 3,
                    shiny::selectInput(
                        inputId = "selectStation_DataTableTab", 
                        label = "Select a Station:",
                        choices = sort(x = infoStation[,"Name"]),
                        selected = sort(x = infoStation[,"Name"])[1]
                    ),
                    shiny::dateRangeInput(
                        inputId = "selectDate_DataTableTab",
                        label = "Select Date Range:",
                        start = "1951-01-01",
                        end = "2018-08-31",
                        min = "1951-01-01",
                        max = "2018-08-31"
                    ),
                    shiny::selectInput(
                        inputId = "selectTimePeriod_DataTableTab", 
                        label = "Select a Time Period:",
                        choices = c("Yearly", "Monthly", "Daily"),
                        selected = "Yearly"
                    ),
                    shiny::downloadButton(
                        outputId = "download_DataTableTab",
                        label = "Download Data"
                    )
                ),
                shinydashboard::box(
                    title = "Map",
                    status = "primary",
                    solidHeader = TRUE,
                    width = 9,
                    leaflet::leafletOutput(
                        outputId = "map_DataTableTab"
                    )
                )
            ),
            shiny::fluidRow(
                shinydashboard::box(
                    title = "Data Table",
                    status = "primary",
                    solidHeader = TRUE,
                    width = 12,
                    DT::dataTableOutput(outputId = "dataTableViwe_DataTableTab")
                )
            )
        )
    )
)


# Creates Dashboard Page for Use in My Shiny App ------------------------------------------------------------------

shinydashboard::dashboardPage(
    header  = dashboard_Header,
    sidebar = dashboard_Sidebar,
    body    = dashboard_Body,
    title   = "Meteorological Data for Iran",
    skin    = "blue" 
)
