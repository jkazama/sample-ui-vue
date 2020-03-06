<!-- 
- CommandButton.vue -
ボタン Vue コンポーネント。
ボタンの標準レイアウト適用とシンプルなイベント処理をサポートします。

[template]
CommandButton(@click="register", :updating="updating") OK
-->
<template>
  <button class="btn btn-secondary btn-block" :disabled="invalid" @click="onClick">
    <slot />
    <font-awesome-icon icon="spinner" spin v-if="updating" />
  </button>
</template>

<script>
export default {
  name: "command-button",
  props: {
    updating: { type: Boolean, default: false },
    disabled: { type: Boolean, default: false }
  },
  computed: {
    invalid() {
      return this.updating || this.disabled;
    }
  },
  methods: {
    onClick(e) {
      this.$emit("click", e);
    }
  }
};
</script>
