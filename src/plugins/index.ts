/**
 * plugins/index.ts
 *
 * Automatically included in `./src/main.ts`
 */

import type { App } from "vue";

// Plugins
import { loadFonts } from "./webfontloader";
import vuetify from "./vuetify";
import pinia from "../store";
import router from "../router";

// My Plugins
import * as UiComponents from "@/components/ui";
const installer = (app: App) => {
  Object.values(UiComponents).forEach((component) => {
    app.component(component.__name || "unkonwn", component);
  });
};

export function registerPlugins(app: App) {
  loadFonts();
  app.use(vuetify).use(router).use(pinia).use(installer);
}
