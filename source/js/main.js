// JQuery Dependency
import jquery from 'platform/jquery'
jquery()

// Vue Extension
import filter from 'platform/vue-filter'
import directive from 'platform/vue-directive'

filter()
directive()

// Vue Routing
import routes from "routes"

let router = new VueRouter()
router.map(routes)

// App
import AppComponent from "app"
router.start(Vue.extend(AppComponent), "#app")
