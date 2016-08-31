<style lang="sass"></style>

<template lang="pug">
.l-withdrawal-crud
  message(global=true)
  .row.l-row
    .col-md-4
      .input-group
        //input.form-control(type="text" placeholder="出金金額" v-model="item.absAmount" @keydown.enter="register" v-disable:spinner="updating")
        input.form-control(type="text" placeholder="出金金額" v-model="item.absAmount" @keydown.enter="register")
        span.input-group-addon 円
      message(field="absAmount")
    .col-md-2
      //button.btn.btn-default.btn-block(@click="register" v-disable:spinner="updating") 依頼する
      button.btn.btn-default.btn-block(@click="register") 依頼する
  .row.l-row
    .col-md-12
      .alert.alert-warning 出金依頼に関わる注記文言を記載。動作確認用サンプルなので導線なり重複依頼はルーズに。
</template>

<script lang="babel">
import ViewCrud from "views/mixins/view-crud"
export default {
  mixins: [ViewCrud],
  props: {
    path: {default: "/asset/cio/withdraw"}
  },
  data() {
    return {
      item: {
        absAmount: ""
      }
    }
  },
  methods: {
    actionSuccessMessage: function() { return "依頼を受け付けました" },
    registerData: function() {
      this.item.currency = "JPY"
      return this.item
    }
  }
}
</script>