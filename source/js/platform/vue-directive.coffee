## Directive
# Vue.jsのカスタムディレクティブを定義します。
# カスタムディレクティブはHTMLエレメントに「v-datepicker」など、新しい拡張属性を加えるものです。
# 例: input type="text" v-datepicker="item.testDay"
# 参考: http://jp.vuejs.org/guide/custom-directive.html
module.exports = ->
  # v-datepickerを定義したコンポーネントを日付選択コンポーネントへ変更します。
  # bootstrap-datepickerを有効とします。
  # 形式   [datepickerオプション] : [フィールドキー]
  # 使用例 v-datepicker="item.testDay"
  # 使用例 v-datepicker="'{autoclose: false}' : item.testDay"
  Vue.directive "datepicker",
    twoWay: true
    bind: ->
      # セパレート無しのformatは直接指定時に挙動が不安定になるので注意
      options =
        format: "yyyy/mm/dd"   # datepicker format
        vmFormat: "YYYY-MM-DD" # moment format
        weekStart: 1
        todayBtn: "linked"
        language: "ja"
        autoclose: true
        toggleActive: true
        todayHighlight: true
      updOptions = if @arg then eval('(' + @arg + ')') else {}
      if updOptions then (for k, v of updOptions then options[k] = v)
      options.format = options.format.toLowerCase()
      @format = options.format.toUpperCase()
      @vmFormat = options.vmFormat
      @$input = $(@el).datepicker(options)
      # JQuery側データ変更検知
      @$input.on "change", =>
        day = @$input.val()
        @set(if day then moment(day, @format).format(@vmFormat) else null)
    unbind: -> @$input.off "change"
    # VM側データ変更検知
    update: (day) ->
      if day then @$input.datepicker('update', moment(day, @vmFormat).format(@format))
