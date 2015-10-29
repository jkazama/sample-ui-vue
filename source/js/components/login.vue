<style lang="sass"></style>

<template lang="jade">
  .container
    .col-xs-6.col-xs-offset-3
      .panel.panel-default.l-panel-login
        .panel-heading ログインフォーム
        .panel-body
          div(v-message="global")
          input.form-control.l-row(type="text" placeholder="ログインID" v-model="loginId" @keydown.enter="login")
          input.form-control(type="password" placeholder="パスワード" v-model="password" @keydown.enter="login")
        .panel-footer
          button.btn.btn-block.btn-primary(@click="login" v-disable:spinner="updating")
            i.fa.fa-fwfa-lg.fa-sign-in
            | 　ログイン
      .alert.alert-warning サーバ側（サンプル実装版）の認証モードを有効にした時は sample/sample でログインしてください。
</template>

<script lang="babel">
import {Level} from "constants"
import * as Lib from "platform/plain"
import * as Option from "platform/vue-option"
export default new Option.ComponentBuilder({
  el: ".l-panel-login",
  data: {
    loginId: "",
    password: "",
    updating: false
  },
  created: function() {
    this.initialized()
    if (this.isLogin()) {
      this.$route.router.go("/")
    }
  },
  methods: {
    login: function() {
      Lib.Log.debug(this.loginId)
      this.updating = true
      let success = (ret) => {
        this.updating = false
        Lib.Log.debug("ログインに成功しました - ")
        this.forward()
      }
      let failure = (error) => {
        this.updating = false
        switch (error.status) {
          case 400:
            this.messageError("IDまたはパスワードに誤りがあります", [], Level.WARN)
            break
          default:
            this.messageError("要求処理に失敗しました")
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