<template lang="pug">
  .container
    Message(global=true)
    .col-xs-6.col-xs-offset-3
      .panel.panel-default.l-panel-login
        .panel-heading ログインフォーム
        .panel-body
          InputText.l-row(placeholder="ログインID", v-model="loginId", @enter="login")
          InputText(placeholder="パスワード", v-model="password", password=true, @enter="login")
        .panel-footer
          CommandButton.btn-primary(@click="login", :updating="updating")
            i.fa.fa-fwfa-lg.fa-sign-in
            | 　ログイン
      .alert.alert-warning サーバ側（サンプル実装版）の認証モードを有効にした時は sample/sample でログインしてください。
</template>

<script lang="babel">
import {Level} from "constants"
import {Log} from "platform/plain"
import ViewBasic from "views/mixins/view-basic"
import api from "api/context"
export default {
  name: 'login-view',
  mixins: [ViewBasic],
  data() {
    return {
      loginId: "",
      password: "",
      updating: false
    }
  },
  methods: {
    login() {
      Log.debug(this.loginId)
      this.updating = true
      let success = (ret) => {
        this.updating = false
        Log.debug("ログインに成功しました - ")
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
      api.login({loginId: this.loginId, password: this.password}, success, failure)
    },
    forward() {
      api.loginAccount(v => {
        this.loginSession(v)
        this.$router.push("/asset")
      })
    }    
  }
}
</script>
