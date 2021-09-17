# based on...
# https://code.markedmondson.me/googleCloudRunner/articles/cloudrun.html#quickstart-plumber-api

# By default, when you load the cloud runner library, it loads
# up your default authentication.  Somewhere along the line, my default
# authentication is in a different project,  there are ways around it.
# one way is to set the default authentication file per project.  
# This is equivalent to having and .Renviron file in the current directory.
# Mark Edmondson, the author of the googleCloudRunner suggests this strategy.
# you might want to heed his advice.  I choose not to, so...

# clear the default GCE_AUTH_FILE, which is a service account for connect_dev...
Sys.setenv("GCE_AUTH_FILE"="")  
Sys.setenv("GCE_AUTH_FILE"="~/.gcpkeys/nih-nci-dceg-druss-ecdbfbe6722b.json")
library(googleCloudRunner)
library(jsonlite)
## authenticate as the service account key.  This is  partularly important for those without full access.
## Only I have access to my key so anyone else will have to use your keys...
googleAuthR::gar_auth_service("~/.gcpkeys/nih-nci-dceg-druss-ecdbfbe6722b.json")
my_plumber_folder = "deploy_test_1"

## set the project/region/bucket...
## Again, you'll have to set this yourself.
## This is the service account that will be performing the CLOUD BUILD which
##   1. uploads your code into cloud storage (needs appropriate permission)
##   2. creates a container image 
##   3. deploys the container image to cloud run...
cr_project_set("nih-nci-dceg-druss")
cr_bucket_set("nih-nci-dceg-druss-cloudrunr")
cr_region_set("us-east1")
cr_email_set("r-to-cloud-build@nih-nci-dceg-druss.iam.gserviceaccount.com")


## If you want the api to be unauthenticated use:
##cr <- cr_deploy_plumber(my_plumber_folder)

# however cr_deploy_plumber does not allow requiring authentication...
# so...
cr <- cr_deploy_run(local = my_plumber_folder,allowUnauthenticated=FALSE)






## in order to call the api we need to authenticate with a Bearer token
## once again I am using the same service account, but it could be different 
## service account, it must be a cloud runner (+bq_data_owner)
## To get the jwt, you need the json key file and the url  There are multiple
## ways I'm going to hard code it, you dont have to do that...

# cr is defined by when you deploy, I chose to hard code the url
# I also hardcode the location of the key, you could have set a variable earlier and
# reused it...
#url = cr$status$url
url = "https://deploy-test-1-raft3imjaq-ue.a.run.app"

jwt <- cr_jwt_create(url,"~/.gcpkeys/nih-nci-dceg-druss-ecdbfbe6722b.json")
token <- cr_jwt_token(jwt,url)
print(token)

## If the token is NULL, we did something wrong, otherwise at this point we have the bearer token 


## make the call....
library(httr)
call_url = "https://deploy-test-1-raft3imjaq-ue.a.run.app/json"
prettify(content(cr_jwt_with_httr(GET(call_url),token)))

## make the call that look up info in BQ.....
call_url = "https://deploy-test-1-raft3imjaq-ue.a.run.app/call"
res<- cr_jwt_with_httr(GET(call_url),token)
results <- fromJSON(unlist(content(res)))
print(results)


## a function that I used during development....
deploy_and_test <- function(){
  
  if (file.exists("deploy_test_1.tar.gz")){
    message("removing old tarball...")
    unlink("deploy_test_1.tar.gz")
  }
  cr <- cr_deploy_run(local = my_plumber_folder,allowUnauthenticated=FALSE,launch_browser = FALSE)
  call_url = "https://deploy-test-1-raft3imjaq-ue.a.run.app/call"
  jsonlite::prettify(cr_jwt_with_httr(GET(call_url),token))
}
deploy_and_test()



### Let move on to sceduling...

## note: this should be a call to cr_run_schedule_http,
## but the function is no where to be found...  So I looked in
## github and recreated the code...

target <- HttpTarget(
  #httpMethod = http_method,
#  uri = uri,
  httpMethod = 'GET',
  uri = call_url,
  body = NULL,
  oidcToken = list(
    serviceAccountEmail = cr_email_get(),
    audience = call_url
  )
)

#cr_schedule("cloud-run-test-scheduled-1",
#            schedule = "*/2 * * * *",
#            httpTarget = target)
# min hour dayMonth Month dayWeek
cr_schedule("cloud-run-test-scheduled-1",
            schedule = "0 0 1 * *",
            httpTarget = target)
