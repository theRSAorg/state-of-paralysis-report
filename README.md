[![All Contributors](https://img.shields.io/github/all-contributors/theRSAorg/economic_security?color=ee8449&style=flat-square)](#contributors)
[![CC BY-NC-SA 4.0][cc-by-nc-sa-shield]][cc-by-nc-sa]

# About
This repository contains data and code to recreate figures and tables used in the RSA's Young People's Future Health & Economic Security report.

The data included in the `data` folder come from the Office for National Statistics (ONS), specifically from the [Annual Survey for Hours and Earning](https://www.ons.gov.uk/employmentandlabourmarket/peopleinwork/earningsandworkinghours/datasets/allemployeesashetable1) and from the [Young adults living with their parents](https://www.ons.gov.uk/peoplepopulationandcommunity/birthsdeathsandmarriages/families/datasets/youngadultslivingwiththeirparents) dataset.
They are included here to make it easier for you to recreate our calculations and plots only; if you are interested in reusing these data for your own purposes, please refer to the Office for National Statistics website.
The links to each of the datasets are provided above.

The raw data (**Wealth and Assets Survey** Rounds 6 and 7 and **Family Resources Survey** from 2003-2004 to 2021-2022, obtained from the UK Data Service) are not included here as that would violate the End User Licence of the UK Data Service.
For ease of replication of the scripts using these data, users are encouraged to acquire the tab-delimited file versions from the UK Data Service and include it in their project repo.

A complete list of the data we used, along with links and persistent identifiers, can be found in the [`data-table.md`](/data-table.md) file.

## Folder structure
```
+---data
|   |   (data currently included in the repo are all downloaded by scripts and could in principle be deleted; see below for restricted data)
|   |
+---figures
|   |   (figures are all created by the scripts and could in principle be deleted)
|   |
+---Python
|   |   income.html (the content of the Jyputer notebook below in a format that's easy to view on an Internet browser)
|   |   income.ipynb (Jupyter notebook using Annual Survey for Hours and Earning data to explore wages for young people)
|   |
+---R
|   |   ashe-exploration.R (script using Annual Survey for Hours and Earning data to explore wage growth rates by age group)
|   |   frs_exploration.R (script using Family Resources Survey data to explore questions around housing for young people)
|   |   minimum_wage_scraping.R (Scrapes data from https://www.nibusinessinfo.co.uk/content/national-minimum-wage-previous-rates
|   |           [which is validated against a government source: https://researchbriefings.files.parliament.uk/documents/CBP-7735/CBP-7735.pdf]
|   |           to explore trends in minimum wage provision from 1999 to 2023.)
|   |   was_exploration.R  (script using Wealth and Assets Survey data to explore questions around debt and financial liabilities for young people)
|   |
\---tables
        wage_growth_2016-2023.docx ([Jolyon to fill in])
```

### Restricted data

To get **Family Resources Survey data**:
1. Download the `TAB` folder specified in the [`data-table.md`](/data-table.md) file from the UK Data Service.
2. Extract the downloaded `.zip` folder.
3. Rename the extracted folder from the long alphanumeric string to FRS_20xx-20xx (e.g. `FRS_2003-2004`).
4. Do this for all specified years.
5. Create a folder called `frs-survey` and place it within the existing `data` folder.
6. Move all renamed folders into the `frs-survey` folder.

To get **Wealth and Assets Survey data**:
1. Download the `TAB` folders for the years listed in the [`data-table.md`](/data-table.md) file from the UK Data Service.
2. Extract the downloaded `.zip` folder.
3. Copy the folder named `UKDA-7215-tab` into the existing `data` folder.

-----------------------------------------------------------------------------

In the end, you should have something like this:

```
> economic_security
+---data
|   |   frs-survey
|   |   |   |    FRS_2003-2004
|   |   |   |   |   |    UKDA-xxxx-tab
|   |   |   |    FRS_2004-2005
|   |   |   |   |   |    UKDA-xxxx-tab
|   |   |   |    etc.
|   |   UKDA-7215-tab
```

## Contributors

<!-- ALL-CONTRIBUTORS-LIST:START - Do not remove or modify this section -->
<!-- prettier-ignore-start -->
<!-- markdownlint-disable -->
<table>
  <tbody>
    <tr>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/eirini-zormpa"><img src="https://avatars.githubusercontent.com/u/30151074?v=4?s=100" width="100px;" alt="Eirini Zormpa"/><br /><sub><b>Eirini Zormpa</b></sub></a><br /><a href="#doc-eirini-zormpa" title="Documentation">📖</a> <a href="#code-eirini-zormpa" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/JolyonJoseph"><img src="https://avatars.githubusercontent.com/u/86312793?v=4?s=100" width="100px;" alt="Jolyon Miles-Wilson"/><br /><sub><b>Jolyon Miles-Wilson</b></sub></a><br /><a href="#code-JolyonJoseph" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/CellyRanks"><img src="https://avatars.githubusercontent.com/u/46204033?v=4?s=100" width="100px;" alt="Celestin Okoroji"/><br /><sub><b>Celestin Okoroji</b></sub></a><br /><a href="#userTesting-CellyRanks" title="User Testing">📓</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/AwayFromTheMountains"><img src="https://avatars.githubusercontent.com/u/56560797?v=4?s=100" width="100px;" alt="Oliver"/><br /><sub><b>Oliver</b></sub></a><br /><a href="#code-AwayFromTheMountains" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/kim-bohling"><img src="https://avatars.githubusercontent.com/u/153218194?v=4?s=100" width="100px;" alt="kim-bohling"/><br /><sub><b>kim-bohling</b></sub></a><br /><a href="#ideas-kim-bohling" title="Ideas, Planning, & Feedback">🤔</a></td>
    </tr>
  </tbody>
</table>

<!-- markdownlint-restore -->
<!-- prettier-ignore-end -->

<!-- ALL-CONTRIBUTORS-LIST:END -->

-----------------------------------------------------------------------------
This work is licensed under a
[Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International License][cc-by-nc-sa].

[![CC BY-NC-SA 4.0][cc-by-nc-sa-image]][cc-by-nc-sa]

[cc-by-nc-sa]: http://creativecommons.org/licenses/by-nc-sa/4.0/
[cc-by-nc-sa-image]: https://licensebuttons.net/l/by-nc-sa/4.0/88x31.png
[cc-by-nc-sa-shield]: https://img.shields.io/badge/License-CC%20BY--NC--SA%204.0-lightgrey.svg
