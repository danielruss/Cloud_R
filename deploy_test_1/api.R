# plumber.R
library(bigrquery)
library(googleAuthR)
library(jsonlite)
library(googleCloudRunner)

#' @serializer html
#' @get /
function(){
  return("<h1>Test 123</h1><hr><div>It worked...</div>")
}

#' @serializer json
#' @get /json
function(){
  l = list(greeting = "hi",calltime=Sys.time())
  #return(paste0( '{"greeting":"hi","datetime":\"',Sys.time(),"\"}"))
  return(toJSON(l,auto_unbox = TRUE))
}


#' @serializer json
#' @get /call
function(){
  l=list()
  l$project_id="nih-nci-dceg-druss"
  bigrquery::bq_auth()
  l$check_auth = googleAuthR::gar_setup_auth_check()
  l$has_token = bq_has_token()
  l$user = bq_user()
  l$valid_token = bq_token()$auth_token$validate()
  
  tryCatch( expr={
    l$in_try=TRUE
    sql <- "SELECT unique_key,complaint_description,status,incident_address,incident_zip,street_number,street_name,incident_zip,longitude,latitude
 FROM `bigquery-public-data.austin_311.311_service_requests` where owning_department = 'Public Health' limit 10"
    l$sql <- sql
    tb <- bq_project_query("nih-nci-dceg-druss",sql)
    l$past_tb = TRUE
    print("hi there!!!")
    l$res <- bq_table_download(tb,quiet = TRUE)
  },warning = function(w){
    print(w)
   l$warning = "there was a warning" 
   l$w = w
  },error = function(ec){
    print(ec)
    l$error <- "caught an error..." 
  },finally = {
    l$in_finally = TRUE
  }
    
  )
  return (toJSON(l,auto_unbox = TRUE))
}

append <- function(lst,key,value){
  lst$key <- c(lst$key,value)
}
