/// <reference types="vite/client" />

declare module "*.vue" {
  import type { DefineComponent } from "vue";
  const component: DefineComponent<{}, {}, any>;
  export default component;
}

interface ImportMetaEnv {
  readonly VITE_APP_API_ROOT: string;
  readonly VITE_APP_LOG_LEVEL: "DEBUG" | "INFO" | "WARN" | "ERROR";
  readonly VITE_APP_SESSION_KEY: string;
}

interface ImportMeta {
  readonly env: ImportMetaEnv;
}
