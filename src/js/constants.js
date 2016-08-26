/*----------------------------------
 - constants.js -
 JS全般で利用される定数
----------------------------------*/

// Enum
// Logging Levels
export const Level = {
  DEBUG: 10,
  INFO: 20,
  WARN: 30,
  ERROR: 40
}

// イベント定数
export const Event = {
  Messages: "vue-event-messages"
}

// 実行アクション定数
export const Action = {
  CrudSuccess: 'vue-action-crud-success'
}

// DOM操作で利用されるクエリセレクタ定数
export const Style = {
  MessagePrefix: '.l-message-',
  ColumnPrefix: '.l-column-',
  DefaultScrollTop: '.panel-body'
}
