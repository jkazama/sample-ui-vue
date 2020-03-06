import Vue from "vue";
import './plugins/fontawesome'
import "./plugins/bootstrap-vue";
import App from "./App.vue";
import router from "./router";
import("./assets/sass/style.scss");

Vue.config.productionTip = false;

// Register Global Event
window.EventEmitter = new Vue();

// Vue Custom Filter
import * as filters from "./filters";
Object.keys(filters).forEach(key => {
  Vue.filter(key, filters[key]);
});

new Vue({
  router,
  render: h => h(App)
}).$mount("#app");
