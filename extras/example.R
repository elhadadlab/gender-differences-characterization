# Parameters
PYTHON_PATH  <- 'C:\\Users\\tonys\\AppData\\Local\\Programs\\Python\\Python39'
PACKAGE_PATH <- 'c:/Users/tonys/Research/characterizationPaperPackage/'
DB           <- 'ohdsi_cumc_2021q1r2'
cdmDatabaseSchema    <- paste(DB, ".dbo", sep='')     # eg: "ohdsi_cumc_2021q1r2.dbo"
cohortDatabaseSchema <- paste(DB, ".results", sep='') # eg: "ohdsi_cumc_2021q1r2.results"
vocabularyDatabaseSchema <- cdmDatabaseSchema
cohortTable <- "cohort_characterization"              # this is the name of the output table

print(DB)
print(1+2)

# Make sure to install all dependencies (not needed if already done):
install.packages("SqlRender")
install.packages("DatabaseConnector")
install.packages("ParallelLogger")
install.packages("readr")
install.packages("tibble")
install.packages("dplyr")
install.packages("RJSONIO")
install.packages("devtools")
install.packages("rlang")
install.packages("reticulate")
install.packages('Rcpp')
# devtools::install_github("ROhdsiWebApi")
devtools::install_github("CohortDiagnostics")

# closeAllConnections()
# rm(list=ls())