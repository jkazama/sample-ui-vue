#----------------------------------
# - common.js.coffee -
# ヘッダ等、画面共通のパネル定義。
#----------------------------------

# ヘッダパネル
header = new Lib.Vue.Panel
  el: ".l-nav-header"
  created: ->
    $nav = $(".navbar-nav", @$panels.main)
    $nav.find("a[href='#{location.pathname}']").parent().addClass("active")
  methods:
    logout: ->
      Lib.Session.logout()
      @apiPost '/logout', {}
      Lib.Log.debug 'ログアウトしました'
      location.href = "/login.html"
