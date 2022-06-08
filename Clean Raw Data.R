if (!require("pacman")) install.packages("pacman"); library(pacman)#Load the package manager 
p_load(haven,dplyr,ggplot2,stats,openxlsx,stringr,readxl,scales)
setwd("~/Documents/EEOC-AWD")
source("utils.R")
box_data <- "../../Library/CloudStorage/Box-Box/EEOC data/"

### Cleaning ----
df <- read_dta(paste0(box_data, 'EEOC_allegations_charges.dta'))
df["complaint_year"] <- str_extract(df$charge_filing_date, "\\d\\d\\d\\d")

#### Clean claim basis ----

df <- df %>% 
  dplyr::mutate(
    broad_basis = ifelse(str_starts(basis, "\\w+[-]") & statute != "ADA",
                         str_replace(str_extract(basis, "\\w+[-]"), "[-]", ""),
                         ifelse(statute == 'ADA', "ADA", 
                                ifelse(str_starts(basis, "\\w+ \\w+[-]"),
                                       str_replace(str_extract(basis, "\\w+ \\w+[-]"), "[-]", ""),
                                       paste(statute, basis)))),
    specific_id = str_trim(str_remove_all(basis, 
                                              "(Equal Pay|National Origin|Race|Religion|Sex)[-]"),
                               side = "both")
  )

df["white"] <- ifelse(df$specific_id == "White",
                      1, 0)
df["is_retaliation"] <- ifelse(df$specific_id=="Retaliation",
                               1, 0)
print("retaliation: ")
table(df$is_retaliation)
df["is_race"] <- ifelse(df$broad_basis == "Race", 1, 0)
df["specific_id_broad"] <- ifelse(df$broad_basis == "Sex" | df$broad_basis == "Race",
                                  df$specific_id, NA)
white_claims <- df %>% filter(white==1)
retal_white <- df %>% 
  filter(specific_id=="Retaliation") %>% 
  filter(charge_unique_number %in% white_claims$charge_unique_number) %>% 
  filter(statute=="Title VII")

df["white_retal"] <- ifelse(df$allegation_unique_number %in% retal_white$allegation_unique_number,
                            1, df$white)
with(df, table(white, white_retal))

df <- df %>% 
  mutate(cp_race_recode = recode(cp_race,
                                 B = "Black",
                                 W = "white",
                                 A = "asian",
                                 S = "asian",
                                 H = "HawaiiPI",
                                 I = "indigenous",
                                 Z = "null",
                                 null = "null",
                                 N = "null",
                                 O = "other",
                                 .default="multi-race"),
         cp_hispanic_recode = recode(hispanic, Y = 1, .default = 0))

### Clean location ----
location_columns <- c("respondent_zip", "respondent_county",
                      "respondent_state", "respondent_city")
df <- df %>% 
  mutate(across(all_of(location_columns),
                ~if_else(str_trim(.x)=="null", "", .x),
                .names="{.col}_nn")) %>% 
  mutate(across(all_of(paste0(location_columns, "_nn")),
                ~na_if(.x,"")))
#fix any places that have the zip code listed as the city
df["respondent_zip_nn"] <- ifelse(!is.na(df$respondent_zip_nn),
                             df$respondent_zip_nn,
                             ifelse(str_ends(df$respondent_city_nn, "\\d\\d\\d\\d\\d"),
                                    df$respondent_city_nn, df$respondent_zip_nn))
df$respondent_city_nn[df$respondent_zip_nn==df$respondent_city_nn] <- NA
df["loc_score"] <- rowSums(!is.na(df[,paste0(location_columns,"_nn")]))
#clean city and state to remove extra spaces
df <- df %>% 
  mutate(city_state = ifelse((is.na(respondent_state_nn)==F & is.na(respondent_city_nn)==F),
                             paste0(str_trim(respondent_city_nn),
                                    ", ", str_trim(respondent_state_nn)),
                             NA),
         city_state_id = str_c(city_state, charge_unique_number))
#group complaints based on the available location info
group_zip <- df %>% 
  filter(!duplicated(charge_unique_number)) %>% 
  group_by(respondent_city_nn,respondent_state_nn,
           respondent_zip_nn,respondent_county_nn,
           city_state) %>% 
  count()
#save a charge -> location crosswalk to make merging after geocoding easier
charge_loc_cw <- df %>% 
  filter(!duplicated(charge_unique_number)) %>% 
  group_by(respondent_city_nn,respondent_state_nn,
           respondent_zip_nn,respondent_county_nn,
           city_state) %>% 
  summarise(charge_unique_numbers = paste0(unique(charge_unique_number), collapse="|")) %>% 
  ungroup()
test.tab <- df %>% 
  group_by(charge_unique_number,city_state) %>% 
  count()
group_merge <- left_join(group_zip, charge_loc_cw, by = c(paste0(location_columns, "_nn"), "city_state"))
group_merge["probably_canada"] <- str_starts(group_merge$respondent_zip_nn, "[A-Z]\\d[A-Z]")
group_merge["apo_fpo"] <- str_detect(group_merge$respondent_state_nn, "(\\bAPO\\b|APO/FPO|\\bFPO\\b)")

## save the dataset to be geocoded in the python notebook ----
write.xlsx(group_merge, 
           paste0(box_data, "places_to_geocode.xlsx"))

## run the python notebook called "Geocode EEOC Complaints.ipynb) ----

## after geocoding ----

new_places <- read.csv(paste0(box_data, "geocoded_places.csv"),
                       colClasses = c("charge_nums"="character"))
df$charge_nums <- as.character(df$charge_unique_number)
merge_zips <- left_join(df, new_places, by = "charge_nums")

#### Look at how geocoding performed
nrow(merge_zips)
failed_merge <- merge_zips[is.na(merge_zips$state_county_fips),]
print("Failed cases: ")
print(nrow(failed_merge))
print(nrow(failed_merge)/nrow(df))

merge_zips["keep"] <- ifelse(is.na(merge_zips$state_county_fips), FALSE, TRUE)
failed_merge <- failed_merge[!duplicated(failed_merge$charge_unique_number),]

print("Failure by state: ")
table(failed_merge$respondent_state_nn,useNA = "ifany")

failed_merge <- merge_zips[is.na(merge_zips$state_county_fips),]
city_table <- data.frame(table(failed_merge$city_state))
city_table <- city_table %>% arrange(desc(Freq))
#how many failures were outside the US?
state_table <- data.frame(table(failed_merge$respondent_state_nn))
state_table <- state_table %>% arrange(desc(Freq))
non_us <- "(American Samoa|Outside|APO|Puerto Rico|Islands|Guam)"
non_us_table <- state_table[str_detect(state_table$Var1, non_us),]
sum(non_us_table$Freq)
print("Failures outside US: ")
sum(non_us_table$Freq)/nrow(failed_merge)

#### Read in county-level attitudes data ----
#https://americanideologyproject.com/estimates/estimates2015/codebook.pdf
attitudes <- read.csv(paste0(box_data, 
                             "county_TW_ideology_estimates.csv"))
attitudes["fixed_fip"] <- str_pad(attitudes$county_fips, width = 5, side = "left",
                                  pad = "0")


#### Aggregate data by county w/retaliation ----
merge_zips["fixed_fip"] <- str_pad(merge_zips$state_county_fips, width = 5, side = "left",
                                   pad = "0")
merge_zips$fixed_fip[is.na(merge_zips$state_county_fips)]<-"FAILED"

grpd_complaints <- merge_zips %>% 
  dplyr::group_by(fixed_fip) %>% 
  dplyr::summarise(included_states = paste0(unique(respondent_state_nn),collapse="|"),
                   included_zips = paste0(unique(respondent_zip_nn.y),collapse="|"),
                   orig_county = paste0(unique(respondent_county_nn.x), collapse="|"),
                   n.white = sum(white),
                   n.complaints = n(),
                   n.white.retal = sum(white_retal),
                   n.retal = sum(is_retaliation),
                   n.race = sum(is_race))
grpd_complaints["n.complaints.noretal"] <- grpd_complaints$n.complaints - grpd_complaints$n.retal
grpd_complaints_att <- left_join(grpd_complaints, attitudes, by = "fixed_fip")
#add counties with 0 complaints
extra_counties <- attitudes[attitudes$fixed_fip %in% grpd_complaints_att$fixed_fip==F,]
grpd_cols <- colnames(grpd_complaints)
grpd_cols <- grpd_cols[grpd_cols!="fixed_fip"]
extra_counties[grpd_cols] <- 0
grpd_complaints_att <- rbind(grpd_complaints_att,extra_counties)
#save the dataset for primary analysis ----
write.csv(grpd_complaints_att,
          paste0(box_data, "agg_claim_info_county_w_retal_v1.csv"))

#generate robustness check dataset ----
merge_zips$complaint_year <- as.numeric(merge_zips$complaint_year)

grpd_complaints_robust <- merge_zips %>% 
  filter(complaint_year > 2009 & complaint_year < 2015) %>% 
  dplyr::group_by(fixed_fip) %>% 
  dplyr::summarise(included_states = paste0(unique(respondent_state_nn),collapse="|"),
                   orig_county = paste0(unique(respondent_county_nn.y), collapse="|"),
                   n.white = sum(white),
                   n.complaints = n(),
                   n.retal= sum(is_retaliation),
                   n.race = sum(is_race)) %>% 
  ungroup()
grpd_complaints_robust["n.complaints.noretal"] <- grpd_complaints_robust$n.complaints - grpd_complaints_robust$n.retal
grpd_complaints_robust_att <- left_join(grpd_complaints_robust, attitudes, by = "fixed_fip")
extra_counties <- attitudes[attitudes$fixed_fip %in% grpd_complaints_robust_att$fixed_fip==F,]
grpd_cols <- colnames(grpd_complaints_robust_att)
grpd_cols <- grpd_cols[grpd_cols!="fixed_fip"]
extra_counties[grpd_cols] <- 0
grpd_complaints_robust_att <- rbind(grpd_complaints_robust_att,extra_counties)
#save robustness check dataset ----
write.csv(grpd_complaints_robust_att,
          paste0(box_data, "agg_claim_info_county_w_retal_robust.csv"))


