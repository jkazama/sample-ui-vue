import login from "components/login"
import timeout from "components/timeout"
import top from "components/top"
import trade from "components/trade"
import asset from "components/asset"

export default {
  "/login":   {component: login},
  "/timeout": {component: timeout},
  "/":        {component: asset},
  "/top":     {component: top},
  "/trade":   {component: trade},
  "/asset":   {component: asset}
}