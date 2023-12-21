# Family Resources Survey data exploration

# Authors: Eirini Zormpa & Jolyon Miles-Wilson
# December 2023

# FRS data is used in:
# figure 1.4 (housing tenure by age group),
# figure 1.5 (housing tenure among 16-24 year olds, 2003-2021), and
# figure 1.6 (median percentage of income spent on housing by age group)
# of the 'Young People's Future Health and Economic Security' report

#### 1. Set-up ####
# packages
packages <- c('here', 'readr', 'purrr', 'tidyr', 'dplyr','forcats', 'stringr', 'ggplot2')
pkg_notinstall <- packages[!(packages %in% installed.packages()[,"Package"])]
lapply(pkg_notinstall, install.packages, dependencies = TRUE)
lapply(packages, library, character.only = TRUE)

# palettes
rsa_palette <- c("#03ECDD",
                 "#000000",
                 "#FF21B8",
                 "#000C78",
                 "#FFA72F",
                 "#FF2800")

rsa_extra_palette <- c("#F5F5F5",
                       "#FFFFFF",
                       "#373737",
                       "#21DCFF")

#### 2. Read in data ####

# create mini-functions for reading in data
# this is useful for read in data from multiple files at once

# there are different functions because different variable names are used
# specifically, from 2003 to 2008 age was captured in HHAGEGR2
# but from 2008 HHAGEGR2 is empty and the data is in HHAGEGR3
read_rename_hhagegr2 <- function(flnm) {
  read_tsv(flnm) %>%
    mutate(filename = flnm) %>% 
    select(filename, id = SERNUM, age = HHAGEGR2, tenure = PTENTYP2)
}

read_rename <- function(flnm) {
  read_tsv(flnm) %>%
    mutate(filename = flnm) %>% 
    select(filename, id = SERNUM, age = HHAGEGR3, tenure = PTENTYP2)
}

# NB: this data is not included in the repository, but is available through the UK Data Service
# more information can be found in the README
tenure_data_2003_2008 <-
  list.files(path = here("data", "frs-survey", "2003-2008"),
             pattern = "\\.tab$",
             full.names = T) %>% 
  map_df(~read_rename_hhagegr2(.)) %>% 
  mutate(age = as_factor(age),
         # information taken from data dictionaries
         age = fct_recode(age,
                          NULL = "-1",
                          "16-24" = "1",
                          "25-34" = "2",
                          "35-44" = "3",
                          "45-54" = "4",
                          "55-59" = "5",
                          "60-64" = "6",
                          "65-74" = "7",
                          "75-84" = "8",
                          "85+" = "9"))

# NB: as above, this data came from the UK Data Service and could not be included here
tenure_data_2008_2022 <-
  list.files(path = here("data", "frs-survey", "2008-2022"),
             pattern = "\\.tab$",
             full.names = T) %>% 
  map_df(~read_rename(.)) %>% 
  mutate(age = as_factor(age),
         age = fct_recode(age,
                          NULL = "-1",
                          "16-24" = "1",
                          "25-34" = "2",
                          "35-44" = "3",
                          "45-54" = "4",
                          "55-59" = "5",
                          "60-64" = "6",
                          "65-74" = "7",
                          "75+" = "8"))

# combine the data
tenure_data <- rbind(tenure_data_2003_2008, tenure_data_2008_2022)

#### 3. Wrangle data ####

# rename the levels for age and tenure
# information taken from the data dictionaries
# the time range is included in the filename, 22 characters from the end
tenure_data_factors <- tenure_data %>%
  mutate(year = str_sub(filename, start = -22, end = -14),
         year = as_factor(year),
         # HHAGEGR2 and HHAGEGR3 have different levels
         age = fct_collapse(age,
                            "75+" = c("75-84", "85+")),
         tenure = as_factor(tenure),
         tenure = fct_recode(tenure,
                             # information from data dictionaries
                             "Rented from Council" = "1",
                             "Rented from Housing Association" = "2",
                             "Rented privately unfurnished" = "3",
                             "Rented privately furnished" = "4",
                             "Owned outright" = "5" ,
                             "Owned with mortgage" = "6"),
         # collapse tenure to match original doc
         tenure = fct_collapse(tenure,
                               "Mortgage" = "Owned with mortgage",
                               "Own outright" = "Owned outright",
                               "Private rent" = c("Rented privately unfurnished",
                                                  "Rented privately furnished"),
                               "Social rent" = c("Rented from Council",
                                                 "Rented from Housing Association")),
         # match level order to original doc
         tenure = factor(tenure, 
                         levels =  c("Private rent",
                                     "Social rent",
                                     "Mortgage",
                                     "Own outright"))
         ) %>% 
  select(-filename)

#### 4. Visualise data ####

# figure 1.4
figure1_4 <- tenure_data_factors %>%
  filter(year == "2021-2022") %>% 
  group_by(age, tenure) %>%
  summarise(n = n()) %>% 
  mutate(percentage = 100 * (n /sum(n))) %>% 
  ggplot(aes(age, percentage, fill = tenure, group = tenure)) +
  geom_col(position = "dodge", colour = "black") +
  theme_bw() +
  scale_fill_manual(values = rsa_palette, name = "Tenure") +
  ylab("Percentage") + xlab("Age group") 

# figure 1.5
figure1_5 <- tenure_data_factors %>%
  filter(age == "16-24") %>% 
  group_by(year, tenure) %>%
  summarise(n = n()) %>% 
  mutate(percentage = 100 * (n /sum(n)),
         year = fct_recode(year,
                           "2003" = "2003-2004",
                           "2004" = "2004-2005",
                           "2005" = "2005-2006",
                           "2006" = "2006-2007",
                           "2007" = "2007-2008",
                           "2008" = "2008-2009",
                           "2009" = "2009-2010",
                           "2010" = "2010-2011",
                           "2011" = "2011-2012",
                           "2012" = "2012-2013",
                           "2013" = "2013-2014",
                           "2014" = "2014-2015",
                           "2015" = "2015-2016",
                           "2016" = "2016-2017",
                           "2017" = "2017-2018",
                           "2018" = "2018-2019",
                           "2019" = "2019-2020",
                           "2020" = "2020-2021",
                           "2021" = "2021-2022")) %>%
  ggplot(aes(x = year, y = percentage, colour = tenure, group = tenure)) +
  geom_line() +
  theme_bw() +
  scale_colour_manual(values = rsa_palette, name = "Tenure") +
  ylab("Percentage") + xlab("") 


# fig 1.6

# this figure requires more variables that the previous plots
# so data is read in and cleaned independently
# like before, this data is not included in the repository
# to comply with the UK Data Service End User Licence
frs_2021_2022 <- read_tsv(here("data", "frs-survey", "2008-2022", "2021-2022_househol.tab"))

fig_1.6_data <- frs_2021_2022 %>%
  select(id = SERNUM,
         age = HHAGEGR3,
         income_num = HHINC,
         income_band = HHINCBND,
         housing_costs_gb = GBHSCOST,
         housing_costs_ni = NIHSCOST) %>%
  mutate(
    age = fct_recode(as_factor(age),
                     "16-24" = "1",
                     "25-34" = "2",
                     "35-44" = "3",
                     "45-54" = "4",
                     "55-59" = "5",
                     "60-64" = "6",
                     "65-74" = "7",
                     "75+" = "8"),
    income_band = fct_recode(as_factor(income_band),
                             "Under £200 a week" = "1",
                             "£200 and less than £400" = "2",
                             "£400 and less than £600" = "3",
                             "£600 and less than £800" = "4",
                             "£800 and less than £1000" = "5",
                             "£1000 and less than £1200" = "6",
                             "£1200 and less than £1400" = "7",
                             "£1400 and less than £1600" = "8",
                             "£1600 and less than £1800" = "9",
                             "£1800 and less than £2000" = "10",
                             "Above £2000" = "11"),
    housing_costs_gb = na_if(housing_costs_gb, -1),
    housing_costs_ni = na_if(housing_costs_ni, -1)) %>% 
  unite("housing_costs", housing_costs_gb:housing_costs_ni, na.rm = TRUE) %>% 
  mutate(housing_costs = as.numeric(housing_costs),
         percentage = (housing_costs/income_num)*100)

fig1.6 <- fig_1.6_data %>% 
  group_by(age) %>% 
  summarise(median_percentage = median(percentage, na.rm = TRUE)) %>% 
  ggplot(aes(x = age, y = median_percentage)) +
  geom_col(fill = "#000C78") +
  scale_y_continuous(n.breaks = 10) +
  labs(x = "Age",
       y = "Median percentage") +
  theme_classic()

# ggsave(filename = "./figures/figure1_4_housing_tenure_2021-22.png")
# ggsave(filename = "./figures/figure1_5_housing_tenure.png", width = 9, height = 3.62)
# ggsave(filename = "./figures/figure1_6_housing-costs-income-percentage.png", width = 9, height = 3.62)
