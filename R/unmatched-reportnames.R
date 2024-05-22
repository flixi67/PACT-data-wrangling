sum(paragraph$report_namePKO %nin% reportstart$report_namePKO)
sum(paragraph$report_namePKO %nin% reportend$report_namePKO)
sum(reportstart$report_namePKO %nin% reportend$report_namePKO)
sum(reportstart$report_namePKO %nin% paragraph$report_namePKO)
sum(reportend$report_namePKO %nin% reportstart$report_namePKO)
sum(reportend$report_namePKO %nin% paragraph$report_namePKO)

reportstart$report_namePKO[which(reportstart$report_namePKO %nin% reportend$report_namePKO)]
reportstart$report_namePKO[which(reportstart$report_namePKO %nin% paragraph$report_namePKO)] # %in%
reportend$report_namePKO[which(reportend$report_namePKO %nin% paragraph$report_namePKO)]
reportstart %>% filter(numberParagraphs <= paragraphRelevant) %>% select(report_namePKO, numberParagraphs, paragraphRelevant)
reportstart %>% filter(numberParagraphs == 0) %>% select(report_namePKO, numberParagraphs)


paragraph %>% filter(report_namePKO == "UNOMIG_S/1994/529")
paragraph %>% filter(report_namePKO == "UNOMIG_S/1994/529/Add.1")
