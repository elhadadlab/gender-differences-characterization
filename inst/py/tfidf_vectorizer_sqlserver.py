#!/usr/bin/env python
# coding: utf-8

import pandas as pd
import tqdm
import numpy as np
from collections import OrderedDict
from collections import defaultdict
import pickle
from sklearn.feature_extraction.text import TfidfVectorizer

from settings_sqlserver import *

import glob

def dd():
    return defaultdict(int)

concept_id_mapper = defaultdict(dd) # dd is a module-level function
# concept_id_mapper = defaultdict(lambda: 'missing')

summary_fp = '../../output/summaries/' + db + '/'

cohort_files = pd.read_csv('../settings/CohortsToCreateFinal.csv')

print('Creating document setup...')

documents = []
cohort = []

for summary_file in tqdm.tqdm(glob.glob(summary_fp + '*.csv')):
    cohort_id = summary_file.split('\\')[-1].split('_')[0]
    # created.append(cohort_id)

    summary = pd.read_csv(summary_file)

    for x in zip([x for x in summary.condition_concept_id.values], [x for x in summary.concept_name.values]):
        concept_id_mapper[x[0]] = x[1]

    cohort.append(cohort_id)

    document_female = ''
    document_male   = ''

    for i, row in summary.iterrows():
        document_female = document_female + (str(row.condition_concept_id) + ' ') * row.num_females_this_symptom
        document_male = document_male + (str(row.condition_concept_id) + ' ') * row.num_males_this_symptom

    big_document = document_female + document_male
    big_document = big_document.strip()
    documents.append(big_document)

with open('../../output/created_files/' + db + '_common_symptoms.pickle', 'wb') as handle:
    pickle.dump(concept_id_mapper, handle, protocol=pickle.HIGHEST_PROTOCOL)

print('Calculating tf-idf...')

vectorizer = TfidfVectorizer()
vectors = vectorizer.fit_transform(documents)
feature_names = vectorizer.get_feature_names()
dense = vectors.todense()
denselist = dense.tolist()

df = pd.DataFrame(denselist, columns=feature_names, index = cohort)
df.reset_index(level=0, inplace=True)
df = df.rename(columns ={'index' : 'cohort_id'})
df.to_csv('../../output/created_files/' + db + '_common_symptom_tfidf.csv', index=True)

final = df.transpose()
cols = [int(x) for x in final.iloc[0].tolist()]
final.columns = cols
final.drop('cohort_id', axis=0, inplace=True)
final['concept_name'] = [concept_id_mapper[int(x)] for x in final.index]
final.reset_index(inplace=True)
final = final.rename(columns = {'index':'condition_concept_id'})
final.to_csv('../../output/created_files/' + db + '_common_symptom_tfidf_final.csv', index=False)
