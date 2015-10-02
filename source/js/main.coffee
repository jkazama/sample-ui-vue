# JQuery dependency
do require('./platform/jquery.coffee')

# Vue Extension
do require("./platform/vue-filter.coffee")
do require("./platform/vue-directive.coffee")

# Vue Routing
router = new VueRouter()
router.map require("./routes.coffee")

# App
App = Vue.extend(require("./app.vue"))
router.start App, "#app"
