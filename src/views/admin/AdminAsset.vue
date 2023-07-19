<script lang="ts" setup>
import { ref } from "vue";
import AdminDeposit from "./asset/AdminDeposit.vue";
import AdminWithdraw from "./asset/AdminWithdraw.vue";
import AdminCashflow from "./asset/AdminCashflow.vue";

const tab = ref("withdraw");
</script>
<template>
  <div>
    <v-tabs v-model="tab" bg-color="grey-lighten-2">
      <v-tab value="deposit">Deposit</v-tab>
      <v-tab value="withdraw">Withdraw</v-tab>
      <v-tab value="cashflow">Cashflow</v-tab>
    </v-tabs>
    <v-window v-model="tab">
      <v-window-item value="deposit" transition="no">
        <AdminDeposit />
      </v-window-item>
      <v-window-item value="withdraw" transition="no">
        <AdminWithdraw />
      </v-window-item>
      <v-window-item value="cashflow" transition="no">
        <AdminCashflow />
      </v-window-item>
    </v-window>
  </div>
</template>
<style scoped></style>
