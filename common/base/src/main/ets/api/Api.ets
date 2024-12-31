import { UserData } from "../viewmodel/UserData";
import { Response } from "./Response";
import { http } from "@kit.NetworkKit";
import { requestSync } from "../utils/HttpClientUtils";
import { SmsCodeModel } from "../viewmodel/SmsCodeModel";
import {TestModel} from "../viewmodel/TestModel"
import { ImageDataModel } from "../viewmodel/ImageDataModel";
import { UserInfoModel } from "../viewmodel/UserInfoModel";
import { HomeIndexModel } from "../viewmodel/HomeIndexModel";

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
  //登录
  async login(username: string, password: string): Promise<Response<UserData>> {
    return requestSync("api/auth/special-driver/connect/token", http.RequestMethod.POST, "",`client_id=app&grant_type=phone&scope=AuthServer offline_access&phone=${username}&code_verifier=${password}&platform=1&clientId=HW_PHONE1`);
  }
  //获取图形验证码
  async getImgsCode(lastNonce?:string): Promise<Response<ImageDataModel>> {
    return requestSync("api/app/notice/Sms/captcha", http.RequestMethod.GET,`lastNonce=${lastNonce}`);
  }
  //获取短信验证码
  async getSmsCode(smsCodeModel:SmsCodeModel): Promise<Response<string>> {
    return requestSync("api/app/notice/Sms/send-sms", http.RequestMethod.POST,"2222",smsCodeModel);
  }
  //获取登录用户信息
  async getUserInfo(): Promise<Response<UserInfoModel>> {
    return requestSync("api/app/special-driver/User-center-appservice/user-info", http.RequestMethod.GET);
  }
  //获取首页数据信息
  async getHomeIndexData(): Promise<Response<HomeIndexModel>> {
    return requestSync("api/app/special-driver/Home/index-data", http.RequestMethod.GET,"2222");
  }


  //获取首页Banner显示
  async getBanner(code:string): Promise<Response<TestModel>> {
    return requestSync("api/app/basics/open/bannerl-list", http.RequestMethod.GET,`platform=3&code=${code}`);
  }
}