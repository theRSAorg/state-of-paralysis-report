# about
This repo contains data and code to recreate figures from the Young People's Future Health & Economic Security report.

The data included here (in the `data` folder) is processed data that was used in prior RSA analyses.
The raw data (Walth and Assets Survey Rounds 6 and 7, obtained from the UK Data Service) are not included here as they are not ours to share.
However, for reproducibility purposes, we share the names of the files, as received from the UK Data Service: `was_round_6_hhold_eul_april_2022.tab` and `was_round_6_hhold_eul_april_2022.tab`.

The `R` folder contains the scripts used to recreate the plots:
- `remaking-plots.R` contains the code used to recreate figure 1.2, which shows savings by age group
- `was_exploration.R` contains the code used to recreate figure 1.3, which shows how much debt different age groups have and the ratio of debt over income.
> Note 1: the original figure 1.3 showed financial liabilities over income, but I was not able to recreate that from the raw data
> Note 2: there is no reason for these scripts to be separate, it's just that @JolyonJoseph and @eirini-zormpa starting working on those problems in separate scripts. We should probably combine these before opening the repo :smile: :sparkles: