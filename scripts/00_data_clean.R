# Preamble ---------------------------------------------------------------------
# Purpose: Clean up 2015 Canadian General Social Survey (GSS) time-use data 
# (obtained from the University of Toronto Library). The raw .csv data from the 
# library comes without descriptive variable names and without descriptive 
# observation coding. This script creates a new file clean_2015_gss.csv 
# containing a subset of the raw GSS data and some composite variables for analysis, 
# with descriptive variable names and observation codes. It also creates a file,
# semi_clean_2015_gss.csv containing the full set of observations from the raw GSS
# data with cleaned variable names (without any recoding).
# Author: Ethan Sansom
# Contact: ethan.sansom@mail.utotoronto.ca
# Date: 2022-03-10
# Pre-requisites: Have downloaded the data from the University of Toronto library.
## 01. Go to http://www.chass.utoronto.ca/
## 02. Hover over Data Center button, click on U. of T. Users
## 03. Click SDA @ CHASS, you should be redirected to a U of T login page
## 04. Enter your U of T credentials, you should be sent to a landing page
## 05. Click Continue in English on the landing page
## 06. Use Crtl + F to find "GSS", click on General social surveys (GSS) link
## 07. Find "General social survey on Time Use (cycle 29), 2015:"
## 08. Click the Data link next to Main File
## 09. Hover over Download Button and click Customized Subset
## 10. Select CSV Data File, STATA Data definitions, and All Variables, except Sample Weights
### - see data_selection.pdf in directory for an image of the proper selection
## 11. Create the files, download, and save them
### - you may have to copy and paste the STATA defintions text from your browser to a .rtf text file
## 12. Rename the .csv file raw_2015_gss.csv and the .rtf file stata_defs.rtf
## 13. Place the files in the inputs/data folder of this directory
# Check: 
# 01. Make sure that the STATA Data definitions file is a .rtf file
# 02. Confirm that the filenames are raw_2015_gss.csv and stata_defs.rtf

# Load Packages ----------------------------------------------------------------
library(tidyverse)
library(janitor)     # For variable name cleaning
library(here)        # For file path management

# Load Raw Data ----------------------------------------------------------------
raw_gss_data <- read_csv(here("inputs/data/raw_2015_gss.csv"))
raw_variable_names <- as_tibble(read_lines(here("inputs/data/stata_defs.rtf")))

# Clean Variable Names ---------------------------------------------------------
# Remove variables ending in "dur" (which are double counted in the data) and CASEID
raw_gss_data <- raw_gss_data |> select(-ends_with("dur"), -CASEID)

# Get the raw GSS variable names and their descriptions
# variable_name regex with help from: 
# https://stackoverflow.com/questions/33856148/regex-in-r-extracting-words-from-a-string
names_list <-
  raw_variable_names |>
  # Skip the document preamble and variable labeling
  slice(1482:1830) |>
  # Retrieve the variable names and desriptions
  mutate(
    variable_desc = gsub(x = value, pattern = '(.*")(.*)(".*)', replace = "\\2"),
    variable_name = gsub(x = value, "^((?:\\S+\\s+){2})(\\S+).*", replace = "\\2")
  ) |>
  # Filter out the variable names ending with "dur"
  filter(!grepl(x = variable_name, pattern = "^\\S+dur"))

# Create a named list of the variable descriptions corresponding to the raw GSS variable names
# var_names named list created with help from: 
# https://www.r-bloggers.com/2017/10/how-best-to-convert-a-names-values-tibble-to-a-named-list/
var_names <- as.list(setNames(names_list$variable_name, names_list$variable_desc))

# Rename the variables as their variable descriptions, clean these names
clean_gss_data <- 
  raw_gss_data |>
  rename(!!!var_names) |>
  clean_names()

#  Save the Semi-Cleaned Data --------------------------------------------------
write_csv(x = clean_gss_data, file = here("inputs/data/semi_clean_2015_gss.csv"))

# Select, Rename, and Recode Subset of Variables for Analysis  -----------------
# Select the variables used for analysis
clean_gss_data <-
  clean_gss_data |>
  select(
    record_identification,
    person_weight,
    sex_of_respondent,
    sex_of_respondents_spouse_partner_living_in_the_household,
    income_personal_income_group_before_tax,
    household_income_household_income_group_before_tax,
    living_arrangement_of_respondents_household_11_categories,
    respondents_child_ren_in_household_0_to_14_years,
    respondent_c2_92s_child_ren_in_household_any_age_marital_status,
    age_group_of_respondent_c2_92s_child_ren_in_household,
    matches("duration")
  )

# Rename variables
clean_gss_data <-
  clean_gss_data |>
  rename(
    "id" = record_identification,
    "sex_of_partner" = sex_of_respondents_spouse_partner_living_in_the_household,
    "personal_income_group" = income_personal_income_group_before_tax,
    "household_income_group" = household_income_household_income_group_before_tax,
    "number_young_children_in_home" = respondents_child_ren_in_household_0_to_14_years,
    "number_children_in_home" = respondent_c2_92s_child_ren_in_household_any_age_marital_status,
    "age_group_children" = age_group_of_respondent_c2_92s_child_ren_in_household,
    "duration_personal_care_of_child_14_under" = duration_care_of_household_child_15_personal_care,
    "duration_personal_care_of_child_15_plus" = duration_care_of_household_child_15_17_personal_care,
    "duration_accompanying_care_of_child_14_under" = duration_care_of_household_child_15_accompanying,
    "duration_accompanying_care_of_child_15_plus" = duration_care_of_household_child_15_17_accompanying
  )

# Create new variables for analysis
clean_gss_data <-
  clean_gss_data |>
  mutate(
    # Difference between the respondents income group and the household income group
    diff_income = household_income_group - personal_income_group
  )

# Recode observations appropriately
clean_gss_data <-
  clean_gss_data |>
  # Change income codes from integers to text labels, if raw code > 8 then recode as NA
  mutate(
    across(
      c(personal_income_group, household_income_group, diff_income),
      ~ case_when(
        . == 0 ~ "Same Income",
        . == 1 ~ "Less than $20,000",
        . == 2 ~ "$20,000 to $39,999",
        . == 3 ~ "$40,000 to $59,999",
        . == 4 ~ "$60,000 to $79,999",
        . == 5 ~ "$80,000 to $99,999",
        . == 6 ~ "$100,000 to $119,999",
        . == 7 ~ "$120,000 to $139,999",
        . == 8 ~ "$140,000 or more"
        )
      )
    ) |>
  # Correct personal_income_group and diff_income top income level
  mutate(
    across(
      c(personal_income_group, diff_income), 
      ~ if_else(. == "$120,000 to $139,999", "$120,000 or more", .)
      )
    ) |>
  # Recode sex variables, if raw code > 2 then recode as NA
  mutate(
    across(
      starts_with("sex"),
      ~ case_when(
        . == 1 ~ "Male",
        . == 2 ~ "Female"
        )
      )
    ) |>
  # Recode number of young/any children in home and the age group of children
  mutate(
    number_young_children_in_home = case_when(
      number_young_children_in_home == 0 ~ "None",
      number_young_children_in_home == 1 ~ "One",
      number_young_children_in_home == 2 ~ "Two",
      number_young_children_in_home == 3 ~ "Three or more"
      ),
    number_children_in_home = case_when(
      number_children_in_home == 0 ~ "None",
      number_children_in_home == 1 ~ "One",
      number_children_in_home == 2 ~ "Two",
      number_children_in_home == 3 ~ "Three",
      number_children_in_home == 4 ~ "Four or more"
      ),
    age_group_children = case_when(
      age_group_children == 1 ~ "No child under 19 years of age at home",
      age_group_children == 2 ~ "All children under 5 years of age",
      age_group_children == 3 ~ "All children between 5 and 12 years of age",
      age_group_children == 4 ~ "All children 13 years of age and older",
      age_group_children == 5 ~ "At least one child under 5 years of age but not all children"
    )
  ) |>
  # Recode responses of duration > 3600 (the # of minutes in a day) as NA
  mutate(across(matches("duration"), ~ case_when(. <= 3600 ~ .)))

# Fix Ambiguity in diff_income measure -----------------------------------------
# Note: If a respondent's personal_income_group == "$120,000 or more" and their
# household_income_group == "$140,000 or more", then the size of the difference
# between their personal income and household income is ambiguous. 
# Recode diff_income to acknowledge this.
clean_gss_data <-
  clean_gss_data |>
  mutate(
    diff_income = 
      if_else(
        personal_income_group == "$120,000 or more" | household_income_group == "$140,000 or more",
        "Ambiguous",
        diff_income
      )
  )

# Filter for only observations of families -------------------------------------
# Specifically respondents living with a spouse and child(ren) that are < 25 years old
clean_gss_data <-
  clean_gss_data |>
  filter(living_arrangement_of_respondents_household_11_categories == 3) |>
  select(-living_arrangement_of_respondents_household_11_categories)

# Save the Cleaned Data --------------------------------------------------------
write_csv(x = clean_gss_data, file = here("inputs/data/clean_2015_gss.csv"))
