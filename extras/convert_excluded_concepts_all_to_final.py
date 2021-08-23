with open('../csv/exclude_concepts_all.csv', 'r') as handle:
    excluded = handle.readlines()
    
old_df = pd.read_csv('C:\\Users\\tonys\\Documents\\Research\\csv\\ccae_counts_final_with_my_estimates.csv')

new_txt = ''
for ele in excluded:
    orig_id = int(ele.split(',')[0])
    rest_of_list = ','.join(ele.split(',')[1:])
    new_cohort_id = old_df[old_df.Cohort_ID == orig_id].NEW_FINAL_COHORT_ID.values[0]
    new_txt = new_txt + str(new_cohort_id) + ',' + ','.join(ele.split(',')[1:])
    
with open('../csv/exclude_concepts_all_final.csv', 'w') as f:
    f.write(new_txt)

f.close()