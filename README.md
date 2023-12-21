# About
This repository contains data and code to recreate figures and tables used in the RSA's Young People's Future Health & Economic Security report.

The data included in the `data` folder come from the Office for National Statistics (ONS), specifically from the [Annual Survey for Hours and Earning](https://www.ons.gov.uk/employmentandlabourmarket/peopleinwork/earningsandworkinghours/datasets/allemployeesashetable1) and from the [Young adults living with their parents](https://www.ons.gov.uk/peoplepopulationandcommunity/birthsdeathsandmarriages/families/datasets/youngadultslivingwiththeirparents) dataset.
They are included here to make it easier for you to recreate our calculations and plots only; if you are interested in reusing these data for your own purposes, please refer to the Office for National Statistics website.
The links to each of the datasets are provided above.

The raw data (**Wealth and Assets Survey** Rounds 6 and 7 and **Family Resources Survey** from 2003-2004 to 2021-2022, obtained from the UK Data Service) are not included here as that would violate the End User Licence of the UK Data Service.
A complete list of the data we used, along with links and persistent identifiers, can be found in the [`data-table.md`](/data-table.md) file.

## Folder structure
```
+---data
|   |   (data are all downloaded by scripts and could in principle be deleted)
|   |
+---figures
|   |   (figures are all created by the scripts and could in principle be deleted)
|   |
+---Python
|   |   income.html (the content of the Jyputer notebook below in a format that's easy to view on an Internet browser)
|   |   income.ipynb (Jupyter notebook using Annual Survey for Hours and Earning data to explore wages for young people)
|   |
+---R
|       ashe-exploration.R (script using Annual Survey for Hours and Earning data to explore wage growth rates by age group)
|       frs_exploration.R (script using Family Resources Survey data to explore questions around housing for young people)
|       minimum_wage_scraping.R ([Jolyon to fill in])
|       was_exploration.R  (script using Wealth and Assets Survey data to explore questions around debt and financial liabilities for young people)
|
\---tables
        wage_growth_2016-2023.docx ([Jolyon to fill in])
```
