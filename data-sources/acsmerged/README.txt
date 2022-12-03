# ACS Merged
### Contains the 16 ACS tables involved in DataDive Dec 2022
Annually - year, 2015-2020
County level - countyFIPS is 5 digit FIPS
Split into five CSV files for github limit of 25MB per file
Code to load the CSV files into a single dataframe:
```
mergelist = []
for chunk in ['1','2','3','4','5']:
    part = pd.read_csv('acsmerge'+chunk+'.csv')
    part['countyFIPS'] = part['countyFIPS'].astype(str).str.zfill(5)
    part['year'] = part['year'].astype(str)
    part['NAME'] = part['NAME'].astype(str)
    part['GEO_ID'] = part['GEO_ID'].astype(str)
    for col in [c for c in part.columns if c not in ['GEO_ID', 'NAME', 'countyFIPS', 'year']]:
        part[col] = part[col].astype(float)
    mergelist.append(part)
acsmerge = pd.concat(mergelist, axis=0, ignore_index=True)
```    

B03002 - HISPANIC OR LATINO ORIGIN BY RACE
C27007 - MEDICAID/MEANS-TESTED PUBLIC COVERAGE
S0101 - AGE AND SEX
S0802 - MEANS OF COMMUTE
S1101 - HOUSEHOLD SIZE
S1501 - EDUCATION ATTAINMENT
S1602 - LIMITED ENGLISH SPEAKING HOUSEHOLDS
S1702 - POVERTY STATUS IN THE PAST 12 MONTHS OF FAMILIES
S1901 - INCOME IN THE PAST 12 MONTHS (IN 2020 INFLATION-ADJUSTED DOLLARS)
S2201 - FOOD STAMPS/SUPPLEMENTAL NUTRITION ASSISTANCE PROGRAM (SNAP)
S2301 - EMPLOYMENT STATUS
S2302 - EMPLOYMENT CHARACTERISTICS OF FAMILIES
S2503 - FINANCIAL CHARACTERISTICS
S2701 - HEALTH INSURANCE COVERAGE STATUS
S2704 - PUBLIC HEALTH INSURANCE COVERAGE
S2802 - TYPES OF INTERNET SUBSCRIPTIONS BY SELECTED CHARACTERISTICS

# Python to load the dataset
