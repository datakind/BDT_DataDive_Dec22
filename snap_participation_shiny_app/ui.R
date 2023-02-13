
# -------------------------------------------------------------------------

fluidPage(
  theme = shinytheme("flatly"),
  titlePanel("Benefits Data Trust"),
  sidebarPanel(
    input_states,
    input_year,
    actionButton("go", "Render Map", width = "90%", icon = icon("paper-plane"),
                 style="color: #fff; background-color: #337ab7; border-color: #337ab7")
  ),
  mainPanel(
    tabsetPanel(
      tabPanel(
        "Map",
        conditionalPanel(
          "input.go == 0",
          fluidRow(
            column(width = 5,
                   box(title = "Welcome!", width = 12, status = "primary",
                       p("Pick a state on the left to render a map.")))
          )
        ),
        conditionalPanel(
          "input.go > 0",
          fluidRow(
            column(
              width = 12,
              h2("Map"),
              div(tmapOutput("map", width = "100%", height = 800) %>% withSpinner(type = 6), align = "center"),
              br(),
              h2("Data Table"),
              div(DT::dataTableOutput("datatable")),
              br())
          )
        )
      ),
      tabPanel(
        "Information",
        br(),
        p(
          "The purpose of this application is to explore participation in SNAP. The application uses USDA Food and Nutrition Service Bi-Annual (January and July) Participation and Issuance Data at the County level.",
          br(),
          p("The original SNAP Data Tables are ", a(href = "https://www.fns.usda.gov/pd/supplemental-nutrition-assistance-program-snap", "found here."), .noWS = c("after-begin", "before-end")),
          p("The script to clean and combine the data tables for use in this application is ", a(href = "https://github.com/michaelbbryan/tools-and-kaggles/tree/main/DataDive2022", "found here.", .noWS = "outside"), .noWS = c("after-begin", "before-end"))
        )
      )
    )
  )
)
