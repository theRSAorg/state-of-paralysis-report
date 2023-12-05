# YPFHES report - new graphs
# Author: Eirini Zormpa
# Date: 4 December 2023

#### 1. install and load packages ####

# if you don't have any of the following packages installed, select the command only and run it to install

# install.packages("here")
# install.packages("readr")
# install.packages("janitor")
# install.packages("tidyr")
# install.packages("dplyr)
# install.packages("forcats")
# install.packages("ggplot2")

# for avoiding confusion with paths
library(here)
# for reading in all sorts of data files and cleaning their names
library(readr)
library(janitor)
# for tidying data
library(tidyr)
library(dplyr)
# for working with factors
library(forcats)
# for making pretty plots
library(ggplot2)

# create the RSA palette
rsa_palette <- c("#03ECDD",
                 "#000000",
                 "#FFFFFF",
                 "#FF21B8",
                 "#000C78",
                 "#FFA72F",
                 "#FF2800")

#### 2. read in and clean data ####
was_data <- read_delim(here("data", "was_round_7_hhold_eul_march_2022.tab"))

savings_data <- was_data %>% 
  select(CASER7, age = HRPDVAge8r7, savings = DVSaValR7_aggr) %>% 
  mutate(age = as_factor(age),
         age = fct_recode(age,
           "16-25" = "2",
           "25-34" = "3",
           "35-44" = "4",
           "45-54" = "5",
           "55-64" = "6",
           "65-74" = "7",
           "75+" = "8"
         ))

#### 3. plot data ####
# y-axis breaks every 5k
fig1.2_a <- savings_data %>% 
  group_by(age) %>%
  summarise(mean_savings = mean(savings)) %>% 
  ggplot(aes(x = age, y = mean_savings)) +
  geom_col(fill = "#000C78") +
  scale_y_continuous(n.breaks = 10) +
  labs(x = "Age",
       y = "") +
  theme_classic()

# y-axis breaks every 2.5k
fig1.2_b <- savings_data %>% 
  group_by(age) %>%
  summarise(mean_savings = mean(savings)) %>% 
  ggplot(aes(x = age, y = mean_savings)) +
  geom_col(fill = "#000C78") +
  scale_y_continuous(n.breaks = 15) +
  labs(x = "Age",
       y = "") +
  theme_classic()

ggsave(here("figures", "figure1_2_10.png"), fig1.2_a)
ggsave(here("figures", "figure1_2_15.png"), fig1.2_b)
