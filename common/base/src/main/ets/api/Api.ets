import { UserData } from "../viewmodel/UserData";
import { Response } from "./Response";
import { http } from "@kit.NetworkKit";
import { requestSync } from "../utils/HttpClientUtils";

export class Api {
  private static instance: Api;

  private constructor() {
  }

  static net(): Api {
    if (Api.instance === undefined) {
      Api.instance = new Api();
    }
    return Api.instance;
  }

  async login(username: string, password: string): Promise<Response<UserData>> {
    return requestSync("api/auth/special-driver/connect/token", http.RequestMethod.POST, `client_id=app&grant_type=phone&scope=AuthServer offline_access&phone=${username}&code_verifier=${password}&platform=1&clientId=HW_PHONE1`);
  }

  async logout(): Promise<Response<string>> {
    return requestSync("/user/logout/json", http.RequestMethod.GET);
  }

  async getUserInfo(): Promise<Response<UserData>> {
    return requestSync("/lg/coin/userinfo/json", http.RequestMethod.GET);
  }

}