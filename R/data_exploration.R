# 04/12/23
# For tracking down data files and trying to replicate plots in document

# Packages
packages <- c('here', 'readr', 'purrr', 'tidyr', 'dplyr','forcats', 'stringr', 'ggplot2')
pkg_notinstall <- packages[!(packages %in% installed.packages()[,"Package"])]
lapply(pkg_notinstall, install.packages, dependencies = TRUE)
lapply(packages, library, character.only = TRUE)

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

# create mini functions for reading multiple files
# read_rename_ptentype <- function(flnm) {
#   read_tsv(flnm) %>%
#     mutate(filename = flnm) %>% 
#     select(filename, id = SERNUM, age = HHAGEGR2, tenure = PTENTYPE)
# }

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

# read in data
# the data are separated because different variable names were used for the same variables over the years
# variable names taken from the data dictionaries
# tenure_data_2000_2003 <-
#   list.files(path = here("data", "frs-survey", "2000-2003"),
#              pattern = "\\.tab$",
#              full.names = T) %>% 
#   map_df(~read_rename_ptentype(.)) %>% 
#   mutate(age = as_factor(age),
#          age = fct_recode(age,
#                           NULL = "-1",
#                           "16-24" = "1",
#                           "25-34" = "2",
#                           "35-44" = "3",
#                           "45-54" = "4",
#                           "55-59" = "5",
#                           "60-64" = "6",
#                           "65-74" = "7",
#                           "75-84" = "8",
#                           "85+" = "9"))

tenure_data_2003_2008 <-
  list.files(path = here("data", "frs-survey", "2003-2008"),
             pattern = "\\.tab$",
             full.names = T) %>% 
  map_df(~read_rename_hhagegr2(.)) %>% 
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
                          "75-84" = "8",
                          "85+" = "9"))

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


# levels(as_factor(tenure_data$age))
# levels(as_factor(tenure_data$tenure))

# rename the levels for age and tenure
# information taken from the data dictionaries
# the time range is included in the filename, 22 characters from the end
tenure_data_factors <- tenure_data %>%
  mutate(year = str_sub(filename, start = -22, end = -14),
         year = as_factor(year),
         age = fct_collapse(age,
                            "75+" = c("75-84", "85+")),
         tenure = as_factor(tenure),
         tenure = fct_recode(tenure,
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

levels(tenure_data_factors$year)

# length(is.na(tenure_data_factors$age)[is.na(tenure_data_factors$age) == TRUE])
# there's way too many NAs for age when using HHAGEGR2

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

# ggsave(filename = "./figures/figure1_4_housing_tenure_2021-22.png")
# ggsave(filename = "./figures/figure1_5_housing_tenure.png", width = 9, height = 3.62)

