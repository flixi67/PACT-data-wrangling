### add additional information from other data sources and create summary vars #
#------------------------------------------------------------------------------#
require(tidyverse)
require(lubridate)
require(countrycode)
source("R/0_utils.R")

# read in data sets
mission_month <- read_rds(file = "out/PACT2_mission-month.Rds")

mission_year <- read_rds(file = "out/PACT2_mission-year.Rds")

paragraph <- read_rds(file = "out/transformed-paragraphs.Rds") %>%
  mutate(report_namePKO = str_replace(report_namePKO, "MIPONHU", "MIPONUH"),
         report_namePKO = str_replace(report_namePKO, "UNMISH", "UNSMIH"),
         report_namePKO = str_replace(report_namePKO, "UNPSG", "UNCPSG"),
         PKO = str_extract(report_namePKO, "[A-Z]*"), .after = )

# clean paragraph data and remove empty paragraphs
# check if empty coded entries are congruent with NA in paragraphNumber
all.equal(paragraph %>% filter(if_all(contains("__"), ~ is.na(.x))), paragraph %>% filter(is.na(paragraphNumber)))

# remove empty paragraphs
paragraph <- paragraph %>%
  filter(!is.na(paragraphNumber))

# read in additional data
mission_countries <- read_rds("data/ipi_continent.Rds")


# check completeness of additional data and append missing missions
unique(mission_month$PKO[which(mission_month$PKO %nin% mission_countries$Mission)])

mission_countries <- mission_countries %>%
  add_case(
    Mission = c("UNCPSG", "MINUJUSTH"),
    Mission_Country = c("Yugoslavia", "Haiti"),
    Mission_Continent = c("Europe", "South America")
  )


# join country data to mission data
mission_month <- mission_month %>%
  left_join(mission_countries, by = join_by(PKO == Mission)) %>%
  relocate(contains("Mission_"), .after = month)

mission_year <- mission_year %>%
  left_join(mission_countries, by = join_by(PKO == Mission)) %>%
  relocate(contains("Mission_"), .after = year)


# add countrycode (ISO3)
# check if country names from data sets give back unambiguous results
countrycode(sourcevar = mission_month$Mission_Country, origin = "country.name", destination = "iso3c")

# code the ISO3 codes into new variable and manually add historic country code for Yugoslavia
mission_month <- mission_month %>%
  mutate(iso3 = countrycode(sourcevar = Mission_Country, origin = "country.name", destination = "iso3c"),
         .after = month)

mission_year <- mission_year %>%
  mutate(iso3 = countrycode(sourcevar = Mission_Country, origin = "country.name", destination = "iso3c"),
         .after = year)

mission_month <- mission_month %>%
  mutate(iso3 = if_else(Mission_Country == "Yugoslavia", "YUG", iso3))

mission_year <- mission_year %>%
  mutate(iso3 = if_else(Mission_Country == "Yugoslavia", "YUG", iso3))


# create summary variables
mission_month <- aggregate_activities(mission_month)

# write data sets to hard drive
write.csv(mission_month, "out/final_data/PACT2_mission-month.csv")

write.csv(mission_year, "out/final_data/PACT2_mission-year.csv")

write.csv(paragraph, "out/final_data/PACT2_paragraph.csv")

write_rds(mission_month, "out/final_data/PACT2_mission-month.rds")

write_rds(mission_year, "out/final_data/PACT2_mission-year.rds")

write_rds(paragraph, "out/final_data/PACT2_paragraph.rds")


