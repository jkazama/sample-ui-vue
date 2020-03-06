import Vue from "vue";
import VueRouter from "vue-router";

import LoginView from "@/views/LoginView.vue";
import TimeoutView from "@/views/TimeoutView.vue";
import TopView from "@/views/TopView.vue";
import TradeView from "@/views/TradeView.vue";
import AssetView from "@/views/AssetView.vue";

Vue.use(VueRouter);

const router = new VueRouter({
  base: "/",
  routes: [
    { path: '/login',   component: LoginView, meta: { anonymous: true } },
    { path: "/timeout", component: TimeoutView, meta: { anonymous: true } },
    { path: "/top", component: TopView },
    { path: "/trade", component: TradeView },
    { path: "/asset", component: AssetView },
    { path: "*", redirect: "/top" }
  ]
});

// SPA ルーティング前のログインチェック差込
router.beforeEach((to, from, next) => {
  if (to.matched.some(m => m.meta.anonymous)) {
    next();
  } else {
    Vue.nextTick(() => router.app.$children[0].checkLogin(to, from, next))
  }
});
export default router;
