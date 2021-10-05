# Load the package
library(characterizationPaperPackage)

# Parameters [loaded from credentials.csv, which is not uploaded to Github!]
# CREDENTIALS  <- 'C:\\Users\\tonys\\Documents\\Research\\csv\\credentials.csv' # login credentials
private.data = read.csv(CREDENTIALS, fileEncoding = 'UTF-8-BOM')

# PYTHON_PATH  <- 'C:\\Users\\tonys\\AppData\\Local\\Programs\\Python\\Python39'

PYTHON_PATH  <- 'C:\\Users\\admin_jhardi10\\AppData\\Local\\Programs\\Python\\Python39'
PACKAGE_PATH <- 'c:/Users/tonys/Research/characterizationPaperPackage/'
DB           <- private.data$db

# You do not have to change the below [but you can]
# cdmDatabaseSchema    <- paste(DB, ".dbo", sep='')     # eg: "ohdsi_cumc_2021q1r2.dbo"
# cohortDatabaseSchema <- paste(DB, ".results", sep='') # eg: "ohdsi_cumc_2021q1r2.results"
# vocabularyDatabaseSchema <- cdmDatabaseSchema
cohortTable <- "testcharacterization"              # this is the name of the output table

connectionSpecifications <- cdmSources %>%
  dplyr::filter(sequence == 1) %>%
  dplyr::filter(database == 'truven_ccae')

dbms <- connectionSpecifications$dbms # example: 'redshift'
port <- connectionSpecifications$port # example: 2234
server <-
  connectionSpecifications$server # example: 'fdsfd.yourdatabase.yourserver.com"
cdmDatabaseSchema <-
  connectionSpecifications$cdmDatabaseSchema # example: "cdm"
vocabularyDatabaseSchema <-
  connectionSpecifications$vocabDatabaseSchema # example: "vocabulary"
databaseId <-
  connectionSpecifications$database # example: "truven_ccae"
userNameService = "redShiftUserName" # example: "this is key ring service that securely stores credentials"
passwordService = "redShiftPassword" # example: "this is key ring service that securely stores credentials"

cohortDatabaseSchema = paste0('scratch_', keyring::key_get(service = userNameService))
# scratch - usually something like 'scratch_grao'

connectionDetails <- DatabaseConnector::createConnectionDetails(
  dbms = dbms,
  user = keyring::key_get(service = userNameService),
  password = keyring::key_get(service = passwordService),
  port = port,
  server = server
)



# Optional: specify where the temporary files will be created:
options(andromedaTempFolder = "D:\\andromedaTemp")


# Details for connecting to the server:

# connectionDetails <- DatabaseConnector::createConnectionDetails(dbms = private.data$dbms,
#                                                                 server = private.data$server,
#                                                                 user = private.data$user,
#                                                                 password = private.data$password,
#                                                                 )

# For Oracle: define a schema that can be used to emulate temp tables:
oracleTempSchema <- NULL

# Start connection
conn <- DatabaseConnector::connect(connectionDetails)
# disconnect(conn)

# Instantiate cohorts:
pathToCsv <- system.file("settings", "CohortsToCreateFinal.csv", package = "characterizationPaperPackage")
cohortsToCreate <- readr::read_csv(pathToCsv, col_types = readr::cols())

# Delete table if it already exists, perhaps from a partial execution of the script.
# Commented out, because new users likely won't already have this table.
# sql = paste0('drop table ', cohortDatabaseSchema, '.', cohortTable, ';')

# sql_part2 = paste(sql_part1, DB, sep='')
# sql_part3 = paste(sql_part2, ".results.", sep = '')
# sql       = paste(sql_part3, cohortTable, sep = '')

#  DatabaseConnector::executeSql(
#   connection = conn,
#   sql = sql,
#   profile = FALSE,
#   progressBar = TRUE,
#   reportOverallTime = TRUE,
#   errorReportFile = file.path(getwd(), "errorReportSql.txt"),
#   runAsBatch = FALSE
# )

sql <- paste0('create table ', cohortDatabaseSchema, '.', cohortTable, '(
    cohort_definition_id bigint,
    subject_id bigint,
    cohort_start_date date,
    cohort_end_date date
);')

DatabaseConnector::executeSql(
  connection = conn,
  sql = sql,
  profile = FALSE,
  progressBar = TRUE,
  reportOverallTime = TRUE,
  errorReportFile = file.path(getwd(), "errorReportSql.txt"),
  runAsBatch = FALSE
)

for (i in 1:nrow(cohortsToCreate)) {
  # if (cohortsToCreate$name[i] > 2677) {
  writeLines(paste("Creating cohort:", cohortsToCreate$name[i]))
  sql <- SqlRender::loadRenderTranslateSql(sqlFilename = paste0(cohortsToCreate$name[i], ".sql"),
                                           packageName = "characterizationPaperPackage",
                                           dbms = attr(conn, "dbms"),
                                           oracleTempSchema = oracleTempSchema,
                                           cdm_database_schema = cdmDatabaseSchema,
                                           vocabulary_database_schema = vocabularyDatabaseSchema,
                                           
                                           target_database_schema = cohortDatabaseSchema,
                                           target_cohort_table = cohortTable,
                                           target_cohort_id = cohortsToCreate$cohortId[i])
  DatabaseConnector::executeSql(conn, sql) #}
}

# Change the below line to reflect where results can be saved. I'm assuming you're saving to cohortDatabaseSchema
results_database_schema = cohortDatabaseSchema # e.g. scratch_jhardi10
results_sex_diff_summary = 'sex_diff_summary'

# Drop table if it already exists from prior execution
sql <- paste0('drop table ', results_database_schema, '.', results_sex_diff_summary)
DatabaseConnector::executeSql(conn, sql)

# Creating table with @params failing, so just create table directly in R
sql <- paste0('create table ', results_database_schema, '.', results_sex_diff_summary, '(
      source_name varchar(255),
      concept_id bigint,
      concept_name varchar(255),
      num_persons bigint,
      prev_overall float,
      num_female bigint,
      prev_female float,
      num_male bigint,
      prev_male float,
      rr_female float,
      pct_female float,
      avg_age float,
      avg_age_female float,
      avg_age_male float,
      avg_age_diff float,
      std_dev_age float,
      std_dev_age_female float,
      std_dev_age_male float,
      min_age float,
      min_age_female float,
      min_age_male float,
      max_age float,
      max_age_female float,
      max_age_male float
) ;')

DatabaseConnector::executeSql(conn, sql)


# Run processing for all_condition_occurrence_summary.sql script
sql <- SqlRender::loadRenderTranslateSql(sqlFilename = "all_condition_occurrence_summary.sql",
                                         packageName = "characterizationPaperPackage",
                                         dbms = attr(conn, "dbms"),
                                         cdm_database = cdmDatabaseSchema,  # This will need to change to your DB name
                                         source_name = paste0("'", cdmDatabaseSchema,"'"), # Note the additional ''s.
                                         results_database_schema = results_database_schema,   # e.g. for me, I save to results
                                         results_sex_diff_summary = results_sex_diff_summary) 

DatabaseConnector::executeSql(conn, sql)

# Run processing sexdiff_cohort_reference_ver5.sql script
sql <- SqlRender::loadRenderTranslateSql(sqlFilename = "sexdiff_cohort_reference_ver5.sql",
                                         packageName = "characterizationPaperPackage",
                                         dbms = attr(conn, "dbms"),
                                         cdm_database = cdmDatabaseSchema,
                                         source_name = paste0("'", cdmDatabaseSchema,"'"),
                                         results_database_schema = results_database_schema,
                                         target_cohort_table = cohortTable,
                                         sexdiff_cohort_covarate_summary_v5 = "sexdiff_cohort_covarate_summary_v5",
                                         sexdiff_cohort_ttonset_v5 = "sexdiff_cohort_ttonset_v5",
                                         sexdiff_cohort_ttonset_summary_v5 = "sexdiff_cohort_ttonset_summary_v5")

DatabaseConnector::executeSql(conn, sql)



# Begin Python processing and output generation
# settings.py changes the os working directory [to allow relative paths]

use_python(PYTHON_PATH) # Python interpreter specified in parameters
# https://community.rstudio.com/t/rpytools-error-recurring-with-package-reticulate/66625
# If it does throw the rpytools error, it's just a runtime error that doesn't actually
# Inhibit the scripts. Just run the same lines twice and it fixes it...
sys <- import("sys", convert = TRUE) # Fixes run-time warning and error?
sys <- import("sys", convert = TRUE) # Fixes run-time warning and error?

if (attr(conn, "dbms") == "sql server") {
  py_run_file('inst/py/settings_sqlserver.py')
  py_run_file('creating_summaries_sqlserver.py')
  py_run_file('tfidf_vectorizer_sqlserver.py')
  py_run_file('generating_prevalence_graphs_sqlserver.py')
  py_run_file('diagnostic_delay_sqlserver.py') 
} else if (attr(conn, "dbms") == "redshift") {
  # If the first run throws a "ModuleNotFoundError: No module named 'rpytools.py',
  # on the settings file, just rerun the chunk again and it should run [it's a known issue]
  py_run_file('inst/py/settings_redshift.py')  
  py_run_file('creating_summaries_redshift.py')
  py_run_file('tfidf_vectorizer_redshift.py')
  py_run_file('generating_prevalence_graphs_redshift.py')
  py_run_file('diagnostic_delay_redshift.py') 
}

disconnect(connection = conn)

# For uploading the results. You should have received the key file from the study coordinator:
# keyFileName <- paste(PACKAGE_PATH, "study-data-site-covid19.dat") #TODO: Talk to Sena
# userName <- "study-data-site-covid19"

# When finished with reviewing the diagnostics, use the next command to upload the diagnostic results
# uploadDiagnosticsResults(outputFolder, keyFileName, userName)


# When finished with reviewing the results, use the next command upload study results to OHDSI SFTP
# server: uploadStudyResults(outputFolder, keyFileName, userName)

# example <- DatabaseConnector::querySql(conn, "select * from ohdsi_cumc_2021q1r2.results.pbr_sexdiff_cohort_covarate_summary_v5 where cohort_definition_id = 11117")

