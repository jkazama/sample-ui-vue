<template lang="pug">
.col-xs-6.col-xs-offset-3
  .panel.panel-default
    .panel-heading セッションタイムアウト
    .panel-body
      .alert.alert-warning ログインしていないか一定時間操作がありませんでした。
    .panel-footer
      router-link.btn.btn-block.btn-default(to="/login")
        |　ログイン画面へ戻る
</template>

<script lang="babel">
export default {name: 'timeout-view'}
</script>
