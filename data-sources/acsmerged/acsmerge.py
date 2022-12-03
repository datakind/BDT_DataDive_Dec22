#
# ACS Downloads
#

"""
Used data.census.gov Advanced Search to download 2015-2020, county level for 
    B03002	 HISPANIC OR LATINO ORIGIN BY RACE
    C27007	 MEDICAID/MEANS-TESTED PUBLIC COVERAGE
    S0101	 AGE AND SEX
    S0802	 MEANS OF COMMUTE
    S1101	 HOUSEHOLD SIZE
    S1501	 EDUCATION ATTAINMENT
    S1602	 LIMITED ENGLISH SPEAKING HOUSEHOLDS
    S1702	 POVERTY STATUS IN THE PAST 12 MONTHS OF FAMILIES
    S1901	 INCOME IN THE PAST 12 MONTHS (IN 2020 INFLATION-ADJUSTED DOLLARS)
    S2201	 FOOD STAMPS/SUPPLEMENTAL NUTRITION ASSISTANCE PROGRAM (SNAP)
    S2301	 EMPLOYMENT STATUS
    S2302	 EMPLOYMENT CHARACTERISTICS OF FAMILIES
    S2503	 FINANCIAL CHARACTERISTICS
    S2701	 HEALTH INSURANCE COVERAGE STATUS
    S2704	 PUBLIC HEALTH INSURANCE COVERAGE
    S2802	 TYPES OF INTERNET SUBSCRIPTIONS BY SELECTED CHARACTERISTICS
"""
import os
import pandas as pd
import numpy as np

acsdir = "C:\\Users\\michael\\Downloads\\acsdump\\"

years = ["2015", "2016", "2017", "2018", "2019", "2020"]
tables = ['S1702','S1901','S2201','S2301','S2302','S2701','S0802','B03002','S1501','S1101','S1602','S2802','S0101','S2503','C27007','S2704']

#for file in os.listdir(acsdir):
#    if "Data" in file:  
        
tabledict = {}

for year in years:
    print("reading",year)
    for table in tables:
        if table in ["B03002","C27007"]:
            huh = "ACSDT5Y"
        else:
            huh = "ACSST5Y"
        try:
            df = pd.read_csv(acsdir+huh+year+"."+table+"-Data.csv", dtype=str)
            df['year'] = year
            df = df.iloc[1: , :] # the first row are remarks
            if table in tabledict.keys():
                tabledict[table].append(df)
            else:
                tabledict[table] = [df]
        except:
            print(year,table)
#Missing 
#    2015 S2802
#    2016 S2802

acstables = {}
for table in tables:
    print("collecting",table)
    df = pd.concat(tabledict[table])
    df = df[['GEO_ID', 'NAME', 'year']+[c for c in df.columns if ((c[-1] == 'E') & (c != "NAME"))]]
    for c in [c for c in df.columns if ((c[-1] == 'E') & (c != "NAME"))]:
        print("----",c)
        # Numeric columns
        df[c] = df[c].astype(str)
        df[c] = df[c].str.replace("+","",regex=True).replace("-","",regex=True) # values like 100+ etc
        df[c] = df[c].str.replace(",","")  # values like 2,500
        df[c] = df[c].replace("(X)",None).replace('N', None).replace('', None).replace('  ', None).replace('-', None)
        df[c] = df[c].astype(float)
    for col in ['GEO_ID', 'NAME', 'year']:  # string columns
        df[col] = df[col].astype(str)
    acstables[table] = df
    
for t in acstables.keys():
    if t == list(acstables.keys())[0]:
        acsmerge = acstables[t]
    else:
        acsmerge = pd.merge(acsmerge.drop(['NAME'],axis=1),acstables[t], \
                            on=['GEO_ID', 'year'], how='outer')
    print(t,acsmerge.shape)
    
acsmerge["countyFIPS"] = acsmerge.GEO_ID.str[9:14]
acsmerge.to_csv('acsmerge.csv',index = False)

tablemeta={}
tablemeta['B03002'] = 'HISPANIC OR LATINO ORIGIN BY RACE'
tablemeta['C27007'] = 'MEDICAID/MEANS-TESTED PUBLIC COVERAGE'
tablemeta['S0101'] = 'AGE AND SEX'
tablemeta['S0802'] = 'MEANS OF COMMUTE'
tablemeta['S1101'] = 'HOUSEHOLD SIZE'
tablemeta['S1501'] = 'EDUCATION ATTAINMENT'
tablemeta['S1602'] = 'LIMITED ENGLISH SPEAKING HOUSEHOLDS'
tablemeta['S1702'] = 'POVERTY STATUS IN THE PAST 12 MONTHS OF FAMILIES'
tablemeta['S1901'] = 'INCOME IN THE PAST 12 MONTHS (IN 2020 INFLATION-ADJUSTED DOLLARS)'
tablemeta['S2201'] = 'FOOD STAMPS/SUPPLEMENTAL NUTRITION ASSISTANCE PROGRAM (SNAP)'
tablemeta['S2301'] = 'EMPLOYMENT STATUS'
tablemeta['S2302'] = 'EMPLOYMENT CHARACTERISTICS OF FAMILIES'
tablemeta['S2503'] = 'FINANCIAL CHARACTERISTICS'
tablemeta['S2701'] = 'HEALTH INSURANCE COVERAGE STATUS'
tablemeta['S2704'] = 'PUBLIC HEALTH INSURANCE COVERAGE'
tablemeta['S2802'] = 'TYPES OF INTERNET SUBSCRIPTIONS BY SELECTED CHARACTERISTICS'

metadict = {}
for year in ["2020"]:
    print("reading",year)
    for table in tables:
        if table in ["B03002","C27007"]:
            huh = "ACSDT5Y"
        else:
            huh = "ACSST5Y"
        df = pd.read_csv(acsdir+huh+year+"."+table+"-Column-Metadata.csv", dtype=str)
        if table in metadict.keys():
            metadict[table].append(df)
        else:
            metadict[table] = [df]

metalist = []
for table in tables:
    metalist = metalist + metadict[table]
    
columnmeta = pd.concat(metalist)
columnmeta = columnmeta[((columnmeta["Column Name"].str[-1] == "E") | (columnmeta["Column Name"].isin(["GEO_ID","NAME"])))]
columnmeta["Table Name"] = columnmeta["Column Name"].str.split("_", n = 1, expand = True)[0]

meta = pd.merge(columnmeta,
         pd.DataFrame({"Table Name":list(tablemeta.keys()),"Table Description":list(tablemeta.values())}),
         on="Table Name", how="outer")
meta = meta[~meta["Column Name"].isin(["GEO_ID","year","NAME"])]

meta.to_csv("acsmetadata.csv", index = False)