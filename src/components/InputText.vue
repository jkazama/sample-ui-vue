<!-- 
- InputText.vue -
入力用 Vue コンポーネント。
入力ボックスの標準レイアウト適用と例外表示、シンプルなイベント処理をサポートします。

[template]
InputText(field="absAmount", placeholder="出金金額",
  v-model="item.absAmount", :updating="updating", @enter="register")

※v-model のバインドは必須です。
※field 未設定時は例外メッセージを無視します。
※updating 指定時は処理中に disabled が有効化されます。
-->
<template>
  <message :field="field" :componentKey="componentKey">
    <div class="input-group" v-if="suffix">
      <input
        class="form-control"
        :type="typeName"
        :placeholder="placeholder"
        :value="value"
        @input="onInput"
        @keydown.enter="onEnter"
        :disabled="updating"
      />
      <div class="input-group-append" v-if="suffixType">
        <span
          class="input-group-text"
          v-text="suffix"
          v-if="suffixType == 'text'"
        />
        <button
          class="btn btn-outline-secondary"
          v-html="suffix"
          @click="onEnter"
          v-if="suffixType == 'button'"
        />
      </div>
    </div>
    <input
      class="form-control"
      v-if="!suffix"
      :type="typeName"
      :placeholder="placeholder"
      :value="value"
      @input="onInput"
      @keydown.enter="onEnter"
      :disabled="updating"
    />
  </message>
</template>

<script>
import Message from "./Message.vue";
export default {
  name: "input-text",
  components: { Message },
  props: {
    /** 例外紐付け先コンポーネントキー（標準では親コンポーネント） */
    componentKey: { type: String, default: null },
    /** 例外メッセージ表示で利用されるフィールドキー */
    field: { type: String },
    /** placeholder 文字列 */
    placeholder: { type: String },
    /** 末尾文字列 (HTMLを許容するので取扱いには注意してください) */
    suffix: { type: String, default: null },
    /** 末尾文字種別 (text[default] or button) */
    suffixType: { type: String, default: "button" },
    /** パスワード種別判定 */
    password: { type: Boolean, default: false },
    /** 処理中フラグ */
    updating: { type: Boolean, default: false },
    // from v-model
    value: { required: true }
  },
  computed: {
    typeName() {
      return this.password ? "password" : "text";
    }
  },
  methods: {
    onEnter(event) {
      this.$emit("enter", event);
    },
    onInput(event) {
      this.$emit("input", event.target.value);
    }
  }
};
</script>
