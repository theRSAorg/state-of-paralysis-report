library(here)
library(readr)
library(tidyr)
library(dplyr)

# I created this dataset manually because I'm currently not able to read in .xsl files
# (because I need admin access to install Java)
ashe <- read_csv(here("data", "ashe-manual.csv")) %>% filter(year != "2019")

ashe_wide <- ashe %>% 
  pivot_wider(names_from = year,
              values_from = median_wage,
              names_prefix = "median_wage_") %>% 
  mutate(growth_rate = (median_wage_2023-median_wage_2008)/median_wage_2008,
         percentage = growth_rate*100)

median_wage_18_21_2008 <- ashe_wide[[1,"median_wage_2008"]]
growth_rate_all_employees <- ashe_wide[[7,"growth_rate"]]
median_wage_18_21_2013 <- ashe_wide[[1,"median_wage_2023"]]

hypothetical <- median_wage_18_21_2008 + (median_wage_18_21_2008*growth_rate_all_employees)
difference <- hypothetical - median_wage_18_21_2013
