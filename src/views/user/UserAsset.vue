<script lang="ts" setup>
import { ref } from "vue";
import UserDeposit from "./asset/UserDeposit.vue";
import UserWithdraw from "./asset/UserWithdraw.vue";
import UserCashflow from "./asset/UserCashflow.vue";

const tab = ref("withdraw");
</script>
<template>
  <div>
    <v-tabs v-model="tab" bg-color="blue-grey-lighten-2">
      <v-tab value="deposit">Deposit</v-tab>
      <v-tab value="withdraw">Withdraw</v-tab>
      <v-tab value="cashflow">Cashflow</v-tab>
    </v-tabs>
    <v-window v-model="tab">
      <v-window-item value="deposit" transition="no">
        <UserDeposit />
      </v-window-item>
      <v-window-item value="withdraw" transition="no">
        <UserWithdraw />
      </v-window-item>
      <v-window-item value="cashflow" transition="no">
        <UserCashflow />
      </v-window-item>
    </v-window>
  </div>
</template>
<style scoped></style>
