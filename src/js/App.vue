<template lang="pug">
  .l-container-main
    nav.navbar.navbar-default.navbar-static-top.l-nav-header(v-if="logined")
      .navbar-header
        a.navbar-brand(href="/") App
      ul.nav.navbar-nav
        li: router-link(to="/top") "取扱い商品名 (TOP)" 
        li: router-link(to="/trade") 取引情報
        li: router-link(to="/asset") 口座資産
      ul.nav.navbar-nav.navbar-right
        li.dropdown
          a.dropdown-toggle(href="#" data-toggle="dropdown" role="button" aria-haspopup="true" aria-expanded="false")
            span(v-text="user.name")
            |  様 
            span.caret
          ul.dropdown-menu(role="menu")
            li: a(href="#")
              i.fa.fa-fw.fa-user
              |  アカウント情報
            li.divider
            li: a(href="#" @click.prevent="logout")
              i.fa.fa-fw.fa-sign-out
              |  ログアウト
    nav.navbar.navbar-default.navbar-static-top(v-if="!logined")
      .navbar-header
        .navbar-brand App
    router-view
</template>

<script lang="babel">
import * as Lib from "platform/plain"
import ViewBasic from "views/mixins/view-basic"
import api from "api/context"
export default {
  name: 'app-view',
  mixins: [ViewBasic],
  data() {
    return {
      logined: false
    }
  },
  computed: {
    user() {
      let logined = this.sessionValue()
      return logined ? logined : {}
    }
  },
  methods: {
    checkLogin(to, from, next) {
      let success = (v) => {
        this.logined = true
        next()
      }
      let failure = (err) => {
        Lib.Log.debug('ログイン情報を確認できませんでした')
        let current = this.logined // 事前ログイン状態に応じて表示ページを変更
        this.logoutLocal()
        current ? next('/timeout') : next('/login')
      }
      api.loginStatus(success, failure)
    },
    logout() {
      this.logoutLocal()
      api.logout()
      this.$router.push('/login')
    },
    logoutLocal() {
      this.logined = false
      Lib.Log.debug('ログアウトしました')
      this.logoutSession()
    }
  }
}
</script>
