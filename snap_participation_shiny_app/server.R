
server = function(input, output) {
  
  county_data = eventReactive(input$go,{
    mapping_data(
      df = df, 
      state = input$input_states, 
      year = input$input_year,
      epsg = 4326
      )
    
  })
  
  output$map = renderTmap({
    tm_basemap(server = "OpenStreetMap") +
    tm_shape(county_data()) +
      tm_polygons(col = "Diff. From State Avg. (%)", id = "countyNAME", n = 9, style = "jenks",
                  popup.vars=c("Pop. Enrolled (%)" = "Pop. Enrolled (%)", 
                               "Diff From State Avg. (%)" = "Diff. From State Avg. (%)")) +
    tm_shape(county_data()) +
      tm_text("countyNAME")
  })
  
  output$datatable = DT::renderDataTable({
    county_data() %>% 
      st_drop_geometry() %>% 
      arrange(`Diff. From State Avg. (%)`) %>% 
      select(Year = year, State = stateNAME, County = countyNAME, `Population (2020)` = population_2020, Enrolled = PersonsTotal,
             `Pop. Enrolled (%)`, `Diff. From State Avg. (%)`) 
  })
  
}



