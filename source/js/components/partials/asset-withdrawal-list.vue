<style lang="sass"></style>

<template lang="jade">
.l-withdrawal-list
  .alert.l-message
  .row
    .col-md-12
      .l-list-body.l-scrollable
        ul.list-group
          li.list-group-item.l-list-wait-row.l-center
            i.fa.fa-spin.fa-spinner
          li.list-group-item.clearfix(v-repeat="item : items")
            .l-item.l-item-day(v-text="item.requestDay | day")
            .l-item.l-item-type
              .label.label-default(v-text="item.statusType")
            .l-item.l-item-currency.pull-right(v-text="item.currency")
            .l-item.l-item-amount.pull-right(v-text="item.absAmount | currencyYen")
</template>

<script lang="coffee">
Option = require "../../platform/vue-option.coffee"
module.exports = new Option.PanelListBuilder(
  path: "/asset/cio/unprocessedOut/"
  attr: {el: {main: ".l-withdrawal-list"}}
  created: -> @initialized()
).build()
</script>