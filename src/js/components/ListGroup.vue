<template lang="pug">
div(:class="{'l-scrollable': fixed}", @scroll="scroll")
  ul.list-group
    li.list-group-item.l-list-wait-row(v-show="updating")
      i.fa.fa-spinner.fa-spin
    slot
</template>

<script lang="babel">
export default {
  name: 'list-group',
  props: {
    updating: {type: Boolean, default: false},
    // 固定モード。 true 時はルート要素に height 指定を行ってください。
    fixed: {type: Boolean, default: false}
  },
  methods: {
    scroll(e) {
      if (e.target.scrollHeight <= (e.target.scrollTop + e.target.offsetHeight)) {
        this.$emit('bottom')
      }
    }
  }
}
</script>