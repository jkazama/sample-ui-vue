<style lang="sass"></style>

<template lang="jade">
  nav.navbar.navbar-default.navbar-static-top.l-nav-header(v-if="logined")
    .navbar-header
      a.navbar-brand(href="/") App
    ul.nav.navbar-nav
      li: a(v-link="'/top'") "取扱い商品名 (TOP)" 
      li: a(v-link="'/trade'") 取引情報
      li: a(v-link="'/asset'") 口座資産
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
          li: a(href="#" v-on="click: logout")
            i.fa.fa-fw.fa-sign-out
            |  ログアウト
  nav.navbar.navbar-default.navbar-static-top(v-if="!logined")
    .navbar-header
      .navbar-brand App
  router-view
</template>

<script lang="coffee">
Param = require "./variables.coffee"
Lib = require "./platform/plain.coffee"
Option = require "./platform/vue-option.coffee"
# ヘッダパネル
module.exports = new Option.ComponentBuilder(
  data: ->
    logined: false
  created: ->
    @initialized()
    @checkLogin => @logined = true
  methods:
    checkLogin: (success) ->
      urlCheck = Param.Api.root + "/account/loginStatus"
      failure = (err) =>
        Lib.Log.debug 'ログイン情報を確認できませんでした'
        @$route.router.go("/timeout")
      Lib.Ajax.get urlCheck, {}, success, failure
    logout: (e) ->
      e.preventDefault()
      @logined = false
      @logoutSession()
      @apiPost '/logout', {}, ((v) -> true), ((e)-> false)
      Lib.Log.debug 'ログアウトしました'
      @$route.router.go("/login")
).build()
</script>
