### reshape paragraph data to dummy format and join with report-level vars #####
#------------------------------------------------------------------------------#
require(tidyverse)
require(fastDummies)

# read in filepaths, dont use filename but foldername
filepaths <- dir("data/pact2", recursive = TRUE, full.names = TRUE)

for (i in seq_along(filepaths)) {
  assign(filepaths[i] %>% str_extract("(?<=2/).+(?=/)"),
         read_csv2(filepaths[i]))
}

rm(filepaths, i)

# create 'spec' for which engagement categories to unlist for each activity
ec <- c("Monitor", "Outreach", "Meeting", "Advocate", "Assist", "MaterialSupport", "Implement", "ProvideSecurity")
ec_additional <- c("AssistAgents", "AssistPolicies", "AssistOther") # for PoliceReform, MilitaryReform, JusticeReform, ElectoralSecurity
engagements <- rep(list(ec), 37) %>% 
  set_names(names(paragraph)[names(paragraph) %nin% c("report_namePKO",  "paragraphNumber", "paragraph_ID", "comments")]) %>% 
  map_at(c("PoliceReform", "MilitaryReform", "JusticeSectorReform", "ElectoralSecurity"), ~ c(.x, ec_additional))

# unlist engagement categories to separate columns (unlist_engage in "0_utils.R" with spec = engagements)
paragraph_dummy <- map_dfc(names(engagements), unlist_engage, spec = engagements) %>%
  set_names(map(names(engagements), ~ paste(.x, engagements[[.x]],sep = "__")) %>% unlist()) %>%
  tibble(paragraph[, c("report_namePKO",  "paragraphNumber", "paragraph_ID", "comments")], .)

# create involvement of 'International Actor' for each activity x engagement as separate dummy
IA_dummy <- map_dfc(names(engagements), unlist_ia, spec = engagements) %>%
  set_names(map(names(engagements), ~ paste(.x, engagements[[.x]], "IA", sep = "__")) %>% unlist()) %>%
  tibble()

paragraph_dummy_IA <- cbind(paragraph_dummy, IA_dummy)

# create dummy variables for DDR process
reportend <- dummy_cols(reportend, select_columns = "DDRprogress", remove_selected_columns = TRUE)

DDR_vars <- names(reportend) %>% str_subset("DDR")

reportend[, DDR_vars] <- map_dfc(reportend[, DDR_vars], as.logical)

# check congruence of report and paragraph-level variables
if (sum(paragraph$report_namePKO %nin% reportstart$report_namePKO) != 0) {
  stop("There are coded paragraphs that do not nest within coded reports.
       Please check for coding mistakes and manually clean.")
}

if(sum(reportstart$report_namePKO %nin% reportend$report_namePKO) != 0) {
   error <- reportstart$report_namePKO[which(reportstart$report_namePKO %nin% reportend$report_namePKO)]
   message("For ", paste(error, collapse = ", "), " there are no matching report-level variables.")
}

report <- reportstart %>%
  left_join(paragraph_dummy_IA, by = "report_namePKO") %>%
  left_join(reportend, by = "report_namePKO", suffix = c("Metadata", "ReportVars"))

write_rds(report, "out/transformed-paragraphs.Rds")

# remove everything except utility functions
rm(list = setdiff(ls(), lsf.str()))
