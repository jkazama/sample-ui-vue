import Param from 'variables'
import {Level, Event, Action} from 'constants'
import * as Lib from 'platform/plain'
import $ from 'jquery'
import Vue from 'vue'

import ViewBasic from 'views/mixins/view-basic'

/**
 * 検索を前提としたVueOptionビルダークラス
 * 一覧パネル等で利用してください。ページング検索(自動ロード方式)もサポートしています。
 * (API側でPagingListを返す必要があります)
 * メソッド定義は「function」を明記する記法で行ってください。(メソッド内部では「() =>」を用いた記法も利用可)
 * 本クラスを利用する際は初期化時に以下の設定が必要です。
 * ・path属性の定義
 * ・createdメソッド内でinitializedを呼び出す
 * ---
 * - 属性 -
 * initialSearch: 初回検索を行うか(未指定時はtrue)
 * paging: ページング検索を行うか(未指定時はfalse)
 * - グローバル属性 -
 * path: 検索APIパス(必須: 標準でapiUrlへ渡されるパス)
 * - 予約Data[data] -
 * searchFlag: 検索パネル表示状態
 * items: 検索結果一覧
 * page: ページング情報
 * updating: 処理中の時はtrue
 * - 拡張メソッド[methods] -
 * search: 検索する
 * searchData: 検索条件をハッシュで生成する
 * searchPath: 検索時の呼び出し先URLパスを生成する(apiUrlへ渡されるパス)
 * layoutSearch: 検索後のレイアウト調整を行う(検索結果は@itemsに格納済)
 */
export default {
  data() {
    return {
      items: [],
      page: (this.paging ? {page: 1, total: 0} : null),
      updating: false
    }
  },
  mixins: [ViewBasic],
  components: {},
  props: {
    initialSearch: {type: Boolean, default: true},
    paging: {type: Boolean, default: false},
    path: {type: String, required: true}
  },
  created() {
    this.clear()
    this.initialized()
  },
  methods: {
    // 初期化後処理。Vue.jsのcreatedメソッドから呼び出す事で以下の処理が有効化されます。
    // ・listBody要素のbottomイベントに自動ページング処理を紐付け
    // ・初期検索を実行
    initialized() {
      // イベント登録
      // if (this.paging) {
      //   $(this.ext().el.pagingBody).onBottom(() => this.next())
      // }
      // 初期化
      if (this.initialSearch) this.search()
    },
    // 検索処理を行います
    // 検索時の接続URLはsearchPath、検索条件はsearchDataに依存します。
    // 検索成功時の後処理はlayoutSearchを実装する事で差し込み可能です。
    search() { this.renderSearch() },
    // 次ページの検索を行います。
    // 検索結果は一覧にそのまま追加されます。
    // ※タイミングによっては重複レコードが発生しますが、現時点ではそれらを取り除く処理は実装していません。
    next() {
      this.page.page = this.page.page + 1
      Lib.Log.debug(`- search next to ${this.page.page}`)
      this.renderSearch(true)
    },
    // 各種メッセージの他、検索結果を初期化します
    clear() {
      this.clearMessage()
      this.items = []
    },
    // 検索条件となるハッシュ情報を返します。
    searchData() { /* 利用先で設定してください */ return {} },
    // 検索時のURLパスを返します。ここで返すURLパスはapiUrlの引数に設定されます。
    searchPath() { return this.path },
    // 検索を行います。appendがfalseのときは常に一覧を初期化します。
    renderSearch(append = false) {
      Lib.Log.debug(`- search url: ${this.apiUrl(this.searchPath())}`)
      let param = this.searchData()
      if (0 < Object.keys(param).length) Lib.Log.debug(param)
      if (append === false) {
        this.clear()
        if (this.page) this.page.page = 1
      }
      if (this.paging) {
        param["page.page"] = this.page.page
      }
      this.updating = true
      let success = (data) => {
        this.updating = false
        this.renderList(data, append)
        this.layoutSearch()
      }
      let failure = (error) => {
        this.updating = false
        this.apiFailure(error)
      }
      this.apiGet(this.searchPath(), param, success, failure)
    },
    // 検索結果をitemsへ格納します。
    // itemsがv-repeat等で画面要素と紐づいていた時は画面側にも内容が反映されます。
    renderList(data, append) {
      Lib.Log.debug('- search result -')
      Lib.Log.debug(data)
      let list = () => {
        if (this.paging) {
          if (data.page) {
            this.page = data.page
            return data.list
          } else {
            Lib.Log.warn('page属性を含む検索結果を受信できませんでした')
            return data
          }
        } else { return data }
      }
      if (append) {
        Array.from(list()).forEach((item) => this.items.push(item))
      } else {
        this.items = list()
      }
    },
    // 検索後の後処理を行います。
    // 検索結果となる一覧変数(items)が設定されている保証があります。
    layoutSearch() { /* 必要に応じて同名のメソッドで拡張実装してください */ }
  }
}