## Directive
# Vue.jsのカスタムディレクティブを定義します。
# カスタムディレクティブはHTMLエレメントに「v-datepicker」など、新しい拡張属性を加えるものです。
# 例: input type="text" v-datepicker="item.testDay"
# 参考: http://jp.vuejs.org/guide/custom-directive.html
module.exports = ->
  Vue = require("vue")
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
    unbind: ->
      $(@el).datepickerJpn()?.off "change"
    # VM側データ変更検知
    update: (day) ->
      jDay = @$input.val()?.replace(/\//g, '')
      if day isnt jDay
        @$input.datepicker('update',
          if day then moment(day, @rawFormat).format(@format) else null)
