import { TitleBar } from '@smarthane/titlebar';
import { router } from '@kit.ArkUI';
import { Api, LoadingUtils } from 'base';
import { UserInfoModel } from 'base/src/main/ets/viewmodel/UserInfoModel';
import { AuthFailReasonModel, Data } from 'base/src/main/ets/viewmodel/AuthFailReasonModel';
import { FailReasonModel } from '../viewmodel/FailReasonModel';
import { showToast } from '@abner/dialog';
import { MMKV } from '@tencent/mmkv';

@Entry
@Component
struct Pages_AuditFailed {
  @State message: string = 'Hello World';
  @State showLoading: boolean = false;
  @State userInfoData:UserInfoModel = new UserInfoModel()
  @State authFailReason:AuthFailReasonModel = new AuthFailReasonModel()
  @State authFailReasonList:Data[] = []
  @State result:FailReasonModel[] = []
  //titleBar组件
  @State model1: TitleBar.Model = new TitleBar.Model()
    .setOnLeftClickListener(() => {
      router.back()
    })
    .setTitleName("哈哈定制司机")
    .setTitleFontColor($r("app.color.text_color1"))

  @Builder TitleBars(){
    Column(){
      TitleBar({ model: $model1 })
    }
  }

  async getUserInfo(){
    LoadingUtils.showLoading("加载中...");
    let res = await Api.net().getUserInfo();
    this.userInfoData = (res.data as UserInfoModel)
    if (res.isSuccessWithData()) { //200
      LoadingUtils.hideLoading();
      if (this.userInfoData?.data?.CarStatus == 1 ) {
        MMKV.defaultMMKV().encodeInt32("CAR_STATUS",this.userInfoData.data.CarStatus)
        ////审核通过   进首页
        router.replaceUrl({
          url:"pages/Index"
        })
      }else if (this.userInfoData?.data?.CarStatus == 0){
        MMKV.defaultMMKV().encodeInt32("CAR_STATUS",this.userInfoData.data.CarStatus)
        //审核中
        router.replaceUrl({
          url:"pages/Pages_SubmitForRevie"
        })
      }else if (this.userInfoData?.data?.CarStatus == -1){
        MMKV.defaultMMKV().encodeInt32("CAR_STATUS",this.userInfoData.data.CarStatus)
        //审核驳回 原因展示
        this.getAuthFailReason()
      }
    }else{
      LoadingUtils.hideLoading();
      showToast(res.message)
    }
  }

  async getAuthFailReason(){
    LoadingUtils.showLoading("加载中...");
    let res = await Api.net().getAuthFailReason();
    if (res.isSuccessWithData()) {
      this.authFailReason = (res.data as AuthFailReasonModel)
      if (this.authFailReason.statusCode == 200) {
        LoadingUtils.hideLoading()
        this.authFailReasonList = this.authFailReason.data as Data[]
        this.result = []
        for (let i = 0; i <this.authFailReasonList.length; i++) {
          const resultBean :FailReasonModel = new FailReasonModel()
          resultBean.Id = this.authFailReasonList[i]?.AuthType as number
          if (this.authFailReasonList[i]?.AuthType == 1){
            resultBean.Type = "身份证信息"
          }else if (this.authFailReasonList[i]?.AuthType == 2){
            resultBean.Type = "驾驶证信息"
          }else if (this.authFailReasonList[i]?.AuthType == 3){
            resultBean.Type = "行驶证信息"
          }else if (this.authFailReasonList[i]?.AuthType == 4){
            resultBean.Type = "网约车资料信息"
          }else if (this.authFailReasonList[i]?.AuthType == 5){
            resultBean.Type = "保险信息"
          }
          resultBean.Content = this.authFailReasonList[i]?.FailReason?.toString() as string
          resultBean.Reason = this.authFailReasonList[i]?.FailReason?.toString() as string
          this.result.push(resultBean)
        }
        console.log("====>"+JSON.stringify(this.result))
        this
      }else{
        LoadingUtils.hideLoading()
        showToast(this.authFailReason.message)
      }
    }else{
      LoadingUtils.hideLoading()
      showToast(res.message)
    }


  }


  aboutToAppear(): void {
    //进来请求车辆绑定状态
    this.getUserInfo()

  }


  build() {
    Column() {
      this.TitleBars()
      //
      AlignItemsFlex({ justifyContent:FlexAlign.Center,alignItems: ItemAlign.Center })
      //请求数据展示

      Column(){
        List({space:10}){
          ForEach(this.result,(item: FailReasonModel , index:number)=>{
            ListItem(){
              Row({space:10}){
                Column({space:5}){
                  Text(item.Type)
                    .fontColor($r("app.color.text_color1"))
                    .fontSize(14)
                  Text(item.Reason)
                    .fontColor($r("app.color.text_h1"))
                    .fontSize(12)
                }
                .margin({left:16})
                .alignItems(HorizontalAlign.Start)
                .justifyContent(FlexAlign.Center)


                Button("重新提交")
                  .type(ButtonType.Normal)
                  .width(90)
                  .borderRadius(8)
                  .fontSize(13)
                  .backgroundColor($r('app.color.color_shubihong'))

              }
              .width('90%')
              .padding(8)
              .margin({left:20,right:20})
              .borderRadius(10)
              .backgroundColor($r("app.color.white"))
              .alignItems(VerticalAlign.Center)
              .justifyContent(FlexAlign.SpaceBetween)
            }
            .onClick(()=>{
              if (item?.Id == 1) {
                router.pushUrl({
                  url:"pages/Pages_CompletionIdCard"
                })
              }else if (item?.Id == 2){
                router.pushUrl({
                  url:"pages/Pages_CompletionDriverCard"
                })
              }else if (item?.Id == 3){
                router.pushUrl({
                  url:"pages/Pages_CompletionTravelCard"
                })
              }
              else if (item?.Id == 4){
                router.pushUrl({
                  url:"pages/Pages_CompletionVehicleLicense"
                })
              }else if (item?.Id == 5){
                router.pushUrl({
                  url:"pages/Pages_CompulsoryTrafficInsurance"
                })
              }
            })
          },(item:Data)=>item?.FailReason)
        }
      }
      .margin({top:10})
      .width('100%')


    }
    .width('100%')
    .height('100%')
    .backgroundColor($r("app.color.system_background_color"))


  }
}

/**
 * 审核失败组件设置
 */
@Component
struct AlignItemsFlex {
  alignItems : number = 0;
  justifyContent : number = 0;
  build() {
    Flex({ justifyContent:this.justifyContent,alignItems: this.alignItems }) {
      //上面
      Column(){
        Image($r('app.media.audit_failed'))
          .width(100)
          .height(100)
        Text("审核失败")
          .fontColor($r('app.color.text_color1'))
          .fontSize(18)
      }
      .alignItems(HorizontalAlign.Center)
      .justifyContent(FlexAlign.Center)

    }
    .size({width: '90%', height: 260})
    .padding(10)
    .margin({top:16})
    .borderRadius(20)
    .backgroundColor(Color.White)
  }
}