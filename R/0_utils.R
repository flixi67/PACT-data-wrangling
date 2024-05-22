library(tidyverse)
library(lubridate)
library(zoo)
library(progress)
library(rlang)

'%nin%' <- function(x,y) { !('%in%'(x,y)) }

# see all coded engagement categories (works for subsets of 'paragraph')
see_engage <- function(data, table = TRUE) {
  engage <- data %>%
    select(-any_of(c("report_namePKO", "paragraphNumber", "paragraph_ID", "comments"))) %>%
    unlist() %>%
    str_split(",") %>%
    unlist() %>%
    unique()%>%
    .[!is.na(.)]
  engage_table <- data %>%
    select(-any_of(c("report_namePKO", "paragraphNumber", "paragraph_ID", "comments"))) %>%
    unlist() %>%
    str_split(",") %>%
    unlist() %>%
    table()
  if (table == TRUE) {
    return(engage_table)
  } else
  return(engage)
}

# unlist engagement categories to separate dummies
unlist_engage <- function(col, spec) {
  map(spec[[col]], ~ grepl(.x, paragraph[[col]])) # paragraph = raw paragraph data
}

unlist_ia <- function(col, spec) {
  map(spec[[col]], ~ grepl(.x, paragraph[[col]]) & grepl("InternationalActor", paragraph[[col]])) # paragraph = raw paragraph data
}

# get active mission months (from first to last, including months without reporting)
mission_active <- function(dat) {
  active_months <- seq(as_date(dat$start), as_date(dat$end), by = "months") %>%
    format("%Y-%m")
  return(active_months)
}

# aggregate paragraphs to mission-month
aggregate_paragraphs <- function(mission_month, paragraphs, vars = NULL, vars_regex = NULL) {
  if (is.null(vars) & is.null(vars_regex)) {
    vars <- names(mission_month)[which(names(mission_month) %in% names(paragraphs))] %>%
      str_subset("PKO|year|month|period", negate = TRUE)
    message("'vars' not specified: \nAggregating data at variables existing in both dataframes.")
  }
  if (!is.null(vars_regex)) {
    vars <- names(mission_month)[which(names(mission_month) %in% names(paragraphs))] %>%
      str_subset(vars_regex)
    message("Aggregating data at variables in both dataframes that contain:\n", vars_regex)
  }
  pb <- progress_bar$new(
    format = "Aggregating for :mission in :month - :year [:bar] :percent in :elapsed",
    total = nrow(mission_month), clear = FALSE, width = 80)
  for (i in 1:nrow(mission_month)) {
    pb$tick(tokens = list(mission = mission_month$PKO[i],
                          month = mission_month$month[i],
                          year = mission_month$year[i]))
    for (j in 1:nrow(paragraphs)) {
      if (mission_month$PKO[i] == paragraphs$PKO[j] &
          as.yearmon(paragraphs$reportPeriod_start[j]) <= as.yearmon(paste(mission_month$year[i], mission_month$month[i], sep = "-")) &
          as.yearmon(paragraphs$reportPeriod_end[j]) >= as.yearmon(paste(mission_month$year[i], mission_month$month[i], sep = "-"))) {
        mission_month[i, vars] <- mission_month[i, vars] | replace(paragraphs[j, vars], is.na(paragraphs[j, vars]), FALSE)
      }
    }
  }
  return(mission_month)
}

# aggregate activities to a summary dummy (1 if any engagement category was coded)
aggregate_activities <- function(dat) {
  grouping <- names(dat) %>%
    str_remove(".*(?=IA)") %>%
    str_extract(".*(?=__)") %>%
    unique()
  for (g in grouping) {
    if (!is.na(g)) {
      dat <- dat %>% mutate(!!paste0(g, "__All") := !!parse_quo(paste(names(dat) %>%
                                                                        str_remove(".*(?=IA)") %>%
                                                                        str_subset(g),
                                                                      collapse = " | "),
                                                                env = caller_env()),
                            !!paste0(g, "__IA") := !!parse_quo(paste(names(dat) %>%
                                                                        str_subset("IA") %>%
                                                                        str_subset(g),
                                                                      collapse = " | "),
                                                                env = caller_env())
      )
    }
  }
  return(dat)
}
