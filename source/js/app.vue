<style lang="sass"></style>

<template lang="jade">
  nav.navbar.navbar-default.navbar-static-top.l-nav-header(v-if="logined")
    .navbar-header
      a.navbar-brand(href="/") App
    ul.nav.navbar-nav
      li: a(v-link="{path: '/top'}") "取扱い商品名 (TOP)" 
      li: a(v-link="{path: '/trade'}") 取引情報
      li: a(v-link="{path: '/asset'}") 口座資産
    ul.nav.navbar-nav.navbar-right
      li.dropdown
        a.dropdown-toggle(href="#" data-toggle="dropdown" role="button" aria-haspopup="true" aria-expanded="false")
          | ○○ 様 
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
import Param from 'variables'
import * as Lib from 'platform/plain'
import * as Option from "platform/vue-option"
// ヘッダパネル
export default new Option.ComponentBuilder({
  data: {
    logined: false
  },
  created: function() {
    this.initialized()
    this.checkLogin(() => this.logined = true)
  },
  methods: {
    checkLogin: function(success) {
      let failure = (err) => {
        Lib.Log.debug('ログイン情報を確認できませんでした')
        this.$route.router.go("/timeout")
      }
      Lib.Ajax.get(`${Param.Api.root}/account/loginStatus`, {}, success, failure)
    },
    logout: function(e) {
      this.logined = false
      this.logoutSession()
      this.apiPost('/logout', {}, ((v) => true), ((e)=> false))
      Lib.Log.debug('ログアウトしました')
      this.$route.router.go("/login")
    }
  }
}).build()
</script>
