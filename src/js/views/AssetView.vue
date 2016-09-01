<style lang="sass">
.tab-pane {
  padding: 10px 0;
}
.l-panel-asset-info {
  .panel-body {
    height: 300px;
  }
}
</style>

<template lang="pug">
.container-fluid
  .row
    .col-md-4
      .panel.panel-default.l-panel-mock.l-panel-asset-info
        .panel-heading
          i.fa.fa-fw.fa-info-circle
          |  資産残高
        .panel-body
    .col-md-8
      ul.nav.nav-tabs
        li: a(href="#deposit" data-toggle="tab") 入金
        li.active: a(href="#withdrawal" data-toggle="tab") 出金依頼
        li: a(href="#cashflow" data-toggle="tab") 入出金一覧
      .tab-content
        .tab-pane#deposit
          |　TBD
        .tab-pane#withdrawal.active
          WithdrawalCrud(ref="crud")
          WithdrawalList(ref="list")
        .tab-pane#cashflow
          |　TBD
  hr
  .row
    .col-md-4
      .panel.panel-default.l-panel-mock: .panel-body
    .col-md-4
      .panel.panel-default.l-panel-mock: .panel-body
    .col-md-4
      .panel.panel-default.l-panel-mock: .panel-body
</template>

<script lang="babel">
import {Action} from 'constants'
import ViewBasic from "views/mixins/view-basic"
import WithdrawalCrud from "views/asset/WithdrawalCrud.vue"
import WithdrawalList from "views/asset/WithdrawalList.vue"
export default {
  name: 'asset-view',
  mixins: [ViewBasic],
  components: {
    "WithdrawalCrud": WithdrawalCrud,
    "WithdrawalList": WithdrawalList
  },
  mounted() {
    EventEmitter.$on(Action.CrudSuccess, (v) => this.$refs.list.search())
  }
}
</script>