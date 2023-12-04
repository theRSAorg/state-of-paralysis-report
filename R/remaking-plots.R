# YPFHES report - new graphs
# Author: Eirini Zormpa
# Date: 4 December 2023

#### 1. install and load packages ####

# if you don't have any of the following packages installed, select the command only and run it to install

# install.packages("here")
# install.packages("readr")
# install.packages("tidyr")
# install.packages("dplyr)
# install.packages("magrittr")
# install.packages("janitor")
# install.packages("ggplot2")

# for avoiding confusion with paths
library(here)
# for reading in all sorts of data files
library(readr)
# for tidying data
library(tidyr)
library(dplyr)
# for piping
library(magrittr)
# for cleaning names
library(janitor)
# for making pretty plots
library(ggplot2)

# create the RSA palette
rsa_palette <- c("#03ECDD",
                 "#000000",
                 "#FFFFFF",
                 "#000C78",
                 "#FF21B8",
                 "#FFA72F",
                 "#FF2800")

#### 2. read in and clean data ####
was_data <- read_csv(here("data", "wealth-assets-survey-data.csv"))

# create a variable for age groups
was_data <- was_data %>% 
  pivot_longer(
    cols = "16-24":"65+",
    names_to = "age",
    values_to = "values"
  )

# separate the variables out (total household debt etc.) and fill them in from the `values` column created above
was_data <- was_data %>% 
  pivot_wider(names_from = variable,
              values_from = values)

was_data %<>% clean_names()

#### 3. plot data ####
fig1_2 <- was_data %>% 
  filter(round == "Round 7 (2018-2020)") %>% 
  ggplot(aes(x = age, y = hhold_value_of_savings_accounts)) +
  geom_col(fill = "#000C78") +
  scale_y_continuous(n.breaks = 10) +
  labs(x = "Age",
       y = "") +
  theme_classic()


ggsave(here("figures", "figure1_2.png"), fig1_2)

