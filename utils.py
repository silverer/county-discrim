import numpy as np
import pandas as pd


us_state_abbrev = {
    "Alabama": "AL",
    "Alaska": "AK",
    "Arizona": "AZ",
    "Arkansas": "AR",
    "California": "CA",
    "Colorado": "CO",
    "Connecticut": "CT",
    "Delaware": "DE",
    "District of Columbia": "DC",
    "Florida": "FL",
    "Georgia": "GA",
    "Hawaii": "HI",
    "Idaho": "ID",
    "Illinois": "IL",
    "Indiana": "IN",
    "Iowa": "IA",
    "Kansas": "KS",
    "Kentucky": "KY",
    "Louisiana": "LA",
    "Maine": "ME",
    "Maryland": "MD",
    "Massachusetts": "MA",
    "Michigan": "MI",
    "Minnesota": "MN",
    "Mississippi": "MS",
    "Missouri": "MO",
    "Montana": "MT",
    "Nebraska": "NE",
    "Nevada": "NV",
    "New Hampshire": "NH",
    "New Jersey": "NJ",
    "New Mexico": "NM",
    "New York": "NY",
    "North Carolina": "NC",
    "North Dakota": "ND",
    "Ohio": "OH",
    "Oklahoma": "OK",
    "Oregon": "OR", 
    "Pennsylvania": "PA",
    "Rhode Island": "RI",
    "South Carolina": "SC",
    "South Dakota": "SD",
    "Tennessee": "TN",
    "Texas": "TX",
    "Utah": "UT",
    "Vermont": "VT",
    "Virginia": "VA",
    "Washington": "WA",
    "West Virginia": "WV",
    "Wisconsin": "WI",
    "Wyoming": "WY",
}

state_fips = {
    "WA": "53",
    "DE": "10",
    "DC": "11",
    "WI": "55",
    "WV": "54",
    "HI": "15",
    "FL": "12",
    "WY": "56",
    "PR": "72",
    "NJ": "34",
    "NM": "35",
    "TX": "48",
    "LA": "22",
    "NC": "37",
    "ND": "38",
    "NE": "31",
    "TN": "47",
    "NY": "36",
    "PA": "42",
    "AK": "02",
    "NV": "32",
    "NH": "33",
    "VA": "51",
    "CO": "08",
    "CA": "06",
    "AL": "01",
    "AR": "05",
    "VT": "50",
    "IL": "17",
    "GA": "13",
    "IN": "18",
    "IA": "19",
    "MA": "25",
    "AZ": "04",
    "ID": "16",
    "CT": "09",
    "ME": "23",
    "MD": "24",
    "OK": "40",
    "OH": "39",
    "UT": "49",
    "MO": "29",
    "MN": "27",
    "MI": "26",
    "RI": "44",
    "KS": "20",
    "MT": "30",
    "MS": "28",
    "SC": "45",
    "KY": "21",
    "OR": "41",
    "SD": "46",
}


def format_county_fip(x):
    if pd.isnull(x):
        return "nan"
    elif type(x) == str:
        if len(x) == 3:
            return x
        if len(x) == 1:
            return "00" + x
        elif len(x) == 2:
            return "0" + x
    else:
        if x < 10:
            return "00" + str(int(x))
        elif x < 100:
            return "0" + str(int(x))
        else:
            return str(int(x))


def format_state_fip(x):
    if pd.isnull(x):
        return "nan"
    elif type(x) == str:
        if len(x) == 1:
            return "0" + x
        else:
            return x
    else:
        x = str(int(x))
        if len(x) < 2:
            return "0" + x
        else:
            return x