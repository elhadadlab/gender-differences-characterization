import pandas.io.sql
import pyodbc
import pandas as pd
import tqdm
from collections import defaultdict, Counter
import pickle
import numpy as np
import glob
import sys

from settings_sqlserver import *

# Create the connection
conn = pyodbc.connect('DRIVER={ODBC Driver 17 for SQL Server};SERVER='+server+';DATABASE='+db+';UID='+user+';PWD='+ password)

per_patient_TTD_dict = {}
per_patient_TTD_dict[db] = {}

phenotypes = pd.read_csv('../csv/phenotype_lookups_final.csv', encoding = 'unicode_escape')
final = pd.read_csv('../../output/created_files/' + db + '_common_symptom_tfidf_final.csv')
summary_fp = '../../output/summaries/' + db + '/'

def dd():
    return defaultdict(int)

concept_id_mapper = defaultdict(dd) # dd is a module-level function

with open('../../output/created_files/' + db + '_common_symptoms.pickle', 'rb') as handle:
    concept_id_mapper = pickle.load(handle)

with open('../csv/exclude_concepts_all_final.csv', 'r') as handle:
    excluded = handle.readlines()

for summary_file in tqdm.tqdm(glob.glob(summary_fp + '*')):
    cohort_file_id = summary_file.split('\\')[-1].split('_')[0]
    sql_query_string = 'select * from ' + sexdiff_cohort_ttonset_v5_tablepath + ' where cohort_definition_id = '
    df = pandas.io.sql.read_sql(sql_query_string + str(cohort_file_id), conn)
    cohort_id = str(cohort_file_id)

    tmp = []

    for ele in excluded:
        if ele.strip('\n').split(',')[0] == cohort_id:
            tmp = ele.strip('\n').split(',')

    # ccae_df = pd.read_csv(base_fp + cohort_id + '.csv', encoding = 'unicode_escape', sep='|', names=names)

    # Let's get remove concepts that are in the definition set
    valid_top_N = []
    skipped = []

    for i, condition_concept_id in enumerate(final.sort_values(by=cohort_id, ascending=False)['condition_concept_id'].values):
        if str(condition_concept_id) in tmp[1:]:
            skipped.append(i)
            continue;
        else:
            valid_top_N.append(condition_concept_id)
        if len(valid_top_N) == 50:
            break;

    # Get the subset of the DF with only these top 50 symptoms
    subset_df = df[df.condition_concept_id.isin(valid_top_N)]

    women_df = subset_df[subset_df.gender_concept_id == 8532]
    men_df   = subset_df[subset_df.gender_concept_id == 8507]

    first_occur_women = women_df.sort_values(by=['person_id', 'time_to_onset'], ascending=False).drop_duplicates(subset=['person_id'])
    first_occur_men = men_df.sort_values(by=['person_id', 'time_to_onset'], ascending=False).drop_duplicates(subset=['person_id'])

    TTO_val_MAX_women = np.asarray(list(first_occur_women.time_to_onset.values))
    # TTO_val_MEAN_women = []
    condition_name_MAX_women = list(first_occur_women.concept_name.values)

    TTO_val_MAX_men = np.asarray(list(first_occur_men.time_to_onset.values))
    # TTO_val_MEAN_men = []
    condition_name_MAX_men = list(first_occur_men.concept_name.values)

    # Sorted list takes a lot more space. Let's just store the counted values
    # (valid_top_N, TTO_val_MAX_women, TTO_val_MAX_men, condition_name_MAX_women, condition_name_MAX_men)

    per_patient_TTD_dict[db][cohort_id] = (valid_top_N, Counter(TTO_val_MAX_women), Counter(TTO_val_MAX_men), Counter(condition_name_MAX_women), Counter(condition_name_MAX_men))

with open('../../output/created_files/' + db + '_per_patient_TTD_.pickle', 'wb') as handle:
    pickle.dump(per_patient_TTD_dict[db], handle, protocol=pickle.HIGHEST_PROTOCOL)

conn.close()
