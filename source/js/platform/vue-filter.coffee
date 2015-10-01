## Filter
# Vue.jsのカスタムフィルタを定義します。
# カスタムフィルタは「v-text」などで変数を表示する際に値のフォーマッティングなどを可能にします。
# 例: v-text="createDay | day"
# 参考: http://jp.vuejs.org/guide/custom-filter.html
module.exports = ->
  Vue = require("vue")
  moment = require("moment")

  # Text Filter

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

  # Options Filter

  # selectのoptionsへ設定するオブジェクト一覧を生成します。
  # 通常のオブジェクト一覧をtext/valueを保持するオブジェクト一覧へ変換します。
  # ---
  # list - key/value変換対象オブジェクト一覧
  # defaultLabel - 指定時は値が空のラベル要素を追加します
  # valueField - 指定したオブジェクトのvalueへバインドするフィールド名
  # textField - 指定したオブジェクトのtextへバインドするフィールド名(未指定時はvalueFieldの値)
  # defaultLabel - valueFieldの値が未設定時の文言
  convertOptions = (v, valueField, textField = null, defaultLabel = null) ->
    v.map (item) ->
      value: item[valueName]?.toString()
      text: (item[textName ? valueName]?.toString() ? (defaultLabel ? '--'))
  Vue.filter 'extract', convertOptions
