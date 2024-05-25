### merge PACT 1.0 and PACT 2.0 data by assimilated variables ##################
#------------------------------------------------------------------------------#
require(tidyverse)
require(openxlsx)
source("R/0_utils.R")

# read in PACT1 and get relevant variables for merging
pact1 <- read.xlsx("data/pact1/carry_forward_aggregations_allData_onlyPKO_11-23-2020.xlsx")

pact1 <- pact1 %>%
  select(c("NamePKO", "Country", "Year", "Month", "Number.StartDate", "Number.DateOfReport", "Number.ReportNumber"),
         contains("2"), -HostilityGov..VerbalRestrictions2) %>%
  as_tibble()


names(pact1) <- names(pact1) %>% str_remove("2")

pact1_vars <- names(pact1)[which(names(pact1) %nin% c("NamePKO", "Country", "Year", "Month", "Number.StartDate", "Number.DateOfReport", "Number.ReportNumber"))]


pact1[, pact1_vars] <- map_dfc(pact1[, pact1_vars], as.logical)

pact1$NamePKO[pact1$NamePKO == "UNSOM"] <- "UNOSOM"


# read in PACT2 and create activity summarised dummies (_All)
pact2 <- read_rds("out/PACT2_mission-month.Rds") %>%
  mutate(month = as.numeric(month))

pact2 <- aggregate_activities(pact2)


# assimilate the activities and engagement categories between PACT 1 and 2 if necessary
    # MilitaryReform
pact1 <- pact1 %>%
  mutate(MilitaryReform_AssistAgents =
           MilitaryReform_AssistAgentsGender |
           MilitaryReform_AssistAgentsHumRight |
           MilitaryReform_AssistAgentsNorms |
           MilitaryReform_AssistAgentsSexViol |
           MilitaryReform_AssistAgentsSkills,
         MilitaryReform_Assist =
           MilitaryReform_AssistAgents |
           MilitaryReform_AssistPolicies |
           MilitaryReform_AssistOther |
           MilitaryReform_Colocation,
         MilitaryReform_Monitor = 
           MilitaryReform_Monitor |
           MilitaryReform_MonitorAbuse,
         MilitaryReform_MaterialSupport =
           MilitaryReform_MaterialSupport |
           MilitaryReform_MaterialSupportInfra)

    # PoliceReform
pact1 <- pact1 %>%
  mutate(PoliceReform_AssistAgents =
           PoliceReform_AssistAgentsGender |
           PoliceReform_AssistAgentsHumRight |
           PoliceReform_AssistAgentsNorms |
           PoliceReform_AssistAgentsSexViol |
           PoliceReform_AssistAgentsSkills,
         PoliceReform_Assist =
           PoliceReform_AssistAgents |
           PoliceReform_AssistPolicies |
           PoliceReform_AssistOther |
           PoliceReform_Colocation,
         PoliceReform_Monitor = 
           PoliceReform_Monitor |
           PoliceReform_MonitorAbuse,
         PoliceReform_MaterialSupport =
           PoliceReform_MaterialSupport |
           PoliceReform_MaterialSupportInfra)

    # JusticeReform (needs to be renamed to JusticeSectorReform)
pact1 <- pact1 %>%
  mutate(JusticeReform_AssistAgents =
           JusticeReform_AssistAgentsGender |
           JusticeReform_AssistAgentsHumRight |
           JusticeReform_AssistAgentsNorms |
           JusticeReform_AssistAgentsSexViol |
           JusticeReform_AssistAgentsSkills,
         JusticeReform_Assist =
           JusticeReform_AssistAgents |
           JusticeReform_AssistPolicies |
           JusticeReform_AssistOther |
           JusticeReform_Colocation,
         JusticeReform_Monitor = 
           JusticeReform_Monitor |
           JusticeReform_MonitorAbuse,
         JusticeReform_MaterialSupport =
           JusticeReform_MaterialSupport |
           JusticeReform_MaterialSupportInfra)

    # ElectoralSecurity
pact1 <- pact1 %>%
  mutate(ElectoralSecurity_Assist =
           ElectoralSecurity_AssistAgents |
           ElectoralSecurity_AssistPolicies |
           ElectoralSecurity_AssistOther,
         ElectoralSecurity_ProvideSecurity =
           ElectoralSecurity_Implement)

    # ElectionAssistance
pact1 <- pact1 %>%
  mutate(ElectionAssistance_Implement = 
           ElectionAssistance_Implement |
           ElectionAssistance_Certification,
         ElectionAssistance_Assist =
           ElectionAssistance_Assist |
           ElectionAssistance_JointAdministration)

    # LegalReform
pact1 <- pact1 %>%
  mutate(LegalReform_Assist =
           LegalReform_Assist |
           LegalReform_ConstitutionWriting,
         LegalReform_Outreach =
           LegalReform_Outreach |
           LegalReform_Dissemination)

    # Operations
pact1 <- pact1 %>%
  mutate(Operations_PatrolsInterventions_Implement =
           Operations_PatrolsSolo |
           Operations_InterventionSolo |
           Operations_OtherSolo,
         Operations_UseOfForce_Implement =
           Operations_ForceSolo,
         Operations_PatrolsInterventions_Assist =
           Operations_PatrolsJointPolice |
           Operations_PatrolsJointMilitary |
           Operations_InterventionJointPolice |
           Operations_InterventionJointMilitary |
           Operations_OtherJointPolice |
           Operations_OtherJointMilitary,
         Operations_UseOfForce_Assist =
           Operations_ForceJointPolice |
           Operations_ForceJointMilitary,
         Operations_UseOfForce_All =
           Operations_UseOfForce_Assist |
           Operations_UseOfForce_Implement,
         Operations_PatrolsInterventions_All =
           Operations_PatrolsInterventions_Assist |
           Operations_PatrolsInterventions_Implement)

    # DDR
pact1 <- pact1 %>%
  mutate(DDRprogressStarStop =
           DDRprogressStarStop |
           DDRprogressStarStall)


# rename other variables in pact2 and pact1
names(pact2) <- names(pact2) %>%
  str_replace_all("__", "_")

names(pact1) <- names(pact1) %>%
  str_replace("JusticeReform", "JusticeSectorReform") %>%
  str_replace("DisarmDemob", "DisarmamentDemobilization") %>%
  str_replace("Reconciliation", "LocalReconciliation")

names(pact2) <- names(pact2) %>%
  str_replace("National_Reconciliation", "NationalReconciliation")

pact1 <- pact1 %>%
  rename(month = Month,
         year = Year,
         PKO = NamePKO,
         abuseInvestigation = AbuseInvestigation,
         abuseAllegations = AbuseAllegations,
         sexualViolenceAllegation = SexualViolenceAllegations,
         sexualViolenceInvestigation = SexualViolenceInvestigation,
         hostilityGov_None = HostilityGov.NoRestrictions,
         hostilityGov_VerbalRestrictions = HostilityGov.VerbRestrictions,
         hostilityGov_PhysicalRestrictions = HostilityGov.PhysRestrictions,
         hostilityGov_ViolentRestrictions = HostilityGov.ViolRestrictions,
         hostilityOther_None = HostilityOth.NoRestrictions,
         hostilityOther_VerbalRestrictions = HostilityOth.VerbRestrictions,
         hostilityOther_PhysicalRestrictions = HostilityOth.PhysRestrictions,
         hostilityOther_ViolentRestrictions = HostilityOth.ViolRestrictions,
         DDRprogress_NO_INFO = DDRprogressNoInf,
         DDRprogress_NOT_STARTED = DDRprogressnotstar,
         DDRprogress_STARTED = DDRprogressStar,
         DDRprogress_START_BUT_STOP = DDRprogressStarStop,
         DDRprogress_COMPLETED = DDRprogressCompleted
         ) %>%
  select(-DDRprogressStarStall) # combined previously with "started but stopped" to match with PACT2

names(pact1)[which(names(pact1) %nin% names(pact2))] %>%
  str_subset("Sanction|PeaceProcess|Ceasefire", negate = TRUE) # this list should only contain special EC coded in PACT1 as well as old operations categories


# merge datasets
pact_fulljoin <- plyr::rbind.fill(pact1, pact2) %>%
  as_tibble()
  mutate(month = as.numeric(month))


# create index since mission start
pact_fulljoin <- pact_fulljoin %>% arrange(year, month) %>% group_by(PKO) %>% 
  mutate(month_index = row_number(PKO))

# add country and continent from IPI data
country_continent <- read_rds("data/ipi_continent.Rds")[-75,]

pact_fulljoin <- left_join(pact_fulljoin, country_continent, by = c("PKO" = "Mission"))

pact_fulljoin$Mission_Continent[pact_fulljoin$PKO == "MINUJUSTH"] <- "South America"
pact_fulljoin$Mission_Country[pact_fulljoin$PKO == "MINUJUSTH"] <- "Haiti"
pact_fulljoin$Mission_Continent[pact_fulljoin$PKO == "UNTAG"] <- "Africa"
pact_fulljoin$Mission_Country[pact_fulljoin$PKO == "UNTAG"] <- "Namibia"
pact_fulljoin$Mission_Continent[pact_fulljoin$PKO == "UNOMIG"] <- "Europe"


# save full and reduced versions
pact_noIA <- pact_fulljoin %>%
  select(!contains("_IA"))

write_csv(pact_fulljoin, "out/final_data/PACT_mission-month_full.csv")

write_csv(pact_noIA, "out/final_data/PACT_mission-month_reduced.csv")
