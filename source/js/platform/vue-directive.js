import {Level, Event} from 'constants'

/** Directive
 * Vue.jsのカスタムディレクティブを定義します。
 * カスタムディレクティブはHTMLエレメントに「v-datepicker」など、新しい拡張属性を加えるものです。
 *# 例: input type="text" v-datepicker="item.testDay"
 * 参考: http://jp.vuejs.org/guide/custom-directive.html
 */
export default function() {

  /**
   * v-messageを定義したコンポーネントをメッセージ表示コンポーネントへ変更します。
   * vm側でmessageメソッドを実行した際にイベント駆動で呼び出されます。
   * グローバルメッセージとカラム例外のパターンをサポートします。
   * 使用例 v-message="global"  -> グローバルメッセージの表示
   * 使用例 v-message="amount"  -> カラム例外のキー(amount)に紐付けられたメッセージを表示
   */
  Vue.directive('message', {
    bind: function() {
      if (this.expression !== 'global') { // カラムの際は固有のカラムクラスタグを付与
        $(this.el).addClass(`l-message-${this.expression.replace('.', '-')}`)
      }
      this.vm.$on('messages', this.handleMessages.bind(this))
    },
    unbind: function() {},
    handleMessages: function(messages) {
      if (this.expression === 'global') {
        this.handleGlobalMessage(messages)
      } else {
        this.handleColumnMessage(messages)
      }
    },
    handleGlobalMessage: function(messages) {
      let $el = $(this.el)
      let message = messages.global
      $el.text(message)
      if (message) {
        let type = this.messageType(messages.level)
        $el.removeClassRegex(/\btext-\S+/g)
        $el.removeClassRegex(/\balert-\S+/g)
        $el.addClass(`alert`)
        $el.addClass(`alert-${type}`)
        $el.addClass(`text-${type}`)
        $el.show()
      } else {
        $el.hide()
      }
    },
    messageType: function(level) {
      switch (level) {
        case Level.INFO:
          return "success"
        case Level.WARN:
          return "warning"
        case Level.ERROR:
          return "danger"
        default:
          return "default"
      }
    },
    handleColumnMessage: function(messages) {
      let $el = $(this.el)
      // clear
      if ($el.parent().hasClass('l-message-group')) {
        $el.parent().find('.l-message-group-item').remove()
        $el.unwrap()
      }
      // append
      let message = this.columnError(messages)
      if (!message) return
      if ($el.find(".l-message-group-item").text() === message) return // 同一メッセージはスルー
      $el.wrap('<div class="input-group l-message-group" />')
      $el.parent().append(`<div class="l-message-group-item text-danger">${message}</div>`)
    },
    columnError: function(messages) {
      if (messages && messages.columns && 0 < messages.columns.length) {
        let err = Array.from(messages.columns).find((err) =>
          (messages.level === Level.WARN || messages.level === Level.ERROR) && err.key === this.expression)
        if (err) return err.values[0]
      }
      return null
    }
  })

  /**
   * v-datepickerを定義したコンポーネントを日付選択コンポーネントへ変更します。
   * bootstrap-datepickerを有効とします。
   * 形式   [datepickerオプション] : [フィールドキー]
   * 使用例 v-datepicker="item.testDay"
   * 使用例 v-datepicker="'{autoclose: false}' : item.testDay"
   */
  Vue.directive('datepicker', {
    twoWay: true,
    bind: function() {
      // セパレート無しのformatは直接指定時に挙動が不安定になるので注意
      var options = {
        format: 'yyyy/mm/dd',   // datepicker format
        vmFormat: 'YYYY-MM-DD', // moment format
        weekStart: 1,
        todayBtn: 'linked',
        language: 'ja',
        autoclose: true,
        toggleActive: true,
        todayHighlight: true
      }
      let updOptions = this.arg ? eval(`(${this.arg})`) : {}
      if (updOptions) Object.keys(updOptions).forEach((k) => options[k] = updOptions[k])
      options.format = options.format.toLowerCase()
      this.format = options.format.toUpperCase()
      this.vmFormat = options.vmFormat
      this.$input = $(this.el).datepicker(options)
      // JQuery側データ変更検知
      this.$input.on('change', () => {
        day = this.$input.val()
        this.set(day ? moment(day, this.format).format(this.vmFormat) : null)
      })
    },
    unbind: function() { this.$input.off('change') },
    // VM側データ変更検知
    update: function(day) {
      if (day) this.$input.datepicker('update', moment(day, this.vmFormat).format(this.format))
    }
  })
}
