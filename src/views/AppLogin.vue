<script lang="ts" setup>
import { ref } from "vue";
import { login } from "@/api/context";
import { Level } from "@/libs/log";
import { useEventStore } from "@/store/event";
import router from "@/router";
import { checkLogin } from "@/libs/app";

const event = useEventStore();

export interface Props {
  admin?: boolean;
}
const props = withDefaults(defineProps<Props>(), {
  admin: false,
});

const param = ref({
  loginId: "",
  password: "",
});

const doLogin = () => {
  const req = {
    loginId: (props.admin ? "INTERNAL-" : "") + param.value.loginId,
    password: param.value.password,
  };
  login(req)
    .then(() => {
      checkLogin(() => {
        router.push("/home");
      });
    })
    .catch(() => {
      event.notify("Login failed.", Level.WARN);
    });
};
</script>

<template>
  <v-container>
    <v-row no-gutters>
      <v-col lg="6" offset-lg="3" sm="8" offset-sm="2" xs="10" offset-xs="1">
        <v-card color="primary" variant="outlined">
          <v-card-title>
            Login Form<span v-if="props.admin"> for Admin</span>
          </v-card-title>
          <v-card-text>
            <TextField
              label="Login ID"
              v-model="param.loginId"
              @keydown.enter="doLogin"
            ></TextField>
            <TextField
              label="Password"
              v-model="param.password"
              type="password"
              @keydown.enter="doLogin"
            ></TextField>
            <Btn @click="doLogin"> Sign In </Btn>
          </v-card-text>
        </v-card>
      </v-col>
    </v-row>
  </v-container>
</template>
