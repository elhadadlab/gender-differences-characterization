pathToCsv <- system.file("settings", "CohortsToCreateFinal.csv", package = "characterizationPaperPackage")
cohortsToCreate <- readr::read_csv(pathToCsv, col_types = readr::cols())


for (i in 1:nrow(cohortsToCreate)) {
  # if (cohortsToCreate$name[i] > 2677) {
  writeLines(paste("Creating cohort:", cohortsToCreate$name[i]))
  sql <- SqlRender::loadRenderTranslateSql(sqlFilename = paste0(cohortsToCreate$name[i], ".sql"),
                                           packageName = "characterizationPaperPackage",
                                           dbms = "redshift",
                                           cdm_database_schema = cdmDatabaseSchema,
                                           vocabulary_database_schema = vocabularyDatabaseSchema,
                                           
                                           target_database_schema = cohortDatabaseSchema,
                                           target_cohort_table = cohortTable,
                                           target_cohort_id = cohortsToCreate$cohortId[i])
  DatabaseConnector::executeSql(conn, sql) #}
}