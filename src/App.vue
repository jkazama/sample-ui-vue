<template>
  <div class="container-fluid">
    <header
      class="navbar navbar-expand-md navbar-dark bg-secondary mb-2"
      v-if="logined"
    >
      <a class="navbar-brand" href="/">App</a>
      <button
        class="navbar-toggler"
        type="button"
        data-toggle="collapse"
        data-target="#navbarNav"
        aria-controls="navbarNav"
        aria-expanded="false"
        aria-label="Toggle navigation"
      >
        <span class="navbar-toggler-icon" />
      </button>
      <div id="navbarNav" class="collapse navbar-collapse">
        <ul class="navbar-nav mr-auto">
          <li class="nav-item">
            <router-link class="nav-link" to="/top"
              >"取扱い商品名 (TOP)"</router-link
            >
          </li>
          <li class="nav-item">
            <router-link class="nav-link" to="/trade">取引情報</router-link>
          </li>
          <li class="nav-item">
            <router-link class="nav-link" to="/asset">口座資産</router-link>
          </li>
        </ul>
        <ul class="navbar-nav">
          <li class="nav-item dropdown">
            <a
              class="nav-link dropdown-toggle"
              href="#"
              data-toggle="dropdown"
              role="button"
              aria-haspopup="true"
              aria-expanded="false"
            >
              <span>{{ user.name }} 様 <span class="caret"/></span>
            </a>
            <ul class="dropdown-menu dropdown-menu-right" role="menu">
              <li class="dropdown-item">
                <a href="#"><font-awesome-icon icon="user" /> アカウント情報 </a>
              </li>
              <li class="dropdown-divider" />
              <li class="dropdown-item">
                <a href="#" @click.prevent="logout">
                  <font-awesome-icon icon="sign-out-alt" /> ログアウト
                </a>
              </li>
            </ul>
          </li>
        </ul>
      </div>
    </header>
    <header
      class="navbar navbar-expand-md navbar-dark bg-secondary mb-2"
      v-if="!logined"
    >
      <div class="navbar-brand">App</div>
    </header>
    <message :global="true" />
    <router-view />
  </div>
</template>

<script>
import { Log, Session } from "@/platform/plain";
import ViewBasic from "@/views/mixins/view-basic";
import api from "@/api/context";
export default {
  name: "app-view",
  mixins: [ViewBasic],
  data() {
    return {
      logined: false
    };
  },
  computed: {
    user() {
      let logined = Session.value();
      return logined ? logined : {name: "Anonymous"};
    }
  },
  methods: {
    checkLogin(to, from, next) {
      let success = v => {
        this.logined = true;
        next();
      };
      let failure = err => {
        Log.debug("ログイン情報を確認できませんでした");
        const current = this.logined; // 事前ログイン状態に応じて表示ページを変更
        this.logoutLocal();
        current ? next("/timeout") : next("/login");
      };
      api.loginStatus(success, failure);
    },
    logout() {
      this.logoutLocal();
      api.logout();
      this.$router.push("/login");
    },
    logoutLocal() {
      this.logined = false;
      Log.debug("ログアウトしました");
      Session.logout();
    }
  }
};
</script>
