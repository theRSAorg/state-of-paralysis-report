library(here)
library(readxl)
library(tidyr)
library(dplyr)

ashe_wide <- ashe %>% 
  pivot_wider(names_from = year,
              values_from = median_wage,
              names_prefix = "median_wage_") %>% 
  mutate(growth_rate = (median_wage_2023-median_wage_2008)/median_wage_2008,
         percentage = growth_rate*100)

# unzip files for 2008 and 2023
unzip(zipfile = here("data", "2008-table-6.zip"),
      files = "Age Group Table 6.7a   Annual pay - Gross 2008.xls",
      exdir = here("data"))

unzip(zipfile = here("data", "ashetable62023provisional.zip"),
      files = "PROV - Age Group Table 6.7a   Annual pay - Gross 2023.xls",
      exdir = here("data"))

# read in files for 2008 and 2023
ashe_2008 <- read_xls(here("data", "Age Group Table 6.7a   Annual pay - Gross 2008.xls"),
                      skip = 4) %>% 
  select(age_group = "Description", median_wage = Median) %>% 
  drop_na(median_wage) %>%
  # I'm dropping information on this age group because the 2023 data is not considered reliable
  filter(age_group != "16-17b")

# the 16-17 age group doesn't need to be dropped explicitly here
# it was marked as "x" in the original data, which is coerced into NA when turning to numeric
# and dropped in the subsequent step
ashe_2023 <- read_xls(here("data", "PROV - Age Group Table 6.7a   Annual pay - Gross 2023.xls"),
                      sheet = "All",
                      skip = 4) %>% 
  select(age_group = "Description", median_wage = Median) %>%
  mutate(median_wage = as.numeric(median_wage)) %>% 
  drop_na(median_wage)

# extract median wages for all employees and 18-21 y.o.s for 2008 and 20023
median_wage_2008_all <- ashe_2008[[1,"median_wage"]]
median_wage_2008_18_21 <- ashe_2008[[2,"median_wage"]]

median_wage_2023_all <- ashe_2023[[1,"median_wage"]]
median_wage_2023_18_21 <- ashe_2023[[2,"median_wage"]]

growth_rate_all <- (median_wage_2023_all-median_wage_2008_all)/median_wage_2008_all
percentage_all <- growth_rate_all*100

growth_rate_18_21 <- (median_wage_2023_18_21-median_wage_2008_18_21)/median_wage_2008_18_21
percentage_18_21 <- growth_rate_18_21*100

hypothetical <- median_wage_2008_18_21 + (median_wage_2008_18_21*growth_rate_all)
difference <- hypothetical - median_wage_2023_18_21
