import { UserData } from "../viewmodel/UserData";
import { Response } from "./Response";
import { http } from "@kit.NetworkKit";
import { requestSync } from "../utils/HttpClientUtils";
import { SmsCodeModel } from "../viewmodel/SmsCodeModel";
import {TestModel} from "../viewmodel/TestModel"
import { ImageDataModel } from "../viewmodel/ImageDataModel";
import { UserInfoModel } from "../viewmodel/UserInfoModel";
import { HomeIndexModel } from "../viewmodel/HomeIndexModel";
import { HomeDataModel } from "../viewmodel/HomeDataModel";
import { OrderListModel } from "../viewmodel/OrderListModel";
import { MyCarInfoModel } from "../viewmodel/MyCarInfoModel";
import { BalanceRecordsModel } from "../viewmodel/BalanceRecordsModel";
import { WithdrawalRecordModel } from "../viewmodel/WithdrawalRecordModel";
import { PayoutsTypeModel } from "../viewmodel/PayoutsTypeModel";
import { OrderTaskModel } from "../viewmodel/OrderTaskModel";
import { AllOrderListModel } from "../viewmodel/AllOrderListModel";
import { CheckTicketModel } from "../viewmodel/CheckTicketModel";
import { PickUpPassengerModel } from "../viewmodel/PickUpPassengerModel";
import { ServiceToPassengerModel } from "../viewmodel/ServiceToPassengerModel";
import { ProgressDataModel } from "../viewmodel/ProgressDataModel";
import { OrderListDetailModel } from "../viewmodel/OrderListDetailModel";
import { AuthFailReasonModel } from "../viewmodel/AuthFailReasonModel";
import { JSON } from "@kit.ArkTS";
import { buildQueryString, QueryParams } from "../utils/QueryParamsUtils";
import { BaseModel } from "../viewmodel/BaseModel";
import { CompanyListModel } from "../viewmodel/CompanyListModel";
import { SubmitCompanyModel } from "../viewmodel/SubmitCompanyModel";
import { SelectCompanyModel } from "../viewmodel/SelectCompanyModel";
import { ImageFileNameModel } from "../viewmodel/ImageFileNameModel";
import { OSSPolicyTokenModel } from "../viewmodel/OSSPolicyTokenModel";
import { SubmitTrafficInsuranceModel } from "../viewmodel/SubmitTrafficInsuranceModel";
import { InquireTrafficInsuranceModel } from "../viewmodel/InquireTrafficInsuranceModel";
import { InquireVehicleLicenseModel } from "../viewmodel/InquireVehicleLicenseModel";
import { InquireTravelCardModel } from "../viewmodel/InquireTravelCardModel";
import { InquireDriverCardModel } from "../viewmodel/InquireDriverCardModel";
import { InquireIdCardModel } from "../viewmodel/InquireIdCardModel";
import { SubmitIdCardModel } from "../viewmodel/SubmitIdCardModel";
import { SubmitTravelCardModel } from "../viewmodel/SubmitTravelCardModel";
import { SubmitDriverCardModel } from "../viewmodel/SubmitDriverCardModel";
import { SubmitVehicleLicenseModel } from "../viewmodel/SubmitVehicleLicenseModel";
import { ChangeInfoModel } from "../viewmodel/ChangeInfoModel";
import { ChangePhoneNumModel } from "../viewmodel/ChangePhoneNumModel";
import { SubmitRechargeModel } from "../viewmodel/SubmitRechargeModel";
import { PayBackModel } from "../viewmodel/PayBackModel";
import { DriverUnifyPayModel } from "../viewmodel/DriverUnifyPayModel";
import { SubmitWithdrawModel } from "../viewmodel/SubmitWithdrawModel";

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
    return requestSync("api/auth/custom-driver/connect/token", http.RequestMethod.POST, "",`client_id=app&grant_type=phone_verify&scope=AuthServer offline_access&phone_number=${username}&phone_verify_code=${password}&platform=1`);
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
    return requestSync("api/app/custom-driver/User-center/user-info", http.RequestMethod.GET);
  }
  //获取首页数据信息
  async getHomeIndexData(): Promise<Response<HomeIndexModel>> {
    return requestSync("api/app/custom-driver/Home/index-data", http.RequestMethod.GET);
  }
  //获取首页待服务数据信息
  async getHomeDatas(carId:string): Promise<Response<HomeDataModel>> {
    return requestSync(`api/app/custom-line/Driver-order/today-order-data/${carId}`, http.RequestMethod.GET,"");
  }

  //获取订单列表
  async getOrderListData(status:string,index:number): Promise<Response<OrderListModel>> {
    return requestSync(`api/app/custom-line/Driver-order/order-list`, http.RequestMethod.GET,"",`size=10&index=${index}&state=${status}`);
  }

  //获取订单详情
  async getOrderListDetail(orderId:string): Promise<Response<OrderListDetailModel>> {
    return requestSync(`api/app/custom-line/Driver-order/order-detail/${orderId}`, http.RequestMethod.GET,"");
  }

  //获取车辆信息
  async getMyCarInfoData(): Promise<Response<MyCarInfoModel>> {
    return requestSync(`api/app/custom-driver/User-center/driver-car-detail`, http.RequestMethod.GET,"");
  }

  //获取余额充值记录
  async getBalanceRechargeRecord(index:number): Promise<Response<BalanceRecordsModel>> {
    return requestSync(`api/app/payment/fund-record/custom-driver-dalance-log-list`, http.RequestMethod.GET,"",`size=10&index=${index}`);
  }

  //余额提现记录
  async getWithdrawalHistory(index:number): Promise<Response<WithdrawalRecordModel>> {
    return requestSync(`api/app/payment/Withdraw/custom-driver-dalance-withdraw-log-list`, http.RequestMethod.GET,"",`size=10&index=${index}`);
  }

  //获取当前平台支持的提现方式
  async getWithdrawType(): Promise<Response<PayoutsTypeModel>> {
    return requestSync(`api/app/payment/Withdraw/custom-driver-withdraw-types`, http.RequestMethod.GET,"");
  }

  //获取订单任务列表
  async getOrderTaskList(carId:string,lineId:string): Promise<Response<OrderTaskModel>> {
    return requestSync(`api/app/custom-line/Driver-order/order-task-list`, http.RequestMethod.GET,"",`carId=${carId}&lineId=${lineId}`);
  }

  //获取订单任务班次订单列表
  async getOrderData(carId:string,lineId:string,shiftId:string): Promise<Response<AllOrderListModel>> {
    return requestSync(`api/app/custom-line/Driver-order/order-task-detail-list`, http.RequestMethod.GET,"",`carId=${carId}&lineId=${lineId}&shiftId=${shiftId}`);
  }

  //客运司机端-检票
  async getCheckTicket(data: Record<string, string>): Promise<Response<BaseModel>> {
    return requestSync(`api/app/custom-line/Driver-order/check-ticket`, http.RequestMethod.POST,"",buildQueryString(data));
  }

  //接到乘客
  async pickUpPassenger(orderId:string): Promise<Response<PickUpPassengerModel>> {
    return requestSync(`api/app/custom-line/Driver-order/pick-up-passenger/${orderId}`, http.RequestMethod.POST,"");
  }

  //送达乘客
  async serviceToPassenger(orderId:string): Promise<Response<ServiceToPassengerModel>> {
    return requestSync(`api/app/custom-line/Driver-order/service-to-passenger/${orderId}`, http.RequestMethod.POST,"");
  }

  //获取订单列表-->日数据
  async getOrderListByDay(index:number,beginTime:string): Promise<Response<OrderListModel>> {
    return requestSync(`api/app/custom-line/Driver-order/order-list`, http.RequestMethod.GET,"",`size=10&index=${index}&dateType=1&beginTime=${beginTime}`);
  }
  //获取订单列表-->周数据
  async getOrderListByWeek(index:number,beginTime:string): Promise<Response<OrderListModel>> {
    return requestSync(`api/app/custom-line/Driver-order/order-list`, http.RequestMethod.GET,"",`size=10&index=${index}&dateType=2&beginTime=${beginTime}`);
  }
  //获取订单列表-->月数据
  async getOrderListByMonth(index:number,beginTime:string): Promise<Response<OrderListModel>> {
    return requestSync(`api/app/custom-line/Driver-order/order-list`, http.RequestMethod.GET,"",`size=10&index=${index}&dateType=3&beginTime=${beginTime}`);
  }
  //获取订单列表-->自定义数据
  async getOrderListByCustomize(index:number,beginTime:string,endTime:string): Promise<Response<OrderListModel>> {
    return requestSync(`api/app/custom-line/Driver-order/order-list`, http.RequestMethod.GET,"",`size=10&index=${index}&dateType=4&beginTime=${beginTime}&endTime=${endTime}`);
  }

  /**
   * 客运司机端-获取文件名
   */
  async getOssFileNameRequest(): Promise<Response<BaseModel>> {
    return requestSync(`api/app/file/Upload/file-name`, http.RequestMethod.GET,"",`type=7&isNeedPath=1`);
  }

  //获取阿里云上传图片所需签名数据
  async getPolicyToken(): Promise<Response<OSSPolicyTokenModel>> {
    return requestSync(`api/app/file/Upload/policy-token`, http.RequestMethod.GET,"");
  }

  async getOssParamRequest(name:string,fileType:string): Promise<Response<BaseModel>> {
    return requestSync(`api/app/file/Upload/presigned-url-for-oss`, http.RequestMethod.GET,"",  `name=${name}&fileType=${fileType}`);
  }



  //获取司机资料完整性进度
  async getDriverInfoProgress(): Promise<Response<ProgressDataModel>> {
    return requestSync(`api/app/custom-line/Driver-center/driver-info-progress`, http.RequestMethod.GET,"");
  }

  //获取 司机身份证信息资料
  async getDriverInfoByIdCard(): Promise<Response<InquireIdCardModel>> {
    return requestSync(`api/app/custom-line/Driver-center/driver-info-by-id-card`, http.RequestMethod.GET,"");
  }

  //获取 司机驾驶证信息
  async getDriverInfoByDriver(): Promise<Response<InquireDriverCardModel>> {
    return requestSync(`api/app/custom-line/Driver-center/driver-info-by-driver-license`, http.RequestMethod.GET,"");
  }

  //获取 行驶证信息
  async getDriverInfoDrivingLicense(): Promise<Response<InquireTravelCardModel>> {
    return requestSync(`api/app/custom-line/Driver-center/driver-info-by-driving-license`, http.RequestMethod.GET,"");
  }

  //获取 网约车资料信息
  async getDriverInfoByCarInfo(): Promise<Response<InquireVehicleLicenseModel>> {
    return requestSync(`api/app/custom-line/Driver-center/driver-info-by-online-car-info`, http.RequestMethod.GET,"");
  }

  //获取 司机保险信息
  async getDriverInfoByInsuranceInfo(): Promise<Response<InquireTrafficInsuranceModel>> {
    return requestSync(`api/app/custom-line/Driver-center/driver-info-by-insurance-info`, http.RequestMethod.GET,"");
  }

  //客运司机端-获取车管公司列表
  async getCompanyList(): Promise<Response<CompanyListModel>> {
    return requestSync(`api/app/custom-driver/User-center/car-company-list`, http.RequestMethod.GET,"");
  }

  //绑定车辆-->车管公司  body入参
  async postBindingLineCar(submitCompanyModel:SubmitCompanyModel): Promise<Response<SelectCompanyModel>> {
    return requestSync(`api/app/custom-line/Driver-center/binding-line-car`, http.RequestMethod.POST,"2222",submitCompanyModel);
  }

  //保存 司机身份证信息资料  body入参
  async postSaveDriverInfoByIdCard(submitIdCard:SubmitIdCardModel): Promise<Response<BaseModel>> {
    return requestSync(`api/app/custom-line/Driver-center/save-driver-info-by-id-card`, http.RequestMethod.POST,"2222",submitIdCard);
  }

  //保存 司机驾驶证信息  body入参
  async postSaveDriverInfoByDriver(submitDriverCard:SubmitDriverCardModel): Promise<Response<BaseModel>> {
    return requestSync(`api/app/custom-line/Driver-center/save-driver-info-by-driverlicense`, http.RequestMethod.POST,"2222",submitDriverCard);
  }

  //保存 行驶证信息  body入参
  async postSaveDriverInfoByDrivingLicense(submitTravelCard:SubmitTravelCardModel): Promise<Response<BaseModel>> {
    return requestSync(`api/app/custom-line/Driver-center/save-driver-info-by-driving-license`, http.RequestMethod.POST,"2222",submitTravelCard);
  }

  //保存 司机网约车资料  body入参
  async postSaveDriverInfoByCarInfo(submitVehicleLicense:SubmitVehicleLicenseModel): Promise<Response<BaseModel>> {
    return requestSync(`api/app/custom-line/Driver-center/save-driver-info-by-online-car-info`, http.RequestMethod.POST,"2222",submitVehicleLicense);
  }

  //保存 保险信息  body入参
  async postSaveDriverInfoByInsuranceInfo(submitTrafficInsurance:SubmitTrafficInsuranceModel): Promise<Response<BaseModel>> {
    return requestSync(`api/app/custom-line/Driver-center/save-driver-info-by-insurance-info`, http.RequestMethod.POST,"2222",submitTrafficInsurance);
  }

  /**
   * 获取审核拒绝原因
   */
  async getAuthFailReason(): Promise<Response<AuthFailReasonModel>> {
    return requestSync(`api/app/custom-line/Driver-center/auth-fail-reason`, http.RequestMethod.GET,"");
  }


  //获取首页Banner显示  保存 司机身份证信息资料
  async getBanner(code:string): Promise<Response<TestModel>> {
    return requestSync("api/app/basics/open/bannerl-list", http.RequestMethod.GET,`platform=3&code=${code}`);
  }

  //绑定个推Cid
  async bindGTPush(record:Record<string, string>): Promise<Response<BaseModel>> {
    return requestSync("api/app/custom-driver/Account/bind-push-cid", http.RequestMethod.POST,"",buildQueryString(record));
  }

  /**
   * 客运司机端-修改个人信息保存
   */
  async changeUserInfo(changeInfoModel:ChangeInfoModel): Promise<Response<BaseModel>> {
    return requestSync("api/app/custom-driver/User-center/save-change-user-info", http.RequestMethod.POST,"2222",changeInfoModel);
  }
  /**
   * 客运司机端-更新手机号
   */
  async changePhoneNum(changePhoneNumModel:ChangePhoneNumModel): Promise<Response<BaseModel>> {
    return requestSync("api/app/custom-driver/User-center/save-change-phone", http.RequestMethod.POST,"2222",changePhoneNumModel);
  }

  /**
   * 客运司机端-提交充值申请
   */
  async submitRecharge(record:Record<string, string>): Promise<Response<SubmitRechargeModel>> {
    return requestSync("api/app/payment/Member/custom-driver-balance-recharge-order", http.RequestMethod.POST,"",buildQueryString(record));
  }

  /**
   * 客运司机端-充值信息返回
   */
  async driverPaymentData(orderNo:string): Promise<Response<PayBackModel>> {
    return requestSync("api/app/payment/Checkstand/custom-driver-payment-data", http.RequestMethod.GET,"",`orderNo=${orderNo}`);
  }

  /**
   * 客运司机端-服务端返回支付订单信息
   */
  async driverUnifyPay(driverUnifyPayModel:DriverUnifyPayModel): Promise<Response<BaseModel>> {
    return requestSync("api/app/payment/Checkstand/custom-driver-checkstand", http.RequestMethod.POST,"2222",driverUnifyPayModel);
  }

  /**
   * 客运司机端-提交 余额提现申请
   */
  async submitWithdraw(submitWithdrawModel:SubmitWithdrawModel): Promise<Response<BaseModel>> {
    return requestSync("api/app/payment/Withdraw/custom-driver-submit-balance-withdraw", http.RequestMethod.POST,"2222",submitWithdrawModel);
  }
}