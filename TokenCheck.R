library(googleAuthR)

#gar_auth(email = "druss@nih.gov")
app <- gargle::oauth_app_from_json(path="~/.gcpkeys/nih-nci-dceg-druss-clientid.json")
token_gar <- gargle::credentials_user_oauth2(app = app,scopes = "https://www.googleapis.com/auth/cloud-platform")
token_gcloud <- system("/Users/druss/Applications/google-cloud-sdk/bin/gcloud auth print-access-token",intern = TRUE)


res <- cr_jwt_with_httr(GET("https://deploy-test-1-raft3imjaq-ue.a.run.app/json"),token_gar$credentials$id_token)
print(prettify(content(res)))
res <- cr_jwt_with_httr(GET("https://deploy-test-1-raft3imjaq-ue.a.run.app/call"),token_gar$credentials$id_token)
print(fromJSON(content(res)[[1]]))
##https://oauth2.googleapis.com/tokeninfo?id_token=XYZ123
gar_token_info()
