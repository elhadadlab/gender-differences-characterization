CREATE TABLE #Codesets  (codeset_id bigint NOT NULL,
  concept_id bigint NOT NULL
)
DISTSTYLE ALL;

INSERT INTO #Codesets (codeset_id, concept_id)
SELECT 0 as codeset_id, c.concept_id FROM (select distinct I.concept_id FROM
(
  select concept_id from @vocabulary_database_schema.CONCEPT where concept_id in (201820,442793,443238)
UNION  select c.concept_id
  from @vocabulary_database_schema.CONCEPT c
  join @vocabulary_database_schema.CONCEPT_ANCESTOR ca on c.concept_id = ca.descendant_concept_id
  and ca.ancestor_concept_id in (201820,442793,443238)
  and c.invalid_reason is null

) I
LEFT JOIN
(
  select concept_id from @vocabulary_database_schema.CONCEPT where concept_id in (201254,4058243,435216,40484648)
UNION  select c.concept_id
  from @vocabulary_database_schema.CONCEPT c
  join @vocabulary_database_schema.CONCEPT_ANCESTOR ca on c.concept_id = ca.descendant_concept_id
  and ca.ancestor_concept_id in (201254,4058243,435216,40484648)
  and c.invalid_reason is null

) E ON I.concept_id = E.concept_id
WHERE E.concept_id is null
) C UNION ALL
SELECT 1 as codeset_id, c.concept_id FROM (select distinct I.concept_id FROM
(
  select concept_id from @vocabulary_database_schema.CONCEPT where concept_id in (40769338,43021173,42539022,46270562)
UNION  select c.concept_id
  from @vocabulary_database_schema.CONCEPT c
  join @vocabulary_database_schema.CONCEPT_ANCESTOR ca on c.concept_id = ca.descendant_concept_id
  and ca.ancestor_concept_id in (40769338,43021173,42539022,46270562)
  and c.invalid_reason is null

) I
) C UNION ALL
SELECT 2 as codeset_id, c.concept_id FROM (select distinct I.concept_id FROM
(
  select concept_id from @vocabulary_database_schema.CONCEPT where concept_id in (21600744)
UNION  select c.concept_id
  from @vocabulary_database_schema.CONCEPT c
  join @vocabulary_database_schema.CONCEPT_ANCESTOR ca on c.concept_id = ca.descendant_concept_id
  and ca.ancestor_concept_id in (21600744)
  and c.invalid_reason is null

) I
) C UNION ALL
SELECT 3 as codeset_id, c.concept_id FROM (select distinct I.concept_id FROM
(
  select concept_id from @vocabulary_database_schema.CONCEPT where concept_id in (40758583,4197971,44786901,3004410,3007263,3003309,3005673,40762352,3034639,2212392)

) I
) C
;

CREATE TABLE #qualified_events

DISTKEY(person_id)
AS
WITH
primary_events (event_id, person_id, start_date, end_date, op_start_date, op_end_date, visit_occurrence_id)
AS
(
-- Begin Primary Events
select P.ordinal as event_id, P.person_id, P.start_date, P.end_date, op_start_date, op_end_date, cast(P.visit_occurrence_id as bigint) as visit_occurrence_id
FROM
(
  select E.person_id, E.start_date, E.end_date,
         ROW_NUMBER() OVER (PARTITION BY E.person_id  ORDER BY E.sort_date  ASC ) ordinal,
         OP.observation_period_start_date as op_start_date, OP.observation_period_end_date as op_end_date, cast(E.visit_occurrence_id as bigint) as visit_occurrence_id
  FROM
  (
  -- Begin Condition Occurrence Criteria
SELECT C.person_id, C.condition_occurrence_id as event_id, C.condition_start_date as start_date, COALESCE(C.condition_end_date, DATEADD(day,CAST(1 as bigint),C.condition_start_date)) as end_date,
  C.visit_occurrence_id, C.condition_start_date as sort_date
FROM
(
  SELECT co.* , ROW_NUMBER() OVER (PARTITION BY co.person_id  ORDER BY co.condition_start_date, co.condition_occurrence_id ) as ordinal
  FROM @cdm_database_schema.CONDITION_OCCURRENCE co
  JOIN #Codesets codesets on ((co.condition_concept_id = codesets.concept_id and codesets.codeset_id = 0))
) C

WHERE C.ordinal = 1
-- End Condition Occurrence Criteria

UNION ALL
-- Begin Drug Exposure Criteria
select C.person_id, C.drug_exposure_id as event_id, C.drug_exposure_start_date as start_date,
       COALESCE(C.DRUG_EXPOSURE_END_DATE, DATEADD(day,CAST(C.DAYS_SUPPLY as bigint),DRUG_EXPOSURE_START_DATE), DATEADD(day,CAST(1 as bigint),C.DRUG_EXPOSURE_START_DATE)) as end_date,
       C.visit_occurrence_id,C.drug_exposure_start_date as sort_date
from
(
  select de.* , ROW_NUMBER() OVER (PARTITION BY de.person_id  ORDER BY de.drug_exposure_start_date, de.drug_exposure_id ) as ordinal
  FROM @cdm_database_schema.DRUG_EXPOSURE de
JOIN #Codesets codesets on ((de.drug_concept_id = codesets.concept_id and codesets.codeset_id = 2))
) C

WHERE C.ordinal = 1
-- End Drug Exposure Criteria

UNION ALL
-- Begin Measurement Criteria
select C.person_id, C.measurement_id as event_id, C.measurement_date as start_date, DATEADD(d,CAST(1 as bigint),C.measurement_date) as END_DATE,
       C.visit_occurrence_id, C.measurement_date as sort_date
from
(
  select m.* , ROW_NUMBER() OVER (PARTITION BY m.person_id  ORDER BY m.measurement_date, m.measurement_id ) as ordinal
  FROM @cdm_database_schema.MEASUREMENT m
JOIN #Codesets codesets on ((m.measurement_concept_id = codesets.concept_id and codesets.codeset_id = 3))
) C

WHERE (C.value_as_number >= 6.5000 and C.value_as_number <= 20.0000)
AND C.unit_concept_id in (8554)
AND C.ordinal = 1
-- End Measurement Criteria

  ) E
	JOIN @cdm_database_schema.observation_period OP on E.person_id = OP.person_id and E.start_date >=  OP.observation_period_start_date and E.start_date <= op.observation_period_end_date
  WHERE DATEADD(day,CAST(1095 as bigint),OP.OBSERVATION_PERIOD_START_DATE) <= E.START_DATE AND DATEADD(day,CAST(0 as bigint),E.START_DATE) <= OP.OBSERVATION_PERIOD_END_DATE
) P
WHERE P.ordinal = 1
-- End Primary Events

)

SELECT
event_id,  person_id , start_date, end_date, op_start_date, op_end_date, visit_occurrence_id

FROM
(
  select pe.event_id, pe.person_id, pe.start_date, pe.end_date, pe.op_start_date, pe.op_end_date, ROW_NUMBER() OVER (partition by pe.person_id  ORDER BY pe.start_date  ASC ) as ordinal, cast(pe.visit_occurrence_id as bigint) as visit_occurrence_id
  FROM primary_events pe

JOIN (
-- Begin Criteria Group
select 0 as index_id, person_id, event_id
FROM
(
  select E.person_id, E.event_id
  FROM primary_events E
  INNER JOIN
  (
    -- Begin Demographic Criteria
SELECT 0 as index_id, e.person_id, e.event_id
FROM primary_events E
JOIN @cdm_database_schema.PERSON P ON P.PERSON_ID = E.PERSON_ID
WHERE (E.start_date >= TO_DATE(TO_CHAR(2010,'0000FM')||'-'||TO_CHAR(1,'00FM')||'-'||TO_CHAR(1,'00FM'), 'YYYY-MM-DD') and E.start_date <= TO_DATE(TO_CHAR(2020,'0000FM')||'-'||TO_CHAR(1,'00FM')||'-'||TO_CHAR(1,'00FM'), 'YYYY-MM-DD'))
GROUP BY e.person_id, e.event_id
-- End Demographic Criteria

  ) CQ on E.person_id = CQ.person_id and E.event_id = CQ.event_id
  GROUP BY E.person_id, E.event_id
  HAVING COUNT(index_id) = 1
) G
-- End Criteria Group
) AC on AC.person_id = pe.person_id and AC.event_id = pe.event_id

) QE
WHERE QE.ordinal = 1
;

--- Inclusion Rule Inserts

CREATE TABLE #Inclusion_0

DISTKEY(person_id)
AS
SELECT
0 as inclusion_rule_id,  person_id , event_id

FROM
(
  select pe.person_id, pe.event_id
  FROM #qualified_events pe

JOIN (
-- Begin Criteria Group
select 0 as index_id, person_id, event_id
FROM
(
  select E.person_id, E.event_id
  FROM #qualified_events E
  INNER JOIN
  (
    -- Begin Correlated Criteria
select 0 as index_id, cc.person_id, cc.event_id
from (SELECT p.person_id, p.event_id
FROM #qualified_events P
JOIN (
  -- Begin Condition Occurrence Criteria
SELECT C.person_id, C.condition_occurrence_id as event_id, C.condition_start_date as start_date, COALESCE(C.condition_end_date, DATEADD(day,CAST(1 as bigint),C.condition_start_date)) as end_date,
  C.visit_occurrence_id, C.condition_start_date as sort_date
FROM
(
  SELECT co.*
  FROM @cdm_database_schema.CONDITION_OCCURRENCE co
  JOIN #Codesets codesets on ((co.condition_concept_id = codesets.concept_id and codesets.codeset_id = 0))
) C


-- End Condition Occurrence Criteria

) A on A.person_id = P.person_id  AND A.START_DATE >= P.OP_START_DATE AND A.START_DATE <= P.OP_END_DATE AND A.START_DATE >= DATEADD(day,CAST(0 as bigint),P.START_DATE) AND A.START_DATE <= P.OP_END_DATE ) cc
GROUP BY cc.person_id, cc.event_id
HAVING COUNT(cc.event_id) >= 1
-- End Correlated Criteria

  ) CQ on E.person_id = CQ.person_id and E.event_id = CQ.event_id
  GROUP BY E.person_id, E.event_id
  HAVING COUNT(index_id) = 1
) G
-- End Criteria Group
) AC on AC.person_id = pe.person_id AND AC.event_id = pe.event_id
) Results
;

CREATE TABLE #Inclusion_1

DISTKEY(person_id)
AS
SELECT
1 as inclusion_rule_id,  person_id , event_id

FROM
(
  select pe.person_id, pe.event_id
  FROM #qualified_events pe

JOIN (
-- Begin Criteria Group
select 0 as index_id, person_id, event_id
FROM
(
  select E.person_id, E.event_id
  FROM #qualified_events E
  INNER JOIN
  (
    -- Begin Correlated Criteria
select 0 as index_id, p.person_id, p.event_id
from #qualified_events p
LEFT JOIN (
SELECT p.person_id, p.event_id
FROM #qualified_events P
JOIN (
  -- Begin Observation Criteria
select C.person_id, C.observation_id as event_id, C.observation_date as start_date, DATEADD(d,CAST(1 as bigint),C.observation_date) as END_DATE,
       C.visit_occurrence_id, C.observation_date as sort_date
from
(
  select o.*
  FROM @cdm_database_schema.OBSERVATION o
JOIN #Codesets codesets on ((o.observation_concept_id = codesets.concept_id and codesets.codeset_id = 1))
) C


-- End Observation Criteria

) A on A.person_id = P.person_id  AND A.START_DATE >= P.OP_START_DATE AND A.START_DATE <= P.OP_END_DATE AND A.START_DATE >= P.OP_START_DATE AND A.START_DATE <= DATEADD(day,CAST(0 as bigint),P.START_DATE) ) cc on p.person_id = cc.person_id and p.event_id = cc.event_id
GROUP BY p.person_id, p.event_id
HAVING COUNT(cc.event_id) = 0
-- End Correlated Criteria

  ) CQ on E.person_id = CQ.person_id and E.event_id = CQ.event_id
  GROUP BY E.person_id, E.event_id
  HAVING COUNT(index_id) = 1
) G
-- End Criteria Group
) AC on AC.person_id = pe.person_id AND AC.event_id = pe.event_id
) Results
;

CREATE TABLE #inclusion_events

DISTKEY(person_id)
AS
SELECT
inclusion_rule_id,  person_id , event_id

FROM
(select inclusion_rule_id, person_id, event_id from #Inclusion_0
UNION ALL
select inclusion_rule_id, person_id, event_id from #Inclusion_1) I;
TRUNCATE TABLE #Inclusion_0;
DROP TABLE #Inclusion_0;

TRUNCATE TABLE #Inclusion_1;
DROP TABLE #Inclusion_1;


CREATE TABLE #included_events

DISTKEY(person_id)
AS
WITH
cteIncludedEvents(event_id, person_id, start_date, end_date, op_start_date, op_end_date, ordinal)
AS
(
  SELECT event_id, person_id, start_date, end_date, op_start_date, op_end_date, ROW_NUMBER() OVER (partition by person_id  ORDER BY start_date  ASC ) as ordinal
  from
  (
    select Q.event_id, Q.person_id, Q.start_date, Q.end_date, Q.op_start_date, Q.op_end_date, SUM(coalesce(POWER(cast(2 as bigint), I.inclusion_rule_id), 0)) as inclusion_rule_mask
    from #qualified_events Q
    LEFT JOIN #inclusion_events I on I.person_id = Q.person_id and I.event_id = Q.event_id
    GROUP BY Q.event_id, Q.person_id, Q.start_date, Q.end_date, Q.op_start_date, Q.op_end_date
  ) MG -- matching groups

  -- the matching group with all bits set ( POWER(2,# of inclusion rules) - 1 = inclusion_rule_mask
  WHERE (MG.inclusion_rule_mask = POWER(cast(2 as bigint),2)-1)

)

SELECT
event_id,  person_id , start_date, end_date, op_start_date, op_end_date

FROM
cteIncludedEvents Results
WHERE Results.ordinal = 1
;



-- generate cohort periods into #final_cohort
CREATE TABLE #cohort_rows

DISTKEY(person_id)
AS
WITH
cohort_ends (event_id, person_id, end_date)
AS
(
	-- cohort exit dates
  -- By default, cohort exit at the event's op end date
select event_id, person_id, op_end_date as end_date from #included_events
),
first_ends (person_id, start_date, end_date) as
(
	select F.person_id, F.start_date, F.end_date
	FROM (
	  select I.event_id, I.person_id, I.start_date, E.end_date, ROW_NUMBER() OVER (partition by I.person_id, I.event_id  ORDER BY E.end_date ) as ordinal
	  from #included_events I
	  join cohort_ends E on I.event_id = E.event_id and I.person_id = E.person_id and E.end_date >= I.start_date
	) F
	WHERE F.ordinal = 1
)

SELECT
 person_id , start_date, end_date

FROM
first_ends;

CREATE TABLE #final_cohort

DISTKEY(person_id)
AS
WITH
cteEndDates (person_id, end_date)
AS
(
	SELECT
		person_id
		, DATEADD(day,CAST(-1 * 0 as bigint),event_date)  as end_date
	FROM
	(
		SELECT
			person_id
			, event_date
			, event_type
			, MAX(start_ordinal) OVER (PARTITION BY person_id ORDER BY event_date, event_type ROWS UNBOUNDED PRECEDING) AS start_ordinal
			, ROW_NUMBER() OVER (PARTITION BY person_id  ORDER BY event_date, event_type ) AS overall_ord
		FROM
		(
			SELECT
				person_id
				, start_date AS event_date
				, -1 AS event_type
				, ROW_NUMBER() OVER (PARTITION BY person_id  ORDER BY start_date ) AS start_ordinal
			FROM #cohort_rows

			UNION ALL


			SELECT
				person_id
				, DATEADD(day,CAST(0 as bigint),end_date) as end_date
				, 1 AS event_type
				, NULL
			FROM #cohort_rows
		) RAWDATA
	) e
	WHERE (2 * e.start_ordinal) - e.overall_ord = 0
),
cteEnds (person_id, start_date, end_date) AS
(
	SELECT
		 c.person_id
		, c.start_date
		, MIN(e.end_date) AS end_date
	FROM #cohort_rows c
	JOIN cteEndDates e ON c.person_id = e.person_id AND e.end_date >= c.start_date
	GROUP BY c.person_id, c.start_date
)

SELECT
 person_id , min(start_date) as start_date, end_date

FROM
cteEnds
group by person_id, end_date
;

DELETE FROM @target_database_schema.@target_cohort_table where cohort_definition_id = @target_cohort_id;
INSERT INTO @target_database_schema.@target_cohort_table (cohort_definition_id, subject_id, cohort_start_date, cohort_end_date)
select @target_cohort_id as cohort_definition_id, person_id, start_date, end_date
FROM #final_cohort CO
;






TRUNCATE TABLE #cohort_rows;
DROP TABLE #cohort_rows;

TRUNCATE TABLE #final_cohort;
DROP TABLE #final_cohort;

TRUNCATE TABLE #inclusion_events;
DROP TABLE #inclusion_events;

TRUNCATE TABLE #qualified_events;
DROP TABLE #qualified_events;

TRUNCATE TABLE #included_events;
DROP TABLE #included_events;

TRUNCATE TABLE #Codesets;
DROP TABLE #Codesets;
