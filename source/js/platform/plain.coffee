#----------------------------------
# - plain.coffee -
# JS全般で利用されるグローバル処理定義
#----------------------------------

Constants = require "../constants.coffee"
Param     = require "../variables.coffee"

## ログユーティリティ
# variables.coffeeでログ出力レベルを変更させる事が可能です。
Log =
  debug: (msg) ->
    if @valid(Constants.Level.DEBUG) then @console "[DEBUG] ", msg
  info: (msg) ->
    if @valid(Constants.Level.INFO) then @console "[INFO] ", msg
  warn: (msg) ->
    if @valid(Constants.Level.WARN) then @console "[WARN] ", msg
  error: (msg) ->
    if @valid(Constants.Level.ERROR) then @console "[ERROR] ", msg
  valid: (checkLevel) ->
    Param.System.logLevel <= checkLevel
  console: (prefix, obj) ->
    if (console?) then console.log prefix, obj
module.exports.Log = Log

## 非同期API要求ユーティリティ
# JSON形式での接続前提とします。
$.ajaxSetup
  dataType: "json"
  cache: false
  timeout: Param.Api.timeout
  xhrFields:
    withCredentials: true

module.exports.Ajax =
  # GET形式でサーバ側へリクエスト処理をします。(非同期)
  get: (url, data = {}, success = @handleSuccess, failure = @handleFailure) ->
    $.ajax
      type: "GET"
      url: @requestUrl(url)
      data: data
    .done (data) =>
      if success? then success(data)
    .fail (error) =>
      @handlePreFailure(error)
      if failure? then failure(error)
  # GET形式でサーバ側へリクエスト処理をします。(同期)
  getSync: (url, data = {}, success = @handleSuccess, failure = @handleFailure) ->
    $.ajax
      type: "GET"
      url: @requestUrl(url)
      data: data
      async: false
    .done (data) =>
      if success? then success(data)
    .fail (error) =>
      @handlePreFailure(error)
      if failure? then failure(error)
  # POST形式でサーバ側へリクエスト処理をします。(非同期)
  post: (url, data = {}, success = @handleSuccess, failure = @handleFailure, async = true) ->
    $.ajax
      type: "POST"
      url: @requestUrl(url)
      data: data
    .done (data) =>
      if success? then success(data)
    .fail (error) =>
      @handlePreFailure(error)
      if failure? then failure(error)
  # POST形式でサーバ側へリクエスト処理をします。(同期)
  postSync: (url, data = {}, success = @handleSuccess, failure = @handleFailure) ->
    $.ajax
      type: "POST"
      url: @requestUrl(url)
      data: data
      async: false
    .done (data) =>
      if success? then success(data)
    .fail (error) =>
      @handlePreFailure(error)
      if failure? then failure(error)
  # 指定したURLに対するアップロード処理をします。
  # 指定されたハッシュデータはFormDataへ紐付けられて送信されます。
  upload: (url, data, success = @handleSuccess, failure = @handleFailure) ->
    form = new FormData()
    for k, v of data
      form.append k, v
    $.ajax
      type: 'POST'
      url: @requestUrl(url)
      processData: false
      contentType: false
      data: form
      timeout: Param.Api.timeoutUpload
    .done (data) =>
      if success? then success(data)
    .fail (error) =>
      @handlePreFailure(error)
      if failure? then failure(error)
  # 接続先URLパスを整形します。
  requestUrl: (url) -> url
  # リクエスト成功時の標準処理を行います。
  handleSuccess: (data) -> Log.info data
  # リクエスト失敗時の事前処理を行います。
  handlePreFailure: (error) ->
    switch error.status
      when 0
        Log.error "接続先が見つかりませんでした"
      when 200
        Log.error "戻り値の解析に失敗しました。JSON形式で応答が返されているか確認してください"
      when 400
        Log.warn error.statusText
      when 401
        Log.error "機能実行権限がありません"
      else
        Log.error error.statusText
  # リクエスト失敗時の処理を行います。
  handleFailure: (error) ->
    # nothing.

## UI側セッションユーティリティ
# WebStorage(LocalStrage)利用を前提としたセッション概念を提供します。
module.exports.Session =
  # ログインさせます。引数に与えたハッシュはWebStrage(Local)に保存されます。
  login: (sessionHash) ->
    @logout()
    @valueSet(Param.Session.key, sessionHash)
  # ログイン中のセッション情報を取得します。key未指定時はログイン情報を返します。
  value: (key=null) ->
    v = localStorage.getItem(key ? Param.Session.key)
    if v then JSON.parse(v) else null
  # セッション情報に値を設定します。リークしやすいため、安易な利用は避けてください。
  valueSet: (key, value) ->
    localStorage.setItem(key, if value then JSON.stringify(value) else null)
  # ログアウトさせます。個別にvalueSetした情報は忘れずにdeleteしてください。
  logout: ->
    @delete()
  # セッション情報の値を削除します。
  delete: (key = null) ->
    localStorage.removeItem(key ? Param.Session.key)
  # セッションを持っているか
  hasSession: -> @value()

## グローバルユーティリティ
module.exports.Utils =
  # URLの引数を解析してハッシュを返します
  parseQuery: (url = null) ->
    target = url ? window.location.search
    if !target then return {}
    idx = target.indexOf('?')
    query = if idx is -1 then target else target.substring(idx + 1)
    values = query.split('&')
    ret = {}
    for v in values
      pair = v.split('=')
      if pair and pair.length is 2
        ret[decodeURIComponent(pair[0])] = decodeURIComponent(pair[1])
    ret
  # 引数に与えたハッシュオブジェクトでネストされたものを「.」付の一階層へ変換します。(引数は上書きしません)
  # {a: {b: {c: 'd'}}} -> {'a.b.c': 'd'}
  # see http://stackoverflow.com/questions/19098797/fastest-way-to-flatten-un-flatten-nested-json-objects
  flatten: (data) ->
    ret = {}
    recurse = (v, prop) ->
      if Object(v) isnt v
        ret[prop] = v
      else if Array.isArray(v)
        for value, i in v
          recurse(value, prop + "[" + i + "]")
        if v.length is 0 then ret[prop] = []
      else
        empty = true
        for key, value of v
          empty = false
          recurse(value, if prop then prop + "." + key else key)
        if empty && prop
          ret[prop] = {}
    recurse(data, "")
    ret
