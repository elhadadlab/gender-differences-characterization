characterizationPaperPackage
===============

This is an OHDSI study package that is how we are going to run our large-scale cohort characterizations. This package is built upon the OHDSI packages CohortDiagnostics and DatabaseConnector, as well as the R package Reticulate [which allows R packages to run Python]. This package was tested on a Windows machine, and requires that the user have read/write access on a SQL Server Instance.

In order to run this package, you will need to:

1. Copy/download/clone this repository; there should be a parent folder called *charaterizationPaperPackage* with all the relevant subfolders folder. For example, download the Zip file [here](https://github.com/toekneesunshine/characterizationPaperPackage) and open it; the default folder should be the *charaterizationPaperPackage* folder and extract it.

2. This project requires a few Python packages - I'm using Python 3.9 on Windows, and I included a *requirements.txt* which you'll need to install prior to running any code. To install Python, you can go to https://www.python.org/downloads/ and install a system-appropriate version. Using your Python 3+ instance, do a `pip install -r requirements.txt` using the requirements file after navigating to this directory from your Terminal window.

3. Minor changes are needed before running the package. Most importantly:
    - Fill in the empty *empty_credentials.csv* in the package's main repository with the appropriate fields
    - In *inst/py/settings.py* change line 10 [the `PATH` variable] to the `PATH` for the *characterizationPaperPackage's* *inst/py/* folder.
    - In *inst/py/settings.py* change line 20 [the `credentials` variable's `read_csv`] to the filepath for *empty_credentials.csv*
    - Fill in the various parameters at the top of *extras/CodeToRun.R*.  Specifically, the `PATH` to the credentials file, the system Python path [e.g. to the Anaconda installation or Python 3.9 installation with the various installed Python packages], etc.
    - In *inst/sql_server/sexdiff_cohort_reference_v5.sql*, change the 1st line to the name of your database [should match what you put into *empty_credentials.csv*]. Likewise, change line 155, line 166, and line 305.
    - In *inst/sql_server/all_condition_occurrence_summary.sql*, change the 1st line to the name of your database [again, should match what you put into *empty_credentials.csv*]. Likewise, change line 51.

4. Open the R project in R studio (e.g. by double-clicking on the *.Rproj* file).

5. Check *inst/settings/CohortsToCreateFinal.csv* to make sure it includes only those cohorts you are interested in. For now, let's stick to the ones already specified. The fields are:

    - **atlasId**: The cohort ID in ATLAS.
    - **atlasName**: The full name of the cohort.
    - **cohortId**: The cohort ID to use in the package. Usually the same as the cohort ID in ATLAS.
    - **name**: A short name for the cohort, to use to create file names.

You can now run the pipeline end-to-end. You can directly execute the full code by going to *extras/CodeToRun.R* and running from source, or running piecemeal. Please feel free to reach out to me at [tys2108@cumc.columbia.edu](mailto:tys2108@cumc.columbia.edu) if there are any issues. The outputs will be in the *outputs* folder, which you will need to send to us.
