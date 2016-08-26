/*----------------------------------
 - routes.js -
 vue-routerのSPAルーティングで利用される定義
----------------------------------*/

import Vue from 'vue'
import Router from 'vue-router'

Vue.use(Router)

import LoginView from "views/LoginView.vue"
import TimeoutView from "views/TimeoutView.vue"
import TopView from "views/TopView.vue"
import TradeView from "views/TradeView.vue"
// import Asset from "components/Asset"

var router = new Router({
  base: '/',
  routes: [
    {path: '/login',   component: LoginView, meta: {anonymous: true}},
    {path: '/timeout', component: TimeoutView, meta: {anonymous: true}},
    {path: '/top',     component: TopView},
    {path: '/trade',   component: TradeView},
    // {path: '/asset',   component: Asset},
    {path: '*',        redirect: '/login'}
  ]
})

var authenticated = true
router.beforeEach(function(route, redirect, next) {
  if (router.app) console.log(router.app.$children[0].logined)
  if (route.matched.some(m => m.meta.anonymous) || authenticated) {
    next()
  } else {
    redirect('/login')
  }
})

export default router


  // created: function() {
  //   this.initialized()
  //   this.checkLogin(() => this.logined = true)
  // },
  // methods: {
  //   checkLogin: function(success) {
  //     let failure = (err) => {
  //       Lib.Log.debug('ログイン情報を確認できませんでした')
  //       this.logined = false
  //       if (this.sessionValue()) {
  //         this.logoutSession()
  //         this.$route.router.go("/timeout")
  //       } else {
  //         this.$route.router.go("/login")
  //       }
  //     }
  //     Lib.Ajax.get(`${Param.Api.root}/account/loginStatus`, {}, success, failure)
  //   },
  //   logout: function(e) {
  //     this.logined = false
  //     this.logoutSession()
  //     this.apiPost('/logout', {}, ((v) => true), ((e)=> false))
  //     Lib.Log.debug('ログアウトしました')
  //     this.$route.router.go("/login")
  //   }
  // }
