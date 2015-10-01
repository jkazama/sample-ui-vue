#----------------------------------
# - ui.coffee -
# Vue.jsに依存しないUI関連の汎用関数群
#----------------------------------

module.exports.Select =
  # selectのoptionsへ設定するオブジェクト一覧を生成します。
  # 通常のオブジェクト一覧をtext/valueを保持するオブジェクト一覧へ変換します。
  # ---
  # list - key/value変換対象オブジェクト一覧
  # defaultLabel - 指定時は値が空のラベル要素を追加します
  # valueField - 指定したオブジェクトのvalueへバインドするフィールド名
  # textField - 指定したオブジェクトのtextへバインドするフィールド名
  values = (list, defaultLabel = null, valueField="value", textField="text") ->
    items = _.collect list, (v) -> {text: v[textField]?.toString(), value: v[valueField]?.toString()}
    if defaultLabel? then _.union([{value: "", text: defaultLabel}], items) else items
  # 指定した年月に応じた日一覧(text/value)を返します。
  calendarDay = (year, month, defaultLabel = null) ->
    if !year? or !month? then return ""
    daysInMonth = moment(year + "-" + month, "YYYY-MM").daysInMonth()
    list = _.collect [1..daysInMonth], (v) -> {text: v, value: v}
    @values list, defaultLabel
  # 指定した年に応じた月一覧(text/value)を返します。
  calendarMonth = (defaultLabel = null) ->
    list = _.collect [1..12], (v) -> {text: v, value: v}
    @values list, defaultLabel
  # 指定した範囲の年一覧(text/value)を返します。
  # ---
  # size - maxからの表示範囲年数
  # max - 最大表示年。未指定時は今年
  # reverse - 一覧表示順。未指定時は昇順
  calendarYear = (defaultLabel = null, size=10, max=null, reverse = false) ->
    maxYear = if max? then max else moment().format("YYYY")
    minYear = maxYear - size
    if reverse
      list = _.collect [maxYear..minYear], (v) -> {text: v, value: v}
    else
      list = _.collect [minYear..maxYear], (v) -> {text: v, value: v}
    @values list, defaultLabel
  # 時間一覧(text/value)を返します。(24時間)
  calendarHour = (defaultLabel = null) ->
    list = _.collect [1..24], (v) -> {text: v, value: v}
    @values list, defaultLabel
  # 時間一覧(text/value)を返します。(12時間)
  calendarHourHalf = (defaultLabel = null) ->
    list = _.collect [1..12], (v) -> {text: v, value: v}
    @values list, defaultLabel
  # 分一覧(text/value)を返します。
  calendarMinute = (defaultLabel = null) ->
    list = _.collect [0..5], (v) -> {text: v * 10, value: v * 10}
    @values list, defaultLabel
