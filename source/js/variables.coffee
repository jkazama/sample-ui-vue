#----------------------------------
# - variables.coffee -
# JS全般で利用されるグローバル変数定義
#----------------------------------

Constants = require "./constants.coffee"

module.exports =
  #### Param [System]
  System:
    logLevel: Constants.Level.DEBUG
  #### Param [Session]
  Session:
    key: 'so'

  #### Param [Api]
  Api:
    ## Time out for API request(Ajax) in milisecond
    timeout: 120000
    ## Time out for file upload in milisecond
    timeoutUpload: 300000

    #### for local-api-test
    ## API base path to Application Server
    root: "http://localhost:8080/api"

    #### for remote-api-test
    ## API base path to Application Server
    # root: "http://192.168.xxx.xxx/api"

    #### for production
    # root: "/api"
