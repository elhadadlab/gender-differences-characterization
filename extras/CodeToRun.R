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
sql = paste0('drop table ', cohortDatabaseSchema, '.', cohortTable, ';')

# sql_part2 = paste(sql_part1, DB, sep='')
# sql_part3 = paste(sql_part2, ".results.", sep = '')
# sql       = paste(sql_part3, cohortTable, sep = '')

 DatabaseConnector::executeSql(
  connection = conn,
  sql = sql,
  profile = FALSE,
  progressBar = TRUE,
  reportOverallTime = TRUE,
  errorReportFile = file.path(getwd(), "errorReportSql.txt"),
  runAsBatch = FALSE
)

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

# Run processing for all_condition_occurrence_summary.sql script
sql <- SqlRender::loadRenderTranslateSql(sqlFilename = "all_condition_occurrence_summary.sql",
                                         packageName = "characterizationPaperPackage",
                                         dbms = attr(conn, "dbms"),
                                         cdm_database = "ohdsi_cumc_2021q1r2",  # This will need to change to your DB name
                                         source_name = "'ohdsi_cumc_2021q1r2'") # Note the additional ''s.

DatabaseConnector::executeSql(conn, sql)


# Run processing sexdiff_cohort_reference_ver5.sql script
sql <- SqlRender::loadRenderTranslateSql(sqlFilename = "sexdiff_cohort_reference_ver5.sql",
                                         packageName = "characterizationPaperPackage",
                                         dbms = attr(conn, "dbms"),
                                         cdm_database = "ohdsi_cumc_2021q1r2",
                                         source_name = "'ohdsi_cumc_2021q1r2'")

DatabaseConnector::executeSql(conn, sql)

# Begin Python processing and output generation
# settings.py changes the os working directory [to allow relative paths]

use_python(PYTHON_PATH) # Python interpreter specified in parameters
# https://community.rstudio.com/t/rpytools-error-recurring-with-package-reticulate/66625
# If it does throw the rpytools error, it's just a runtime error that doesn't actually
# Inhibit the scripts.
sys <- import("sys", convert = TRUE) # Fixes run-time warning and error?
py_run_file('inst/py/settings.py')
py_run_file('creating_summaries.py')
py_run_file('tfidf_vectorizer.py')
py_run_file('generating_prevalence_graphs.py')
py_run_file('diagnostic_delay.py') 

disconnect(connection = conn)

# For uploading the results. You should have received the key file from the study coordinator:
# keyFileName <- paste(PACKAGE_PATH, "study-data-site-covid19.dat") #TODO: Talk to Sena
# userName <- "study-data-site-covid19"

# When finished with reviewing the diagnostics, use the next command to upload the diagnostic results
# uploadDiagnosticsResults(outputFolder, keyFileName, userName)


# When finished with reviewing the results, use the next command upload study results to OHDSI SFTP
# server: uploadStudyResults(outputFolder, keyFileName, userName)

# example <- DatabaseConnector::querySql(conn, "select * from ohdsi_cumc_2021q1r2.results.pbr_sexdiff_cohort_covarate_summary_v5 where cohort_definition_id = 11117")

