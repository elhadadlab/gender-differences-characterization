Because of issues with Reticulate on the EC2 instance, we're going to just use PowerShell to
execute the 4 Python scripts at the end of the pipeline.

STEP 1: Open up PowerShell and navigate to the Python packages directory:
  - cd D:/Git/characterizationPaperPackage/inst/py/

STEP 2: Run the first Python summary generation script:
  - C:/Users/admin_jhardi10/AppData/Local/Programs/Python/Python39/python.exe creating_summaries_redshift.py

STEP 3: Run the second Python TF-IDF script:
  - C:/Users/admin_jhardi10/AppData/Local/Programs/Python/Python39/python.exe tfidf_vectorizer_redshift.py

STEP 4: Run the third Python prevalence graph script:
  - C:/Users/admin_jhardi10/AppData/Local/Programs/Python/Python39/python.exe generating_prevalence_graphs_redshift.py

STEP 5: Run the last Python script:
  - C:/Users/admin_jhardi10/AppData/Local/Programs/Python/Python39/python.exe diagnostic_delay_redshift.py
