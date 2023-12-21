# Wealth and Assets Survey data exploration

# Authors: Eirini Zormpa & Jolyon Miles-Wilson
# December 2023

#### 1. Load packages ####
packages <- c("here", "readr", "magrittr", "tidyr", "dplyr", "ggplot2", "forcats", "GGally")
pkg_notinstall <- packages[!(packages %in% installed.packages()[, "Package"])]
lapply(pkg_notinstall, install.packages, dependencies = TRUE)
lapply(packages, library, character.only = TRUE)

#### 2. Read in data ####

# household-level data

# NB: the data read in below is not included in the repository
# that is because the data comes from the UK Data Service and
# it is not permitted under their End User Licence to redistribute data
# there is more information in the README file

# 2016-2018 data (Round 6)
data_1618 <- read_tsv(here("data", "was_round_6_hhold_eul_april_2022.tab")) %>%
  # variables were selected by examining the data dictionaries
  select(
    id = CASER6,
    age = HRPDVAge8R6,
    credit_debt = totcsc_persr6_aggr,
    # if the total household income before housing costs was 0 or below, the value of this variable was set to 0
    # if income was over zero then this variable was calculated as:
    # (Hhold value of financial liabilities* (for credit cards including persistent credit card debt only) - hhold value of student loans (from banks and student loan companies)) / total hhold income before housing costs
    # *financial liabilities = credit/store/charge cards + mail orders + Hire Purchase accounts + formal/informal/student loans + overdrawn accounts + arrears
    fin_liab_to_income_ratio = HHdebtIncRatr6,
    YearR6
  ) %>%
  mutate(year = "2016-2018")

# 2018-2020 data (Round 7)
data_1820 <- read_tsv(here("data", "was_round_7_hhold_eul_march_2022.tab")) %>%
  select(
    id = CASER7,
    age = HRPDVAge8r7,
    credit_debt = totcsc_persr7_aggr,
    fin_liab_to_income_ratio = HHdebtIncRatr7,
    yearr7
  ) %>%
  mutate(year = "2018-2020")

# person-level data
data_1618_person <- read_tsv(here("data", "was_round_6_person_eul_april_2022.tab")) %>%
  select(
    id = CASER6,
    age = HRPDVAge8R6
  ) %>%
  mutate(year = "2016-2018")

data_1820_person <- read_tsv(here("data", "was_round_7_person_eul_june_2022.tab")) %>%
  select(
    id = CASER7,
    age = HRPDVAge8r7
  ) %>%
  mutate(year = "2018-2020")

#### 3. Sanity checks ####

# checking that all identifiers are unique, i.e. no respondents are repeated
length(unique(data_1820$id)) == length(data_1820$id)
length(unique(data_1618$id)) == length(data_1618$id)

# checking the years included in the dataset
levels(as.factor(data_1618$YearR6))
levels(as.factor(data_1820$yearr7))

# the years were only needed for the sanity check so I remove them
data_1618 %<>% select(-YearR6)
data_1820 %<>% select(-yearr7)

#### 4. Combine data from years 2016-2018 and 2018-2020 ####
data_1620 <- rbind(data_1820, data_1618) %>%
  mutate(
    age = as_factor(age),
    age = fct_recode(age,
      "16-24" = "2",
      "25-34" = "3",
      "35-44" = "4",
      "45-54" = "5",
      "55-64" = "6",
      "65-74" = "7",
      "75+" = "8"
    )
  )

data_1620_person <- rbind(data_1820_person, data_1618_person) %>%
  mutate(
    age = as_factor(age),
    age = fct_recode(age,
      "16-24" = "2",
      "25-34" = "3",
      "35-44" = "4",
      "45-54" = "5",
      "55-64" = "6",
      "65-74" = "7",
      "75+" = "8"
    )
  )

#### 5. Debt and other stats ####
data_1620 %>%
  group_by(age, year) %>%
  summarise(mean_credit_debt = mean(credit_debt)) %>%
  ungroup() %>%
  mutate(debt_change = lead(mean_credit_debt) / mean_credit_debt) %>%
  filter(year == "2016-2018") %>%
  select(age, debt_change)

# see how many observations come from each group
# household
data_1620 %>%
  group_by(year, age) %>%
  summarise(n = n()) %>%
  ungroup() %>%
  group_by(year) %>%
  mutate(percentage = n / sum(n))

# individual
data_1620_person %>%
  group_by(year, age) %>%
  summarise(n = n()) %>%
  ungroup() %>%
  group_by(year) %>%
  mutate(percentage = n / sum(n))

#### 6. Data visualisation ####

# bar plot for financial-liabilities-to-income ratio
fin_liab_to_income_ratio_dotplot <- data_1620 %>%
  group_by(age, year) %>%
  summarise(mean_fin_liab_to_income_ratio = mean(fin_liab_to_income_ratio, na.rm = T)) %>%
  ungroup() %>%
  mutate(mean_fin_liab_to_income_ratio_2020 = lead(mean_fin_liab_to_income_ratio)) %>%
  filter(year == "2016-2018") %>%
  drop_na(age) %>%
  ggplot() +
  geom_segment(aes(x = age, xend = age, y = mean_fin_liab_to_income_ratio, yend = mean_fin_liab_to_income_ratio_2020), colour = "grey") +
  geom_point(aes(x = age, y = mean_fin_liab_to_income_ratio, colour = "2016-2018"), size = 3) +
  geom_point(aes(x = age, y = mean_fin_liab_to_income_ratio_2020, colour = "2018-2020"), size = 3) +
  scale_y_continuous(n.breaks = 8) +
  coord_flip() +
  labs(
    x = "Age",
    y = "Mean ratio of financial liabilities to income"
  ) +
  theme_classic() +
  scale_colour_manual(
    values = c("#000C7860", "#FFA72F60"),
    guide = guide_legend(),
    name = "Year range"
  ) +
  theme(
    legend.position = "bottom",
    panel.border = element_blank()
  )

# ggsave(here("figures", "1.3_financial_liability_income_ratio_dotplot.png"), fin_liab_to_income_ratio_dotplot)
