<style lang="sass">
.tab-pane
  padding: 10px 0

.l-list-body
  height: 210px

.l-panel-asset-info
  .panel-body
    height: 300px
</style>

<template lang="jade">
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
          div(v-component="asset-withdrawal-crud")
          div(v-component="asset-withdrawal-list")
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
// Option = require "platform/vue-option"
// module.exports = new Option.ComponentBuilder(
//   components:
//     "asset-withdrawal-crud": require("components/partials/asset-withdrawal-crud")
//     "asset-withdrawal-list": require("components/partials/asset-withdrawal-list")
//   ready: ->
//     @$on 'action-success-crud', (v) => @$children[1].search()
// ).build()
</script>
