### aggregate data from paragraph level to mission-month and mission-year ######
#------------------------------------------------------------------------------#
require(tidyverse)
require(lubridate)
require(zoo)

# read in output from previous script
data <- read_rds("out/transformed-paragraphs.Rds") %>%
  mutate(report_namePKO = str_replace(report_namePKO, "MIPONHU", "MIPONUH"),
         report_namePKO = str_replace(report_namePKO, "UNMISH", "UNSMIH"),
         report_namePKO = str_replace(report_namePKO, "UNPSG", "UNCPSG"),
         PKO = str_extract(report_namePKO, "[A-Z]*"))


# create new dataset with each mission-year-month combination as rows and append relevant variables
# Sys.setlocale("LC_TIME", "en_GB.UTF-8") for MacOS
Sys.setlocale("LC_TIME","English")

mission_dates <- read_rds("out/PKOlist_start_end.Rds") %>%
  select(-`Missionname`) %>%
  transmute(PKO = Acronym,
            start = as.yearmon(start_date),
            end = as.yearmon(end_date) %>% replace_na(as.yearmon("August 2019")))

mission_month <- map_dfr(unique(data$PKO), ~ expand_grid(PKO = .x,
                                                         yearmon = mission_dates %>%
                                                           filter(PKO == .x) %>%
                                                           mission_active())) %>%
  separate(yearmon, c("year", "month"))

mission_month[names(data) %>% str_subset("__|hostility|abuse|sexual|DDR")] <- FALSE


# parse for every paragraph entry and take binary value or increase count
mission_month <- aggregate_paragraphs(mission_month = mission_month, paragraphs = data)

mission_year <- mission_month %>%
  group_by(PKO, year) %>%
  summarise_at(vars(contains("__"), contains("hostility"), contains("abuse"), contains("sexual")),
               ~ mean(.x, na.rm = TRUE) %>% round())


# write to .Rds and .csv for later use
write_rds(mission_month, "out/PACT2_mission-month.Rds")

write_rds(mission_year, "out/PACT2_mission-year.Rds")


# remove everything except utility functions
rm(list = setdiff(ls(), lsf.str()))
