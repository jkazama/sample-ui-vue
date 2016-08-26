/*----------------------------------
 - app.js -
 SPA Entry File
----------------------------------*/

// require('es6-promise').polyfill()

// JQuery Dependency
import jquery from 'platform/jquery'
jquery()

// Vue
import Vue from 'vue'
import App from 'App.vue'
import router from './router'
import * as filters from './filters'
import directives from './directives'
directives()

Object.keys(filters).forEach(key => {
  Vue.filter(key, filters[key])
})

// Application Vue Initialize
new Vue({
  router,
  template: '<App />',
  components: {
    'App': App
  }
}).$mount('#app')