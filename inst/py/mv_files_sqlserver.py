import pandas as pd
import numpy as np
import glob
import sys
import os

from settings_redshift import *

print('Moving old summaries...')
# Create the connection
# conn = pyodbc.connect('DRIVER={ODBC Driver 17 for SQL Server};SERVER='+server+';DATABASE='+db+';UID='+user+';PWD='+ password)

# What cohorts to create
cohort_files = pd.read_csv('../settings/CohortsToCreateFinal.csv')
phenotypes   = pd.read_csv('../csv/phenotype_lookups_final')

if not os.path.exists('../../output/OLD_summaries/' + db + '/'):
    os.makedirs('../../output/OLD_summaries/' + db + '/')

for cohort_file_id in cohort_files.cohortId:
#     if os.path.exists('../../output/OLD_summaries/' + db + '/' + str(cohort_file_id) + '_3yronly_summary.csv'):
#         continue;

    if phenotypes[phenotypes.Cohort_ID == cohort_file_id].Lookback.values[0] == 1:
        try:
            os.rename('../../output/summaries/' + db + '/' + str(cohort_file_id) + '_summary.csv', '../../output/OLD_summaries/' + db + '/' + str(cohort_file_id) + '_3yronly_summary.csv')
        except FileNotFoundError:
            continue
    elif phenotypes[phenotypes.Cohort_ID == cohort_file_id].Lookback.values[0] == 10:
        try:
            os.rename('../../output/summaries/' + db + '/' + str(cohort_file_id) + '_summary.csv', '../../output/OLD_summaries/' + db + '/' + str(cohort_file_id) + '_3yronly_summary.csv')
        except FileNotFoundError:
            continue
