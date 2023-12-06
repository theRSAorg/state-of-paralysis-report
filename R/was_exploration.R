rm(list = ls()) # clear the work space
# Packages
packages <- c('here', 'readr','dplyr','ggplot2','forcats', 'GGally')
pkg_notinstall <- packages[!(packages %in% installed.packages()[,"Package"])]
lapply(pkg_notinstall, install.packages, dependencies = TRUE)
lapply(packages, library, character.only = TRUE)

# 2018-2020 data
data_1820 <- readr::read_tsv("./data/was_round_7_hhold_eul_march_2022.tab") %>% 
  select(id = CASER7,
         #yearr7,
         age = HRPDVAge8r7,
         credit_debt = totcsc_persr7_aggr,
         debt_to_income_ratio = HHdebtIncRatr7) %>% 
  mutate(year = "2018-2020")

# sanity checks

# checking that all identifiers are unique, i.e. no respondents are repeated
length(unique(data_1820$id)) == length(data_1820$id)

# checking the years included in the dataset
#levels(as.factor(data_1820$yearr7))

# 2016-2018 data
data_1618 <- readr::read_tsv("./data/was_round_6_hhold_eul_april_2022.tab") %>% 
  select(id = CASER6,
         #YearR6,
         age = HRPDVAge8R6,
         credit_debt = totcsc_persr6_aggr,
         debt_to_income_ratio = HHdebtIncRatr6) %>% 
  mutate(year = "2016-2018")

# checking that all identifiers are unique, i.e. no respondents are repeated
length(unique(data_1618$id)) == length(data_1618$id)

# checking the years included in the dataset
#levels(as.factor(data_1618$YearR6))

# combine the datasets from years 2016-2018 and 2018-2020
data_1620 <- rbind(data_1820, data_1618) %>% 
  mutate(age = as_factor(age),
         age = fct_recode(age,
                          "16-25" = "2",
                          "25-34" = "3",
                          "35-44" = "4",
                          "45-54" = "5",
                          "55-64" = "6",
                          "65-74" = "7",
                          "75+" = "8"))

# bar plot for debt change
debt_chage_barplot <- data_1620 %>%
  group_by(age, year) %>%
  summarise(mean_credit_debt = mean(credit_debt, na.rm = T)) %>%
  ungroup() %>%
  mutate(debt_change = lead(mean_credit_debt) - mean_credit_debt) %>%
  filter(year == "2016-2018") %>%
  drop_na(age) %>% 
  ggplot(aes(x = age, y = debt_change)) +
  geom_col(fill = "#000C78") +
  scale_y_continuous(n.breaks = 10) +
  labs(x = "Age",
       y = "") +
  theme_classic()

# connected dot plot for debt
debt_connected_dotplot <- data_1620 %>%
  group_by(age, year) %>%
  summarise(mean_credit_debt = mean(credit_debt, na.rm = T)) %>%
  ungroup() %>%
  mutate(mean_credit_debt_2020 = lead(mean_credit_debt)) %>%
  filter(year == "2016-2018") %>%
  drop_na(age) %>%
  ggplot() +
    geom_segment( aes(x=age, xend=age, y=mean_credit_debt, yend=mean_credit_debt_2020), color="grey") +
    geom_point( aes(x=age, y=mean_credit_debt), color="#000000", size=2 ) +
    geom_point( aes(x=age, y=mean_credit_debt_2020), color="#03ECDD", size=2 ) +
    coord_flip() +
    labs(x = "Age",
         y = "Mean credit card debt") +
    theme_classic()

# ggsave(here("figures", "1.3_debt_barplot.png"), debt_chage_barplot)
# ggsave(here("figures", "1.3_debt_dotplot.png"), debt_connected_dotplot)

# bar plot for debt-to-income ratio
debt_to_income_ratio_dotplot <- data_1620 %>%
  group_by(age, year) %>%
  summarise(mean_debt_to_income_ratio = mean(debt_to_income_ratio, na.rm = T)) %>%
  ungroup() %>%
  mutate(mean_debt_to_income_ratio_2020 = lead(mean_debt_to_income_ratio)) %>%
  filter(year == "2016-2018") %>%
  drop_na(age) %>%
  ggplot() +
  geom_segment( aes(x=age, xend=age, y=mean_debt_to_income_ratio, yend=mean_debt_to_income_ratio_2020), color="grey") +
  geom_point( aes(x=age, y=mean_debt_to_income_ratio), color="#000000", size=2 ) +
  geom_point( aes(x=age, y=mean_debt_to_income_ratio_2020), color="#03ECDD", size=2 ) +
  coord_flip() +
  labs(x = "Age",
       y = "Mean debt-to-income ratio") +
  theme_classic()

# ggsave(here("figures", "1.3_debt_income_ratio_dotplot.png"), debt_to_income_ratio_dotplot)
