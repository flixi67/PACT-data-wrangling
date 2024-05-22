# Data wrangling for the Peacekeeping Activity Dataset 2.0

More information on the data: ### HERE LINK EINFÜGEN ###

## What is Peacekeeping Activity (PACT) Data?

PACT 2.0 provides detailed information on the activities of peacekeepers during United Nations Peacekeeping Operations (UNPKOs), recording 37 distinct activities. Additionally, it categorizes peacekeepers' involvement into 8 different engagement levels. Lastly, it indicates whether each activity was conducted in collaboration with an international actor.

The dataset covers 23 UNPKOs in Europe, Asia, and the Americas, based on data derived from 389 UN Secretary-General (UNSG) progress reports.

It is an extension to the Peackeeping Activity Dataset (PACT) of Hannah Smidt and Rob Blair, which is not yet published.

## How was the data collected?

The data was collected by student coders. For that purpose, a database was set up containing the coding modalities according to the codebook (LINK CODEBOOK). Through this procedure, the quality of the raw output was improved. The coders underwent individual training with the project lead Sabine Otto in order to complete the task. We carried out intercoder reliability tests in order to assure a consistent quality of the data.

Contributors:
Masumi Honda, Sofia Kahma, Joanna Grace Nakabiito, and Felix Kube. Special thanks go to Hannah Smidt (https://hannahsmidt.com/), who introduced us to the coding procedure.

## In this repository

### Raw data

The coders collected three distinct entries in the database.

1. A _reportstart_ dataset for each report
2. The single paragraphs, contained alltogether in the _paragraphs_ dataset
3. A _reportend_ dataset for each report

The first and third dataset contained metadata on the Secretary General reports used to track the UN Peacekeeping missions' activities. Variables contain for example the name of the coder, number of paragraphs in the report, start of the relevant sections, a field for comments, the name of the coded report, the country in case of transnational missions, and an identification number used for matching report level and paragraph level data.

The single paragraphs were coded in a way that for each of the 37 distinct activities, the 8 engagement categories were added with the name of the report as well as the number of the paragraph. Therefore, this data allows for further analysis not yet carried out in the project, for example if more sensitive activities may be reported towards the end of reports, while politically desired activities may be reported at the beginning. Another option for further analysis could be which activities or levels of engagement are reported in close proximity in the text corpus.

(ABB EINFÜGEN MIT ABDECKUNG DER BERICHTE)

### Scripts

This repo contains four main scripts.

> 0_utils.R
>
> 1_transform.R
> 
> 2_mission-month.R
> 
> 3_merge.R

These four scripts have to be carried out chronologically in order to reproduce the data wrangling.

In '0_utils.R' are all the helper functions and very technical code that performs the data transformation.

'1_transform.R' unnests the tagwords from the database into separate dummy variables and joins them with the reportlevel metadata.

The script '2_mission-month.R' then performs the aggregation from report level data into calendar format data (mission year and mission month).

Lastly, '3_merge.R' adds last additional information, creates some more dummy variables and exports the data to the published format.

In this clean repository, extensive scripts to test the validity of the data were removed. You can contact felix.kube (a) uni-konstanz.de if you are interested in these or care to investigate the quality of the data and varifiability of the data.

## Publications

Otto, S., Kube, F., & Smidt, H. (2024). UN peacekeeping upon deployment: Peacekeeping activities in theory and practice. Cooperation and Conflict, 0(0). https://doi.org/10.1177/00108367241235888

Kube, F. (2024). PACT Interactive Visualization (Shiny app). Published on GitHub.
