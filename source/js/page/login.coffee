login = new Lib.Vue.Panel
  el: ".l-panel-login"
  data:
    loginId: ""
    password: ""
  methods:
    login: ->
      Lib.Log.debug @loginId
      success = (ret) =>
        Lib.Log.debug "ログインに成功しました - "
        @forward()
      failure = (error) =>
        @clearMessage()
        switch error.status
          when 400
            @message "IDまたはパスワードに誤りがあります"
          else
            @message "要求処理に失敗しました", "danger"
      @apiPost "/login", {loginId: @loginId, password: @password}, success, failure
    forward: ->
      @apiGet "/account/loginAccount", {}, (v) =>
        @loginSession(v)
        location.href = "index.html"
