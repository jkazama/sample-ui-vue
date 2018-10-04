<style lang="scss">
.l-card-mock {
  .card-body {
    height: 30rem;
  }
}
</style>

<template lang="pug">
div
  .row
    .col-sm
      .card.l-card-mock.mb-2
        .card-body
          .card-title
            i.fas.fa-info-circle
            |  資産残高
          .card-text
    .col-sm-8
      ul.nav.nav-tabs.mb-3
        li.nav-item: a.nav-link(href="#deposit" data-toggle="tab") 入金
        li.nav-item: a.nav-link.active(href="#withdrawal" data-toggle="tab") 出金依頼
        li.nav-item: a.nav-link(href="#cashflow" data-toggle="tab") 入出金一覧
      .tab-content
        .tab-pane#deposit
          |　TBD
        .tab-pane#withdrawal.active
          WithdrawalCrud
          WithdrawalList
        .tab-pane#cashflow
          |　TBD
</template>

<script lang="babel">
import ViewBasic from "views/mixins/view-basic"
import WithdrawalCrud from "views/asset/WithdrawalCrud.vue"
import WithdrawalList from "views/asset/WithdrawalList.vue"
export default {
  name: 'asset-view',
  mixins: [ViewBasic],
  components: {
    "WithdrawalCrud": WithdrawalCrud,
    "WithdrawalList": WithdrawalList
  }
}
</script>