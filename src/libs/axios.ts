import Axios, { AxiosError } from "axios";
import { Log } from "./log";
export const axios = Axios.create({
  baseURL: import.meta.env.VITE_APP_API_ROOT,
  headers: {
    common: {
      Expires: -1,
      "Cache-Control": "no-cache,no-store,must-revalidate,max-age=-1,private",
    },
  },
  withCredentials: true,
});
axios.interceptors.response.use(
  (res) => {
    return res.data;
  },
  (err: AxiosError) => {
    const res = err.response;
    if (res && res.status) {
      Log.warn(
        "[" + res.status + "] " + (res.statusText || "empty statusText")
      );
      switch (res.status) {
        case 0:
          Log.error("No host was found to connect to.");
          break;
        case 200:
          Log.error(
            "Failed to parse the return value, please check if the response is returned in JSON format"
          );
          break;
        case 400:
          if (res.data) {
            Log.warn(res.data);
          }
          break;
        case 401:
          Log.error("You do not have permission to execute the api.");
          break;
        default:
          if (res.data) {
            Log.error(res.data);
          }
      }
    } else {
      Log.error(err);
    }
    return Promise.reject(err);
  }
);
