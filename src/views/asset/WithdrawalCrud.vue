<template>
<div>
  <div class="row mb-2">
    <div class="col-md-4">
      <input-text
        field="absAmount"
        placeholder="出金金額"
        suffix="円"
        suffixType="text"
        v-model="item.absAmount"
        :updating="updating"
        @enter="register" />
    </div>
    <div class="col-md-3">
      <command-button @click="register" :updating="updating">依頼する</command-button>
    </div>
  </div>
  <div class="row">
    <div class="col">
      <div class="alert alert-warning small p-2 mb-2">
        出金依頼に関わる注記文言を記載。動作確認用サンプルなので導線なり重複依頼はルーズに。
      </div>
    </div>
  </div>
</div>
</template>

<script>
import { Action } from '@/enums'
import ViewBasic from '@/views/mixins/view-basic'
import api from '@/api/asset'
export default {
  mixins: [ ViewBasic ],
  data() {
    return {
      item: {
        absAmount: "",
      }
    }
  },
  methods: {
    register() {
      const data = {
        currency: 'JPY',
        absAmount: this.item.absAmount,
      }
      this.updating = true
      api.withdraw(data, v => {
        this.item = {} // 入力情報の初期化
        this.updating = false
        window.EventEmitter.$emit(Action.UpdateAsset, v)
        this.message('依頼を受け付けました')
      }, this.actionFailure)
    }
  }
}
</script>