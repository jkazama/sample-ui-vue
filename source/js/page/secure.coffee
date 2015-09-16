#----------------------------------
# - secure.js.coffee -
# ログイン判断のセキュリティチェックを行います。
# APIサーバからログインセッションを取得できない時はタイムアウト画面へ遷移させます。
#----------------------------------

# セッションチェック
urlCheck = Param.Api.root + "/account/loginStatus"
success = (ret) ->
  # nothing
failure = (err) ->
  Lib.Log.debug 'ログイン情報を確認できませんでした'
  location.href = '/timeout.html'
Lib.Ajax.get urlCheck, {}, success, failure
