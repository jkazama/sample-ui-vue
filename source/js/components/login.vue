<template lang="jade">
  .container
    .col-xs-6.col-xs-offset-3
      .panel.panel-default.l-panel-login
        .panel-heading ログインフォーム
        .panel-body
          .alert.l-message
          input.form-control.l-model-loginId.l-row(type="text" placeholder="ログインID" v-model="loginId" v-on="keydown: login | key 'enter'")
          input.form-control.l-model-password(type="password" placeholder="パスワード" v-model="password" v-on="keydown: login | key 'enter'")
        .panel-footer
          button.btn.btn-block.btn-primary(v-on="click: login")
            i.fa.fa-fwfa-lg.fa-sign-in
            | 　ログイン
      .alert.alert-warning サーバ側（サンプル実装版）の認証モードを有効にした時は sample/sample でログインしてください。
</template>
<script lang="coffee">
Lib = require "../platform/plain.coffee"
Option = require "../platform/vue-option.coffee"
module.exports = new Option.PanelBuilder(
  attr:
    el:
      main: ".l-panel-login"
  data: ->
    loginId: ""
    password: ""
  methods:
    login: ->
      Lib.Log.debug @loginId
      success = (ret) =>
        Lib.Log.debug "ログインに成功しました - "
        @forward()
      failure = (error) =>
        @clearMessage()
        switch error.status
          when 400
            @message "IDまたはパスワードに誤りがあります"
          else
            @message "要求処理に失敗しました", "danger"
      @apiPost "/login", {loginId: @loginId, password: @password}, success, failure
    forward: ->
      @apiGet "/account/loginAccount", {}, (v) =>
        @loginSession(v)
        location.href = "index.html"
).build()
</script>