<style lang="sass"></style>

<template lang="jade">
  .col-xs-6.col-xs-offset-3
    .panel.panel-default
      .panel-heading セッションタイムアウト
      .panel-body
        .alert.alert-warning ログインしていないか一定時間操作がありませんでした。
      .panel-footer
        a.btn.btn-block.btn-default(v-link="'/login'")
          |　ログイン画面へ戻る
</template>

<script lang="coffee">
Option = require "../platform/vue-option.coffee"
module.exports = new Option.ComponentBuilder({})
</script>
