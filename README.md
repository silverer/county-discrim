# Regional Correlates of Majority Group Discrimination Claims

By [Elisabeth R. Silver](es61@rice.edu), [Paul Treacy](paulctreacy@gmail.com), & [Mikki Hebl](hebl@rice.edu)

*Rice University, Houston, TX, USA*


This paper is currently in the publication process.

This study examines county-level contextual factors associated with the prevalence of formal allegations of discrimination against White employees.

## Data Overview


This section describes the data files referenced in the code. To respect copyright and privacy, we do not include any raw data or reproduce any publicly available datasets in this repository. Within the code, we link to a cloud storage folder mounted on personnel endpoints by specifying the cloud file path at the beginning of every code file. 


### Claims Data


This project uses a restricted-use dataset from the U.S. Equal Employment Opportunity Commission obtained via special request to the agency by Dr. Paul Treacy. The data include all EEOC complaints filed between 2005-2016 To maintain confidentiality, we are unable to make the EEOC data files available. 

The EEOC data files and associated geocoding files include:

- The full claims dataset, referred to in the code as `EEOC_allegations_charges.dta`
- The unique locations from the  full dataset, saved as `places_to_geocode.xlsx` (created in `Clean Raw Data.R`)
- Cities and states that are often misspelled and need to be fixed manually: `manual_fix_citystates_v1.xlsx`
- A [crosswalk file](https://www.unitedstateszipcodes.org/zip-code-database/) linking U.S. zip codes to county names, states, cities, latitude, and longitude: `zip_code_database.csv`
- Locations that failed to geocode: `failed_geocode.xlsx` (created in `Geocode EEOC Complaints.ipynb`)
- County names resolved by hand based on the failed locations spreadsheet: `manual_countynames.xlsx`
- A dataset linking charge unique numbers to the geocoded places used to assign county Federal Information Processing System (FIPS) codes with the claims: `geocoded_places.csv` (created in `Geocode EEOC Complaints.ipynb`)
- A county-level dataset with the number of claims in each county: `agg_claim_info_county_w_retal_v1.csv` (created in `Clean Raw Data.R`)
- A county-level dataset with counts of discrimination claims for each year: `long_annual_claims_dataset.csv` (created in `Clean Raw Data.R`)


### Ideology Data


We use a publicly available dataset from [the American Ideology Project](https://dataverse.harvard.edu/file.xhtml?fileId=6690216&version=1.0) developed by Chris Tausanovitch and Christopher Warshaw. This dataset is referred to as `aip_counties_ideology_v2022a.dta`. It is merged with the cross-sectional county-level complaints dataset in `Clean Raw Data.R` and with the longitudinal county-level complaints dataset in `Temporal_analysis.R`.


### U.S. Census Data


We use public-use data from the U.S. Census Bureau's [American Community Survey (ACS)](https://www.census.gov/data/developers/data-sets/acs-5year.html) five-year estimates spanning years 2010-2014 (used as predictors in the primary analysis) and five-year estimates spanning years 2005-2009 (used as predictors in the exploratory temporal analysis). Data are retrieved using the Census' open-source Application Programming Interface (API). Variables include white unemployment rate, percent of county residents who are not non-Hispanic white, total population, and overall unemployment rate. Data curation is implemented in Python 3.8 in the notebook titled `Get Census Data for Merge.ipynb`. The  dataset is named as `emp_pop_data_05_14.csv`.

We perform a robustness check assessing the relationship between 2007-2011 Census data (i.e., White unemployment, racial diversity/representation of POC, total population), 2006-2011 ideology estimates, and 2007-2011 claims data to increase the temporal correspondence of predictors and outcomes. For ease, we collect the 2007-2011 Census variables using the `tidycensus` R package in `UPDATED Primary Analysis.Rmd`.

### Other Data and Data Sources


We include a file that helps with formatting regression outputs, titled `data/regression_format_v1.csv` which is used in `UPDATED Primary Analysis.Rmd`.

The data file named `census_variable_guide.xlsx` lists the original variable names and variable descriptions of Census variables collected via the API. 

Census data access via the API requires a Census API key. Save this key in a file named `tokens.py` as the variable `CENSUS_KEY`.


## Code Overview


### Required R (4.2.3) Packages


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
- `tidycensus`
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

Cleans the raw EEOC data, generates a dataset of unique locations, merges the geocoded locations with the claims dataset (after running `Geocode EEOC Complaints.ipynb`), aggregates the data at the county level, and merges aggregated data with ideology dataset. 


4. `Geocode EEOC Complaints.ipynb`

Imports user-generated `utils.py` and `tokens.py`.

Creates a crosswalk mapping unique EEOC charge numbers onto state and county FIPS codes. Also generates a file with locations that failed to geocode.


5. `Get Census Data for Merge.ipynb`

Imports user-generated `utils.py` and `tokens.py`.

Pulls and saves Census data on White unemployment rate, total population, percent of county residents who are not non-Hispanic  White, and overall unemployment rate. Loads `census_variable_guide.xlsx` to determine which ACS variables are collected via API call.


6. `UPDATED Primary Analysis.Rmd`

Merges aggregated claims dataset with Census data, performs the primary analyses and robustness checks, and saves the results. Produces files and plots in `output/`.  Also calls the `tidycensus` package to retrieve county-level demographic and employment data for years spanning 2007-2011 for a robustness check. 

7. `Temporal_analysis.R`

Exploratory analysis investigating how county-level conditions during years 2005-2009 relate to claims during years 2010 onward. Produces files and plots in `output/`. Uses the same Census data file from the primary analysis, the longitudinal claims dataset, and the same conservatism estimates used in the primary analysis. 
