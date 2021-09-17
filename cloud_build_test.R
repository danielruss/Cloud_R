library(tidyverse)
library(bigrquery)

Sys.setenv("BIGQUERY_TEST_PROJECT"="nih-nci-dceg-connect-dev")
bq_auth()
## read data from big query
sql <- "SELECT count(unique_key) FROM `bigquery-public-data.austin_311.311_service_requests`"
if (bq_testable()){
  tb <- bq_project_query(bq_test_project(),sql)
  x <- bq_table_download(tb)
  print(x)
}

