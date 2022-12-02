
# Setup -------------------------------------------------------------------

library(shiny)
library(shinythemes)
library(shinydashboard)
library(shinycssloaders)
library(tidycensus)
library(magrittr)
library(janitor)
library(stringr)
library(tigris)
library(readr)
library(dplyr)
library(tmap)
library(DT)
library(sf)

options(tigris_use_cache=TRUE)
tmap_mode("view")
census_api_key(read_file("census_api_key"))

# Load Data ---------------------------------------------------------------

working_dir <- getwd()

data_dir <- file.path(working_dir, "data")
df <- read_csv(file.path(data_dir, "snapmerge.csv")) %>% 
  mutate(stateNAME = str_to_title(stateNAME),
         countyNAME = str_remove(countyNAME, " ?County")) %>% 
  group_by(year, stateFIPS, countyFIPS, countyNAME, stateNAME) %>% 
  summarize(across(where(is.numeric), mean)) %>%
  ungroup() %>% 
  mutate(PersonsTotal = round(PersonsTotal))

# Functions ---------------------------------------------------------------

create_county_data <- function(df, states, year_val, epsg = 4326) {
  
  df <- df %>% 
    filter(stateNAME %in% states,
           year == year_val) %>% 
    group_by(countyFIPS, countyNAME)
  
  get_counties <- tigris::counties(df$stateFIPS, cb = TRUE)
  counties <- st_transform(st_as_sf(get_counties), epsg) %>% 
    select(countyFIPS = GEOID, geometry)
  
  county_data <- df %>% 
    left_join(counties, by = "countyFIPS") %>% 
    select(year, stateFIPS, stateNAME, countyFIPS, countyNAME, PersonsTotal, geometry)
  
  return(county_data)
}

get_2020_demographics <- function(states) {
  dem_data <- tidycensus::get_decennial(
    geography = "county",
    variable = "P1_001N",
    year = 2020,
    state = states
  ) %>% 
    select(population_2020 = value, countyFIPS = GEOID)
  return(dem_data)
}

mapping_data <- function(df, states, year_val, epsg = 4326) {
  county_data <- create_county_data(df, states, year_val, epsg)
  dem_data <- get_2020_demographics(states)
  
  merge <- county_data %>% 
    left_join(dem_data, by = "countyFIPS") %>% 
    mutate(`Pop. Enrolled (%)` = round(PersonsTotal / population_2020, 4)*100) %>% 
    group_by(stateNAME) %>% 
    mutate(state_avg_pct_enrolled = round(sum(PersonsTotal) / sum(population_2020), 4)*100) %>% 
    ungroup() %>% 
    mutate(`Diff. From State Avg. (%)` = `Pop. Enrolled (%)` - state_avg_pct_enrolled) %>% 
    mutate(across(where(is.numeric), round, 2)) %>% 
    st_set_geometry("geometry")
  
  return(merge)
}

# Inputs ------------------------------------------------------------------

input_states = selectInput(
  inputId = "input_states",
  label = "Select state",
  choices = unique(df$stateNAME)
)

input_year = selectInput(
  inputId = "input_year",
  label = "Select year",
  choices = sort(unique(df$year), decreasing = TRUE)
)
