<template lang="pug">
  .row.justify-content-center
    .col-md-4
      Message(global=true)
      .card.m-2
        .card-body
          .card-title.p-1: h5 ログインフォーム
          .card-text
            .mb-2
              InputText.l-row(placeholder="ログインID", v-model="loginId", @enter="login")
            .mb-2
              InputText(placeholder="パスワード", v-model="password", password=true, @enter="login")
            .mb-2
              CommandButton.btn-primary(@click="login", :updating="updating")
                i.fas.fa-lg.fa-sign-in-alt
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
