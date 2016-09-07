/*----------------------------------
 - app.js -
 SPA Entry File
----------------------------------*/

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

// Application Initialize
import App from 'App.vue'
new Vue({
  router,
  template: '<App ref="app" />',
  components: {
    'App': App
  }
}).$mount('#app')