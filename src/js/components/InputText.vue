<template lang="pug">
Message(:field="field")
  .input-group(v-if="suffix")
    input.form-control(type="text", :placeholder="placeholder", :value="value",
      @keydown="$emit('input', $event.target.value)", @keydown.enter="onEnter", :disabled="updating")
    span.input-group-addon(v-text="suffix" v-if="suffix")
  input.form-control(v-if="!suffix", type="text", :placeholder="placeholder", :value="value",
      @keydown="$emit('input', $event.target.value)", @keydown.enter="onEnter", :disabled="updating")
</template>

<script lang="babel">
import * as Lib from 'platform/plain'
import Vue from 'vue'
import Message from 'components/Message.vue'
export default {
  name: 'input-text',
  components: { Message },
  props: {
    placeholder: {type: String},
    suffix: {type: String, default: null},
    field: {type: String},
    updating: {type: Boolean, default: false},
    enter: {type: Function},
    // from v-model
    value: {}
  },
  methods: {
    onEnter(event) {
      if (this.enter) {
        this.enter(event)
      } else {
        Lib.Log.debug('enter empty executed. please set v-bind:enter="yourParentMethodName"')
      }
    }
  }
}
</script>