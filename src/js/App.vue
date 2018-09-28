<template lang="pug">
  .container-fluid
    header.navbar.navbar-expand-md.navbar-dark.bg-secondary.mb-2(v-if="logined")
      a.navbar-brand(href="/") App
      button.navbar-toggler(type="button", data-toggle="collapse", data-target="#navbarNav", aria-controls="navbarNav", aria-expanded="false", aria-label="Toggle navigation")
        span.navbar-toggler-icon
      #navbarNav.collapse.navbar-collapse
        ul.navbar-nav.mr-auto
          li.nav-item: router-link.nav-link(to="/top") "取扱い商品名 (TOP)" 
          li.nav-item: router-link.nav-link(to="/trade") 取引情報
          li.nav-item: router-link.nav-link(to="/asset") 口座資産
        ul.navbar-nav
          li.nav-item.dropdown
            a.nav-link.dropdown-toggle(href="#" data-toggle="dropdown" role="button" aria-haspopup="true" aria-expanded="false")
              span(v-text="user.name")
              |  様 
              span.caret
            ul.dropdown-menu.dropdown-menu-right(role="menu")
              li.dropdown-item: a
                i.fa.fa-fw.fa-user
                |  アカウント情報
              li.dropdown-divider
              li.dropdown-item: a(href="#" @click.prevent="logout")
                i.fa.fa-fw.fa-sign-out
                |  ログアウト
    header.navbar.navbar-expand-md.navbar-dark.bg-secondary(v-if="!logined")
      .navbar-brand App
    Message(global=true)
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
