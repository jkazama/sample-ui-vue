<template lang="pug">
.row.justify-content-center
  .col-md-4
    .card.m-2
      .card-body
        .card-title.p-1: h5 セッションタイムアウト
        .card-text
          .alert.alert-warning.mb-2 ログインしていないか一定時間操作がありませんでした。
          router-link.btn.btn-block.btn-default(to="/login")
            |　ログイン画面へ戻る
</template>

<script lang="babel">
export default {name: 'timeout-view'}
</script>
