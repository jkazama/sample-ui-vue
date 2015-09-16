#----------------------------------
# - jquery.coffee -
# JQueryライブラリの拡張実装
#----------------------------------

# 対象となるコントロールを無効化します
$.fn.enable = ->
  @attr("disabled", false)

# 対象となるコントロールを有効化します
$.fn.disable = ->
  @attr("disabled", true)

# jquery.bottom
# スクロール末端に到達したイベント[bottom]を追加しています。
$.fn.bottom = (options) ->
  defaults =
    proximity: 0
  options = $.extend(defaults, options)
  @each ->
    obj = @
    $(obj).bind "scroll", ->
      if (obj is window)
        scrollHeight = $(document).height()
      else
        scrollHeight = $(obj)[0].scrollHeight
      scrollPosition = $(obj).height() + $(obj).scrollTop()
      if ((scrollHeight - scrollPosition) / scrollHeight <= options.proximity)
        $(obj).trigger("bottom")
    false

# スクロール末端に到達したイベント[bottom]の受信処理
$.fn.onBottom = (fn) ->
  @bottom
    proximity: 0.05
  @on "bottom", fn

# bootstrap-datepickerのプロジェクト固有実装
#https://github.com/eternicode/bootstrap-datepicker/issues/1261
$.fn.datepickerJpn = (updOptions) ->
  # セパレート無しのformatは直接指定時に挙動が不安定になるので注意
  options =
    format: "yyyy/mm/dd"
    weekStart: 1
    todayBtn: "linked"
    language: "ja"
    autoclose: true
    toggleActive: true
    todayHighlight: true
  if updOptions
    for k, v of updOptions
      options[k] = v
  @datepicker options

# 指定した正規表現の要素クラスを削除
$.fn.removeClassRegex = (regex) ->
  @removeClass (index, css) ->
    (css.match (regex) || [])?.join(' ')
