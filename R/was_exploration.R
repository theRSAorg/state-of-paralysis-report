rm(list = ls()) # clear the work space
# Packages
packages <- c('readr','dplyr','ggplot2','forcats')
pkg_notinstall <- packages[!(packages %in% installed.packages()[,"Package"])]
lapply(pkg_notinstall, install.packages, dependencies = TRUE)
lapply(packages, library, character.only = TRUE)

# 2018-2020 data
data_1820 <- readr::read_tsv("./data/was_round_7_hhold_eul_march_2022.tab")
# 2016-2018 data - (to merge credit debt by age group)
data_1618 <- readr::read_tsv("./data/was_round_6_hhold_eul_april_2022.tab")

credit_debt <- data %>%
  rename(
    age = HRPDVAge8r7,
    credit_debt = totcsc_persr7_aggr
  ) %>%
  group_by(age) %>%
  summarise(
    mean_credit_debt = mean(credit_debt, na.rm = T)
  )
