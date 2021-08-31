#!/usr/bin/env python
# coding: utf-8

'''
Saves the full CSV locally, as well as creating the png files used for the prevalence-in-population graphs for the paper.
'''

import pandas as pd
import tqdm
import numpy as np
from collections import OrderedDict
from collections import defaultdict
import pickle
import glob
from matplotlib import pyplot as plt
import matplotlib.patches as mpatches
import plotly
import plotly.graph_objects as go
import pandas.io.sql
import pyodbc
import tqdm
import pickle
import glob

from settings import *

# Create the connection
conn = pyodbc.connect('DRIVER={ODBC Driver 17 for SQL Server};SERVER='+server+';DATABASE='+db+';UID='+user+';PWD='+ password)

sql_query_string = 'select * from ' + db + '.results.pbr_sex_diff_summary'
all_conds_df = pandas.io.sql.read_sql(sql_query_string, conn)

# sys.getsizeof(all_conds_df)

all_conds_df.to_csv('../../output/created_files/' + db + '_pbr_sex_diff_summary.csv', index = False)

# New criteria
DQD = pd.read_csv('../csv/OMOP_dqd.csv')

# Minumum number of humans
num_persons = all_conds_df['num_persons'] >= 50

# Remove OHDSI's DQD list of sex-specific
not_sex_specific = ~all_conds_df['concept_id'].isin(DQD[~DQD['plausibleGender'].isnull()]['conceptId'])

# Limit diseases that are super prevalent in only females
not_female_only = all_conds_df['pct_female'] < 0.99
not_male_only   = all_conds_df['pct_female'] > 0.01

# Remove conditions that have male/female in their names
sex_specific_name = []
for cond in all_conds_df['concept_name']:
    cond = cond.lower()
    if 'male' in cond or 'maternal' in cond or 'uterine' in cond     or 'pregnancy' in cond or 'menopausal' in cond or 'uterus' in cond     or 'umbilical' in cond or 'gestation' in cond or 'cervix' in cond     or 'birth' in cond or 'vaginal' in cond or 'vagina' in cond or 'vulva' in cond or 'placenta' in cond     or 'ovary' in cond or 'miscarriage' in cond or 'postpartum' in cond or 'live born' in cond or 'obstet' in cond:
        # print(cond)
        sex_specific_name.append(False)
    elif 'penis' in cond or 'testis' in cond or 'testicle' in cond:
        sex_specific_name.append(False)
    else:
        sex_specific_name.append(True)

not_a_legit_concept = all_conds_df['concept_name'] == 'No matching concept'

valid_conds = (num_persons) & (not_sex_specific) & (sex_specific_name) & (not_male_only) & (not_female_only) & (~not_a_legit_concept)

# V4 updated
N, bins, patches = plt.hist(all_conds_df[valid_conds]['rr_female'], color='#676767',
         alpha=0.5, range = (0, 5), bins=55)

for i, bin_val in enumerate(bins):
    if bin_val > 1.47:
        try:
            patches[i].set_facecolor('red')
        except IndexError:
            continue

for i, bin_val in enumerate(bins):
    if bin_val < 2/3:
        try:
            patches[i].set_facecolor('blue')
        except IndexError:
            continue

greater = len(all_conds_df[valid_conds][(all_conds_df[valid_conds]['rr_female']) > 3/2])
fewer   = len(all_conds_df[valid_conds][(all_conds_df[valid_conds]['rr_female']) < 2/3])

# plt.vlines(x=10, ymin=0, ymax=300)
plt.title('Distribution of female risk ratio')
# plt.legend(loc='upper left')
plt.text(2, 335, '$RR_{female}$ > 3/2: ' + str(greater) + ' concepts') # 350
plt.text(2, 285, '$RR_{female}$ < 2/3: ' + str(fewer) + ' concepts') # 300
plt.xlabel('Female risk ratio')
plt.ylabel('Count')

# ax = plt.axes()
# ax.set(facecolor = '#ffffff')

plt.vlines(x=2/3 + 0.04, ymin=0, ymax=300, color='black')
plt.vlines(x=1.53, ymin=0, ymax=350, color='black')

plt.hlines(y=350, xmin=1.53, xmax=1.8, color='black')
plt.hlines(y=300, xmin=2/3 + 0.02, xmax=1.8, color='black')

fig = plt.gcf()
fig.set_size_inches(6, 6)
fig.savefig('../../output/graphs/' + db + '_female_rr.png')


### Normed customized risk ratio [centered at zero]:
rr_female = list(all_conds_df[valid_conds]['rr_female'])
customized = []

for ele in rr_female:
    if ele > 1:
        customized.append(ele - 1) # Append 1 - female risk ratio
    else:
        customized.append(-1 * (1/ele - 1)) # Append -1 * 1 - male risk ratio

mean = np.mean(customized)
std  = np.std(customized)


# V4 updated
N, bins, patches = plt.hist(100 * np.asarray(customized), color='green',
         alpha=0.5, bins=55, range=(-500, 500))

for i, bin_val in enumerate(bins):
    if bin_val < 0:
        try:
            patches[i].set_facecolor('blue')
        except IndexError:
            continue

for i, bin_val in enumerate(bins):
    if bin_val > 0:
        try:
            patches[i].set_facecolor('red')
        except IndexError:
            continue

red_patch = mpatches.Patch(color='red', label='Women greater risk', alpha = 0.5)
blue_patch = mpatches.Patch(color='blue', label='Men greater risk', alpha = 0.5)

plt.legend(handles=[blue_patch, red_patch], loc='upper left')

# plt.vlines(x=10, ymin=0, ymax=300)
plt.title('Distribution of increased risk: $\mu = ' + str(np.round(mean, 2)) + '\%$')
# plt.legend(loc='upper left')
# plt.text(2, 330, '$RR_{female}$ > 1:: 2424 concepts')
# plt.text(2, 300, '$RR_{female}$ < 1:: 4357 concepts')
plt.xlabel('Percentage increased risk (relative to other class)')
plt.ylabel('Count')
fig = plt.gcf()
fig.set_size_inches(6, 6)
fig.savefig('../../output/graphs/' + db + '_increased_risk.png')

#  Age diff
all_conds_df['avg_age_diff'] = all_conds_df['avg_age_female'] - all_conds_df['avg_age_male']
mean_age = np.mean(all_conds_df[valid_conds]['avg_age_diff'])

greater10 = len(all_conds_df[valid_conds][(all_conds_df[valid_conds]['avg_age_diff']) > 10])
lessthan10 = len(all_conds_df[valid_conds][(all_conds_df[valid_conds]['avg_age_diff']) < -10])

# V4 updated
N, bins, patches = plt.hist(all_conds_df[valid_conds]['avg_age_diff'], color='#676767',
         alpha=0.5, bins=55)

plt.rc('font', size=10)          # controls default text sizes

for i, bin_val in enumerate(bins):
    if bin_val > 9.6:
        try:
            patches[i].set_facecolor('red')
        except IndexError:
            continue

for i, bin_val in enumerate(bins):
    if bin_val < -10:
        try:
            patches[i].set_facecolor('blue')
        except IndexError:
            continue

plt.vlines(x=10, ymin=0, ymax=300, color='black')
plt.vlines(x=-9, ymin=0, ymax=300, color='black')

plt.title('Distribution of age differences: $\mu_{diff} = ' + str(np.round(mean_age, 2)) + '$ years')
# plt.legend(loc='upper left')
plt.text(11, 250, str(greater10) + ' conditions w/\n10+ year older\nfirst age of\ndiagnosis for women')
plt.text(-41, 250, str(lessthan10) + ' conditions w/\n10+ year older\nfirst age of diagnosis\nfor men')

plt.xlabel('Age difference (female - male)')
plt.ylabel('Count')
fig = plt.gcf()
fig.set_size_inches(6, 6)
fig.savefig('../../output/graphs/' + db + '_age_dist.png')

conn.close()
