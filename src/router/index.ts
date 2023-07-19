// Composables
import { nextTick } from "vue";
import { RouteRecordRaw, createRouter, createWebHashHistory } from "vue-router";
import { AppLogin, AppTimeout, AppUser, AppAdmin } from "@/views";
import { UserHome, UserTrade, UserAsset } from "@/views/user";
import { AdminHome, AdminTrade, AdminAsset, AdminSystem } from "@/views/admin";
import { checkLogin } from "@/libs/app";
import { useStore } from "@/store/app";

const routes: RouteRecordRaw[] = [
  {
    path: "/user",
    component: AppUser,
    children: [
      { path: "login", component: AppLogin, meta: { anonymous: true } },
      { path: "timeout", component: AppTimeout, meta: { anonymous: true } },
      { path: "home", component: UserHome },
      { path: "trade", component: UserTrade },
      { path: "asset", component: UserAsset },
    ],
  },
  {
    path: "/admin",
    component: AppAdmin,
    children: [
      {
        path: "login",
        component: AppLogin,
        props: { admin: true },
        meta: { anonymous: true },
      },
      {
        path: "timeout",
        component: AppTimeout,
        props: { admin: true },
        meta: { anonymous: true },
      },
      { path: "home", component: AdminHome },
      { path: "trade", component: AdminTrade },
      { path: "asset", component: AdminAsset },
      { path: "system", component: AdminSystem },
    ],
  },
  { path: "/:pathMatch(.*)*", redirect: "/user/login" },
];

const router = createRouter({
  history: createWebHashHistory(process.env.BASE_URL),
  routes,
});
router.beforeEach((to, from, next) => {
  if (
    to.matched
      .filter((m) => m.children.length == 0)
      ?.some((m) => m.meta.anonymous)
  ) {
    next();
  } else {
    nextTick(() => {
      const store = useStore();
      const current = store.logined;
      const prefix =
        from && 0 <= from.path.indexOf("/admin") ? "/admin" : "/user";
      checkLogin(
        () => next(),
        () => (current ? next(prefix + "/timeout") : next(prefix + "/login"))
      );
    });
  }
});
export default router;
