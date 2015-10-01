# JQuery dependency
do require('./platform/jquery.coffee')

# Vue
Vue = require('vue')

# Vue Extension
do require("./platform/vue-filter.coffee")
do require("./platform/vue-directive.coffee")

# Vue Routing
VueRouter = require('vue-router')
Vue.use VueRouter

router = new VueRouter()
router.map require("./routes.coffee")

# App
App = Vue.extend(require("./app.vue"))
router.start App, "#app"
