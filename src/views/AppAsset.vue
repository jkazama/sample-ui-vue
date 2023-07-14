<script lang="ts" setup>
import { isAdmin } from "@/libs/app";
import { UserAsset, AdminAsset } from "@/views/asset";
</script>

<template>
  <div>
    <AdminAsset v-if="isAdmin()" />
    <UserAsset v-else />
  </div>
</template>

<style scoped></style>
