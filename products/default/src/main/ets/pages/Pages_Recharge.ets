import { TitleBar } from '@smarthane/titlebar';
import { router } from '@kit.ArkUI';
import { MoneyModel } from '../viewmodel/MoneyModel';
import { Api, LoadingUtils, showToast } from 'base';
import { SubmitRechargeModel } from 'base/src/main/ets/viewmodel/SubmitRechargeModel';
import { PayBackModel } from 'base/src/main/ets/viewmodel/PayBackModel';
import { BaseModel } from 'base/src/main/ets/viewmodel/BaseModel';
import { DriverUnifyPayModel } from 'base/src/main/ets/viewmodel/DriverUnifyPayModel';
import * as wxopensdk from '@tencent/wechat_open_sdk';
import { OnWXResp, WXApi, WXEventHandler } from '../model/WXApiWrap';
import { common } from '@kit.AbilityKit';
import json from '@ohos.util.json';

/**
 * 充值页面
 */
@Entry
@Component
struct Pages_Recharge {
  private wxApi = WXApi
  private wxEventHandler = WXEventHandler

  @State payResultText: string = ''
  private onWXResp: OnWXResp = (resp) => {
    this.payResultText = JSON.stringify(resp ?? {}, null, 2)
  }
  @State model1: TitleBar.Model = new TitleBar.Model()
    .setOnLeftClickListener(() => {
      router.back()
    })
    .setTitleName("余额充值")
    .setTitleFontColor($r("app.color.text_color1"))

  @State moneyList: Array<MoneyModel> = [
    new MoneyModel("200", "1"),
    new MoneyModel("100", "0"),
    new MoneyModel("50", "0"),
    new MoneyModel("30", "0"),
    new MoneyModel("20", "0"),
    new MoneyModel("10", "0")
  ];
  @State checkMoneyNum:string = ""
  @State submitRecharge :SubmitRechargeModel = new SubmitRechargeModel()
  @State payBack :PayBackModel = new PayBackModel()
  @State driverUnifyPays :DriverUnifyPayModel = new DriverUnifyPayModel()
  @State driverUnifyPayBack :BaseModel = new BaseModel()
  @State submitInfo :Record<string,string> = {}
  @State backServiceData :Record<string,string> = {}

  @Builder TitleBars(){
    Column(){
      TitleBar({ model: $model1 })
    }
  }

  aboutToAppear(): void {
    this.wxEventHandler.registerOnWXRespCallback(this.onWXResp)
  }

  aboutToDisappear(): void {
    this.wxEventHandler.unregisterOnWXRespCallback(this.onWXResp)
  }


  async submitRecharges(){
    LoadingUtils.showLoading("加载中...");
    this.submitInfo = {
      'recharge':this.checkMoneyNum
    }
    let res = await Api.net().submitRecharge(this.submitInfo);
    if (res.isSuccessWithData()) { //200
      this.submitRecharge = (res.data as SubmitRechargeModel)
      if (this.submitRecharge.statusCode == 200) {
        LoadingUtils.hideLoading();
        // console.log("====>"+JSON.stringify(this.submitRecharge.data))
        this.getDriverPayment(this.submitRecharge.data.OrderNo)
      }

    }else{
      LoadingUtils.hideLoading();
      showToast(res.message)
    }
  }

  async getDriverPayment(orderNo:string){
    LoadingUtils.showLoading("加载中...");
    this.submitInfo = {
      'orderNo':orderNo
    }
    let res = await Api.net().driverPaymentData(orderNo);
    if (res.isSuccessWithData()) { //200
      this.payBack = (res.data as PayBackModel)
      if (this.payBack?.statusCode == 200) {
        LoadingUtils.hideLoading();
        this.getDriverUnifyPay(this.payBack?.data?.OrderNo,this.payBack?.data?.CouponId)
      }
    }else{
      LoadingUtils.hideLoading();
      showToast(res.message)
    }
  }

  async getDriverUnifyPay(orderNo:string,couponId:string){
    this.driverUnifyPays.OrderNo = orderNo
    this.driverUnifyPays.CouponId = couponId
    this.driverUnifyPays.PaymentType = 4
    LoadingUtils.showLoading("加载中...");
    let res = await Api.net().driverUnifyPay(this.driverUnifyPays);
    if (res.isSuccessWithData()) { //200
      this.driverUnifyPayBack = (res.data as BaseModel)
      if (this.driverUnifyPayBack.statusCode == 200) {
        LoadingUtils.hideLoading();
        // console.log("====>" +JSON.stringify(this.driverUnifyPayBack))
        this.backServiceData = json.parse(this.driverUnifyPayBack.data) as Record<string,string>
        // console.log("11111====>" +JSON.stringify(this.backServiceData))
        //调微信支付  根据上面的返回值填写下面的信息
        let req = new wxopensdk.PayReq
        req.partnerId = this.backServiceData?.partnerid
        req.appId = this.backServiceData?.appid
        req.packageValue = this.backServiceData?.package
        req.prepayId = this.backServiceData?.prepayid
        req.nonceStr = this.backServiceData?.noncestr
        req.timeStamp = this.backServiceData?.timestamp
        req.sign = this.backServiceData?.sign
        req.extData = 'extData'

        let finished = await this.wxApi.sendReq(getContext(this) as common.UIAbilityContext, req)
        console.log("send request finished: ", finished)
      }

    }else{
      LoadingUtils.hideLoading();
      showToast(res.message)
    }
  }

  //跳转隐私协议页面
  openWebUrl(urlSuffix:string){
    let url= "https://h5.hnxzkj.cn/"+urlSuffix;
    router.pushUrl({
      url: 'pages/Pages_WebView',
      params:{
        data1: 'message',
        url: url  // 传递的 URL 参数
      }
    }, router.RouterMode.Single)
  }




  build() {
    Column(){
      this.TitleBars()

      Text("充值金额")
        .fontColor($r("app.color.text_color1"))
        .fontSize(16)
        .width("100%")
        .padding(10)
        .textAlign(TextAlign.Start)
      List({ space: 10 }) {
        ForEach(this.moneyList, (item: MoneyModel, index: number) => {
          ListItem() {
            Row() {
              Text(item.num)
                .height(40)
                .layoutWeight(1)
                .textAlign(TextAlign.Center)
                .fontColor(this.moneyList[index].isCheck == "1" ? $r("app.color.white") : $r("app.color.text_color1"))
                .fontSize(15)
                .backgroundColor(this.moneyList[index].isCheck == "1" ? $r("app.color.color_shubihong") : $r("app.color.white"))
                .onClick(() => {
                  // 切换选中状态
                  this.toggleSelection(index);
                  this.checkMoneyNum = this.moneyList[index].num
                  // showToast("点击切换选中金额"+JSON.stringify(this.checkMoneyNum));
                });
            }
            .margin({ left: 10, right: 10 })
            .border({
              width: 1,
              color: "#F7F7F7"
            })
            .width("90%");
          }
        }, (item: MoneyModel) => item.num);
      }
      .lanes(2)
      .padding({ top: 15, bottom: 15 })
      .backgroundColor($r("app.color.white"));

      Row(){
        Button("立即充值")
          .type(ButtonType.Normal)
          .borderRadius(10)
          .backgroundColor($r("app.color.color_shubihong"))
          .width("100%")
          .onClick(()=>{
            this.submitRecharges()
          })
      }
      .margin({top:20,left:15,right:15})
      .width("90%")


      Row(){
        Text("点击立即充值，即表示已阅读并同意")
          .fontColor($r("app.color.text_h1"))
          .fontSize(12)
        Text("《充值规则》")
          .fontColor($r("app.color.color_shubihong"))
          .fontSize(12)
          .onClick(()=>{
            this.openWebUrl("otherPages/pages/rich-text/rich-text?code=CustomDriverAppRechargeAgreeme")
          })
      }
      .width("90%")
      .margin({left:15,right:15,top:15})
      .alignItems(VerticalAlign.Center)
      .justifyContent(FlexAlign.Start)





    }
    .height('100%')
    .width('100%')
    .backgroundColor($r("app.color.system_background_color"))
  }

  // 切换选中状态的方法
  private toggleSelection(index: number) {
    // 创建一个新的数组，确保引用发生变化
    const newMoneyList = this.moneyList.map((item, i) => {
      return new MoneyModel(item.num, i === index ? "1" : "0");
    });
    // 更新状态
    this.moneyList = newMoneyList;
    console.log("更新===>", JSON.stringify(this.moneyList));
  }

}