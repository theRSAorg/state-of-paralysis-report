rm(list = ls()) # clear the work space
# Packages
packages <- c('here', readr','dplyr','ggplot2','forcats', 'GGally')
pkg_notinstall <- packages[!(packages %in% installed.packages()[,"Package"])]
lapply(pkg_notinstall, install.packages, dependencies = TRUE)
lapply(packages, library, character.only = TRUE)

# 2018-2020 data
data_1820 <- readr::read_tsv("./data/was_round_7_hhold_eul_march_2022.tab") %>% 
  select(id = CASER7,
         age = HRPDVAge8r7,
         credit_debt = totcsc_persr7_aggr) %>% 
  mutate(year = "2018-2020")

# 2016-2018 data - (to merge credit debt by age group)
data_1618 <- readr::read_tsv("./data/was_round_6_hhold_eul_april_2022.tab") %>% 
  select(id = CASER6,
         age = HRPDVAge8R6,
         credit_debt = totcsc_persr6_aggr) %>% 
  mutate(year = "2016-2018")

credit_debt_data <- rbind(data_1820, data_1618) %>% 
  mutate(age = as_factor(age),
         age = fct_recode(age,
                          "16-25" = "2",
                          "25-34" = "3",
                          "35-44" = "4",
                          "45-54" = "5",
                          "55-64" = "6",
                          "65-74" = "7",
                          "75+" = "8"))

plot_data <- credit_debt_data %>%
  group_by(age, year) %>%
  summarise(mean_credit_debt = mean(credit_debt, na.rm = T)) %>%
  ungroup() %>%
  mutate(debt_change = lead(mean_credit_debt) - mean_credit_debt) %>%
  filter(year == "2016-2018") %>%
  drop_na(age)

# bar plot for debt change
debt_chage_barplot <- credit_debt_data %>%
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
debt_connected_dotplot <- credit_debt_data %>%
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

ggsave(here("figures", "1.3_barplot.png"), debt_chage_barplot)
ggsave(here("figures", "1.3_dotplot.png"), debt_connected_dotplot)

