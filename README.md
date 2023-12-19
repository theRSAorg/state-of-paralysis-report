# about
This repo contains data and code to recreate figures from the Young People's Future Health & Economic Security report.

The data included here (in the `data` folder) come from the Office for National Statistics (ONS), specifically from the [Annual Survey for Hours and Earning](https://www.ons.gov.uk/employmentandlabourmarket/peopleinwork/earningsandworkinghours/datasets/allemployeesashetable1) and from the [Young adults living with their parents](https://www.ons.gov.uk/peoplepopulationandcommunity/birthsdeathsandmarriages/families/datasets/youngadultslivingwiththeirparents) dataset.
These datasets are included here for convenience only; if you are interested in reusing these data, please refer to the Office for National Statistics website. The links to each of the datasets are provided above.

The raw data (Walth and Assets Survey Rounds 6 and 7 and Family Resources Survey from 2003-2004 to 2021-2022, obtained from the UK Data Service) are not included here as they are not ours to share.

The `R` folder contains the scripts used to clean the data and create the plots used in the report:
- `ashe-exploration.R` contains the code used to calculate wage growth rates
- `frs_exploration.R` contains the code used to create plots 1.4 (housing tenure by age group), 1.5 (housing tenure among 16-24 year olds, 2003-2021) and 1.6 (median percentage of income spent on housing by age group)
- `minimum_wage_scraping.R`
- `was_exploration.R` contains the code used to recreate figure 1.3, which shows the ratio of financial liabilities to income
