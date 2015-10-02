### Vue向け オプションビルダー ###

Param = require "../variables.coffee"
Lib = require "./plain.coffee"

# Vue向けOptionビルダークラス
# ファイルアップロードや確認ダイアログ/単純表示等、シンプルな処理が必要なときは
# 本インスタンスのbuild実行戻り値(optionハッシュ)を元にVue.jsオブジェクトを作成してください。
# 作成方式は通常のVue.jsと同様です。(new Vue / Vue.extend / Vue.component)
# 本クラスを利用する際は初期化時に以下の設定が必要です。
# ・createdメソッド内でinitializedを呼び出す
# ---
# - 拡張属性[attr] -
# el.message: メッセージ表示用のエレメント属性(未指定時は.l-message)
# - 標準API
# show: パネルを表示する
# hide: パネルを非表示にする
# clear: グローバルエラー及び/コントロールエラーを初期化する
# scrollTop: スクロール位置を最上位へ移動する
# changeFlag: 指定要素(dataに対するパス)を反転した値にする(booleanを想定)
# apiGet: APIへのGET処理を行う
# apiPost: APIへのPOST処理を行う
# apiUpload: APIへのファイルアップロード処理(POST)を行う
# apiUrl: APIプリフィックスを付与したURLを返す
# apiFailure: API実行時の標準例外ハンドリング
# file: type=fileの値参照を返す。apiUploadのdata値へ設定する際に利用
# files: type=fileの値参照一覧を返す。
# flattenItem: 引数に与えたハッシュオブジェクトを結合文字列へ変換する
# paramArray:　配列(オブジェクト)をフラットなパラメタ要素へ展開
# renderWarning: 例外情報を画面へ反映する
# renderColumnWarning: コントロール単位の画面例外反映
class ComponentBuilder
  optionsOrigin: {}
  options: {}
  # 初期化コンストラクタ
  constructor: (options) ->
    if !options then return Lib.Log.error "コンストラクタ引数は必須です"
    @optionsOrigin = options ? {}
    @options = _.clone options
    @options.attr = @options.attr ? {}
    @options.attr.el = @options.attr.el ? {}
    @options.attr.el.message = @options.attr.el.message ? ".l-message"
    @options.attr.el.modelPrefix = @options.attr.el.modelPrefix ? ".l-model-"
    el = if typeof options.el is "function" then options.el() else "body"
    @options.el = -> el
    data = if typeof options.data is "function" then options.data() else options.data
    @options.data = -> data
    @options.methods = _.clone @defaultMethods
    if @optionsOrigin.methods then (for k, v of @optionsOrigin.methods then @options.methods[k] = v)
  # 初期化時のattributes設定を行います
  bindOptions: ->
    # 継承先で必要に応じて実装してください
  # 初期化時のmethods設定を行います
  bindMethods: ->
    # 継承先で必要に応じて実装してください
  # データ初期化処理を行います
  setup: ->
    # 継承先で必要に応じて実装してください
  build: ->
    # 定義指定に対する拡張挿入
    @bindOptions()
    @bindMethods()
    @setup()
    @options
  defaultMethods:
    attr: -> @$options.attr
    $main: -> $(@$el)
    $message: -> $(@attr().el.message, @$main())
    # 指定したdata要素キーに紐づくJQueryオブジェクトを返します
    # ※事前に対象コントロールに対し「.l-model-[dataKey]」が付与されている必要があります
    #   ネストオブジェクト対応としてkeyに「.」が含まれていた時は「-」である事を期待します。
    #   e.x. dataKey: hoge.hoga -> .l-model-hoge-hoga
    $obj: (key) ->
      key = key?.replace(/\./g, '-')
      @$main().find(@attr().el.modelPrefix + key)
    # 初期化処理
    initialized: ->
      @clear()
    # パネルを表示します
    show: (speed=100) ->
      @message()
      @clearMessage()
      @$main().show(speed)
      @scrollTop()
    # パネルを隠します
    hide: -> @$main().hide()
    # $message要素においてメッセージを表示します
    # message: メッセージ文字列
    # type: 表示種別(success/warning(default)/danger)
    message: (message, type="warning", speed=100) ->
      if message
        @$message().text message
        @$message().removeClassRegex /\btext-\S+/g
        @$message().removeClassRegex /\balert-\S+/g
        @$message().addClass "alert-#{type} alert-dismissible"
        @$message().show(speed)
        Lib.Log.debug message
      else @$message().hide()
    # グローバルエラー及び/コントロールエラーを初期化します
    clear: ->
      @message()
      @clearMessage()
    clearMessage: ->
      @$main().find(".l-message-group .l-message-group-item").remove()
      @$main().find(".l-message-group .input-group").unwrap()
      @$main().find(".l-message-group .form-control").unwrap()
    # スクロール位置を最上位へ移動します。elにはスクローラブルな親要素を指定してください
    scrollTop: (el = '.panel-body') -> $(el, @$main()).scrollTop(0)
    # 指定要素(dataに対するパス)を反転した値にします(booleanを想定)
    changeFlag: (flagPath) -> @$set(flagPath, !@$get(flagPath))
    # APIへのGET処理を行います
    apiGet: (path, data, success, failure = @apiFailure) ->
      Lib.Ajax.get @apiUrl(path), data, success, failure
    # APIへのPOST処理を行います
    apiPost: (path, data, success, failure = @apiFailure) ->
      Lib.Ajax.post @apiUrl(path), data, success, failure
    # APIへのファイルアップロード処理(POST)を行います
    # アップロード対象キーの値はfileメソッドを利用して定義するようにしてください
    apiUpload: (path, data, success, failure = @apiFailure) ->
      Lib.Ajax.upload @apiUrl(path), data, success, failure
    # APIプリフィックスを付与したURLを返します。
    apiUrl: (path) -> Param.Api.root + path
    # ファイルオブジェクトを取得します。apiUpload時のdataへ設定するアップロード値を取得する際に使用してください。
    file: (el) -> @files(el)[0]
    files: (el) -> $(el, @$main()).prop("files")
    # 引数に与えたハッシュオブジェクトでネストされたものを「.」付の一階層へ変換します。(引数は上書きしません)
    # {a: {b: {c: 'd'}}} -> {'a.b.c': 'd'}
    flattenItem: (item) -> Lib.Utils.flatten item
    #　配列(オブジェクト)をフラットなパラメタ要素へ展開します
    # 直接オブジェクトへ上書きしたい際は第3引数にハッシュオブジェクトを渡してください。
    # [{k: 'a'}, {k: 'b'}] -> {'params[0].k': 'a', 'params[1].k': 'b'}
    # ※jquery/SpringMVCでのネスト値不具合を解消します。
    # see http://stackoverflow.com/questions/5900840/post-nested-object-to-spring-mvc-controller-using-json
    paramArray: (array, keyName = "params", ret = {}) ->
      i = 0
      _.each array, (param) ->
        for key, value of param
          k = keyName + '[' + i + '].' + key
          ret[k] = value
        i++
      ret
    # API実行時の標準例外ハンドリングを行います。
    apiFailure: (error) ->
      @clearMessage()
      switch error.status
        when 200
          @message "要求処理は成功しましたが、戻り値の解析に失敗しました", "warning"
        when 400
          @message "入力情報を確認してください"
          @renderWarning $.parseJSON(error.responseText)
        when 401
          @message "機能実行権限がありません", "danger"
        else
          @message "要求処理に失敗しました", "danger"
    # 例外ハッシュ(要素キー: エラー文字列)をUI要素へ紐づけます。
    # 要素キーが空文字の時はグローバル例外として取り扱います。
    # 要素キーが設定されている時はrenderColumnWarningが呼び出されます。
    renderWarning: (warn) ->
      gwarn = null
      cwarns = {}
      for key, value of warn
        if key is ""
          gwarn = value[0]
        else
          cwarns[key] = value[0]
      # render global
      if gwarn then @message gwarn
      # render columns
      for key, message of cwarns
        @renderColumnWarning key, message
    # 指定したdata要素キーに警告エラーメッセージを付与します
    # UI側入力チェックなどで利用してください
    # ※事前に対象コントロールに対し「.l-model-[dataKey]」が付与されている必要があります
    renderColumnWarning: (key, message) ->
      $column = @$obj(key)
      if $column.length is 0 then return
      prevMsg = $column.parent().find(".l-message-group-item").text()
      if prevMsg is message then return # 同一メッセージはスルー
      $column.wrap '<div class="input-group l-message-group" />'
      $column.parent().append '<div class="l-message-group-item text-danger">' + message + '</div>'
    # for session
    # ハッシュ情報をログインセッションへ紐付けします
    loginSession: (sessionHash) -> Lib.Session.login(sessionHash)
    # ログインセッション情報を破棄します
    logoutSession: -> Lib.Session.logout()
    # セッション情報を取得します。key未指定時はログインセッションハッシュを返します
    sessionValue: (key = null) -> Lib.Session.value(key)
    # セッション情報を取得します。key未指定時はログインセッションハッシュを返します
    hasAuthority: (id) ->
      list = @sessionValue()?.authorities
      if list then _.contains(list, 'ROLE_' + id) else false
module.exports.ComponentBuilder = ComponentBuilder

# 検索を前提としたVueOptionビルダークラス
# 一覧パネル等で利用してください。ページング検索(自動ロード方式)もサポートしています。
# (API側でPagingListを返す必要があります)
# 本クラスを利用する際は初期化時に以下の設定が必要です。
# ・path属性の定義
# ・createdメソッド内でinitializedを呼び出す
# ---
# - 拡張属性[attr] -
# initialSearch: 初回検索を行うか(未指定時はtrue)
# paging: ページング検索を行うか(未指定時はfalse)
# el.search: 検索条件要素(未指定時は.l-panel-search)
# el.listBody: 一覧表示要素(未指定時は.l-list-body)
# el.listCount: 検索結果件数表示要素(未指定時は.l-list-cnt span)
# el.listWaitRow: 検索中の処理待ちアイコン要素(未指定時は.l-list-wait-row)
# - グローバル属性 -
# path: 検索APIパス(必須: 標準でapiUrlへ渡されるパス)
# - 予約Data[data] -
# searchFlag: 検索パネル表示状態
# items: 検索結果一覧
# page: ページング情報
# - 拡張メソッド[methods] -
# search: 検索する
# searchData: 検索条件をハッシュで生成する
# searchPath: 検索時の呼び出し先URLパスを生成する(apiUrlへ渡されるパス)
# layoutSearch: 検索後のレイアウト調整を行う(検索結果は@itemsに格納済)
class PanelListBuilder extends ComponentBuilder
  # 初期化時のattributes設定を行います
  bindOptions: ->
    attr = @options.attr
    attr.initialSearch = attr.initialSearch ? true
    attr.paging = attr.paging ? false
    attr.el.listBody = attr.el?.listBody ? ".l-list-body"
    attr.el.listCount = attr.el?.listCount ? ".l-list-cnt span"
    attr.el.listWaitRow = attr.el?.listWaitRow ? ".l-list-wait-row"
  # 初期化時のmethods設定を行います
  bindMethods: ->
    m = @options.methods
    for k, v of @overrideMethods then m[k] = v
    for k, v of @optionsOrigin.methods then m[k] = v
  # 初期化処理を行います
  setup: ->
    if !@options.path then throw new Error("path属性は必須です")
    data = @optionsOrigin.data ? {}
    if typeof data is "function" then data = data()
    data.items = data.items ? []
    data.page = if @options.attr.paging then {page: 1, total: 0} else null
    # 予約属性
    @options.data = -> data
  overrideMethods:
    $body: -> $(@attr().el.listBody, @$main())
    $waitRow: ->  $(@attr().el.listWaitRow, @$body())
    $count: -> $(@attr().el.listCount, @$main())
    # 初期化後処理。Vue.jsのcreatedメソッドから呼び出す事で以下の処理が有効化されます。
    # ・page情報を監視して検索結果の件数を表示する
    # ・listBody要素のbottomイベントに自動ページング処理を紐付け
    # ・初期検索を実行
    initialized: ->
      @$waitRow().hide()
      # イベント登録
      if @attr().paging
        @$watch 'page', (page) => @$count().text page.total ? "-1"
        @$panels.body.onBottom => @next()
      else
        @$watch 'items', (items) => @$count().text items.length
      # 初期化
      if @attr().initialSearch then @search()
    show: (speed=100) ->
      @initSearch()
      @$main().show(speed)
    # 検索パネルを表示する際の初期化処理
    initSearch: ->
      # 必要に応じて同名のメソッドで拡張実装してください
    # 検索処理を行います
    # 検索時の接続URLはsearchPath、検索条件はsearchDataに依存します。
    # 検索成功時の後処理はlayoutSearchを実装する事で差し込み可能です。
    search: ->
      @renderSearch()
    # 次ページの検索を行います。
    # 検索結果は一覧にそのまま追加されます。
    # ※タイミングによっては重複レコードが発生しますが、現時点ではそれらを取り除く処理は実装していません。
    next: ->
      @page.page = @page.page + 1
      Lib.Log.debug "- search next to " + @page.page
      @renderSearch(true)
    # 各種メッセージの他、検索結果を初期化します
    clear: ->
      @message()
      @clearMessage()
      @$set "items", []
    # 検索条件となるハッシュ情報を返します。
    searchData: -> {}
    # 検索時のURLパスを返します。ここで返すURLパスはapiUrlの引数に設定されます。
    searchPath: -> @$options.path
    # 検索を行います。appendがfalseのときは常に一覧を初期化します。
    renderSearch: (append = false) ->
      Lib.Log.debug "- search url: " + @apiUrl(@searchPath())
      param = @searchData()
      if append is false then @page?.page = 1
      if @attr().paging then param["page.page"] = @page.page
      if (0 < _.keys(param).length)
        Lib.Log.debug param
      if append is false then @clear()
      if @$waitRow().size() then @$waitRow().show()
      success = (data) =>
        @$waitRow().hide()
        @renderList(data, append)
        @layoutSearch()
      failure = (error) =>
        @$waitRow().hide()
        @apiFailure(error)
      @apiGet @searchPath(), param, success, failure
    # 検索結果をitemsへ格納します。
    # itemsがv-repeat等で画面要素と紐づいていた時は画面側にも内容が反映されます。
    renderList: (data, append) ->
      Lib.Log.debug "- search result -"
      Lib.Log.debug data
      list =
        if @attr().paging
          if data.page?
            @page = data.page
            data.list
          else
            Lib.Log.warn "page属性を含む検索結果を受信できませんでした"
            data
        else data
      if append
        _.each list, (item) =>
          @items.push item
      else @$set "items", list
    # 検索後の後処理を行います。
    # 検索結果となる一覧変数(items)が設定されている保証があります。
    layoutSearch: ->
      # 必要に応じて同名のメソッドで拡張実装してください
module.exports.PanelListBuilder = PanelListBuilder

# 特定情報の登録/変更/削除を前提としたOptionビルダークラス
# 情報に対するCRUD目的のパネルで利用してください。
# 本クラスを利用する際は初期化時に以下の設定が必要です。
# ・path属性の定義
# ・createdメソッド内でinitializedを呼び出す
# また利用する際は登録時にshowRegister。変更/削除時にshowUpdateを呼び出すようにしてください。
# ---
# - 拡張属性[attributes] -
# popup: ポップアップパネルの時はtrue
# spinner: register呼び出し時に呼び出し元のコントロール末尾に処理中スピナーを表示するか(標準はtrue)
# list: 親の検索リスト。設定時は更新完了後に検索を自動的に呼び出す。
# flattenItem: 更新時に与えたitemをflattenItem(ネストさせないオブジェクト化)とするか
# el.id: IDのinputに紐づく要素キー(未指定時は.l-model-id)
#   設定時はAPIパス構築時に値が利用されるほか、showUpdate利用時にdisabled状態となる。
# el.scrollBody: 例外発生時にスクロール制御する際の親el(未指定時は.panel-body)
# - グローバル属性 -
# path: CRUD-API基準パス(必須)。
#   pathが「/hoge/」の時。 登録時: /hoge/, 更新時: /hoge/{idPath}/, 削除時: /hoge/{idPath}/delete
# - 予約Data[data] -
# updateFlag: 更新モードの時はtrue
# item: 登録/更新情報
# - 拡張メソッド[methods] -
# showRegister: 登録モードで表示します
# initRegister: 登録モードで表示する際の初期化処理
# showUpdate: 変更モードで表示します
# initUpdate: 変更モードで表示する際の初期化処理(@item未設定)
# layoutUpdate: 変更モードで表示する際のレイアウト処理(@item設定済)
# register: 登録/変更します
# registerData: 登録/変更情報をハッシュで生成します
# registerPath: 登録先パスを生成します
# updatePath: 変更先パスを生成します
# deletePath: 削除先パスを生成します
# startAction: イベント開始処理を行います。(2度押し対応)
# endAction: イベント完了処理を行います。(2度押し対応)
# actionSuccess: 成功時のイベント処理
# actionSuccessMessage: 登録/変更/削除時の表示文言
# actionSuccessAfter: 成功時のイベント後処理
# actionFailure: 失敗時のイベント処理
# actionFailureAfter: 失敗時のイベント処理
class PanelCrudBuilder extends ComponentBuilder
  # 初期化時のattributes設定を行います
  bindOptions: ->
    attr = @options.attr
    attr.popup = attr.popup ? false
    attr.spinner = attr.spinner ? true
    attr.flattenItem = attr.flattenItem ? false
    attr.el.id = attr.el?.id ? "id"
    attr.el.scrollBody = attr.el?.scrollBody ? ".panel-body"
  # 初期化時のmethods設定を行います
  bindMethods: ->
    m = @options.methods
    for k, v of @overrideMethods then m[k] = v
    for k, v of @optionsOrigin.methods then m[k] = v
  # 初期化処理を行います
  setup: ->
    if !@options.path then throw new Error("path属性は必須です")
    data = @optionsOrigin.data ? {}
    if typeof data is "function" then data = data()
    data.item = data.item ? {}
    data.updateFlag = data.updateFlag ? false
    # 予約属性
    @itemOrigin = _.clone(data.item)
    @options.data = -> data
  overrideMethods:
    $id: -> $(@attr().el.modelPrefix + @attr().el.id, @$main())
    # 初期化後処理。Vue.jsのcreatedメソッドから呼び出す事で以下の処理が有効化されます。
    # ・ポップアップ指定に伴う自身の非表示制御
    initialized: ->
      if @attr().popup then @hide()
    # 登録/変更処理を行います。
    # 実行時の接続URLは前述のattributes解説を参照。実際の呼び出しはregisterPath/updatePathの値を利用。
    # 登録情報はregisterDataに依存します。
    # 登録成功時の後処理はactionSuccessAfter、失敗時の後処理はactionFailureAfterを実装する事で差し込み可能です。
    register: (event) ->
      $btn = @startAction(event)
      path = if @updateFlag then @updatePath() else @registerPath()
      Lib.Log.debug "- register url: " + @apiUrl(path)
      param = @registerData()
      if (0 < _.keys(param).length)
        Lib.Log.debug param
      success = (v) =>
        @actionSuccess(v)
        @endAction($btn)
      failure = (error) =>
        @actionFailure(error)
        @endAction($btn)
      @apiPost path, param, success, failure
    # イベント開始処理を行います。
    # 具体的にはイベントオブジェクト(ボタンを想定)をdisableにして末尾に処理中のspinnerを表示します。
    startAction: (event, el = null) ->
      if !event or !@attr().spinner then return null
      $btn = $(el ? event.target)
      $btn.disable()
      $btn.append('<i class="fa fa-spinner fa-spin l-spin-crud" />')
      $btn
    # イベント終了処理を行います。startActionの戻り値を引数に設定してください
    endAction: ($btn) ->
      if !$btn or !@attr().spinner then return
      $('.l-spin-crud', $btn).remove()
      $btn.enable()
    # 削除処理を行います。
    # 削除時の接続URLは前述のattributes解説を参照。実際の呼び出しはdeletePathの値を利用。
    # 削除成功時の後処理はactionSuccessAfter、失敗時の後処理はactionFailureAfterを実装する事で差し込み可能です。
    delete: (event) ->
      $btn = @startAction(event)
      path = @deletePath()
      Lib.Log.debug "- delete url: " + @apiUrl(path)
      success = (v) =>
        @actionSuccess(v)
        @endAction($btn)
      failure = (error) =>
        @actionFailure(error)
        @endAction($btn)
      @apiPost path, {}, success, failure
    # 各種メッセージの他、登録情報を初期化します
    clear: ->
      @message()
      @clearMessage()
      for k, v of @item then @$set "item.#{k}", null
    # 登録モードで自身を表示します
    showRegister: =>
      @hide()
      @updateFlag = false
      @clear()
      @$id().removeAttr("disabled")
      @initRegister()
      @show()
      Lib.Log.debug "show register [" + @$el?.className + "]"
    # 登録モードで表示する際の初期化処理を行います
    initRegister: ->
      # 必要に応じて同名のメソッドで拡張実装してください
    # 変更モードで自身を表示します
    showUpdate: (item) =>
      @hide()
      @updateFlag = true
      @clear()
      @$id().attr("disabled", "true")
      v = _.clone item
      @initUpdate(v)
      @item = if @attr().flattenItem is true then @flattenItem(v) else v
      @layoutUpdate()
      @show()
      Lib.Log.debug "show update [" + @$el?.className + "]"
    # 変更モードで表示する際の初期化処理を行います(@item未設定)
    # itemバインドがまだされていない点に注意してください。itemバインド後の処理が必要な時は
    # layoutUpdateを実装してください。
    initUpdate: (item) ->
      # 必要に応じて同名のメソッドで拡張実装してください
    # 変更モードで表示する際のレイアウト処理を行います(@item設定済)
    layoutUpdate: ->
      # 必要に応じて同名のメソッドで拡張実装してください
    # 登録時のURLパスを返します。ここで返すURLパスはapiUrlの引数に設定されます。
    registerPath: -> @$options.path
    # 更新時のURLパスを返します。ここで返すURLパスはapiUrlの引数に設定されます。
    updatePath: -> @registerPath() + @idPath() + "/"
    # 削除時のURLパスを返します。ここで返すURLパスはapiUrlの引数に設定されます。
    deletePath: -> @registerPath() + @idPath() + "/delete"
    # 更新/削除時に利用されるID情報を返します。
    # $idが定義されている時はその値、未定義の時はitem.idを利用します。
    # 各利用先で上書き定義する事も可能です。
    idPath: -> if 0 < @$id().size() then @$id().val() else @item.id
    # 登録/変更情報をハッシュで返します。
    # 標準ではitemの値をコピーして返します。
    registerData: ->
      data = _.clone @item
      for k, v of data
        if typeof v is "object" then data[k] = null
      data
    # 登録/変更/削除時の成功処理を行います。
    actionSuccess: (v) ->
      @$dispatch "action-success-crud", v
      if @attr().popup
        @clear()
        @hide()
      else
        if @updateFlag is false then @clear()
        msg = @actionSuccessMessage()
        @scrollTop()
        @message msg, "success"
      Lib.Log.debug "success"
      @actionSuccessAfter(v)
    # 登録/変更/削除時の表示文言を返します。
    actionSuccessMessage: ->
      if @updateFlag then "変更(削除)を完了しました" else "登録を完了しました"
    # 登録/変更/削除時の成功後処理を行います。
    actionSuccessAfter: (v) ->
      # 必要に応じて同名のメソッドで拡張実装してください
    # 登録/変更/削除時の失敗処理を行います。
    actionFailure: (error) ->
      @apiFailure(error)
      gwarn = null
      cwarns = {}
      switch error.status
        when 400
          warn = $.parseJSON(error.responseText)
          for key, value of warn
            if key is "" then gwarn = value[0] else cwarns[key] = value[0]
          if gwarn then @scrollTop() else @scrollToColumn(@attr().el.scrollBody, cwarns)
      @actionFailureAfter(error, gwarn, cwarns)
    # 登録/変更/削除時の失敗後処理を行います。
    actionFailureAfter: (error, gwarn, cwarns) ->
      # 必要に応じて同名のメソッドで拡張実装してください
    # 指定したbodyEl内の要素キーで例外を持つ最上位のコントロールへスクロール移動します。
    scrollToColumn: (bodyEl, cwarns) ->
      keys = _.keys(cwarns)
      if 0 < keys.length
        $body = $(bodyEl, @$main())
        $target = @$obj(keys[0])
        if 0 < $target.length
          $body.scrollTop($target.offset().top - $body.offset()?.top + $body.scrollTop())
        else @scrollTop()
module.exports.PanelCrudBuilder = PanelCrudBuilder
