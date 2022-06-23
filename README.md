# Effects of Diversity, Ideology, and Economic Threat on "Anti-White" Discrimination Claims

By [Elisabeth R. Silver](es61@rice.edu), [Paul Treacy](paulctreacy@gmail.com), & [Mikki Hebl](hebl@rice.edu)

*Rice University, Houston, TX, USA*


This paper is currently in the publication process.

This study examines county-level contextual factors associated with the prevalence of formal allegations of discrimination against white employees. The results suggest that greater racial diversity is associated with the prevalence of anti-white discrimination claims, particularly in areas with high endorsement of conservative ideology. We find that the stronger association between racial diversity and anti-white claims in highly conservative areas is more pronounced in counties with high economic threat to white people (i.e., high levels of white unemployment). 

This research is the first to demonstrate that threats to white people's majority status are associated with formal anti-white employment discrimination claims, particularly in areas with high endorsement of conservative values and high economic threat to white people. 


## Data Overview


This section describes the data files referenced in the code. To respect copyright and privacy, we do not include any raw data or reproduce any publicly available datasets in this repository. Within the code, we link to a cloud storage folder mounted on personnel endpoints by specifying the cloud file path at the beginning of every code file. 


### Equal Employment Opportunity Commission (EEOC) Data


This project uses a restricted-use dataset from the U.S. Equal Employment Opportunity Commission obtained via special request to the agency by Dr. Paul Treacy. The data include all EEOC complaints filed between 2005-2016 To maintain confidentiality, we are unable to make the EEOC data files available. 

The EEOC data files and associated geocoding files include:

- The full claims dataset, referred to in the code as `EEOC_allegations_charges.dta`
- The unique locations from the  full dataset, saved as `places_to_geocode.xlsx` (created in `Clean Raw Data.R`)
- Cities and states that are often misspelled and need to be fixed manually: `manual_fix_citystates_v1.xlsx`
- A [crosswalk file](https://www.unitedstateszipcodes.org/zip-code-database/) linking U.S. zip codes to county names, states, cities, latitude, and longitude: `zip_code_database.csv`
- Locations that failed to geocode: `failed_geocode.xlsx` (created in `Geocode EEOC Complaints.ipynb`)
- County names resolved by hand based on the failed locations spreadsheet: `manual_countynames.xlsx`
- A dataset linking charge unique numbers to the geocoded places used to assign county Federal Information Processing System (FIPS) codes with the claims: `geocoded_places.csv` (created in `Geocode EEOC Complaints.ipynb`)
- A county-level dataset with the number of claims in each county, the number of anti-white discrimination claims, and location information: `agg_claim_info_county_w_retal_v1.csv` (created in `Clean Raw Data.R`)
- A county-level dataset with only claims spanning 2010-2014 (for the robustness check): `agg_claim_info_county_w_retal_robust.csv` (created in `Clean Raw Data.R`)
- A county-level dataset with all Census data and conservatism data merged with the claims information: `agg_claim_info_county_w_census_w_retal_v1.csv` (created in `Primary Analysis.Rmd`)


### Ideology Data


We use a publicly available dataset from [the American Ideology Project](https://americanideologyproject.com/) developed by Chris Tausanovitch and Christopher Warshaw. This dataset is referred to as `county_TW_ideology_estimates.csv`. It is merged with the county-level complaints dataset in `Clean Raw Data.R`.


### U.S. Census Data


We use public-use data from the U.S. Census Bureau's [American Community Survey (ACS)](https://www.census.gov/data/developers/data-sets/acs-5year.html) five-year estimates spanning years 2010-2014 (in the primary analysis) and years 2006-2010 (as a robustness check). Data are retrieved using the Census' open-source Application Programming Interface (API). Variables include white unemployment rate, percent of county residents who are not non-Hispanic white, and overall unemployment rate. Data curation is implemented in Python 3.8 in the notebook titled `Get Census Data for Merge.ipynb`. The 2010-2014 dataset is referred to as `white_unemployment_pop.csv`and the 2006-2010 dataset is referred to as `white_unemployment_pop_2010.csv`. After generating the datasets, they are merged with the aggregated claims data files within the `.Rmd` analysis files.


### Other Data and Data Sources


We include a file that helps with formatting regression outputs, titled `data/regression_format.csv` which is used in both of the `.Rmd` analysis files. 

Geocoding (specifically, use of the [FCC's Area API](https://geo.fcc.gov/api/census/)) and Census data access via the API require a Census API key. Save this key in a file named `tokens.py` as the variable `CENSUS_KEY`.


## Code Overview


### Required R (4.2.0) Packages


- `pacman`
- `tidyverse`
- `openxlsx`
- `haven`
- `readxl`
- `devtools`
- `cowplot`
- `scales`
- `effects`
- `lsmeans`
- `interactions`
- `Hmisc`
- `apaTables`
- `stats`
- `statstring` (download using `devtools::install_github("silverer/statstring")`)


### Required Python (3.8) Packages


- `pandas`
- `numpy`
- `regex`
- `openpyxl`
- `requests`
- `time`


### Code Files


1. `utils.R` and `utils.py`

Contains helper functions for other scripts.


2. `tokens.py`

Contains your Census API key, saved as `CENSUS_KEY = [YOUR_KEY_HERE]`


3. `Clean Raw Data.R`

Imports user-generated `utils.R`.

Cleans the raw EEOC data, generates a dataset of unique locations, merges the geocoded locations with the claims dataset (after running `Geocode EEOC Complaints.ipynb`), aggregates the data at the county level, and merges aggregated data with conservatism dataset. 


4. `Geocode EEOC Complaints.ipynb`

Imports user-generated `utils.py` and `tokens.py`.

Creates a crosswalk mapping unique EEOC charge numbers onto state and county FIPS codes. Also generates a file with locations that failed to geocode.


5. `Get Census Data for Merge.ipynb`

Imports user-generated `utils.py` and `tokens.py`.

Pulls and saves Census data on white unemployment rate, percent of county residents who are not non-Hispanic  white, and overall unemployment rate.


6. `Primary Analysis.Rmd`

Merges aggregated claims dataset with Census data. Performs the primary analyses and saves the results. Produces files and plots in `output/` and the `Primary-Analysis.docx` file. 


7. `Robustness Check.Rmd`

Merges aggregated claims datasets with respective Census data for the robustness checks. Produces files in `output/` that begin with `robustness_` and the `Robustness-Check.docx` file.

