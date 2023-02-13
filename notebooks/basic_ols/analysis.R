
# Setup -------------------------------------------------------------------

library(tidyverse)
library(janitor)
library(readxl)
library(modelr)

# Functions ---------------------------------------------------------------

read_unem = function(file_path) {
  col_names = c("state_fips", "county_fips", "county_name", "year", 
                "labor_force", "employed", "unemployed", "ue_rate_pct")
  df = read_excel(file_path, skip = 5, col_names = FALSE) %>% select(-c(1, 6))
  colnames(df) = col_names
  df = df %>% mutate(county_fips = paste0(state_fips, county_fips))
  
  return(df)
}

load_and_bind_unem = function(file_dir) {
  unemployment_data = tibble()
  
  for (fname in list.files(file_dir)) {
    df = read_unem(file.path(file_dir, fname))
    unemployment_data = rbind(unemployment_data, df)
  }
  return(unemployment_data)
}

get_2020_demographics <- function(states) {
  dem_data <- tidycensus::get_decennial(
    geography = "county",
    variable = "P1_001N",
    year = 2020,
    state = states
  ) %>% 
    select(county_fips = GEOID, population_2020 = value)
  return(dem_data)
}

get_2020_household_stats <- function(states) {
  hh_data = tidycensus::get_acs(
    geography = "county", 
    variables = c("DP02_0001", "DP02_0016"),
    year = 2020,
    state = states,
    survey = "acs5"
  ) %>% 
    pivot_wider(id_cols = GEOID, names_from = variable, values_from = estimate) %>% 
    rename(county_fips = 1, total_households = 2, avg_hh_size = 3)
  return(hh_data)
}

get_2020_pct_uninsured = function(states) {
  ins_data = tidycensus::get_acs(
    geography = "county",
    variables = "S2701_C05_031",
    year = 2020,
    survey = "acs5",
    state = states
  ) %>% 
    select(county_fips = GEOID, pct_uninsured = estimate)
  return(ins_data)
}  

# Load --------------------------------------------------------------------

snap = read_csv(file.path("data", "snapmergecounty.csv")) %>%
  clean_names() %>% 
  group_by(year, substate, state_fips, state_name, county_fips, county_name) %>% 
  summarize(enrolled_persons = round(mean(persons_total)),
            enrolled_households = round(mean(households_total))) %>% 
  ungroup() %>% 
  mutate(state_name = str_to_title(state_name)) %>% 
  filter(year == 2020,
         state_fips != 0,
         enrolled_persons != 0) %>% 
  arrange(county_fips, desc(enrolled_persons)) %>% 
  distinct(county_fips, .keep_all = TRUE) %>% 
  select(-c(year, substate))
  
unem = load_and_bind_unem(file.path("data", "bls")) %>% 
  filter(year == 2020) %>% 
  select(-c(state_fips, county_name, year))

saipe = read_excel(file.path("data", "saipe.xls"), skip = 3) %>% 
  clean_names() %>% 
  select(1:5, 8, 23) %>% 
  filter(county_fips_code != "000") %>% 
  mutate(across(starts_with("poverty"), as.numeric),
         median_household_income = as.numeric(median_household_income),
         county_fips = paste0(state_fips_code, county_fips_code)) %>% 
  relocate(county_fips, .after = state_fips_code) %>% 
  rename(state = postal_code, state_fips = state_fips_code) %>% 
  select(-c(county_fips_code, state_fips, state, name))

pop_2020 = get_2020_demographics(unique(snap$state_fips))
hh_2020 = get_2020_household_stats(unique(snap$state_fips))
unins_2020 = get_2020_pct_uninsured(unique(snap$state_fips))

# Merge -------------------------------------------------------------------

merged = snap %>% 
  left_join(unem, by = "county_fips") %>% 
  left_join(saipe, by = "county_fips") %>% 
  left_join(pop_2020, by = "county_fips") %>% 
  left_join(hh_2020, by = "county_fips") %>% 
  left_join(unins_2020, by = "county_fips") %>% 
  mutate(enrolled_persons_rate = round(enrolled_persons / population_2020, 5)*100,
         enrolled_hh_rate = round(enrolled_households / total_households, 5)*100,
         log_income = log(median_household_income)) %>% 
  filter(enrolled_persons_rate <= 100,
         enrolled_hh_rate <= 100)

# Model Data --------------------------------------------------------------

model_df_hh = merged %>%  
  select(enrolled_hh_rate, log_income, ue_rate_pct, pct_uninsured,
         poverty_percent_all_ages, avg_hh_size)

model_df_persons = merged %>% 
  select(enrolled_persons_rate, log_income, ue_rate_pct, pct_uninsured,
         poverty_percent_all_ages, avg_hh_size)

# Linear Regression -------------------------------------------------------

model1 = lm(enrolled_hh_rate ~ ., data = model_df_hh)
model2 = lm(enrolled_persons_rate ~ ., data = model_df_persons)

# Add Predictions ---------------------------------------------------------

model1_predictions = merged %>% 
  select(county_fips, all_of(colnames(model_df_hh))) %>% 
  add_predictions(model1) %>% 
  mutate(predicted_gap = pred - enrolled_hh_rate) %>% 
  relocate(c(pred, predicted_gap), .after = enrolled_hh_rate) 
  
model2_predictions = merged %>% 
  select(county_fips, all_of(colnames(model_df_persons))) %>% 
  add_predictions(model2) %>% 
  mutate(predicted_gap = pred - enrolled_persons_rate) %>% 
  relocate(c(pred, predicted_gap), .after = enrolled_persons_rate)

# Save --------------------------------------------------------------------

save(merged, model1, model2, model1_predictions, model2_predictions,
     file = "output.RData")
