# Family Resources Survey data exploration

# Authors: Eirini Zormpa & Jolyon Miles-Wilson
# December 2023

# FRS data is used in:
# figure 1.5 (housing tenure by age group),
# figure 1.6 (housing tenure among 16-24 year olds, 2003-2021), and
# of the 'Young People's Future Health and Economic Security' report

#### 1. Set-up ####
rm(list = ls())
# packages
packages <- c("here", "readr", "purrr", "tidyr", "dplyr", "forcats", "stringr", "extrafont", "ggplot2")
pkg_notinstall <- packages[!(packages %in% installed.packages()[, "Package"])]
lapply(pkg_notinstall, install.packages, dependencies = TRUE)
lapply(packages, library, character.only = TRUE)

# if you have never used the extrafont package before
# you will need to import the fonts first
# this could take a few minutes, depending on how many you have installed

# font_import()

# palettes
rsa_palette <- c(
  "#03ECDD",
  "#000000",
  "#FF21B8",
  "#000C78",
  "#FFA72F",
  "#FF2800"
)

rsa_extra_palette <- c(
  "#F5F5F5",
  "#FFFFFF",
  "#373737",
  "#21DCFF"
)

#### 2. Read in data ####

# create mini-functions for reading in data
# this is useful to read in data from multiple files at once

# there are different functions because different variable names are used
# specifically, from 2003 to 2008 age was captured in HHAGEGR2
# but from 2008 HHAGEGR2 is empty and the data is in HHAGEGR3
read_rename_hhagegr2 <- function(flnm) {
  read_tsv(flnm) %>%
    mutate(filename = flnm) %>%
    # for index 1 of 2003-2008, PTENTYP2 is missing. need to investigate whether PTENTYPE can be used in its place (compare dictionaries)
    select(filename, id = SERNUM, age = HHAGEGR2, tenure = PTENTYP2)
}

read_rename <- function(flnm) {
  read_tsv(flnm) %>%
    mutate(filename = flnm) %>%
    # use contains because 2018-2019 uses lower case
    select(filename, id = contains("sernum"), age = HHAGEGR3, tenure = PTENTYP2)
}

# NB: this data is not included in the repository, but is available through the UK Data Service
# more information can be found in the README
files <- list.files(
  path = here("data", "frs-survey"),
  pattern = "\\househol.tab$",
  full.names = T,
  recursive = T
)

# read in data
files_2003_2008 <- files[which(sapply(files, function(x) if(sum(str_detect(x, as.character(c(2003:2008)))) > 1){1} else{0}) > 0)]
files_2008_2022 <- files[which(sapply(files, function(x) if(sum(str_detect(x, as.character(c(2008:2022)))) > 1){1} else{0}) > 0)]

tenure_data_2003_2008 <-
  files_2003_2008 %>%
  map_df(~ read_rename_hhagegr2(.)) %>%
  mutate(
    age = as_factor(age),
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
      "85+" = "9"
    )
  )

# NB: as above, this data came from the UK Data Service and could not be included here
tenure_data_2008_2022 <-
  files_2008_2022 %>%
  map_df(~ read_rename(.)) %>%
  mutate(
    age = as_factor(age),
    age = fct_recode(age,
      NULL = "-1",
      "16-24" = "1",
      "25-34" = "2",
      "35-44" = "3",
      "45-54" = "4",
      "55-59" = "5",
      "60-64" = "6",
      "65-74" = "7",
      "75+" = "8"
    )
  )

# N.B. readr throws problems for 2018-2019 with some rows for vars in cols 117 and 128.
# It expects boolean but apparently finds floats. But subsetting to problem
# cells simply yields NA. In fact, all values for these columns are NA for 2018-2019 
# Since we're not interested in these columns we can continue.

# combine the data
tenure_data <- rbind(tenure_data_2003_2008, tenure_data_2008_2022)

#### 3. Wrangle data ####

# rename the levels for age and tenure
# information taken from the data dictionaries
# the time range is included in the filename, 22 characters from the end
tenure_data_factors <- tenure_data %>%
  mutate(
    year = str_sub(filename, start = str_locate(filename,"FRS_")[,2]+1, 
                   end = str_locate(filename, "/UKDA")[,1]-1),
    year = as_factor(year),
    # HHAGEGR2 and HHAGEGR3 have different levels
    age = fct_collapse(age,
      "75+" = c("75-84", "85+")
    ),
    tenure = as_factor(tenure),
    tenure = fct_recode(tenure,
      # information from data dictionaries
      "Rented from Council" = "1",
      "Rented from Housing Association" = "2",
      "Rented privately unfurnished" = "3",
      "Rented privately furnished" = "4",
      "Owned outright" = "5",
      "Owned with mortgage" = "6"
    ),
    # collapse tenure to match original doc
    tenure = fct_collapse(tenure,
      "Mortgage" = "Owned with mortgage",
      "Own outright" = "Owned outright",
      "Private rent" = c(
        "Rented privately unfurnished",
        "Rented privately furnished"
      ),
      "Social rent" = c(
        "Rented from Council",
        "Rented from Housing Association"
      )
    ),
    # match level order to original doc
    tenure = factor(tenure,
      levels = c(
        "Private rent",
        "Social rent",
        "Mortgage",
        "Own outright"
      )
    )
  ) %>%
  select(-filename)

#### 4. Visualise data ####

# figure 1.5
figure1_5 <- tenure_data_factors %>%
  filter(year == "2021-2022") %>%
  group_by(age, tenure) %>%
  summarise(n = n()) %>%
  mutate(percentage = 100 * (n / sum(n))) %>%
  ggplot(aes(age, percentage, fill = tenure, group = tenure)) +
  geom_col(position = "dodge", colour = "black") +
  theme_bw() +
  scale_fill_manual(values = rsa_palette, name = "Tenure") +
  ylab("Percentage") +
  xlab("Age group") +
  theme(text = element_text(family="Gill Sans MT"))

# figure 1.6
figure1_6 <- tenure_data_factors %>%
  filter(age == "16-24") %>%
  group_by(year, tenure) %>%
  summarise(n = n()) %>%
  mutate(
    percentage = 100 * (n / sum(n)),
    # recode so that year is the year ending, i.e., 2003-2004 is financial year ending 2004
    year = fct_recode(year,
      "2004" = "2003-2004",
      "2005" = "2004-2005",
      "2006" = "2005-2006",
      "2007" = "2006-2007",
      "2008" = "2007-2008",
      "2009" = "2008-2009",
      "2010" = "2009-2010",
      "2011" = "2010-2011",
      "2012" = "2011-2012",
      "2013" = "2012-2013",
      "2014" = "2013-2014",
      "2015" = "2014-2015",
      "2016" = "2015-2016",
      "2017" = "2016-2017",
      "2018" = "2017-2018",
      "2019" = "2018-2019",
      "2020" = "2019-2020",
      "2021" = "2020-2021",
      "2022" = "2021-2022"
    )
  ) %>%
  ggplot(aes(x = year, y = percentage, colour = tenure, group = tenure)) +
  geom_line() +
  geom_point() +
  theme_bw() +
  scale_colour_manual(values = rsa_palette, name = "Tenure") +
  ylab("Percentage") +
  xlab("Financial year ending") +
  theme(text = element_text(family="Gill Sans MT"))

# ggsave(figure1_5, filename = "./figures/1.5_housing_tenure_2021-22.png")
# ggsave(figure1_6, filename = "./figures/1.6_housing_tenure.png", width = 9, height = 3.62)
