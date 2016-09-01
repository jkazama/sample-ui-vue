<template lang="pug">
button.btn.btn-default.btn-block(disabled=updating)
  slot
  i.fa.fa-spinner.fa-spin(v-if="updating")
</template>

<script lang="babel">
export default {
  name: 'command-button',
  props: {
    updating: {type: Boolean, default: false}
  },
  methods: {}
}
</script>