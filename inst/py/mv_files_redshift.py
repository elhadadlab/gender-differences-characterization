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
phenotypes   = pd.read_csv('../csv/phenotype_lookups_final.csv')

if not os.path.exists('../../output/OLD_summaries/' + db + '/'):
    os.makedirs('../../output/OLD_summaries/' + db + '/')

for filepath in glob.glob('../../output/summaries/' + db + '/*.csv'):
#     if os.path.exists('../../output/OLD_summaries/' + db + '/' + str(cohort_file_id) + '_3yronly_summary.csv'):
#         continue;

    cohort_file_id = int(filepath.split('\\')[-1].split('_')[0])

    if phenotypes[phenotypes.Cohort_ID == cohort_file_id].Lookback.values[0] == 1:
        os.rename('../../output/summaries/' + db + '/' + str(cohort_file_id) + '_summary.csv', '../../output/OLD_summaries/' + db + '/' + str(cohort_file_id) + '_3yronly_summary.csv')
    elif phenotypes[phenotypes.Cohort_ID == cohort_file_id].Lookback.values[0] == 10:
        os.rename('../../output/summaries/' + db + '/' + str(cohort_file_id) + '_summary.csv', '../../output/OLD_summaries/' + db + '/' + str(cohort_file_id) + '_3yronly_summary.csv')
