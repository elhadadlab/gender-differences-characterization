import pandas.io.sql
import pyodbc
import pandas as pd
import numpy as np
from tqdm import tqdm
import glob
import sys
import os

from settings_redshift import *

print('Creating summaries...')
# Create the connection
conn = pyodbc.connect('Driver={Amazon Redshift (x64)};Server='+server+';Database='+db+';UID='+user+';PWD='+password+';Port='+port)

# What cohorts to create
cohort_files = pd.read_csv('../settings/CohortsToCreateFinal.csv')

# If the folder for the db doesn't already exist, create it.
if not os.path.exists('../../output/summaries/' + db + '/'):
    os.makedirs('../../output/summaries/' + db + '/')

# For each cohort_file_id [e.g. from 11111 onwards...]
for cohort_file_id in tqdm(cohort_files.cohortId):
    # If the file already exists [prior execution paused?], continue
    if os.path.exists('../../output/summaries/' + db + '/' + str(cohort_file_id) + '_summary.csv'):
        continue;

    sql_query_string = 'select * from ' + sexdiff_cohort_ttonset_v5_tablepath + ' where cohort_definition_id = ' # db.results.sexdiff_cohort_ttonset_v5'
    df = pandas.io.sql.read_sql(sql_query_string + str(cohort_file_id), conn)
    # print(cohort_file_id, len(df))

    if len(df) == 0:
        print(str(cohort_file_id) + ' is empty, continuing...')
        continue;

    # df = pd.read_csv(cohort_file, sep='|', names=names, encoding = 'unicode_escape')
    # female_df and male_df
    female_df = df[df.gender_concept_id == 8532]
    male_df   = df[df.gender_concept_id == 8507]

    # num_female and num_male TOTAL
    num_female_TOT = len(female_df.person_id.unique())
    num_male_TOT   = len(male_df.person_id.unique())

    # common_symptoms (at least one man and one woman)
    common_symptoms = set(female_df.condition_concept_id.unique()).intersection(set(male_df.condition_concept_id.unique()))

    data_dict = {}
    cohort_id = []
    condition = []
    condition_name = []
    num_females = []
    num_males   = []
    avg_TTD_females = []
    avg_TTD_males   = []
    std_TTD_females = []
    std_TTD_males   = []
    TOT_FEMALES_IN_COHORT = []
    TOT_MALES_IN_COHORT   = []

    print('Generating summary...')
    for common_condition_concept in tqdm(common_symptoms):
        cohort_id.append(cohort_file_id)
        condition.append(common_condition_concept)
        condition_name.append(female_df[female_df.condition_concept_id == common_condition_concept].concept_name.values[0])

        num_females.append(len(female_df[female_df.condition_concept_id == common_condition_concept].person_id.unique()))
        num_males.append(len(male_df[male_df.condition_concept_id == common_condition_concept].person_id.unique()))

        avg_TTD_females.append(np.mean(female_df[female_df.condition_concept_id == common_condition_concept].time_to_onset))
        std_TTD_females.append(np.std(female_df[female_df.condition_concept_id == common_condition_concept].time_to_onset))

        avg_TTD_males.append(np.mean(male_df[male_df.condition_concept_id == common_condition_concept].time_to_onset))
        std_TTD_males.append(np.std(male_df[male_df.condition_concept_id == common_condition_concept].time_to_onset))

        TOT_FEMALES_IN_COHORT.append(num_female_TOT)
        TOT_MALES_IN_COHORT.append(num_male_TOT)

    data_dict['cohort_definition_id'] = cohort_id
    data_dict['condition_concept_id'] = condition
    data_dict['concept_name'] = condition_name
    data_dict['num_females_COHORT'] = TOT_FEMALES_IN_COHORT
    data_dict['num_males_COHORT'] = TOT_MALES_IN_COHORT
    data_dict['num_females_this_symptom'] = num_females
    data_dict['num_males_this_symptom'] = num_males
    data_dict['avg_TTD_females_days'] = avg_TTD_females
    data_dict['avg_TTD_males_days'] = avg_TTD_males
    data_dict['std_TTD_females_days'] = std_TTD_females
    data_dict['std_TTD_males_days'] = std_TTD_males

    summary = pd.DataFrame.from_dict(data_dict)
    summary.to_csv('../../output/summaries/' + db + '/' + str(cohort_id[0]) + '_summary.csv', index = False)

conn.close()
