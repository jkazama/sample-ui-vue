<style lang="sass"></style>

<template lang="pug">
div
  div(v-if="global")
    .alert(v-bind:class="[classAlert, classText]" v-text="message" v-if="message")
  div(v-if="!global")
    .input-group.l-message-group(v-if="message")
      .l-message-group-item.text-danger(v-text="message")
</template>

<script lang="babel">
import {Level, Event} from 'constants'
export default {
  name: 'message',
  data() {
    return {
      classAlert: null,
      classText: null,
      message: null
    }
  },
  props: {
    global: {
      type: Boolean,
      default: false
    },
    field: {type: String}
  },
  created() {
    EventEmitter.$on(Event.Messages, (v) => this.handleMessages(v))
  },
  methods: {
    handleMessages(messages) {
      this.global ? this.handleGlobalMessage(messages) : this.handleColumnMessage(messages)
    },
    handleGlobalMessage(messages) {
      let message = messages.global
      this.message = message
      if (message) {
        let type = this.messageType(messages.level)
        this.classAlert = `alert-${type}`
        this.classText = `text-${type}`
      } else {
        this.classAlert = null
        this.classText = null
      }
    },
    messageType(level) {
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
    handleColumnMessage(messages) {
      this.message = this.columnError(messages)
    },
    columnError(messages) {
      if (messages && messages.columns && 0 < messages.columns.length) {
        let err = Array.from(messages.columns).find((err) =>
          (messages.level === Level.WARN || messages.level === Level.ERROR) && err.key === this.field)
        if (err) return err.values[0]
      }
      return null
    }
  }
}
</script>