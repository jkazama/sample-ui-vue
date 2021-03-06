<!-- 
- Message.vue -
エラーメッセージ表示機能を提供する Vue コンポーネント。
グローバルイベント(Event.Messages)で通知された内容を表示します。

[template]
Message(global=true)
Message(global=true, globalKey=anyEventKey)
Message(field=anyMessageKey)
  <input type="text" …
-->
<style lang="scss" scoped>
.l-message-global {
  position: fixed;
  top: 2rem;
  right: 2rem;
  z-index: 1;
}
.l-message-group {
  display: block;
  input,
  textarea,
  select {
    border-color: #ed4c4c;
    background-color: #f6e3e3;
  }
  .l-message-group-item {
    font-size: 75%;
    padding: 0.2em;
    margin-bottom: 0.2em;
  }
}
.fade-enter-active,
.fade-leave-active {
  transition: opacity 0.5s;
}
.fade-enter,
.fade-leave-to {
  opacity: 0;
}
</style>

<template>
  <div>
    <div v-if="global">
      <transition v-if="notification" name="fade">
        <div class="l-message-global">
          <div
            class="alert p-2"
            :class="[classAlert, classText]"
            v-if="message"
          >
            <font-awesome-icon icon="exclamation-triangle" /> &nbsp;{{ message }}
          </div>
        </div>
      </transition>
    </div>
    <div v-if="!global">
      <div :class="{ 'input-group': message, 'l-message-group': message }">
        <slot />
        <div class="l-message-group-item" :class="[classText]" v-if="message">
          {{ message }}
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import { Level, Event } from "@/enums";
export default {
  name: "message",
  data() {
    return {
      classAlert: null,
      classText: null,
      message: null,
      notification: false
    };
  },
  props: {
    // グローバル例外表示フラグ
    global: { type: Boolean, default: false },
    // グローバル例外識別キー
    globalKey: { type: String, default: null },
    // フィールド例外表示キー (グローバル例外表示フラグが false 時に有効)
    field: { type: String },
    // グローバル例外表示期間（msec）
    showTime: { type: Number, default: 2000 }
  },
  created() {
    window.EventEmitter.$on(Event.Messages, v => this.handleMessages(v));
  },
  methods: {
    handleMessages(messages) {
      this.global
        ? this.handleGlobalMessage(messages)
        : this.handleColumnMessage(messages);
    },
    handleGlobalMessage(messages) {
      this.notification = false;
      const message = messages.global;
      const valid = this.globalKey
        ? this.globalKey === messages.globalKey
        : true;
      if (message && valid) {
        this.message = Array.isArray(message) ? message[0] : message;
        let type = this.messageType(messages.level);
        this.classAlert = `alert-${type}`;
        this.classText = null;
        this.notification = true;
        setTimeout(() => (this.notification = false), this.showTime);
      } else {
        this.message = null;
        this.classAlert = null;
        this.classText = null;
      }
    },
    messageType(level) {
      switch (level) {
        case Level.INFO:
          return "success";
        case Level.WARN:
          return "warning";
        case Level.ERROR:
          return "danger";
        default:
          return "default";
      }
    },
    handleColumnMessage(messages) {
      this.message = this.columnError(messages);
    },
    columnError(messages) {
      if (messages && messages.columns && 0 < messages.columns.length) {
        const column = Array.from(messages.columns).find(
          v => v.key === this.field
        );
        if (!column) return null;
        const type = this.messageType(column.level);
        this.classText = `text-${type}`;
        return column ? column.messages[0] : null;
      } else {
        this.classText = null;
        return null;
      }
    }
  }
};
</script>
