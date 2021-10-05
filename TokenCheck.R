library(googleAuthR)
library(httr)
library(jsonlite)
Sys.setenv("GCE_AUTH_FILE"="")
library(googleCloudRunner)

#gar_auth(email = "druss@nih.gov")
#token_gar <- gargle::credentials_user_oauth2(app = app,scopes = "https://www.googleapis.com/auth/cloud-platform")
#token_gcloud <- system("/Users/druss/Applications/google-cloud-sdk/bin/gcloud auth print-identity-token",intern = TRUE)
#token_service <- gargle::credentials_service_account(scopes = 
#                                                       c("https://www.googleapis.com/auth/cloud-platform","https://www.googleapis.com/auth/userinfo.email","openid"),
#                                                     path = "~/.gcpkeys/nih-nci-dceg-druss-ecdbfbe6722b.json")

is_expired <- function(tkn,refresh=FALSE){
  isToken <- "Token" %in% class(tkn)
  if ( isToken ){
    strings <- strsplit(tkn$credentials$id_token, ".", fixed = TRUE)[[1]]
  } else{
    strings <- strsplit(tkn, ".", fixed = TRUE)[[1]]
  }

  obj <- fromJSON( rawToChar(jose::base64url_decode(strings[2])) )
  iat <- obj$iat
  exp <- obj$exp
  tz = "America/New_York"
  
  expired = Sys.time() > exp
  if (all(isToken,refresh,expired)){
    if (tkn$can_refresh()) {
      tkn$refresh()
      expired = Sys.time() > exp
    }
  }
  cat("issue: ", format( lubridate::as_datetime(iat,tz=tz),usetz=TRUE),
      "\nexpire: ",format( lubridate::as_datetime(exp,tz=tz),usetz=TRUE),
      "\ncurrent time:",format( lubridate::as_datetime(Sys.time(),tz=tz),usetz=TRUE ),"\n")

  
  return (expired)
}

check_res <- function(result){
  if ( http_status(result)$category == "Success"){
    print( fromJSON(unlist(content(result))) )
  } else{
    print(result)
  }
}




#token_gar <- token_fetch(scopes)


app <- gargle::oauth_app_from_json(path="~/.gcpkeys/nih-nci-dceg-druss-clientid.json")
scopes =  c("https://www.googleapis.com/auth/cloud-platform",
            "https://www.googleapis.com/auth/userinfo.email",
            "openid")
token_gar <- credentials_user_oauth2(scopes = scopes,app = app)

url = "https://deploy-test-1-raft3imjaq-ue.a.run.app"
jwt <- cr_jwt_create(url,"~/.gcpkeys/nih-nci-dceg-druss-ecdbfbe6722b.json")
token_service <- cr_jwt_token(jwt,url)

is_expired(token_gar,refresh = TRUE)
is_expired(token_service,refresh = TRUE)




url_call <- "https://deploy-test-1-raft3imjaq-ue.a.run.app/call"
res_1 <- 
  GET(url_call, config = add_headers(Authorization = sprintf("Bearer %s", token_gar$credentials$id_token)))
check_res(res_1)

res_2 <- 
  GET(url_call, config = add_headers(Authorization = sprintf("Bearer %s", token_service)))
check_res(res_2)


if ("googleCloudRunner" %in% .packages()){
  res <- googleCloudRunner::cr_jwt_with_httr(GET("https://deploy-test-1-raft3imjaq-ue.a.run.app/json"),token_gar$credentials$id_token)
  print(prettify(content(res)))
  res <- googleCloudRunner::cr_jwt_with_httr(GET("https://deploy-test-1-raft3imjaq-ue.a.run.app/json"),token_gcloud)
  print(prettify(content(res)))
  res <- googleCloudRunner::cr_jwt_with_httr(GET("https://deploy-test-1-raft3imjaq-ue.a.run.app/call"),token_gar$credentials$id_token)
  if ( http_status(res)$category == "Success"){
    print(fromJSON(content(res)[[1]]))
  } else{
    print(res)
  }
}


  ##https://oauth2.googleapis.com/tokeninfo?id_token=XYZ123

gar_token_info()



res <- 
  GET("https://deploy-test-1-raft3imjaq-ue.a.run.app/call",
      config = add_headers(Authorization = sprintf("Bearer %s", token_gar$credentials$id_token)))
if ( http_status(res)$category == "Success"){
  print(fromJSON(content(res)[[1]]))
} else{
  print(res)
}

res <- 
  GET("https://deploy-test-1-raft3imjaq-ue.a.run.app/call",config = add_headers(Authorization = sprintf("Bearer %s", token_service)))
if ( http_status(res)$category == "Success"){
  print(fromJSON(content(res)[[1]]))
} else{
  print(res)
}




is_expired(z)
if (is_expired(token_gar)){
  message("token is expired")
  if (token_gar$can_refresh()){
    message("refreshing token")
    token_gar <- token_gar$refresh()
  } else{
    
  }
}

decode_jwt <- function(token){
  isToken <- "Token" %in% class(token)
  if (isToken){
    (strings <- strsplit(token$credentials$id_token, ".", fixed = TRUE)[[1]])
  }else{
    (strings <- strsplit(token, ".", fixed = TRUE)[[1]])
  }
  ##(strings <- strsplit(token$credentials$id_token, ".", fixed = TRUE)[[1]])
  cat(rawToChar(jose::base64url_decode(strings[1])),"\n")
  cat(rawToChar(jose::base64url_decode(strings[2])),"\n")
  exp = as.numeric( fromJSON( rawToChar(jose::base64url_decode(strings[2]) ))$exp )
  cat("==== \n")
  cat("expires: ",format( lubridate::as_datetime(1632873429),usetz=TRUE ),"\n"  )
  cat("==== \n")
  cat(strings[3],"\n")
}
#decode_jwt(token_gar)

decode_jwt(token_gar)
decode_jwt(token_service)



bb <- token_gar$credentials$id_token
url = "https://deploy-test-1-raft3imjaq-ue.a.run.app/call"
GET(url, add_headers(Authorization = sprintf("Bearer: %s",bb)) )
GET(url, add_headers(Authorization = sprintf("Bearer: %s",token)) )
