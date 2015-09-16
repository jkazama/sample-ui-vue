#----------------------------------
# - variables.coffee -
# JS全般で利用されるグローバル変数定義
#----------------------------------

#### Param [System]
Param.System.logLevel = Lib.Level.DEBUG

#### Param [Session]
Param.Session =
  key: 'so'

#### Param [Api]
## Time out for API request(Ajax) in milisecond
Param.Api.timeout = 120000
## Time out for file upload in milisecond
Param.Api.timeoutUpload = 300000

#### for local-api-test
## API base path to Application Server
Param.Api.root = "http://localhost:8080/api"

#### for remote-api-test
## API base path to Application Server
# Param.Api.root = "http://192.168.xxx.xxx/api"

#### for production
# Param.Api.root = "/api"
