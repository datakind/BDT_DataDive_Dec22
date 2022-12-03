#
# SNAP Biannual Participation and Issuance dataset
#
"""
Generates the snapmerge dataset, combining biannual files against FIPS county and state codes.
66 files with about 2600 observations per report for 183,005 rows total.

Columns:

    month,year:  JAN or JUL for 1999-2001  in 

    Substate:  Name of the reporting office
    
    Participation counts of Persons and Housholds
        PersonsPublic:
        PersonsNonPublic:
        PersonsTotal,
        HouseholdsPublicAssistance:
        HouseholdsNonPublicAssistance,
        HouseholdsTotal:

    Issuance:  SNAP benefits issued

    countyFIPS:
    countyNAME:
    stateFIPS:
    stateNAME:

"""



import pandas as pd
import os

# download the google drive https://drive.google.com/drive/folders/1PRZrWnwLgO-jl9S8-H7zmkMUWlv51af7
# and unzip

############ REPLACE THIS DIR WITH YOUR OWN, DOWNLOAD EXTRACT ALL ####################
snapdir = "C:\\Users\\michael\\Documents\\DataDive\\SNAP\\"

# loop over these files appending, twice a year JAN,JUL 
snapfiles = []
for fn in os.listdir(snapdir):
    df = pd.read_excel(snapdir+fn, skiprows=4, header=None)
    df["month"] = fn[:3].upper()
    df["year"] = fn[4:8]
    snapfiles.append(df)    
snap = pd.concat(snapfiles)

# Remove blank columns, drop summary footers, foot notes and state subtotal rows
snap.columns = ['Substate','PersonsPublic','n1','PersonsNonPublic','n2','PersonsTotal','n3','HouseholdsPublicAssistance',
            'n4','HouseholdsNonPublicAssistance','n5','HouseholdsTotal','n6','Issuance','month','year']
snap.drop(['n1','n2','n3','n4','n5','n6'],axis=1,inplace=True)
snap = snap[snap.Substate != 'U.S. Summary']  # each biannual file has a summary record
snap = snap[~snap.Substate.isna()]            # Spreadsheets have trailing rows and foot notes
snap['countyFIPS'] = snap.Substate.str[:5]
snap['stateFIPS'] = snap.Substate.str[:2]
snap = snap[snap.countyFIPS.str.isnumeric()]       # Disclaimer statements 'Data is subject to change'
snap = snap[snap.countyFIPS.str[2:5] != "000"]     # State level subtotal records, county 000

# Get FIPS reference data
fipsstate = pd.read_fwf('https://transition.fcc.gov/oet/info/maps/census/fips/fips.txt',
                        skiprows=16, skipfooter=3198, dtype=str,
                        names=['stateFIPS','stateNAME'], colspecs = [(7, 9), (17, 30)])
fipscounty = pd.read_fwf('https://transition.fcc.gov/oet/info/maps/census/fips/fips.txt',
                        skiprows=72, dtype=str,
                        names=['countyFIPS','countyNAME'], colspecs = [(4, 9), (17, 80)])
fipscounty['stateFIPS'] = fipscounty.countyFIPS.str[:2]
fips = pd.merge(fipscounty,fipsstate,on='stateFIPS',how='left')

# Merge the SNAP with FIPS reference data
snapmerge = pd.merge(snap,fips,on='countyFIPS',how='left')
snapmerge.drop(['stateFIPS_x'], axis=1, inplace=True)
snapmerge.rename(columns={"stateFIPS_y": "stateFIPS"},inplace=True)
snapmerge.to_csv('snapmerge.csv', index=False)