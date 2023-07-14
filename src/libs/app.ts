import { loginAccount, loginStatus } from "@/api/context";
import { useStore } from "@/store/app";
import { LoginedKey, LogoutKey, useEventStore } from "@/store/event";
import { ActorRoleType } from "@/types";

export const isAdmin = () => {
  const store = useStore();
  switch (store.user.roleType) {
    case ActorRoleType.INTERNAL:
    case ActorRoleType.ADMINISTRATOR:
      return true;
    default:
      return false;
  }
};

export const checkLogin = async (
  success: () => void = () => {},
  failure: () => void = () => {}
) => {
  const store = useStore();
  const event = useEventStore();
  try {
    await loginStatus();
    if (store.logined) {
      success();
      return;
    }
    const user = await loginAccount();
    event.emit(LoginedKey, user);
    success();
  } catch (err) {
    event.emit(LogoutKey, null);
    failure();
  }
};
