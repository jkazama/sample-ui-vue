// Composables
import { createRouter, createWebHashHistory } from "vue-router";
import AppLogin from "@/views/AppLogin.vue";
import AdminLogin from "@/views/AdminLogin.vue";
import AppTimeout from "@/views/AppTimeout.vue";
import AppHome from "@/views/AppHome.vue";
import AppTrade from "@/views/AppTrade.vue";
import AppAsset from "@/views/AppAsset.vue";
import AppSystem from "@/views/AppSystem.vue";
import { nextTick } from "vue";
import { checkLogin } from "@/libs/app";
import { useStore } from "@/store/app";

const routes = [
  { path: "/login", component: AppLogin, meta: { anonymous: true } },
  { path: "/admin", component: AdminLogin, meta: { anonymous: true } },
  { path: "/timeout", component: AppTimeout, meta: { anonymous: true } },
  { path: "/home", component: AppHome },
  { path: "/trade", component: AppTrade },
  { path: "/asset", component: AppAsset },
  { path: "/system", component: AppSystem },
  { path: "/:pathMatch(.*)*", redirect: "/login" },
];

const router = createRouter({
  history: createWebHashHistory(process.env.BASE_URL),
  routes,
});
router.beforeEach((to, from, next) => {
  if (to.matched.some((m) => m.meta.anonymous)) {
    next();
  } else {
    nextTick(() => {
      const store = useStore();
      const current = store.logined;
      checkLogin(
        () => next(),
        () => (current ? next("/timeout") : next("/login"))
      );
    });
  }
});
export default router;
