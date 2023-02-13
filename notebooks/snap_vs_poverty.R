setwd("/Users/toyerinde/Desktop/DataKind")
# Read SNAP enrollment file
snap_data<-read.csv("./State_SNAP_enrollment_ACSST5Y_2021est_upd.csv")
# Remove error estimate columns from snap_data dataframe
snap_datass<- snap_data[,!grepl("_Margin.of.Error$",names(snap_data))]
# Select the rows of relevant data e.g poverty and income data
snap_datass_new<-snap_datass[c(1,22,23,24,38,39),]
# Rearranging/Transforming the data in snap_datass_new into a form that is easy for visualization
states<-c("Alabama","Alaska","Arizona","Arkansas","California","Colorado", "Connecticut",
          "Delaware","District of Columbia","Florida", "Georgia", "Hawaii","Idaho","Illinois",
          "Indiana", "Iowa", "Kansas", "Kentucky", "Louisiana", "Maine", "Maryland", "Massachusetts",
          "Michigan", " Minnesota", "Mississippi", "Missouri", "Montana", "Nebraska", "Nevada",
          "New_Hampshire", "New_Jersey", "New_Mexico", "New_York", "North_Carolina", "North_Dakota",
          "Ohio", "Oklahoma", "Oregon", "Pennsylvania", "Rhode_Island", "South_Carolina",
          "South_Dakota", "Tennessee", "Texas", "Utah", "Vermont", "Virginia", "Washington",
          "West_Virginia", "Wisconsin", "Wyoming", "Puerto_Rico")

states_total_hh <- c(snap_datass_new[1,2],snap_datass_new[1,8],snap_datass_new[1,14],snap_datass_new[1,20],snap_datass_new[1,26],
                           snap_datass_new[1,32],snap_datass_new[1,38],snap_datass_new[1,44],snap_datass_new[1,50],snap_datass_new[1,56],
                           snap_datass_new[1,62],snap_datass_new[1,68],snap_datass_new[1,74],snap_datass_new[1,80],snap_datass_new[1,86],
                           snap_datass_new[1,92],snap_datass_new[1,98],snap_datass_new[1,104],snap_datass_new[1,110],snap_datass_new[1,116],
                           snap_datass_new[1,122],snap_datass_new[1,128],snap_datass_new[1,134],snap_datass_new[1,140],snap_datass_new[1,146],
                           snap_datass_new[1,152],snap_datass_new[1,158],snap_datass_new[1,164],snap_datass_new[1,170],snap_datass_new[1,176],
                           snap_datass_new[1,182],snap_datass_new[1,188],snap_datass_new[1,194],snap_datass_new[1,200],snap_datass_new[1,206],
                           snap_datass_new[1,212],snap_datass_new[1,218],snap_datass_new[1,224],snap_datass_new[1,230],snap_datass_new[1,236],
                           snap_datass_new[1,242],snap_datass_new[1,248],snap_datass_new[1,254],snap_datass_new[1,260],snap_datass_new[1,266],
                           snap_datass_new[1,272],snap_datass_new[1,278],snap_datass_new[1,284],snap_datass_new[1,290],snap_datass_new[1,296],
                           snap_datass_new[1,302],snap_datass_new[1,308])

states_hh_receiving_snap <-c(snap_datass_new[1,4],snap_datass_new[1,10],snap_datass_new[1,16],snap_datass_new[1,22],snap_datass_new[1,28],
                              snap_datass_new[1,34],snap_datass_new[1,40],snap_datass_new[1,46],snap_datass_new[1,52],snap_datass_new[1,58],
                              snap_datass_new[1,64],snap_datass_new[1,70],snap_datass_new[1,76],snap_datass_new[1,82],snap_datass_new[1,88],
                              snap_datass_new[1,94],snap_datass_new[1,100],snap_datass_new[1,106],snap_datass_new[1,112],snap_datass_new[1,118],
                              snap_datass_new[1,124],snap_datass_new[1,130],snap_datass_new[1,136],snap_datass_new[1,142],snap_datass_new[1,148],
                              snap_datass_new[1,154],snap_datass_new[1,160],snap_datass_new[1,166],snap_datass_new[1,172],snap_datass_new[1,178],
                              snap_datass_new[1,184],snap_datass_new[1,190],snap_datass_new[1,196],snap_datass_new[1,202],snap_datass_new[1,208],
                              snap_datass_new[1,214],snap_datass_new[1,220],snap_datass_new[1,226],snap_datass_new[1,232],snap_datass_new[1,238],
                              snap_datass_new[1,244],snap_datass_new[1,250],snap_datass_new[1,256],snap_datass_new[1,262],snap_datass_new[1,268],
                              snap_datass_new[1,274],snap_datass_new[1,280],snap_datass_new[1,286],snap_datass_new[1,292],snap_datass_new[1,298],
                              snap_datass_new[1,304],snap_datass_new[1,310])

states_hh_below_poverty_level <-c(snap_datass_new[3,2],snap_datass_new[3,8],snap_datass_new[3,14],snap_datass_new[3,20],snap_datass_new[3,26],
                                  snap_datass_new[3,32],snap_datass_new[3,38],snap_datass_new[3,44],snap_datass_new[3,50],snap_datass_new[3,56],
                                  snap_datass_new[3,62],snap_datass_new[3,68],snap_datass_new[3,74],snap_datass_new[3,80],snap_datass_new[3,86],
                                  snap_datass_new[3,92],snap_datass_new[3,98],snap_datass_new[3,104],snap_datass_new[3,110],snap_datass_new[3,116],
                                  snap_datass_new[3,122],snap_datass_new[3,128],snap_datass_new[3,134],snap_datass_new[3,140],snap_datass_new[3,146],
                                  snap_datass_new[3,152],snap_datass_new[3,158],snap_datass_new[3,164],snap_datass_new[3,170],snap_datass_new[3,176],
                                  snap_datass_new[3,182],snap_datass_new[3,188],snap_datass_new[3,194],snap_datass_new[3,200],snap_datass_new[3,206],
                                  snap_datass_new[3,212],snap_datass_new[3,218],snap_datass_new[3,224],snap_datass_new[3,230],snap_datass_new[3,236],
                                  snap_datass_new[3,242],snap_datass_new[3,248],snap_datass_new[3,254],snap_datass_new[3,260],snap_datass_new[3,266],
                                  snap_datass_new[3,272],snap_datass_new[3,278],snap_datass_new[3,284],snap_datass_new[3,290],snap_datass_new[3,296],
                                  snap_datass_new[3,302],snap_datass_new[3,308])

states_hh_below_poverty_snap_receivers <-c(snap_datass_new[3,4],snap_datass_new[3,10],snap_datass_new[3,16],snap_datass_new[3,22],snap_datass_new[3,28],
                                           snap_datass_new[3,34],snap_datass_new[3,40],snap_datass_new[3,46],snap_datass_new[3,52],snap_datass_new[3,58],
                                           snap_datass_new[3,64],snap_datass_new[3,70],snap_datass_new[3,76],snap_datass_new[3,82],snap_datass_new[3,88],
                                           snap_datass_new[3,94],snap_datass_new[3,100],snap_datass_new[3,106],snap_datass_new[3,112],snap_datass_new[3,118],
                                           snap_datass_new[3,124],snap_datass_new[3,130],snap_datass_new[3,136],snap_datass_new[3,142],snap_datass_new[3,148],
                                           snap_datass_new[3,154],snap_datass_new[3,160],snap_datass_new[3,166],snap_datass_new[3,172],snap_datass_new[3,178],
                                           snap_datass_new[3,184],snap_datass_new[3,190],snap_datass_new[3,196],snap_datass_new[3,202],snap_datass_new[3,208],
                                           snap_datass_new[3,214],snap_datass_new[3,220],snap_datass_new[3,226],snap_datass_new[3,232],snap_datass_new[3,238],
                                           snap_datass_new[3,244],snap_datass_new[3,250],snap_datass_new[3,256],snap_datass_new[3,262],snap_datass_new[3,268],
                                           snap_datass_new[3,274],snap_datass_new[3,280],snap_datass_new[3,286],snap_datass_new[3,292],snap_datass_new[3,298],
                                           snap_datass_new[3,304],snap_datass_new[3,310])

states_snap_receivers_hh_median_income <-c(snap_datass_new[6,4],snap_datass_new[6,10],snap_datass_new[6,16],snap_datass_new[6,22],snap_datass_new[6,28],
                                        snap_datass_new[6,34],snap_datass_new[6,40],snap_datass_new[6,46],snap_datass_new[6,52],snap_datass_new[6,58],
                                        snap_datass_new[6,64],snap_datass_new[6,70],snap_datass_new[6,76],snap_datass_new[6,82],snap_datass_new[6,88],
                                        snap_datass_new[6,94],snap_datass_new[6,100],snap_datass_new[6,106],snap_datass_new[6,112],snap_datass_new[6,118],
                                        snap_datass_new[6,124],snap_datass_new[6,130],snap_datass_new[6,136],snap_datass_new[6,142],snap_datass_new[6,148],
                                        snap_datass_new[6,154],snap_datass_new[6,160],snap_datass_new[6,166],snap_datass_new[6,172],snap_datass_new[6,178],
                                        snap_datass_new[6,184],snap_datass_new[6,190],snap_datass_new[6,196],snap_datass_new[6,202],snap_datass_new[6,208],
                                        snap_datass_new[6,214],snap_datass_new[6,220],snap_datass_new[6,226],snap_datass_new[6,232],snap_datass_new[6,238],
                                        snap_datass_new[6,244],snap_datass_new[6,250],snap_datass_new[6,256],snap_datass_new[6,262],snap_datass_new[6,268],
                                        snap_datass_new[6,274],snap_datass_new[6,280],snap_datass_new[6,286],snap_datass_new[6,292],snap_datass_new[6,298],
                                        snap_datass_new[6,304],snap_datass_new[6,310])

snap_df<- data.frame(states,states_total_hh,states_hh_receiving_snap,states_hh_below_poverty_level,
                     states_hh_below_poverty_snap_receivers,states_snap_receivers_hh_median_income)

library(dplyr)
library(tibble)
#Convert snap_df dataframe to tibble
snap_df_tibble <- as_tibble(snap_df)
snap_df_tibble_trans<-snap_df_tibble %>%
  mutate(percent_total_hh_receiving_snap = states_hh_receiving_snap/states_total_hh*100,
         percent_total_hh_below_poverty_level = states_hh_below_poverty_level/states_total_hh*100,
         percent_total_hh_below_poverty_level_receiving_snap = states_hh_below_poverty_snap_receivers/states_hh_below_poverty_level*100,
         snap_enrollment_gap_below_poverty = 100-percent_total_hh_below_poverty_level_receiving_snap) %>%
  arrange(desc(snap_enrollment_gap_below_poverty))
  
library (readr)
write.csv(snap_df_tibble_trans,file = "./States_SNAP_enrollment_gap.csv", quote = FALSE)

