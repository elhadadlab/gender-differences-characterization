-- change select statements to match Truven or CMS data
-- use ohdsi_cumc_2021q1r2;
use @cdm_database

--for a set of cohorts
--stratify by gender, look at differences in age and prior conditions
IF OBJECT_ID(N'tempdb..#pbr_sexdiff_cohort_ref') IS NOT NULL
BEGIN
DROP TABLE #pbr_sexdiff_cohort_ref
END

-- drop table #pbr_sexdiff_cohort_ref;
create table #pbr_sexdiff_cohort_ref
(
  cohort_definition_id bigint,
  cohort_definition_name varchar(255)
);

-- HERA phenotypes
insert into #pbr_sexdiff_cohort_ref (cohort_definition_id, cohort_definition_name) values (11111, '[PL 24134003] Neck pain cohort: First occurrence of "neck pain" concept without descendants')
insert into #pbr_sexdiff_cohort_ref (cohort_definition_id, cohort_definition_name) values (11112, '[PL 24609003] Hypoglycemia disorder incident cohort: First occurrence + descendants with >=1095d prior observation')
insert into #pbr_sexdiff_cohort_ref (cohort_definition_id, cohort_definition_name) values (11113, '[PL 31317003] Dysphagia incident cohort: First occurrence of Dysphagia and Difficulty swallowing descendants with >=1095d prior observation')
insert into #pbr_sexdiff_cohort_ref (cohort_definition_id, cohort_definition_name) values (11114, '[PL 31967003] Nausea Events All Events of referent concept "Nausea + descendants" with 30 day gap')
insert into #pbr_sexdiff_cohort_ref (cohort_definition_id, cohort_definition_name) values (11115, '[PL 75860003] Constipation Events: all occurrence of referent concept + descendants with 30 days gap')
insert into #pbr_sexdiff_cohort_ref (cohort_definition_id, cohort_definition_name) values (11116, '[PL 80180003] Osteoarthritis incident cohort: First occurrence of osteoarthritis concept  with >=1095d prior observation')
insert into #pbr_sexdiff_cohort_ref (cohort_definition_id, cohort_definition_name) values (11117, '[PL 80502001] Osteoporosis referent concept incident cohort: First occurrence of referent concept + descendants with >=1095d prior observation')
insert into #pbr_sexdiff_cohort_ref (cohort_definition_id, cohort_definition_name) values (11118, '[PL 80809003] Rheumatoid arthritis at first diagnosis (no history of Rheumatoid arthritis)')
insert into #pbr_sexdiff_cohort_ref (cohort_definition_id, cohort_definition_name) values (11119, '[PL 81893003] Ulcerative colitis at first diagnosis with no history of ulcerative colitis')
insert into #pbr_sexdiff_cohort_ref (cohort_definition_id, cohort_definition_name) values (11120, '[PL 81931004] Psoriatic arthritis')
insert into #pbr_sexdiff_cohort_ref (cohort_definition_id, cohort_definition_name) values (11121, '[PL 132702003] Erythema multiforme  incident cohort: First occurrence of Erythema multiforme or Stevens Johnson Syndrome concept with >=1095d prior observation')
insert into #pbr_sexdiff_cohort_ref (cohort_definition_id, cohort_definition_name) values (11122, '[PL 132797003] Sepsis during hospitalization, defined by condition occurrences of sepsis conceptset occurring between start and end of inpatient visit')
insert into #pbr_sexdiff_cohort_ref (cohort_definition_id, cohort_definition_name) values (11123, '[PL 133444001] Thyroiditis referent concept incident cohort: First occurrence of referent concept + descendants with >=1095d prior observation')
insert into #pbr_sexdiff_cohort_ref (cohort_definition_id, cohort_definition_name) values (11124, '[PL 133834005] Atopic dermatitis and Eczema at first diagnosis')
insert into #pbr_sexdiff_cohort_ref (cohort_definition_id, cohort_definition_name) values (11125, '[PL 134442005] Systemic sclerosis or or localized scleroderma at first diagnosis')
insert into #pbr_sexdiff_cohort_ref (cohort_definition_id, cohort_definition_name) values (11126, '[PL 137977001] Jaundice referent concept incident cohort: First occurrence of referent concept + descendants with >=1095d prior observation')
insert into #pbr_sexdiff_cohort_ref (cohort_definition_id, cohort_definition_name) values (11127, '[PL 138379003] Chronic lymphoid leukemia, disease referent concept prevalent cohort: First occurrence of updated concept set + descendants (condition and observation domain)')
insert into #pbr_sexdiff_cohort_ref (cohort_definition_id, cohort_definition_name) values (11128, '[PL 138994001] Myelodysplastic syndrome referent concept incident cohort: First occurrence of referent concept + descendants with >=1095d prior observation')
insert into #pbr_sexdiff_cohort_ref (cohort_definition_id, cohort_definition_name) values (11129, '[PL 139803005] Transverse myelitis events, using diagnosis codes from Marrie MSRD 2018')
insert into #pbr_sexdiff_cohort_ref (cohort_definition_id, cohort_definition_name) values (11130, '[PL 140168003] Psoriasis at first diagnosis (no history of Psoriasis)')
insert into #pbr_sexdiff_cohort_ref (cohort_definition_id, cohort_definition_name) values (11131, '[PL 140352001] Acute myeloid leukemia, disease referent concept incident cohort: First occurrence of referent concept + descendants with >=1095d prior observation')
insert into #pbr_sexdiff_cohort_ref (cohort_definition_id, cohort_definition_name) values (11132, '[PL 140673001] Hypothyroidism referent concept incident cohort: First occurrence of referent concept + descendants with >=1095d prior observation')
insert into #pbr_sexdiff_cohort_ref (cohort_definition_id, cohort_definition_name) values (11133, '[PL 141456001] Chilblains referent concept incident cohort: First occurrence of referent concept + descendants with >=1095d prior observation')
insert into #pbr_sexdiff_cohort_ref (cohort_definition_id, cohort_definition_name) values (11134, '[PL 192671003] Gastrointestinal bleeding events, defined by condition occurrences of Gastrointestinal hemorrhage GI bleeding conceptset occurring between start and end of inpatient or ER visit')
insert into #pbr_sexdiff_cohort_ref (cohort_definition_id, cohort_definition_name) values (11135, '[PL 192675003] Primary biliary cirrhosis for first time in patients history, with exclusion of secondary biliary cirrhosis')
insert into #pbr_sexdiff_cohort_ref (cohort_definition_id, cohort_definition_name) values (11136, '[PL 194133001] Low back pain referent concept incident cohort: First occurrence of referent concept + descendants with >=1095d prior observation')
insert into #pbr_sexdiff_cohort_ref (cohort_definition_id, cohort_definition_name) values (11137, '[PL 194992001] Celiac disease referent concept incident cohort: First occurrence of referent concept + descendants with >=1095d prior observation')
insert into #pbr_sexdiff_cohort_ref (cohort_definition_id, cohort_definition_name) values (11138, '[PL 197320004] Acute kidney injury diagnosis during hospitalization, defined by condition occurrences of acute renal failure conceptset occurring between start and end of inpatient visit')
insert into #pbr_sexdiff_cohort_ref (cohort_definition_id, cohort_definition_name) values (11139, '[PL 197494004] Hepatitis C prevalent cohort:  First condition occurrence of Hepatitis C conceptset (with Viral Hepatitis Carrier, Cirrhosis of liver due to chronic hepatitis C)')
insert into #pbr_sexdiff_cohort_ref (cohort_definition_id, cohort_definition_name) values (11140, '[PL 197508001] Malignant tumor of urinary bladder referent concept incident cohort: First occurrence of referent concept + descendants with >=1095d prior observation')
insert into #pbr_sexdiff_cohort_ref (cohort_definition_id, cohort_definition_name) values (11141, '[PL 198571003] Cardiogenic shock by Vallabhajosyula, All events of Cardiogenic shock during inpatient or ER')
insert into #pbr_sexdiff_cohort_ref (cohort_definition_id, cohort_definition_name) values (11142, '[PL 198985001] Primary malignant neoplasm of kidney referent concept incident cohort: First occurrence of referent concept + descendants with >=1095d prior observation')
insert into #pbr_sexdiff_cohort_ref (cohort_definition_id, cohort_definition_name) values (11143, '[PL 199074003] Acute pancreatitis prevalent cohort: defined by condition occurrences of Acute pancreatitis conceptset occurring between start and end of inpatient or ER visit')
insert into #pbr_sexdiff_cohort_ref (cohort_definition_id, cohort_definition_name) values (11144, '[PL 200219001] Abdominal pain referent concept incident cohort: First occurrence of referent concept + descendants with >=1095d prior observation')
insert into #pbr_sexdiff_cohort_ref (cohort_definition_id, cohort_definition_name) values (11145, '[PL 201214001] Toxic shock syndrome referent concept incident cohort: First occurrence of referent concept + descendants with >=1095d prior observation')
insert into #pbr_sexdiff_cohort_ref (cohort_definition_id, cohort_definition_name) values (11146, '[PL 201254003] Type 1 diabetes mellitus incident cohort: First occurrence of Type 1 diabetes mellitus concept with >=1095d prior observation')
insert into #pbr_sexdiff_cohort_ref (cohort_definition_id, cohort_definition_name) values (11147, '[PL 201340001] Gastritis referent concept incident cohort: First occurrence of referent concept + descendants with >=1095d prior observation')
insert into #pbr_sexdiff_cohort_ref (cohort_definition_id, cohort_definition_name) values (11148, '[PL 201606003] Crohns disease for first time with no history (Thirumurthi)')
insert into #pbr_sexdiff_cohort_ref (cohort_definition_id, cohort_definition_name) values (11149, '[PL 201620001] Kidney stone referent concept incident cohort: First occurrence of referent concept + descendants with >=1095d prior observation')
insert into #pbr_sexdiff_cohort_ref (cohort_definition_id, cohort_definition_name) values (11150, '[PL 201826005] Type 2 diabetes mellitus incident cohort: First condition occurrence of Type 2 diabetes mellitus conceptset or Type 2 diabetes treatment or HbA1c > 6.5 and no prior observation of History of diabetes')
insert into #pbr_sexdiff_cohort_ref (cohort_definition_id, cohort_definition_name) values (11151, '[PL 254443003] Sjogrens syndrome at first diagnosis')
insert into #pbr_sexdiff_cohort_ref (cohort_definition_id, cohort_definition_name) values (11152, '[PL 255573003] Hospitalization for Chronic obstructive pulmonary disease, defined by inpatient visit with a primary condition occurrence of COPD conceptset')
insert into #pbr_sexdiff_cohort_ref (cohort_definition_id, cohort_definition_name) values (11153, '[PL 255848004] Pneumonia prevalent cohort: Episodes of pneumonia, defined by condition occurrences of pneumonia conceptset')
insert into #pbr_sexdiff_cohort_ref (cohort_definition_id, cohort_definition_name) values (11154, '[PL 257007001] Allergic rhinitis referent concept incident cohort: First occurrence of referent concept + descendants with >=1095d prior observation')
insert into #pbr_sexdiff_cohort_ref (cohort_definition_id, cohort_definition_name) values (11155, '[PL 257628003] Systemic lupus erythematosus (SLE) at first diagnosis')
insert into #pbr_sexdiff_cohort_ref (cohort_definition_id, cohort_definition_name) values (11156, '[PL 312327003] Acute myocardial infarction events, defined by condition occurrences of Acute myocardial Infarction conceptset occurring between start and end of inpatient or ER visit')
insert into #pbr_sexdiff_cohort_ref (cohort_definition_id, cohort_definition_name) values (11157, '[PL 312437003] Dyspnea prevalent cohort:  Episodes of dyspnea, defined by condition occurrences of shortness of breath (dyspnea) conceptset')
insert into #pbr_sexdiff_cohort_ref (cohort_definition_id, cohort_definition_name) values (11158, '[PL 312939001] Thromboangiitis obliterans referent concept incident cohort: First occurrence of referent concept + descendants with >=1095d prior observation')
insert into #pbr_sexdiff_cohort_ref (cohort_definition_id, cohort_definition_name) values (11159, '[PL 313217006] Atrial fibrillation incident cohort: First occurrence of Atrial fibrillation with descendants with >=1095d prior observation, removing family history code')
insert into #pbr_sexdiff_cohort_ref (cohort_definition_id, cohort_definition_name) values (11160, '[PL 313223001] Granulomatosis with polyangiitis referent concept incident cohort: First occurrence of referent concept + descendants with >=1095d prior observation')
insert into #pbr_sexdiff_cohort_ref (cohort_definition_id, cohort_definition_name) values (11161, '[PL 313459001] Sleep apnea referent concept incident cohort: First occurrence of referent concept + descendants with >=1095d prior observation')
insert into #pbr_sexdiff_cohort_ref (cohort_definition_id, cohort_definition_name) values (11162, '[PL 313800003] Thrombotic microangiopathy events, based on diagnosis codes from Reynolds AJKD 2003 and Perkins NDT 2006')
insert into #pbr_sexdiff_cohort_ref (cohort_definition_id, cohort_definition_name) values (11163, '[PL 314381003] Multi-system inflammatory syndrome (Kawasaki disease or toxic shock syndrome) episodes, defined by condition occurrences of Toxic shock syndrome or kawasaki disease conceptset')
insert into #pbr_sexdiff_cohort_ref (cohort_definition_id, cohort_definition_name) values (11164, '[PL 314383003] Myocarditis by Sundbøll, First diagnosis of custom codes from Sundbøll, during inpatient or outpatient')
insert into #pbr_sexdiff_cohort_ref (cohort_definition_id, cohort_definition_name) values (11165, '[PL 316139001] Heart failure referent concept incident cohort: First occurrence of referent concept + descendants with >=1095d prior observation')
insert into #pbr_sexdiff_cohort_ref (cohort_definition_id, cohort_definition_name) values (11166, '[PL 316866003] Hypertensive disorder prevalent cohort:  First condition occurrence of Hypertension conceptset')
insert into #pbr_sexdiff_cohort_ref (cohort_definition_id, cohort_definition_name) values (11167, '[PL 317009003] Hospitalization for Asthma, defined by inpatient visit with a primary condition occurrence of asthma conceptset')
insert into #pbr_sexdiff_cohort_ref (cohort_definition_id, cohort_definition_name) values (11168, '[PL 318736003] Migraine incident cohort: First occurrence of Migraine excluding abdominal migraine+ descendants excluding abdominal migraine with >=1095d prior observation')
insert into #pbr_sexdiff_cohort_ref (cohort_definition_id, cohort_definition_name) values (11169, '[PL 318800003] Gastroesophageal reflux disease incident cohort: First occurrence of GERD concept with >=1095d prior observation')
insert into #pbr_sexdiff_cohort_ref (cohort_definition_id, cohort_definition_name) values (11170, '[PL 319049003] Acute respiratory failure incident cohort: First occurrence of Acute respiratory failure conceptset with >=1095d prior observation')
insert into #pbr_sexdiff_cohort_ref (cohort_definition_id, cohort_definition_name) values (11171, '[PL 321052001] Peripheral vascular disease referent concept incident cohort: First occurrence of referent concept + descendants with >=1095d prior observation')
insert into #pbr_sexdiff_cohort_ref (cohort_definition_id, cohort_definition_name) values (11172, '[PL 372328001] Otitis media referent concept incident cohort: First occurrence of referent concept + descendants with >=1095d prior observation')
insert into #pbr_sexdiff_cohort_ref (cohort_definition_id, cohort_definition_name) values (11173, '[PL 373503003] Transient ischemic attack events, defined by condition occurrences of Transient cerebral Ischemia (TCA) conceptset occurring between start and end of inpatient or ER visit')
insert into #pbr_sexdiff_cohort_ref (cohort_definition_id, cohort_definition_name) values (11174, '[PL 374021003] Acute disseminated encephalomyelitis hospitalization events, using diagnosis codes from Minegishi 2019')
insert into #pbr_sexdiff_cohort_ref (cohort_definition_id, cohort_definition_name) values (11175, '[PL 374919003] Multiple Sclerosis (MS) at first diagnosis')
insert into #pbr_sexdiff_cohort_ref (cohort_definition_id, cohort_definition_name) values (11176, '[PL 374954001] Optic neuritis referent concept incident cohort: First occurrence of referent concept + descendants with >=1095d prior observation')
insert into #pbr_sexdiff_cohort_ref (cohort_definition_id, cohort_definition_name) values (11177, '[PL 376713003] Hemorrhagic stroke events, defined by condition occurrences of intracranial bleed Hemorrhagic stroke conceptset occurring between start and end of inpatient or ER visit')
--insert into #pbr_sexdiff_cohort_ref (cohort_definition_id, cohort_definition_name) values (11178, '[PL 378419003] Alzheimers disease by Imfeld Epilepsia, 2013')
insert into #pbr_sexdiff_cohort_ref (cohort_definition_id, cohort_definition_name) values (11179, '[PL 380378008] Epilepsy Moura 1')
insert into #pbr_sexdiff_cohort_ref (cohort_definition_id, cohort_definition_name) values (11180, '[PL 381270001] Parkinsons disease referent concept incident cohort: First occurrence of referent concept + descendants with >=1095d prior observation')
insert into #pbr_sexdiff_cohort_ref (cohort_definition_id, cohort_definition_name) values (11181, '[PL 381316003] Stroke events, defined by condition occurrences of Stroke (ischemic or hemorrhagic) conceptset occurring between start and end of inpatient or ER visit')
insert into #pbr_sexdiff_cohort_ref (cohort_definition_id, cohort_definition_name) values (11182, '[PL 432791003] Angioedema events, defined by condition occurrences of Angioedema conceptset occurring between start and end of inpatient or ER visit')
insert into #pbr_sexdiff_cohort_ref (cohort_definition_id, cohort_definition_name) values (11183, '[PL 432867001] Hyperlipidemia referent concept incident cohort: First occurrence of referent concept + descendants with >=1095d prior observation')
insert into #pbr_sexdiff_cohort_ref (cohort_definition_id, cohort_definition_name) values (11184, '[PL 432870003] Idiopathic thrombocytopenic purpura events, as defined by diagnosis codes from Shaw Platelets 2020')
insert into #pbr_sexdiff_cohort_ref (cohort_definition_id, cohort_definition_name) values (11185, '[PL 432870004] Thrombocytopenia events, as defined by diagnosis codes from Altomare ClinEpi 2016')
--insert into #pbr_sexdiff_cohort_ref (cohort_definition_id, cohort_definition_name) values (11186, '[PL 433736003] Obesity prevalent cohort:  Earliest of condition occurrence or observation of obesity diagnoses conceptset or BMI > 30 or body weight > 120kg')
insert into #pbr_sexdiff_cohort_ref (cohort_definition_id, cohort_definition_name) values (11187, '[PL 434119003] Hidradenitis at first diagnosis')
insert into #pbr_sexdiff_cohort_ref (cohort_definition_id, cohort_definition_name) values (11188, '[PL 434557003] Tuberculosis prevalent cohort:  First condition occurrence of Respiratory and pulmonary tuberculosis conceptset')
insert into #pbr_sexdiff_cohort_ref (cohort_definition_id, cohort_definition_name) values (11189, '[PL 434592003] B-cell lymphoma incident cohort: First occurrence of "B-cell lymphoma" with exclusions + descendants with >=1095d prior observation')
insert into #pbr_sexdiff_cohort_ref (cohort_definition_id, cohort_definition_name) values (11190, '[PL 435783003] Schizophrenia by Ren,  2005 and repeated in literature')
insert into #pbr_sexdiff_cohort_ref (cohort_definition_id, cohort_definition_name) values (11191, '[PL 436073003] Hospitalization for Psychosis, defined by inpatient visit with a primary condition occurrence of psychosis conceptset')
insert into #pbr_sexdiff_cohort_ref (cohort_definition_id, cohort_definition_name) values (11192, '[PL 436100003] Narcolepsy (generalized algorithm from literature)')
insert into #pbr_sexdiff_cohort_ref (cohort_definition_id, cohort_definition_name) values (11193, '[PL 436642004] Behcets syndrome custom concept (includes arthropathy) incident cohort: First occurrence of referent concept + descendants with >=1095d prior observation')
insert into #pbr_sexdiff_cohort_ref (cohort_definition_id, cohort_definition_name) values (11194, '[PL 436665001] Bipolar disorder referent concept incident cohort: First occurrence of referent concept + descendants with >=1095d prior observation')
insert into #pbr_sexdiff_cohort_ref (cohort_definition_id, cohort_definition_name) values (11195, '[PL 436676001] Posttraumatic stress disorder referent concept incident cohort: First occurrence of referent concept + descendants with >=1095d prior observation')
insert into #pbr_sexdiff_cohort_ref (cohort_definition_id, cohort_definition_name) values (11196, '[PL 436962003] Insomnia with disorders of maintaing sleep concept prevalent cohort: First occurrence of expanded concept + descendants (excluding hypo/hypersomnias)')
insert into #pbr_sexdiff_cohort_ref (cohort_definition_id, cohort_definition_name) values (11197, '[PL 437082001] Ankylosing spondylitis referent concept incident cohort: First occurrence of referent concept + descendants with >=1095d prior observation')
insert into #pbr_sexdiff_cohort_ref (cohort_definition_id, cohort_definition_name) values (11198, '[PL 437233001] Multiple myeloma referent concept incident cohort: First occurrence of referent concept + descendants with >=1095d prior observation')
insert into #pbr_sexdiff_cohort_ref (cohort_definition_id, cohort_definition_name) values (11199, '[PL 437541001] Glaucoma referent concept incident cohort: First occurrence of referent concept + descendants with >=1095d prior observation')
insert into #pbr_sexdiff_cohort_ref (cohort_definition_id, cohort_definition_name) values (11200, '[PL 438409001] Attention deficit hyperactivity disorder referent concept incident cohort: First occurrence of referent concept + descendants with >=1095d prior observation')
insert into #pbr_sexdiff_cohort_ref (cohort_definition_id, cohort_definition_name) values (11201, '[PL 439727004] HIV prevalent cohort: First occurrence of HIV excluding HIV-II conceptset')
insert into #pbr_sexdiff_cohort_ref (cohort_definition_id, cohort_definition_name) values (11202, '[PL 439776001] Autism spectrum disorder referent concept incident cohort: First occurrence of referent concept + descendants with >=1095d prior observation')
insert into #pbr_sexdiff_cohort_ref (cohort_definition_id, cohort_definition_name) values (11203, '[PL 440383003] Depressive disorder prevalent cohort, defined as the earliest condition occurrence of Depressive disorder conceptset with no teratment more than 30 days prior and no prior psychosies/mania')
insert into #pbr_sexdiff_cohort_ref (cohort_definition_id, cohort_definition_name) values (11204, '[PL 440417003] Pulmonary embolism events, defined by condition occurrences of Pulmonary embolism conceptset')
insert into #pbr_sexdiff_cohort_ref (cohort_definition_id, cohort_definition_name) values (11205, '[PL 440674001] Gout referent concept incident cohort: First occurrence of referent concept + descendants with >=1095d prior observation')
insert into #pbr_sexdiff_cohort_ref (cohort_definition_id, cohort_definition_name) values (11206, '[PL 440740001] Takayasus disease referent concept incident cohort: First occurrence of referent concept + descendants with >=1095d prior observation')
--insert into #pbr_sexdiff_cohort_ref (cohort_definition_id, cohort_definition_name) values (11207, '[PL 441202003] Anaphylactic reaction by Walsh (Mini-sentinial validated definition)')
insert into #pbr_sexdiff_cohort_ref (cohort_definition_id, cohort_definition_name) values (11208, '[PL 443387001] Malignant tumor of stomach referent concept incident cohort: First occurrence of referent concept + descendants with >=1095d prior observation')
insert into #pbr_sexdiff_cohort_ref (cohort_definition_id, cohort_definition_name) values (11209, '[PL 443454003] Ischemic stroke events, defined by condition occurrences of Ischemic stroke conceptset occurring between start and end of inpatient or ER visit')
insert into #pbr_sexdiff_cohort_ref (cohort_definition_id, cohort_definition_name) values (11210, '[PL 444044001] Acute tubular necrosis referent concept incident cohort: First occurrence of referent concept + descendants with >=1095d prior observation')
insert into #pbr_sexdiff_cohort_ref (cohort_definition_id, cohort_definition_name) values (11211, '[PL 4038838001] Non-Hodgkins lymphoma referent concept incident cohort: First occurrence of referent concept + descendants with >=1095d prior observation')
insert into #pbr_sexdiff_cohort_ref (cohort_definition_id, cohort_definition_name) values (11212, '[PL 4074815003] Inflammatory bowel disease')
insert into #pbr_sexdiff_cohort_ref (cohort_definition_id, cohort_definition_name) values (11213, '[PL 4091559001] Facial palsy referent concept incident cohort: First occurrence of referent concept + descendants with >=1095d prior observation')
insert into #pbr_sexdiff_cohort_ref (cohort_definition_id, cohort_definition_name) values (11214, '[PL 4103295003] ventricular arrhythmia or cardiac arrest during hospitalization, defined by condition occurrences of ventricular arrhythmia or cardiac arrest conceptset occurring between start and end of inpatient visit')
insert into #pbr_sexdiff_cohort_ref (cohort_definition_id, cohort_definition_name) values (11215, '[PL 4133004005] Deep vein thrombosis events, defined by condition occurrences of deep vein thrombosis conceptset')
insert into #pbr_sexdiff_cohort_ref (cohort_definition_id, cohort_definition_name) values (11216, '[PL 4164770003] Guillain-Barre syndrome inpatient (Arya et al, ScallenWalter et al, Iqbal et al, Anandan et al, Rasmussen et al. Baxter et al.)')
insert into #pbr_sexdiff_cohort_ref (cohort_definition_id, cohort_definition_name) values (11217, '[PL 4180790001] Malignant tumor of colon referent concept incident cohort: First occurrence of referent concept + descendants with >=1095d prior observation')
insert into #pbr_sexdiff_cohort_ref (cohort_definition_id, cohort_definition_name) values (11228, '[PL 4181343001] Malignant tumor of esophagus referent concept incident cohort: First occurrence of referent concept + descendants with >=1095d prior observation')
insert into #pbr_sexdiff_cohort_ref (cohort_definition_id, cohort_definition_name) values (11229, '[PL 4182210001] Dementia referent concept incident cohort: First occurrence of referent concept + descendants with >=1095d prior observation')
insert into #pbr_sexdiff_cohort_ref (cohort_definition_id, cohort_definition_name) values (11220, '[PL 4201096003] Aseptic meningitis by Perez-Vilar (specific codes for meningitias excluding encephalitis diagnosis)')
insert into #pbr_sexdiff_cohort_ref (cohort_definition_id, cohort_definition_name) values (11221, '[PL 4245975003] Hepatic failure prevalent cohort:  First condition occurrence of hepatic failure, necrosis or coma conceptset')
insert into #pbr_sexdiff_cohort_ref (cohort_definition_id, cohort_definition_name) values (11222, '[PL 4246127001] Malignant neoplasm of liver referent concept incident cohort: First occurrence of referent concept + descendants with >=1095d prior observation')
insert into #pbr_sexdiff_cohort_ref (cohort_definition_id, cohort_definition_name) values (11223, '[PL 4256228001] Respiratory failure referent concept incident cohort: First occurrence of referent concept + descendants with >=1095d prior observation')
--insert into #pbr_sexdiff_cohort_ref (cohort_definition_id, cohort_definition_name) values (11224, '[PL 4266367003] Influenza custom cohort: Flu-like symptom episodes')
insert into #pbr_sexdiff_cohort_ref (cohort_definition_id, cohort_definition_name) values (11225, '[PL 4281232001] Type B viral hepatitis referent concept incident cohort: First occurrence of referent concept + descendants with >=1095d prior observation')
insert into #pbr_sexdiff_cohort_ref (cohort_definition_id, cohort_definition_name) values (11226, '[PL 4290976003] Giant cell arteritis at first diagnosis (no history of giant cell arteritis)')
insert into #pbr_sexdiff_cohort_ref (cohort_definition_id, cohort_definition_name) values (11227, '[PL 4311499001] Primary malignant neoplasm of respiratory tract referent concept incident cohort: First occurrence of referent concept + descendants with >=1095d prior observation')
insert into #pbr_sexdiff_cohort_ref (cohort_definition_id, cohort_definition_name) values (11228, '[PL 4322024001] Pulmonary hypertension referent concept incident cohort: First occurrence of referent concept + descendants with >=1095d prior observation')
insert into #pbr_sexdiff_cohort_ref (cohort_definition_id, cohort_definition_name) values (11229, '[PL 40479589003] Stress Cardiomyopathy as per Bhat et al (US 2020)')
insert into #pbr_sexdiff_cohort_ref (cohort_definition_id, cohort_definition_name) values (11230, '[PL 42535714003] Vasculitis associated with Antineutrophil cytoplasmic antibody (ANCA)-associated vasculitis')
insert into #pbr_sexdiff_cohort_ref (cohort_definition_id, cohort_definition_name) values (11231, '[PL 43530714003] Anosmia OR Hyposmia OR Dysgeusia episodes, defined by condition occurrences of Altered smell or taste conceptset')
insert into #pbr_sexdiff_cohort_ref (cohort_definition_id, cohort_definition_name) values (11232, '[PL 44784217001] Cardiac arrhythmia referent concept incident cohort: First occurrence of referent concept + descendants with >=1095d prior observation')
--insert into #pbr_sexdiff_cohort_ref (cohort_definition_id, cohort_definition_name) values (11233, '[PL 45763653003] Fracture of bone of hip region (dx + px) referent concept incident cohort (aged 50-89): First occurrence of hip fracture dx or procedure with >=1095d prior observation')
insert into #pbr_sexdiff_cohort_ref (cohort_definition_id, cohort_definition_name) values (11234, '[PL 46271022006] Chronic kidney disease incident cohort:  First condition occurrence of chronic kidney disease conceptset')
---

-- select * from #pbr_sexdiff_cohort_ref
-- drop table #sexdiff_cohort;
IF OBJECT_ID(N'tempdb..#sexdiff_cohort') IS NOT NULL
BEGIN
DROP TABLE #sexdiff_cohort
END

-- differences in Microsoft SQL server 2017 vs PostGreSQL
SELECT c1.COHORT_DEFINITION_ID, c1.SUBJECT_ID, c1.cohort_start_date, c1.cohort_end_date
INTO #sexdiff_cohort
FROM @cdm_database_schema.results.cohort_characterization c1 -- created in the R script!
INNER JOIN #pbr_sexdiff_cohort_ref cr1 on c1.COHORT_DEFINITION_ID = cr1.cohort_definition_id

-- select * from #sexdiff_cohort

IF OBJECT_ID(N'results.pbr_sexdiff_cohort_covarate_summary_v5') IS NOT NULL
BEGIN
DROP TABLE results.pbr_sexdiff_cohort_covarate_summary_v5
END

-- drop table results.pbr_sexdiff_cohort_covarate_summary_v5 --#pbr_sexdiff_cohort_covarate_summary;
SELECT @source_name as source_name, -- change to your DB name
       cr1.cohort_definition_id as cohort_definition_id,
       cr1.cohort_definition_name as cohort_definition_name,
       c1.concept_id as concept_id,
       c1.concept_name as concept_name,
       t3.num_persons_w_covariate as num_persons_w_covariate,
       t3.num_persons_total as num_persons_total,
       t3.pct_persons_w_covariate as pct_persons_w_covariate,
       t3.num_females as num_females,
       t3.num_males as num_males,
       t3.pct_females as pct_females,
       t3.prev_females as prev_females,
       t3.prev_males as prev_males,
       case when t3.prev_males > 0 then 1.0 * t3.prev_females / t3.prev_males else 0 end as rr_female --,
       --t3.avg_age as avg_age,
       --t3.avg_age_male as avg_age_male,
       --t3.avg_age_female as avg_age_female,
       --t3.avg_age_diff as avg_age_diff
INTO results.pbr_sexdiff_cohort_covarate_summary_v5 -- #pbr_sexdiff_cohort_covarate_summary
FROM
  (
  select t2.cohort_definition_id,
    t2.condition_concept_id,
    sum(t2.num_persons) as num_persons_w_covariate,
    sum(n1.num_persons) as num_persons_total,
    1.0*sum(t2.num_persons)/sum(n1.num_persons) pct_persons_w_covariate,
    max(case when t2.gender_concept_id = 8532 then t2.num_persons else 0 end) as num_females,
    max(case when t2.gender_concept_id = 8507 then t2.num_persons else 0 end) as num_males,
    1.0*max(case when t2.gender_concept_id = 8532 then t2.num_persons else 0 end)/sum(t2.num_persons) as pct_females,
    case when max(case when t2.gender_concept_id = 8532 then n1.num_persons else 0 end) > 0 then 100.0*max(case when t2.gender_concept_id = 8532 then t2.num_persons else 0 end)/max(case when t2.gender_concept_id = 8532 then n1.num_persons else 0 end) else 0 end as prev_females,
    case when max(case when t2.gender_concept_id = 8507 then n1.num_persons else 0 end) > 0 then  100.0*max(case when t2.gender_concept_id = 8507 then t2.num_persons else 0 end)/max(case when t2.gender_concept_id = 8507 then n1.num_persons else 0 end) else 0 end as prev_males--,
    --avg(1.0*t2.age) as avg_age,
    --avg(case when t2.gender_concept_id = 8532 then 1.0*age else null end) as avg_age_female,
    --avg(case when t2.gender_concept_id = 8507 then 1.0*age else null end) as avg_age_male,
    --avg(case when t2.gender_concept_id = 8532 then 1.0*age else null end) - avg(case when t2.gender_concept_id = 8507 then 1.0*age else null end) as avg_age_diff
  from
    (
    select
      t1.cohort_definition_id,
      t1.gender_concept_id,
      co1.condition_concept_id,
      count(distinct t1.person_id) as num_persons--,
      --t1.age
    from
      (
      select sc1.cohort_definition_id, p1.person_id, p1.gender_concept_id, year(cohort_start_date) - p1.year_of_birth as age, sc1.cohort_start_date
        from #sexdiff_cohort sc1
          inner join person p1
          on sc1.subject_id = p1.person_id
      ) t1
    inner join dbo.condition_occurrence co1
    on t1.person_id = co1.person_id
    and co1.condition_start_date >= dateadd(dd,-1095,t1.cohort_start_date)
    and co1.condition_start_Date < t1.cohort_start_date
    group by t1.cohort_definition_id,
      t1.gender_concept_id,
      co1.condition_concept_id--,
    --  t1.age
    ) t2
  inner join
    (
      select sc1.cohort_definition_id,
        gender_concept_id,
        count(person_id) as num_persons
      from #sexdiff_cohort sc1
      inner join dbo.person p1
      on sc1.subject_id = p1.person_id
      group by sc1.cohort_definition_id,
        gender_concept_id
    ) n1
  on t2.cohort_definition_id = n1.cohort_definition_id
  and t2.gender_concept_id = n1.gender_concept_id
  group by t2.cohort_definition_id,
    t2.condition_concept_id
  ) t3

inner join #pbr_sexdiff_cohort_ref cr1
  on t3.cohort_definition_id = cr1.cohort_definition_id
inner join concept c1
  on t3.condition_concept_id = c1.concept_id

-- save this output for visuals for prevalence [or, access using Python]
-- select * from results.pbr_sexdiff_cohort_covarate_summary_v5 where cohort_definition_id = 11117 --#pbr_sexdiff_cohort_covarate_summary

-- drop table #pbr_sexdiff_cohort_ttonset;
IF OBJECT_ID(N'results.pbr_sexdiff_cohort_ttonset_v5') IS NOT NULL
BEGIN
DROP TABLE results.pbr_sexdiff_cohort_ttonset_v5
END

-- drop table #pbr_sexdiff_cohort_ttonset;
IF OBJECT_ID(N'results.pbr_sexdiff_cohort_ttonset_summary_v5') IS NOT NULL
BEGIN
DROP TABLE results.pbr_sexdiff_cohort_ttonset_summary_v5
END

select
    a.person_id
  , h5.gender_concept_id
  , a.cohort_definition_id
  , h3.cohort_definition_name
  , a.condition_concept_id
  , h4.concept_name
  , a.cohort_start_date
  , a.condition_start_date
  , a.time_to_onset
  , (1.0*year(a.condition_start_date) - h5.year_of_birth) as age
INTO results.pbr_sexdiff_cohort_ttonset_v5 -- #pbr_sexdiff_cohort_ttonset
from (select
    h1.person_id
  , h2.cohort_start_date
  , h1.condition_concept_id
  , h1.condition_start_date
  , h2.cohort_definition_id
  , DATEDIFF(day, h1.condition_start_date, h2.cohort_start_date) as time_to_onset
  from (select
      m.person_id
    , m.condition_concept_id
    , n.concept_name
    , min(m.condition_start_date) as condition_start_date
  from dbo.condition_occurrence as m
    inner join dbo.concept as n
    on m.condition_concept_id=n.concept_id
  where m.condition_concept_id != '0'
  group by m.person_id, m.condition_concept_id, n.concept_name
  ) as h1
  inner join #sexdiff_cohort as h2
    on h1.person_id=h2.subject_id
    where DATEDIFF(day, h1.condition_start_date, h2.cohort_start_date) between 0 and 1095) as a
  inner join #pbr_sexdiff_cohort_ref as h3
    on a.cohort_definition_id=h3.cohort_definition_id
  inner join dbo.concept as h4
    on a.condition_concept_id=h4.concept_id
  inner join dbo.person as h5
      on a.person_id = h5.person_id
    where h5.gender_concept_id in ('8532','8507')
    -- 8532 female
    -- 8507 male
-- drop table results.pbr_sexdiff_cohort_ttonset_summary_v5 -- #pbr_sexdiff_cohort_ttonset_summary;
select @source_name as source_name
    , a.*
    , b.num_males
    , b.avg_time_onset_males
    , b.std_time_onset_males
    , a.num_females + b.num_males as num_persons
into results.pbr_sexdiff_cohort_ttonset_summary_v5 -- #pbr_sexdiff_cohort_ttonset_summary
from (select  cohort_definition_id
    , cohort_definition_name
    , condition_concept_id as concept_id
    , concept_name
    , count(gender_concept_id) as num_females
    , avg(time_to_onset)/365.25 as avg_time_onset_females
    , stdev(time_to_onset)/365.25 as std_time_onset_females
from results.pbr_sexdiff_cohort_ttonset_v5 -- #pbr_sexdiff_cohort_ttonset
where gender_concept_id = '8532'
group by cohort_definition_id, cohort_definition_name, condition_concept_id, concept_name) as a
inner join
(select cohort_definition_id
    , cohort_definition_name
    , condition_concept_id as concept_id
    , concept_name
    , count(gender_concept_id) as num_males
    , avg(time_to_onset)/365.25 as avg_time_onset_males
    , stdev(time_to_onset)/365.25 as std_time_onset_males
from results.pbr_sexdiff_cohort_ttonset_v5 -- #pbr_sexdiff_cohort_ttonset
where gender_concept_id = '8507'
group by cohort_definition_id, cohort_definition_name, condition_concept_id, concept_name) as b
on a.cohort_definition_id = b.cohort_definition_id
   and a.concept_id = b.concept_id
