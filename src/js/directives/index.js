/*----------------------------------
 Vue.jsのカスタムディレクティブ定義
 カスタムディレクティブはHTMLエレメントに「v-datepicker」など、新しい拡張属性を加えるものです。
 例: <input type="text" v-datepicker="item.testDay">
 参考: http://jp.vuejs.org/guide/custom-directive.html
----------------------------------*/

import Vue from 'vue'
import {Level, Event, Style} from 'constants'

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
        $(this.el).addClass(`${Style.MessagePrefix}${this.expression.replace('.', '-')}`)
      }
      this.vm.$on(Event.Messages, this.handleMessages.bind(this))
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
   * v-disableを定義したコンポーネントに実行中操作不可の概念を付与します。
   * Crudパネルと併用しての利用を想定しています。
   * 使用例 v-disable="updating"          -> updatingがtrueの時はdisableにする
   * 使用例 v-disable:spinner="updating"  -> updating中にspinnerを表示させる
   */
  Vue.directive('disable', function(updating) {
    let $el = $(this.el)
    let spinner = this.arg === 'spinner'
    if (updating) {
      $el.disable()
      if (spinner) $el.append('<i class="fa fa-spinner fa-spin" />')
    } else {
      $el.enable()
      if (spinner) $el.find('.fa-spinner').remove()
    }
  })

  /**
   * v-identityを定義したコンポーネントにIDの概念を付与します。
   * Crudパネルと併用しての利用を想定しています。
   * 使用例 v-identity="accountId"        -> 引数にはdataのPKフィールドを指定
   */
  Vue.directive('identity', {
    bind: function() {
      $(this.el).addClass(`${Style.ColumnPrefix}-id`)
      this.vm.$watch('updateFlag', (updateFlag) => {
        if (updateFlag) {
          $(this.el).disable()
        } else {
          $(this.el).enable()
        }
      })
    }
  })
}
