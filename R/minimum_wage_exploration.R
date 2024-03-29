# Minimum wage exploration
# Author: Jolyon Miles-Wilson
# Date: December 2023

# Scrapes data from https://www.nibusinessinfo.co.uk/content/national-minimum-wage-previous-rates 
# (which is validated against a government source: https://researchbriefings.files.parliament.uk/documents/CBP-7735/CBP-7735.pdf)
# to explore trends in minimum wage provision from 1999 to 2023.
# Creates figures 1.2 and 1.3 of the report, as well as table 1.1

rm(list = ls()) # clear the workspace

# Packages
packages <- c("rvest", "dplyr", "tibble", "tidyr", "extrafont", "ggplot2", "lubridate", "readr", "stringr", "knitr", "kableExtra", "apaTables")
pkg_notinstall <- packages[!(packages %in% installed.packages()[, "Package"])]
lapply(pkg_notinstall, install.packages, dependencies = TRUE)
lapply(packages, library, character.only = TRUE)

# if you have never used the extrafont package before
# you will need to import the fonts first
# this could take a few minutes, depending on how many you have installed

# font_import()

rsa_palette <- c(
  "#03ECDD",
  "#000000",
  "#FF21B8",
  "#000C78",
  "#FFA72F",
  "#FF2800",
  "#373737",
  "#21DCFF"
)

# Define the URL
# this source has been cross-validated with house of commons report:
# https://researchbriefings.files.parliament.uk/documents/CBP-7735/CBP-7735.pdf
url <- "https://www.nibusinessinfo.co.uk/content/national-minimum-wage-previous-rates"

# Read the HTML content of the page

page <- read_html(url)

# Extract the tables from the page

tables <- html_nodes(page, "table")

# Convert the tables to a list of data frames

table_list <- lapply(
  tables,
  function
  (x) {
    html_table(x, fill = TRUE)
  }
)

# Combine all tables into a single tibble
table_1 <- table_list[[1]]
table_2 <- table_list[[2]]

################################################################################
### Pre 2016 rates #############################################################
################################################################################
pre_nlw_rates <- table_1[-which(table_1$Date == ""), ]

# Apply apprentice colname
colnames(pre_nlw_rates) <- c(colnames(pre_nlw_rates)[1:4], "Apprentice")

# Get the national living wage rates (i.e., 2016 onwards)
pre_nlw_rates <- pre_nlw_rates %>%
  # strip £ sign for all groups
  mutate(across(.col = 2:ncol(.), function(x) as.numeric(substring(x, 2, nchar(x))))) %>%
  rename(
    Year = Date
  )

pre_nlw_rates_long <- pre_nlw_rates %>%
  pivot_longer(!"Year",
    names_to = "Age",
    values_to = "Wage"
  )

# calculate each non-main rate as a proportion of the main rate
pre_nlw_rates_prop_long <- pre_nlw_rates %>%
  # get proprotion for all groups
  mutate(across(.col = 2:ncol(pre_nlw_rates), function(x) 100 * (x / `Main Rate (Age 22+)`))) %>%
  pivot_longer(!"Year",
    names_to = "Age",
    values_to = "Wage proportion"
  )

all_pre_nlw_rates <- merge(pre_nlw_rates_long, pre_nlw_rates_prop_long, by = c("Year", "Age")) %>%
  mutate(
    Year = lubridate::dmy(Year)
  ) %>%
  mutate(
    # reorder levels
    Age = forcats::fct_relevel(
      Age,
      "Apprentice",
      "Age 16-17 Rate",
      "Youth Development Rate (Age 18-21)",
      "Main Rate (Age 22+)"
    ),
    # then recode levels of age to show changes in groups
    Age = forcats::fct_recode(Age,
      `16 to 17` = "Age 16-17 Rate",
      `18 to 21 (1999-2009); \n18 to 20 (2010 on)` = "Youth Development Rate (Age 18-21)",
      `'Main rate': \n22+ (1999-2009); \n21+ (2010-2015)` = "Main Rate (Age 22+)"
    )
  )



################################################################################
### Post 2016 rates ############################################################
################################################################################

nlw_rates <- table_2[-which(table_2$Year == "Year"), ]

# add 2023 data
# from: https://www.gov.uk/government/publications/the-national-minimum-wage-in-2023/the-national-minimum-wage-in-2023
new_data <- c("1 Apr 2023", "£10.42", "£10.18", "£7.49", "£5.28", "£5.28")
nlw_rates <- rbind(nlw_rates, new_data)

# Get the national living wage rates (i.e., 2016 onwards)
nlw_rates <- nlw_rates %>%
  # strip £ sign for all groups
  mutate(across(.col = 2:ncol(.), function(x) as.numeric(substring(x, 2, nchar(x)))))

nlw_rates_long <- nlw_rates %>%
  pivot_longer(
    cols = 2:6,
    names_to = "Age",
    values_to = "Wage"
  )

# calculate each non-main rate as a proportion of the main rate
nlw_rates_prop_long <- nlw_rates %>%
  # get proprotion for all groups
  mutate(across(.col = 2:ncol(nlw_rates), function(x) 100 * (x / `25 and over`))) %>%
  pivot_longer(!"Year",
    names_to = "Age",
    values_to = "Wage proportion"
  )

all_nlw_rates <- merge(nlw_rates_long, nlw_rates_prop_long, by = c("Year", "Age")) %>%
  mutate(
    Year = lubridate::dmy(Year)
  ) %>%
  mutate(
    # reorder levels
    Age = forcats::fct_relevel(
      Age,
      "Apprentice",
      "Under 18",
      "18 to 20",
      "21 to 24",
      "25 and over"
    ),
    # then recode levels of age to show changes in groups
    Age = forcats::fct_recode(Age,
      `16 to 17` = "Under 18",
      `21 to 24 (2016-2020); \n21 to 22 (2021 on)` = "21 to 24",
      `National Living Wage: \n25+ (2016-2020); \n23+ (2021 on)` = "25 and over"
    )
  )


################################################################################
######### Combine all wage data ################################################
################################################################################

all_nlw_rates_edit <- all_nlw_rates %>%
  mutate(
    Age = forcats::fct_recode(Age,
      `18 to 21 (1999-2009); \n18 to 20 (2010 on)` = "18 to 20"
    )
  )

all_wage_data <- rbind(all_pre_nlw_rates, all_nlw_rates_edit) %>%
  mutate(
    Age = forcats::fct_relevel(
      Age,
      "Apprentice",
      "16 to 17",
      "18 to 21 (1999-2009); \n18 to 20 (2010 on)",
      "21 to 24 (2016-2020); \n21 to 22 (2021 on)",
      "'Main rate': \n22+ (1999-2009); \n21+ (2010-2015)",
      "National Living Wage: \n25+ (2016-2020); \n23+ (2021 on)"
    )
  )

# define coords to be used for joining main rate lines
line_coords <- data.frame(x = c(lubridate::ymd("2015-10-01"), lubridate::ymd("2016-04-01")),
                          y = c(all_wage_data$Wage[which(all_wage_data$Year == lubridate::ymd("2015-10-01")
                                                         & all_wage_data$Age == "'Main rate': \n22+ (1999-2009); \n21+ (2010-2015)")],
                                all_wage_data$Wage[which(all_wage_data$Year == lubridate::ymd("2016-04-01")
                                                         & all_wage_data$Age == "National Living Wage: \n25+ (2016-2020); \n23+ (2021 on)")]))

all_wage_data %>%
  mutate(Age = forcats::fct_recode(Age,
                                   "16-17" = "16 to 17",
                                   "18-21 (1999-2009); \n18-20 (2010 on)" = "18 to 21 (1999-2009); \n18 to 20 (2010 on)",
                                   "21-24 (2016-20); \n21-22 (2021 on)" = "21 to 24 (2016-2020); \n21 to 22 (2021 on)",
                                   "'Main rate': \n22+ (1999-2009); \n21+ (2010-15)"= "'Main rate': \n22+ (1999-2009); \n21+ (2010-2015)",
                                   "National Living Wage: \n25+ (2016-20); \n23+ (2021 on)" = "National Living Wage: \n25+ (2016-2020); \n23+ (2021 on)")) %>% 
  ggplot2::ggplot(., aes(Year, Wage, colour = Age)) +
  geom_vline(xintercept = lubridate::ymd("2010-10-01"), linetype = "dashed") +
  geom_vline(xintercept = lubridate::ymd("2016-04-01"), linetype = "dashed") +
  geom_vline(xintercept = lubridate::ymd("2021-04-01"), linetype = "dashed") +
  geom_segment(aes(x = line_coords$x[1], xend = line_coords$x[2],
                   y = line_coords$y[1], yend = line_coords$y[2]), 
               lty = "11",
               size = 0.5) +
  geom_point() +
  geom_line() +
  theme_bw() +
  # change legend text sizes and spacing between levels
  theme(legend.title = element_text(size = 15),
        legend.text = element_text(size = 13),
        legend.key.size = unit(2,'cm')) + 
  scale_colour_manual(values = rsa_palette, name = "Age group") +
  scale_x_date(date_breaks = "1 year", date_labels = "%Y") +
  scale_y_continuous(breaks = seq(3, 11, 1)) + 
  ylab("Wage (£)") +
  theme(text = element_text(family="Gill Sans MT"))

# save plot
# ggsave(filename = "./figures/1.2_minimum_wage_1999-2023.png", width = 12, height = 7)

all_wage_data %>%
  filter(
    !(stringr::str_detect(Age, "^National")) &
      !(stringr::str_detect(Age, "^'Main"))
  ) %>% 
  mutate(Age = forcats::fct_recode(Age,
                                   "16-17" = "16 to 17",
                                   "18-21 (1999-2009); \n18-20 (2010 on)" = "18 to 21 (1999-2009); \n18 to 20 (2010 on)",
                                   "21-24 (2016-20); \n21-22 (2021 on)"= "21 to 24 (2016-2020); \n21 to 22 (2021 on)")) %>%
  ggplot2::ggplot(., aes(Year, `Wage proportion`, colour = Age)) +
  geom_vline(xintercept = lubridate::ymd("2010-10-01"), linetype = "dashed") +
  geom_vline(xintercept = lubridate::ymd("2016-04-01"), linetype = "dashed") +
  geom_vline(xintercept = lubridate::ymd("2021-04-01"), linetype = "dashed") +
  geom_text(x = lubridate::ymd("1999-01-01"), y = 105, hjust = 0, label = "Adult group = 'Main rate' (22+)", family = "Gill Sans MT", show.legend = FALSE) +
  geom_text(x = lubridate::ymd("2011-01-01"), y = 105, hjust = 0, label = "Adult group = \n'Main rate' (21+)", family = "Gill Sans MT", show.legend = FALSE) +
  geom_text(x = lubridate::ymd("2016-06-01"), y = 105, hjust = 0, label = "Adult group = \nNLW (25+)", family = "Gill Sans MT", show.legend = FALSE) +
  geom_text(x = lubridate::ymd("2021-06-01"), y = 105, hjust = 0, label = "Adult group = \nNLW (23+)", family = "Gill Sans MT", show.legend = FALSE) +
  geom_point() +
  geom_line() +
  theme_bw() +
  # change legend text sizes and spacing between levels
  theme(legend.title = element_text(size = 15),
        legend.text = element_text(size = 13),
        legend.key.size = unit(1.5,'cm')) + 
  scale_colour_manual(values = rsa_palette, name = "Age group") +
  scale_x_date(date_breaks = "1 year", date_labels = "%Y") +
  scale_y_continuous(breaks = seq(40, 100, 10)) +
  coord_cartesian(
    ylim = c(40, 105),
    xlim = c(
      lubridate::ymd("1999-01-01"),
      lubridate::ymd("2023-04-01")
    )
  ) +
  ylab("Proprorion of adult rate (%)") +
  theme(text = element_text(family="Gill Sans MT"))

# save plot
# ggsave(filename = "./figures/1.3_minimum_wage_proportion_1999-2023.png", width = 12, height = 7)

################################################################################

################################################################################
#### Calculate growth since 2016 for each group ################################
################################################################################

# calculate growth from 2016 (first row) to 2023 (last row)
growth <- nlw_rates %>%
  summarise(
    across(2:6, function(x) growth <- round(100 * ((x[9] / x[1]) - 1), 2))
  ) %>%
  add_column(Year = "", .before = 1) # add empty column for subsequent binding

ages <- colnames(nlw_rates)[-1] # get age groups to add as new column subsequently
growth_table <- nlw_rates[c(1, nrow(nlw_rates)), ] %>% # just first and last tows
  rbind(., growth) %>%
  t() %>% # transpose
  as_tibble()

# make colnames from first row, plus growth
colnames(growth_table) <- c(growth_table[1, 1:2], "Growth")
growth_table <- growth_table[-1, ] # drop first row
growth_table <- growth_table %>%
  mutate_all(function(x) as.numeric(x)) %>%
  mutate(
    Age = ages, .before = 1 # add in the ages column
  )

# save table in a word doc
# growth_table %>%
#   flextable::flextable() %>%
#   flextable::save_as_docx(path = "./tables/wage_growth_2016-2023.docx")

# week's wages
weeks_wages <- growth_table %>%
  select(-"Growth") %>%
  mutate_if(is.numeric, function(x) round(x * 37.5, 2)) %>%
  mutate(
    Increase = .[[3]] - .[[2]]
  )

################################################################################
# Wider format for exporting tables #
################################################################################

# nlw_rates_wide <- nlw_rates %>%
#   pivot_wider(names_from = Year,
#               values_from = c(Wage, `Wage proportion`))

pre_nlw_rates <- table_1[-which(table_1$Date == ""), ]

# Apply apprentice colname
colnames(pre_nlw_rates) <- c(colnames(pre_nlw_rates)[1:4], "Apprentice")

# Get the national living wage rates (i.e., 2016 onwards)
pre_nlw_rates <- pre_nlw_rates %>%
  # strip £ sign for all groups
  mutate(across(.col = 2:ncol(.), function(x) as.numeric(substring(x, 2, nchar(x))))) %>%
  mutate(across(.col = 2:ncol(pre_nlw_rates), list(wage_proportion = function(x) 100 * (x / `Main Rate (Age 22+)`)))) %>%
  mutate(across(contains("proportion"), function(x) round(x, 2)))

# save to csv and do table manually
# ideally should do table programmatically
# readr::write_csv(pre_nlw_rates, file = "./data/wage_proportions_1999-2016.csv")

nlw_rates <- table_2[-which(table_2$Year == "Year"), ]

# Get the national living wage rates (i.e., 2016 onwards)
nlw_rates <- nlw_rates %>%
  # strip £ sign for all groups
  mutate(across(.col = 2:ncol(.), function(x) as.numeric(substring(x, 2, nchar(x))))) %>%
  mutate(across(.col = 2:ncol(nlw_rates), list(wage_proportion = function(x) 100 * (x / `25 and over`)))) %>%
  mutate(across(contains("proportion"), function(x) round(x, 2)))

# readr::write_csv(nlw_rates, file = "./data/wage_proportions_1999-2016.csv")
