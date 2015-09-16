#----------------------------------
# - vue.js.coffee -
# Vue.jsのコンポーネント拡張
#----------------------------------

# 本ファイルではVue.jsを薄くラップした汎用部品を提供しています。
# Vue.jsについては以下を参照してください。
# http://jp.vuejs.org/guide/
# ※内部でJQueryを積極的に利用しています。

### 汎用部品 ###

## Filter
# Vue.jsのカスタムフィルタを定義します。
# カスタムフィルタは「v-text」などで変数を表示する際に値のフォーマッティングなどを可能にします。
# 例: v-text="createDay | day"
# 参考: http://jp.vuejs.org/guide/custom-filter.html

# 値が未設定の場合に引数へ与えた標準ラベルを表示します。
Vue.filter 'defaultText', (v, label = "-") -> v ? label

# 値に改行が含まれていたときに<br>タグへ変換します。
Vue.filter 'multiline', (v) -> if v then v?.replace /\r?\n/g, "<br/>" else ""

# 日付を「/」区切りのフォーマットへ変換します。
Vue.filter 'day', (v) -> if v then moment(v).format("YYYY/MM/DD") else ""

# 日付を「年月日」形式のフォーマットへ変換します。
Vue.filter 'dayJp', (v) -> if v then moment(v).format("YYYY年MM月DD日") else ""

# 日時型を「yyyy/MM/dd hh:mm」形式へ変換します。引数にtrueを指定したときは秒も含めます。
Vue.filter 'date', (v, s = "true") ->
  fmt = "YYYY/MM/DD HH:mm"
  if s is "true" then fmt = fmt + ":ss"
  if v then moment(v).format(fmt) else ""

# 日時型を「hh:mm:ss」形式へ変換します。
Vue.filter 'time', (v) -> if v then moment(v).format("HH:mm:ss") else ""

# 日付を「yyyy/MM」形式へ変換します。
Vue.filter 'month', (v) -> if v then moment(v).format("YYYY/MM") else ""

# 日付を「yyyy年MM月」形式へ変換します。
Vue.filter 'monthJp', (v) -> if v then moment(v).format("YYYY年MM月") else ""

# 金額を「,」区切りへ変換します。
Vue.filter 'currencyYen', (v) ->
  if v then v.toString().replace(/(\d)(?=(\d\d\d)+(?!\d))/g, '$1,')
  else if v?.toString() is "0" then "0" else ""

# 金額を「,」区切りへ変換します。末尾に円を付与します。
Vue.filter 'currencyYenWith', (v) ->
  unit = " 円"
  if v then v.toString().replace(/(\d)(?=(\d\d\d)+(?!\d))/g, '$1,') + unit
  else if v?.toString() is "0" then "0" + unit else ""

# 数量を「,」区切りへ変換します。
Vue.filter 'quantity', (v) ->
  if v then v.toString().replace(/(\d)(?=(\d\d\d)+(?!\d))/g, '$1,')
  else if v?.toString() is "0" then "0" else ""

# 割合の末尾に%を付与します。
Vue.filter 'rate', (v) -> if v then v + " %" else ""

## Directive
# Vue.jsのカスタムディレクティブを定義します。
# カスタムディレクティブはHTMLエレメントに「v-datepicker」など、新しい拡張属性を加えるものです。
# 例: input type="text" v-datepicker="item.testDay"
# 参考: http://jp.vuejs.org/guide/custom-directive.html

# v-datepickerを定義したコンポーネントを日付選択コンポーネントへ変更します。
# bootstrap-datepickerを有効とします。
# 形式   [datepickerオプション] : [フィールドキー]
# 使用例 v-datepicker="item.testDay"
# 使用例 v-datepicker="'{autoclose: false}' : item.testDay"
Vue.directive "datepicker",
  bind: ->
    options = if @arg then eval('(' + @arg + ')') else {}
    @format = options.format ? "YYYY/MM/DD"
    @rawFormat = options.rawFormat ? "YYYYMMDD"
    @$input = $(@el).datepickerJpn(options)
    # JQuery側データ変更検知
    @$input.on "change", =>
      day = @vm.$get(@expression)
      jDay = @$input.val()?.replace(/\//g, '')
      if day isnt jDay
        if jDay.length in [4, 6, 8] then @vm.$set(@expression, jDay)
        else @vm.$set(@expression, null)
  # VM側データ変更検知
  update: (day) ->
    jDay = @$input.val()?.replace(/\//g, '')
    if day isnt jDay
      @$input.datepicker('update',
        if day then moment(day, @rawFormat).format(@format) else null)


### Vueパネル 基底クラス ###

# Vue拡張基底クラス
# ファイルアップロードや確認ダイアログ/単純表示等、シンプルな処理が必要なときは
# 本クラスを元にVue.jsオブジェクトを作成してください。
# 作成方式は通常のVue.jsと同様です。(コンストラクタ引数へハッシュ渡しされた情報を元に構築されます)
# ---
# - 拡張属性[attributes] -
# el.message: メッセージ表示用のエレメント属性(未指定時は.l-message)
# - グローバル属性 -
# $message: メッセージ要素のJQueryオブジェクト
# - パネル(JQuery)[$panels] -
# main: el指定されたパネルのJQueryオブジェクト
# - 標準API(差し替えする際は継承した先で上書きする必要有)
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
class Lib.Vue.Panel extends Vue
  # 初期化コンストラクタ。el未指定時は「.l-panel-main」を利用
  constructor: (v) ->
    if !v then return Lib.Log.error "コンストラクタ引数は必須です"
    # 拡張属性のプリセット
    v.el = v.el ? ".l-panel-main"
    v.data = v.data ? {}
    @attributes = v.attributes ? {}
    @attributes.el = @attributes.el ? {}
    @attributes.el.message = @attributes.el.message ? ".l-message"
    @$panels = v.panels ? {}
    @$panels.main = $(v.el)
    @$message = $(@attributes.el.message, @$panels.main)
    # 定義指定に対する拡張挿入
    @bindOptions(v)
    @bindPanels(v)
    @bindMethods(v)
    # 初期化
    @clear()
    @setup(v)
    super(v)
  # 初期化時のattributes設定を行います
  bindOptions: (v) ->
    # 継承先で必要に応じて実装してください
  # 初期化時の$panels設定を行います
  bindPanels: (v) ->
    # 継承先で必要に応じて実装してください
  # 初期化時のmethods設定を行います
  bindMethods: (v) ->
    # 継承先で必要に応じて実装してください
  # 初期化後処理を行います
  # 全ての初期化定義が終わったタイミングで呼び出されます
  setup: (v) ->
    # 継承先で必要に応じて実装してください
  # パネルを表示します
  show: (speed=100) =>
    @message()
    @clearMessage()
    @$panels.main.show(speed)
    @scrollTop()
  # パネルを隠します
  hide: => @$panels.main.hide()
  # $message要素においてメッセージを表示します
  # message: メッセージ文字列
  # type: 表示種別(success/warning(default)/danger)
  message: (message, type="warning", speed=100) =>
    if message
      @$message.text message
      @$message.removeClassRegex /\btext-\S+/g
      @$message.removeClassRegex /\balert-\S+/g
      @$message.addClass "alert-" + type
      @$message.show(speed)
      Lib.Log.debug message
    else @$message.hide()
  # グローバルエラー及び/コントロールエラーを初期化します
  clear: =>
    @message()
    @clearMessage()
  clearMessage: =>
    @$panels.main.find(".l-message-group .l-message-group-item").remove()
    @$panels.main.find(".l-message-group .input-group").unwrap()
    @$panels.main.find(".l-message-group .form-control").unwrap()
  # スクロール位置を最上位へ移動します。elにはスクローラブルな親要素を指定してください
  scrollTop: (el = '.panel-body') -> $(el, @$panels.main).scrollTop(0)
  # 指定要素(dataに対するパス)を反転した値にします(booleanを想定)
  changeFlag: (flagPath) -> @$set(flagPath, !@$get(flagPath))
  # APIへのGET処理を行います
  apiGet: (path, data, success, failure = @apiFailure) =>
    Lib.Ajax.get @apiUrl(path), data, success, failure
  # APIへのPOST処理を行います
  apiPost: (path, data, success, failure = @apiFailure) =>
    Lib.Ajax.post @apiUrl(path), data, success, failure
  # APIへのファイルアップロード処理(POST)を行います
  # アップロード対象キーの値はfileメソッドを利用して定義するようにしてください
  apiUpload: (path, data, success, failure = @apiFailure) =>
    Lib.Ajax.upload @apiUrl(path), data, success, failure
  # APIプリフィックスを付与したURLを返します。
  apiUrl: (path) -> Param.Api.root + path
  # ファイルオブジェクトを取得します。apiUpload時のdataへ設定するアップロード値を取得する際に使用してください。
  file: (el) -> @files(el)[0]
  files: (el) -> $(el, @$panels.main).prop("files")
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
  apiFailure: (error) =>
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
  renderWarning: (warn) =>
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
  renderColumnWarning: (key, message) =>
    $column = @$obj(key)
    if $column.length is 0 then return
    prevMsg = $column.parent().find(".l-message-group-item").text()
    if prevMsg is message then return # 同一メッセージはスルー
    $column.wrap '<div class="input-group l-message-group" />'
    $column.parent().append '<div class="l-message-group-item text-danger">' + message + '</div>'
  # 指定したdata要素キーに紐づくJQueryオブジェクトを返します
  # ※事前に対象コントロールに対し「.l-model-[dataKey]」が付与されている必要があります
  #   ネストオブジェクト対応としてkeyに「.」が含まれていた時は「-」である事を期待します。
  #   e.x. dataKey: hoge.hoga -> .l-model-hoge-hoga
  $obj: (key) ->
    key = key?.replace(/\./g, '-')
    @$panels.main.find(".l-model-" + key)
  #　指定したel要素のJQueryオブジェクトを返します
  $panel: (el) -> $(el, @$panels.main)
  # for session
  # ハッシュ情報をログインセッションへ紐付けします
  login: (sessionHash) -> Lib.Session.login(sessionHash)
  # ログインセッション情報を破棄します
  logout: -> Lib.Session.logout()
  # セッション情報を取得します。key未指定時はログインセッションハッシュを返します
  sessionValue: (key = null) -> Lib.Session.value(key)
  # セッション情報を取得します。key未指定時はログインセッションハッシュを返します
  hasAuthority: (id) ->
    list = @sessionValue()?.authorities
    if list then _.contains(list, 'ROLE_' + id) else false

# 検索を前提としたVueクラス
# 一覧パネル等で利用してください。ページング検索(自動ロード方式)もサポートしています。
# (API側でPagingListを返す必要があります)
# 本クラスを利用する際は初期化時に以下の設定が必要です。
# ・path属性の定義
# ・searchDataメソッドの設定
# ・createdメソッド内でinitializedを呼び出す
# ---
# - 拡張属性[attributes] -
# initialSearch: 初回検索を行うか(未指定時はtrue)
# paging: ページング検索を行うか(未指定時はfalse)
# el.search: 検索条件要素(未指定時は.l-panel-search)
# el.listBody: 一覧表示要素(未指定時は.l-list-body)
# el.listCount: 検索結果件数表示要素(未指定時は.l-list-cnt span)
# el.listWaitRow: 検索中の処理待ちアイコン要素(未指定時は.l-list-wait-row)
# - グローバル属性 -
# path: 検索APIパス(必須: 標準でapiUrlへ渡されるパス)
# $waitRow: 処理待ちアイコン要素のJQueryオブジェクト
# - パネル(JQuery)[$panels] -
# search: el.searchで指定された要素のJQueryオブジェクト
# body: el.listBodyで指定された要素のJQueryオブジェクト
# - 予約Data[data] -
# searchFlag: 検索パネル表示状態
# items: 検索結果一覧
# page: ページング情報
# - 拡張メソッド[methods] -
# initSearch: 検索パネルを表示する際の初期化処理
# toggleSearch: 検索条件パネルを開閉する
# closeSearch: 検索条件パネルを閉じる
# search: 検索する
# searchData: 検索条件をハッシュで生成する
# searchPath: 検索時の呼び出し先URLパスを生成する(apiUrlへ渡されるパス)
# layoutSearch: 検索後のレイアウト調整を行う(検索結果は@itemsに格納済)
class Lib.Vue.List extends Lib.Vue.Panel
  # 初期化時のattributes設定を行います
  bindOptions: (v) ->
    attr = v.attributes ? {}
    @attributes.initialSearch = attr.initialSearch ? true
    @attributes.paging = attr.paging ? false
    @attributes.el.listBody = attr.el?.listBody ? ".l-list-body"
    @attributes.el.listCount = attr.el?.listCount ? ".l-list-cnt span"
    @attributes.el.listWaitRow = attr.el?.listWaitRow ? ".l-list-wait-row"
  # 初期化時の$panels設定を行います
  bindPanels: (v) ->
    @$panels.body = $(@attributes.el.listBody, @$panels.main)
    @$waitRow = $(@attributes.el.listWaitRow, @$panels.body)
  # 初期化時のmethods設定を行います
  bindMethods: (v) ->
    m = v.methods ? {}
    m.initSearch = m.initSearch ? @initSearch
    m.toggleSearch = m.toggleSearch ? @toggleSearch
    m.closeSearch = m.closeSearch ? @closeSearch
    m.search = m.search ? @search
    m.searchData = m.searchData ? @searchData
    m.searchPath = m.searchPath ? @searchPath
    m.layoutSearch = m.layoutSearch ? @layoutSearch
    v.methods = m
  # 初期化後処理を行います
  # 全ての初期化定義が終わったタイミングで呼び出されます
  setup: (v) ->
    @path = v.path ? throw new Error("path属性は必須です")
    # 予約属性
    v.data.items = v.data.items ? []
    if @attributes.paging
      v.data.page =
        page: 1
        total: 0
  # 初期化後処理。Vue.jsのcreatedメソッドから呼び出す事で以下の処理が有効化されます。
  # ・page情報を監視して検索結果の件数を表示する
  # ・listBody要素のbottomイベントに自動ページング処理を紐付け
  # ・初期検索を実行
  initialized: ->
    @$waitRow.hide()
    # イベント登録
    if @attributes.paging
      @$watch 'page', (page) =>
        $cnt = $(@attributes.el.listCount, @$panels.main)
        $cnt.text page.total ? "-1"
      @$panels.body.onBottom =>
        @next()
    else
      @$watch 'items', (items) =>
        $cnt = $(@attributes.el.listCount, @$panels.main)
        $cnt.text items.length
    # 初期化
    if @attributes.initialSearch then @search()
  show: (speed=100) =>
    @initSearch()
    @$panels.main.show(speed)
  # 検索パネルを表示する際の初期化処理
  initSearch: ->
    # 必要に応じて同名のメソッドで拡張実装してください
  # 検索処理を行います
  # 検索時の接続URLはsearchPath、検索条件はsearchDataに依存します。
  # 検索成功時の後処理はlayoutSearchを実装する事で差し込み可能です。
  search: =>
    @renderSearch()
  # 次ページの検索を行います。
  # 検索結果は一覧にそのまま追加されます。
  # ※タイミングによっては重複レコードが発生しますが、現時点ではそれらを取り除く処理は実装していません。
  next: =>
    @page.page = @page.page + 1
    Lib.Log.debug "- search next to " + @page.page
    @renderSearch(true)
  # 各種メッセージの他、検索結果を初期化します
  clear: =>
    super()
    @items = []
  # 検索条件となるハッシュ情報を返します。
  searchData: -> {}
  # 検索時のURLパスを返します。ここで返すURLパスはapiUrlの引数に設定されます。
  searchPath: -> @path
  # 検索を行います。appendがfalseのときは常に一覧を初期化します。
  renderSearch: (append = false) =>
    Lib.Log.debug "- search url: " + @apiUrl(@searchPath())
    param = @searchData()
    if append is false then @page?.page = 1
    if @attributes.paging then param["page.page"] = @page.page
    if (0 < _.keys(param).length)
      Lib.Log.debug param
    if append is false then @clear()
    if @$waitRow.size() then @$waitRow.show()
    success = (data) =>
      @$waitRow.hide()
      @renderList(data, append)
      @layoutSearch()
    failure = (error) =>
      @$waitRow.hide()
      @apiFailure(error)
    @apiGet @searchPath(), param, success, failure
  # 検索結果をitemsへ格納します。
  # itemsがv-repeat等で画面要素と紐づいていた時は画面側にも内容が反映されます。
  renderList: (data, append) =>
    Lib.Log.debug "- search result -"
    Lib.Log.debug data
    list =
      if @attributes.paging
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
    else @items = list
  # 検索後の後処理を行います。
  # 検索結果となる一覧変数(items)が設定されている保証があります。
  layoutSearch: ->
    # 必要に応じて同名のメソッドで拡張実装してください

# 特定情報の登録/変更/削除を前提としたVueクラス
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
class Lib.Vue.Crud extends Lib.Vue.Panel
  # 初期化時のattributes設定を行います
  bindOptions: (v) ->
    attr = v.attributes ? {}
    @attributes.popup = attr.popup ? false
    @attributes.spinner = attr.spinner ? true
    @attributes.flattenItem = attr.flattenItem ? false
    @attributes.list = attr.list ? null
    @attributes.el.id = attr.el?.id ? ".l-model-id"
    @attributes.el.scrollBody = attr.el?.scrollBody ? ".panel-body"
  # 初期化時の$panels設定を行います
  bindPanels: (v) ->
    @$id = $(@attributes.el.id, @$panels.main)
  # 初期化時のmethods設定を行います
  bindMethods: (v) ->
    m = v.methods ? {}
    m.showRegister = m.showRegister ? @showRegister
    m.initRegister = m.initRegister ? @initRegister
    m.showUpdate = m.showUpdate ? @showUpdate
    m.initUpdate = m.initUpdate ? @initUpdate
    m.layoutUpdate = m.layoutUpdate ? @layoutUpdate
    m.register = m.register ? @register
    m.registerData = m.registerData ? @registerData
    m.registerPath = m.registerPath ? @registerPath
    m.updatePath = m.updatePath ? @updatePath
    m.deletePath = m.deletePath ? @deletePath
    m.idPath = m.idPath ? @idPath
    m.actionSuccess = m.actionSuccess ? @actionSuccess
    m.actionSuccessMessage = m.actionSuccessMessage ? @actionSuccessMessage
    m.actionSuccessAfter = m.actionSuccessAfter ? @actionSuccessAfter
    m.actionFailure = m.actionFailure ? @actionFailure
    m.actionFailureAfter = m.actionFailureAfter ? @actionFailureAfter
    v.methods = m
  # 初期化後処理を行います
  # 全ての初期化定義が終わったタイミングで呼び出されます
  setup: (v) ->
    @path = v.path ? throw new Error("path属性は必須です")
    # 予約属性
    v.data.item = v.data.item ? {}
    v.data.updateFlag = false
  # 初期化後処理。Vue.jsのcreatedメソッドから呼び出す事で以下の処理が有効化されます。
  # ・ポップアップ指定に伴う自身の非表示制御
  initialized: ->
    if @attributes.popup then @hide()
  # 登録/変更処理を行います。
  # 実行時の接続URLは前述のattributes解説を参照。実際の呼び出しはregisterPath/updatePathの値を利用。
  # 登録情報はregisterDataに依存します。
  # 登録成功時の後処理はactionSuccessAfter、失敗時の後処理はactionFailureAfterを実装する事で差し込み可能です。
  register: (event) =>
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
    if !event or !@attributes.spinner then return null
    $btn = $(el ? event.target)
    $btn.disable()
    $btn.append('<i class="fa fa-spinner fa-spin l-spin-crud" />')
    $btn
  # イベント終了処理を行います。startActionの戻り値を引数に設定してください
  endAction: ($btn) ->
    if !$btn or !@attributes.spinner then return
    $('.l-spin-crud', $btn).remove()
    $btn.enable()
  # 削除処理を行います。
  # 削除時の接続URLは前述のattributes解説を参照。実際の呼び出しはdeletePathの値を利用。
  # 削除成功時の後処理はactionSuccessAfter、失敗時の後処理はactionFailureAfterを実装する事で差し込み可能です。
  delete: (event) =>
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
    super()
    @item = {}
  # 登録モードで自身を表示します
  showRegister: =>
    @hide()
    @updateFlag = false
    @clear()
    @$id.removeAttr("disabled")
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
    @$id.attr("disabled", "true")
    v = _.clone item
    @initUpdate(v)
    @item = if @attributes.flattenItem is true then @flattenItem(v) else v
    @layoutUpdate()
    @show()
    Lib.Log.debug "show update [" + @$el.className + "]"
  # 変更モードで表示する際の初期化処理を行います(@item未設定)
  # itemバインドがまだされていない点に注意してください。itemバインド後の処理が必要な時は
  # layoutUpdateを実装してください。
  initUpdate: (item) ->
    # 必要に応じて同名のメソッドで拡張実装してください
  # 変更モードで表示する際のレイアウト処理を行います(@item設定済)
  layoutUpdate: ->
    # 必要に応じて同名のメソッドで拡張実装してください
  # 登録時のURLパスを返します。ここで返すURLパスはapiUrlの引数に設定されます。
  registerPath: =>
    @path
  # 更新時のURLパスを返します。ここで返すURLパスはapiUrlの引数に設定されます。
  updatePath: =>
    @registerPath() + @idPath() + "/"
  # 削除時のURLパスを返します。ここで返すURLパスはapiUrlの引数に設定されます。
  deletePath: =>
    @registerPath() + @idPath() + "/delete"
  # 更新/削除時に利用されるID情報を返します。
  # $idが定義されている時はその値、未定義の時はitem.idを利用します。
  # 各利用先で上書き定義する事も可能です。
  idPath: =>
    if 0 < @$id.size() then @$id.val() else @item.id
  # 登録/変更情報をハッシュで返します。
  # 標準ではitemの値をコピーして返します。
  registerData: =>
    data = _.clone @item
    for k, v of data
      if typeof v is "object" then data[k] = null
    data
  # 登録/変更/削除時の成功処理を行います。
  actionSuccess: (v) =>
    list = @attributes.list
    if list then list.search()
    if @attributes.popup
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
  actionFailure: (error) =>
    @apiFailure(error)
    gwarn = null
    cwarns = {}
    switch error.status
      when 400
        warn = $.parseJSON(error.responseText)
        for key, value of warn
          if key is "" then gwarn = value[0] else cwarns[key] = value[0]
        if gwarn then @scrollTop() else @scrollToColumn(@attributes.el.scrollBody, cwarns)
    @actionFailureAfter(error, gwarn, cwarns)
  # 登録/変更/削除時の失敗後処理を行います。
  actionFailureAfter: (error, gwarn, cwarns) ->
    # 必要に応じて同名のメソッドで拡張実装してください
  # 指定したbodyEl内の要素キーで例外を持つ最上位のコントロールへスクロール移動します。
  scrollToColumn: (bodyEl, cwarns) ->
    keys = _.keys(cwarns)
    if 0 < keys.length
      $body = $(bodyEl, @$panels.main)
      $target = @$obj(keys[0])
      if 0 < $target.length
        $body.scrollTop($target.offset().top - $body.offset()?.top + $body.scrollTop())
      else @scrollTop()
