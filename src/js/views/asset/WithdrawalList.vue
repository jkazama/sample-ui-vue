<style lang="sass"></style>

<template lang="pug">
.l-withdrawal-list
  .row
    .col-md-12
      .l-list-body.l-scrollable
        ul.list-group
          //li.list-group-item.l-list-wait-row(v-show="updating" v-disable:spinner="updating")
          li.list-group-item.l-list-wait-row(v-show="updating")
          li.list-group-item.clearfix(v-for="item in items")
            .l-item.l-item-day {{item.requestDay | day}}
            .l-item.l-item-type
              .label.label-default {{item.statusType}}
            .l-item.l-item-currency.pull-right  {{item.currency}}
            .l-item.l-item-amount.pull-right {{item.absAmount | amount}}
</template>

<script lang="babel">
import ViewList from "views/mixins/view-list"
export default {
  mixins: [ViewList],
  props: {
    path: {default: "/asset/cio/unprocessedOut/"}
  }
}
</script>