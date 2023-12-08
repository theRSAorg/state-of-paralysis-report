# 04/12/23
# For tracking down data files and trying to replicate plots in document

rm(list = ls()) # clear the workspace
# Packages
packages <- c('haven','dplyr','ggplot2','forcats')
pkg_notinstall <- packages[!(packages %in% installed.packages()[,"Package"])]
lapply(pkg_notinstall, install.packages, dependencies = TRUE)
lapply(packages, library, character.only = TRUE)

rsa_palette <- c("#03ECDD",
                 "#000000",
                 
                 "#FF21B8",
                 "#000C78",
                 "#FFA72F",
                 "#FF2800")

rsa_extra_palette <- c("#F5F5F5",
                       "#FFFFFF",
                       "#373737",
                    "#21DCFF")

data <- haven::read_sav("./data/househol.sav")
  
dplyr::glimpse(data)

# Summarise tenure by age group
tenure_tab <- data %>%
  mutate(
    # apply labels and create better names
    age = haven::as_factor(HHAGEGR3),
    tenure = as_factor(PTENTYP2)
  ) %>%
  mutate(
    # collapse tenure to match original doc
    tenure = forcats::fct_collapse(tenure,
                                   "Mortgage" = "Owned with mortgage",
                                   "Own outright" = "Owned outright",
                                   "Private rent" = c("Rented privately unfurnished",
                                                      "Rented privately furnished"),
                                   "Social rent" = c("Rented from Council",
                                                     "Rented from Housing Association")),
    # match level order to original doc
    tenure = factor(tenure, 
                      levels =  c("Mortgage",
                      "Own outright",
                      "Private rent",
                      "Social rent")
      )
    ) %>%
  # summarise etc
  group_by(age, tenure) %>%
  summarise(
    n = n()
  ) %>%
  mutate(
    percentage = 100 * (n / sum(n))
  )

# plot
ggplot2::ggplot(tenure_tab, aes(age, percentage, fill = tenure, group = tenure)) +
  geom_col(position = "dodge", colour = "black") +
  theme_bw() +
  scale_fill_manual(values = rsa_palette, name = "Tenure") +
  ylab("Percentage") + xlab("Age group") 

# ggsave(filename = "./figures/figure1_4_housing_tenure_2021-22.png")
