rm(list = ls()) # clear the workspace

# Packages
packages <- c('rvest','dplyr','tibble','tidyr','ggplot2','lubridate','readr')
pkg_notinstall <- packages[!(packages %in% installed.packages()[,"Package"])]
lapply(pkg_notinstall, install.packages, dependencies = TRUE)
lapply(packages, library, character.only = TRUE)

rsa_palette <- c("#03ECDD",
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

table_list <- lapply(tables, 
                     function
                     (x) html_table(x, fill = TRUE))

# Combine all tables into a single tibble
table_1 <- table_list[[1]]
table_2 <- table_list[[2]]

################################################################################
### Pre 2016 rates #############################################################
################################################################################
pre_nlw_rates <- table_1[-which(table_1$Date == ""),]

# Apply apprentice colname
colnames(pre_nlw_rates) <- c(colnames(pre_nlw_rates)[1:4],"Apprentice")

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
               values_to = "Wage")

# calculate each non-main rate as a proportion of the main rate
pre_nlw_rates_prop_long <- pre_nlw_rates %>%
  # get proprotion for all groups
  mutate(across(.col = 2:ncol(pre_nlw_rates), function(x) 100 * (x / `Main Rate (Age 22+)`))) %>%
  pivot_longer(!"Year", 
               names_to = "Age",
               values_to = "Wage proportion"
  )

pre_nlw_rates <- merge(pre_nlw_rates_long, pre_nlw_rates_prop_long, by = c("Year", "Age")) %>%
  mutate(
    Year = lubridate::dmy(Year)
  )

pre_nlw_rates %>%
  subset(Age != "Main Rate (Age 22+)") %>%
  ggplot2::ggplot(., aes(Year, `Wage proportion`, colour = Age)) +
  geom_point() + 
  geom_line() +
  theme_bw() +
  scale_colour_manual(values = rsa_palette, name = "Group") +
  scale_x_date(date_breaks = "1 year", date_labels = "%Y") +
  # scale_y_continuous(breaks = seq(0,10,1)) +
  ylab("Proprotion of Main Rate (%)")

################################################################################


######################
### Post 2016 rates ###
######################

nlw_rates <- table_2[-which(table_2$Year == "Year"), ]

# Get the national living wage rates (i.e., 2016 onwards)
nlw_rates <- nlw_rates %>%
  # strip £ sign for all groups
  mutate(across(.col = 2:ncol(.), function(x) as.numeric(substring(x, 2, nchar(x))))) 

nlw_rates_long <- nlw_rates %>%
  pivot_longer(cols = 2:6,
               names_to = "Age",
               values_to = "Wage")

# calculate each non-main rate as a proportion of the main rate
nlw_rates_prop_long <- nlw_rates %>%
  # get proprotion for all groups
  mutate(across(.col = 2:ncol(nlw_rates),function(x) 100 * (x / `25 and over`))) %>%
  pivot_longer(!"Year", 
               names_to = "Age",
               values_to = "Wage proportion"
  )
  
nlw_rates <- merge(nlw_rates_long, nlw_rates_prop_long, by = c("Year", "Age")) %>%
  mutate(
    Year = lubridate::dmy(Year)
  )

nlw_rates %>%
  subset(Age != "25 and over") %>%
  ggplot2::ggplot(., aes(Year, `Wage proportion`, colour = Age)) +
  geom_point() + 
  geom_line() +
  theme_bw() +
  scale_colour_manual(values = rsa_palette, name = "Group") +
  scale_x_date(date_breaks = "1 year", date_labels = "%Y") +
  # scale_y_continuous(breaks = seq(0,10,1)) +
  ylab("Wage (£)")

################################################################################

################################################################################
#### Plotting post-2016 data separately for pre and post 2021 ##################
################################################################################

# Separate out pre and post change to categories in 2021
nlw_rates_1 <- nlw_rates[1:which(nlw_rates$Year == "Year")-1,]

# get the new names to apply to table 2 and apply them to table 2
nlw_2_names <- nlw_rates[which(nlw_rates$Year == "Year"),] 
nlw_rates_2 <- nlw_rates[(which(nlw_rates$Year == "Year")+1):nrow(nlw_rates),]
colnames(nlw_rates_2) <- nlw_2_names 

# Pivot longer for plotting
nlw_rates_1 <- nlw_rates_1 %>%
  tidyr::pivot_longer(cols = !"Year",
    names_to = "age",
    values_to = "wage"
  ) %>%
  mutate(
    Year = lubridate::dmy(Year), # make date format
    wage = as.numeric(substring(wage, 2, nchar(wage))), # strip £ sign
    NLW = "Pre-2021" # create the pre-post grouping
  )

# Pivot longer
nlw_rates_2 <- nlw_rates_2 %>%
  tidyr::pivot_longer(cols = !"Year",
                      names_to = "age",
                      values_to = "wage"
  ) %>%
  mutate(
    Year = lubridate::dmy(Year),
    wage = as.numeric(substring(wage, 2, nchar(wage))), # drop £ symbol and convert
    NLW = "2021 onwards"
  )

# Create tidier factors
nlw_combined <- bind_rows(nlw_rates_1, nlw_rates_2) %>%
  mutate(
    NLW = factor(NLW, levels = c("Pre-2021","2021 onwards")),
    age = factor(age, levels = c("Apprentice", 
                                 "Under 18", "16 to 17",
                                 "18 to 20",
                                 "21 to 24", "21 to 22",
                                 "25 and over","23 and over"))
  )

ggplot2::ggplot(data = nlw_combined, aes(Year, wage, colour = age, linetype = NLW)) +
  geom_point() + 
  geom_line() +
  theme_bw() +
  scale_colour_manual(values = rsa_palette, name = "Group") +
  scale_x_date(date_breaks = "1 year", date_labels = "%Y") +
  scale_y_continuous(breaks = seq(0,10,1)) +
  ylab("Wage (£)")

################################################################################

################################################################################
# Back to wider format for NLW #
################################################################################

# nlw_rates_wide <- nlw_rates %>%
#   pivot_wider(names_from = Year,
#               values_from = c(Wage, `Wage proportion`))

nlw_rates <- table_2[-which(table_2$Year == "Year"), ]

# Get the national living wage rates (i.e., 2016 onwards)
nlw_rates <- nlw_rates %>%
  # strip £ sign for all groups
  mutate(across(.col = 2:ncol(.), function(x) as.numeric(substring(x, 2, nchar(x))))) %>%
  mutate(across(.col = 2:ncol(nlw_rates), list(wage_proportion = function(x) 100 * (x / `25 and over`)))) %>%
  mutate(across(contains("proportion"), function(x) round(x, 2)))

# save to csv and do table manually
# ideally should do table programmatically 
readr::write_csv(nlw_rates, file = "./data/wage_proportions_2016-2021.csv")
         