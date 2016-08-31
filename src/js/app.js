/*----------------------------------
 - app.js -
 SPA Entry File
----------------------------------*/

// require('es6-promise').polyfill()

// JQuery Dependency
import jquery from 'platform/jquery'
jquery()

// Vue / Vue Routing
import Vue from 'vue'
import router from './router'

// Register Global Event
window.EventEmitter = new Vue()

// Vue Custom Filter
import * as filters from './filters'
Object.keys(filters).forEach(key => {
  Vue.filter(key, filters[key])
})

import directives from './directives'
directives()

// Application Initialize
import App from 'App.vue'
new Vue({
  router,
  template: '<App />',
  components: {
    'App': App
  }
}).$mount('#app')