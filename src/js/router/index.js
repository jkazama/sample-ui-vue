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
import AssetView from "views/AssetView.vue"

var router = new Router({
  base: '/',
  routes: [
    {path: '/login',   component: LoginView, meta: {anonymous: true}},
    {path: '/timeout', component: TimeoutView, meta: {anonymous: true}},
    {path: '/top',     component: TopView},
    {path: '/trade',   component: TradeView},
    {path: '/asset',   component: AssetView},
    {path: '*',        redirect: '/top'}
  ]
})

// SPA ルーティング前のログインチェック差込
router.beforeEach((route, redirect, next) => {
  if (route.matched.some(m => m.meta.anonymous)) {
    next()
  } else {
    Vue.nextTick(() => router.app.$refs.app.checkLogin(route, redirect, next))
  }
})
export default router
