FROM gcr.io/gcer-public/googlecloudrunner:master
RUN install2.r bigrquery jsonlite googleAuthR readr
COPY ["./", "./"]
ENTRYPOINT ["R", "-e", "pr <- plumber::plumb(commandArgs()[4]); pr$run(host='0.0.0.0', port=as.numeric(Sys.getenv('PORT')))"]
CMD ["api.R"]
