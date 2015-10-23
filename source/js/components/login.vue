<style lang="sass"></style>

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

<script lang="babel">
import * as Lib from "platform/plain"
import * as Option from "platform/vue-option"
export default new Option.ComponentBuilder({
  el: ".l-panel-login",
  data: {
    loginId: "",
    password: ""
  },
  methods: {
    login: function() {
      Lib.Log.debug(this.loginId)
      let success = (ret) => {
        Lib.Log.debug("ログインに成功しました - ")
        this.forward()
      }
      let failure = (error) => {
        this.clearMessage()
        switch (error.status) {
          case 400:
            this.message("IDまたはパスワードに誤りがあります")
            break
          default:
            this.message("要求処理に失敗しました", "danger")
        }
      }
      this.apiPost("/login", {loginId: this.loginId, password: this.password}, success, failure)
    },
    forward: function() {
      this.apiGet("/account/loginAccount", {}, (v) => {
        this.loginSession(v)
        location.href = "index.html"
      })
    }
  }
}).build()
</script>