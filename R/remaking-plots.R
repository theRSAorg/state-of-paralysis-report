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
           "16-24" = "2",
           "25-34" = "3",
           "35-44" = "4",
           "45-54" = "5",
           "55-64" = "6",
           "65-74" = "7",
           "75+" = "8"
         ))

# explore savings by age group
savings_data %>% 
  group_by(age) %>%
  summarise(mean_savings = mean(savings),
            median_savings = median(savings),
            min_savings = min(savings),
            max_savings = max(savings))

savings_data %>% 
  filter(age == "16-24") %>% 
  summary()

# create bins for savings amounts in the 16-24 group
plot1.2_data <- savings_data %>%
  filter(age == "16-24") %>%
  mutate(
    saving_bins = case_when(
      savings <= 500 ~ "<500",
      savings > 500 & savings <= 1000 ~ "501-1000",
      savings > 1000 & savings <= 1500 ~ "1001-1500",
      savings > 1500 & savings <= 2000 ~ "1501-2000",
      savings > 2000 ~ ">2000")) %>% 
  count(saving_bins) %>%
  mutate(percentage = n/sum(n))

#### 3. plot data ####
# recreate original plot
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

# fig1.2_new
plot1.2_data %>%
  mutate(saving_bins = fct_relevel(saving_bins, "<500", "501-1000", "1001-1500", "1501-2000", ">2000")) %>% 
  ggplot(aes(x = saving_bins, y = percentage)) +
  geom_col(fill = "#000C78") +
  labs(x = "Median savings",
       y = "%") +
  theme_classic()
  
  
  
# ggsave(here("figures", "figure1_2_10.png"), fig1.2_a)
# ggsave(here("figures", "figure1_2_15.png"), fig1.2_b)
