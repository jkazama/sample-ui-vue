# JQuery dependency
do require('platform/jquery')

# Vue Extension
do require("platform/vue-filter")
do require("platform/vue-directive")

# Vue Routing
router = new VueRouter()
router.map require("routes")

# App
App = Vue.extend(require("app"))
router.start App, "#app"
