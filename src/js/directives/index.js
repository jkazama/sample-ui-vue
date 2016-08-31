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
}
