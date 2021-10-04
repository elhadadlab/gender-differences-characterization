-- change select statements to match Truven or CMS data
--use @cdm_database ;

--for a set of cohorts
--stratify by gender, look at differences in age and prior conditions
--IF OBJECT_ID(N'results.pbr_sex_diff_summary') IS NOT NULL
--BEGIN
--DROP TABLE results.pbr_sex_diff_summary
--END

--try to make it incident events with people who have been observed > 1yr
--concept-level summary
-- concept, prevalence, % female, age, age for female, age difference
--insert into @cdm_database.@results_database_schema.@results_sex_diff_summary (source_name, concept_id, concept_name, num_persons, prev_overall, num_female, prev_female,
insert into @results_database_schema.@results_sex_diff_summary (source_name, concept_id, concept_name, num_persons, prev_overall, num_female, prev_female,

                                   num_male, prev_male, rr_female, pct_female, avg_age, avg_age_female, avg_age_male, avg_age_diff,
                                   std_dev_age, std_dev_age_female, std_dev_age_male, min_age, min_age_female, min_age_male,
                                   max_age, max_age_female, max_age_male)

--     'q1_female', 'q1_male',
--     'q3_female', 'q3_male',
--     'median_female', 'median_male';

select CAST(@source_name AS varchar) as source_name, -- change to your database name
    c1.concept_id,
    c1.concept_name,
    t2.num_persons,
    100.0*t2.num_persons / p2.num_persons as prev_overall,
    t2.num_female,
    100.0*t2.num_female / p2.num_female as prev_female,
    t2.num_male,
    100.0*t2.num_male / p2.num_male as prev_male,
    case when  100.0*t2.num_male / p2.num_male > 0 then  (100.0*t2.num_female / p2.num_female) / (100.0*t2.num_male / p2.num_male) else 1 end as rr_female,
    t2.pct_female,
    t2.avg_age,
    t2.avg_age_female,
    t2.avg_age_male,
    t2.avg_age_diff,
    t2.std_dev_age,
    t2.std_dev_age_female,
    t2.std_dev_age_male,
    t2.min_age,
    t2.min_age_female,
    t2.min_age_male,
    t2.max_age,
    t2.max_age_female,
    t2.max_age_male
from
(
select t1.condition_concept_id, count(t1.person_id) as num_persons,
    sum(case when p1.gender_concept_id = 8507 then 1 else 0 end) as num_male,
    sum(case when p1.gender_concept_id = 8532 then 1 else 0 end) as num_female,
    1.0*sum(case when p1.gender_concept_id = 8532 then 1 else 0 end)/count(t1.person_id) as pct_female,
    avg(1.0*year(t1.index_date) - p1.year_of_birth) as avg_age,
    avg(case when p1.gender_concept_id = 8532 then 1.0*year(t1.index_date) - p1.year_of_birth else null end) as avg_age_female,
    avg(case when p1.gender_concept_id = 8507 then 1.0*year(t1.index_date) - p1.year_of_birth else null end) as avg_age_male,
    avg(case when p1.gender_concept_id = 8532 then 1.0*year(t1.index_date) - p1.year_of_birth else null end) - avg(case when p1.gender_concept_id = 8507 then 1.0*year(t1.index_date) - p1.year_of_birth else null end) as avg_age_diff,
    stdev(1.0*year(t1.index_date) - p1.year_of_birth) as std_dev_age,
    stdev(case when p1.gender_concept_id = 8532 then 1.0*year(t1.index_date) - p1.year_of_birth else null end) as std_dev_age_female,
    stdev(case when p1.gender_concept_id = 8507 then 1.0*year(t1.index_date) - p1.year_of_birth else null end) as std_dev_age_male,
    min(1.0*year(t1.index_date) - p1.year_of_birth) as min_age,
    min(case when p1.gender_concept_id = 8532 then 1.0*year(t1.index_date) - p1.year_of_birth else null end) as min_age_female,
    min(case when p1.gender_concept_id = 8507 then 1.0*year(t1.index_date) - p1.year_of_birth else null end) as min_age_male,
    max(1.0*year(t1.index_date) - p1.year_of_birth) as max_age,
    max(case when p1.gender_concept_id = 8532 then 1.0*year(t1.index_date) - p1.year_of_birth else null end) as max_age_female,
    max(case when p1.gender_concept_id = 8507 then 1.0*year(t1.index_date) - p1.year_of_birth else null end) as max_age_male
from
  (select condition_concept_id, cp1.person_id, min(condition_start_date) as index_date
  from @cdm_database.condition_occurrence as cp1
  left join @cdm_database.person p1
  on cp1.person_id = p1.person_id
  where cp1.CONDITION_START_DATE between '2010-01-01' and '2020-12-31' -- holdover from CCAE data at CUMC was only between 2008-01-01 and 2017-12-31
  group by condition_concept_id, cp1.person_id
  ) t1
inner join (select p1.person_id, p1.gender_concept_id, p1.year_of_birth, min(op1.observation_period_start_date) as index_date
from @cdm_database.observation_period op1
  inner join @cdm_database.person p1
  on op1.person_id = p1.person_id
where datediff(dd, op1.observation_period_start_date, op1.observation_period_end_date) > 365
group by p1.person_id, p1.gender_concept_id, p1.year_of_birth
    ) p1
on t1.person_id = p1.person_id
and t1.index_date >= dateadd(dd,365,p1.index_date)
-- where datediff(dd, t1.index_date, p1.year_of_birth) > 4744
group by t1.condition_concept_id
) t2
inner join @cdm_database.concept c1
on t2.condition_concept_id = c1.concept_id,
(
select count(person_id) as num_persons,
  sum(case when gender_concept_id = 8532 then 1 else 0 end) as num_female,
  1.0*sum(case when gender_concept_id = 8532 then 1 else 0 end)/count(person_id) as pct_female,
  sum(case when gender_concept_id = 8507 then 1 else 0 end) as num_male,
  1.0*sum(case when gender_concept_id = 8507 then 1 else 0 end)/count(person_id) as pct_male
from (select p1.person_id, p1.gender_concept_id, p1.year_of_birth, min(op1.observation_period_start_date) as index_date
from @cdm_database.observation_period op1
  inner join @cdm_database.person p1
  on op1.person_id = p1.person_id
where datediff(dd, op1.observation_period_start_date, op1.observation_period_end_date) > 365
group by p1.person_id, p1.gender_concept_id, p1.year_of_birth) p0
) p2
;