import { TitleBar } from '@smarthane/titlebar';
import { router } from '@kit.ArkUI';
import { Api, LoadingUtils, showToast } from 'base';
import { UserInfoModel } from 'base/src/main/ets/viewmodel/UserInfoModel';
import * as wxopensdk from '@tencent/wechat_open_sdk';
import { OnWXResp, WXApi, WXEventHandler } from '../model/WXApiWrap';
import { common } from '@kit.AbilityKit';

@Entry
@Component
struct Pages_BindWX {
  @State isBindStatus: string = '';
  @State model1: TitleBar.Model = new TitleBar.Model()
    .setOnLeftClickListener(() => {
      router.back()
    })
    .setTitleName("账号绑定")
    .setTitleFontColor($r("app.color.text_color1"))
  @State userInfoData:UserInfoModel = new UserInfoModel()
  private wxApi = WXApi
  private wxEventHandler = WXEventHandler
  @State authResultText: string = ''
  private onWXResp: OnWXResp = (resp) => {
    this.authResultText = JSON.stringify(resp ?? {}, null, 2)
  }


  @Builder TitleBars(){
    Column(){
      TitleBar({ model: $model1 })
    }
  }

  aboutToAppear(): void {
    this.wxEventHandler.registerOnWXRespCallback(this.onWXResp)
    this.getUserInfos()
  }

  aboutToDisappear(): void {
    this.wxEventHandler.unregisterOnWXRespCallback(this.onWXResp)
  }

  //获取个人信息
  async getUserInfos(){
    LoadingUtils.showLoading('加载中...')
    let res = await Api.net().getUserInfo();
    console.log("获取个人信息-==="+JSON.stringify(res))
    if (res.isSuccessWithData()) {//200
      this.userInfoData = (res.data as UserInfoModel)
      if (res.data?.statusCode == 200) {
        LoadingUtils.hideLoading()
        if (this.userInfoData.data.IsBindWxToApp) {
          this.isBindStatus = '换绑'
        }else{
          this.isBindStatus = '未绑定'
        }
      }else {
        LoadingUtils.hideLoading()
        showToast(this.userInfoData.message)
      }
    }else{
      LoadingUtils.hideLoading()
      showToast(res.message);
    }
  }




  build() {
    Column() {
      this.TitleBars()

      Column(){
        Row({space:10}){
          Column({space:8}){
            Text("微信昵称")
              .fontColor($r("app.color.text_color1"))
              .fontSize(14)
              .textAlign(TextAlign.Center)

            Text(this.userInfoData?.data?.NickName ? this.userInfoData?.data?.NickName:"xxxx")
              .fontColor($r("app.color.text_color1"))
              .fontSize(14)
              .textAlign(TextAlign.Center)

          }
          .justifyContent(FlexAlign.Center)
          .alignItems(HorizontalAlign.Start)
          .height(70)
          .layoutWeight(1)

          Row(){
            Text(this.isBindStatus)
              .fontColor($r("app.color.text_h1"))
              .fontSize(15)
              .textAlign(TextAlign.Center)

            Image($r('app.media.refresh'))
              .width(15)
              .height(15)
          }
          .onClick(async () => {
            // showToast("换绑")
            let req = new wxopensdk.SendAuthReq
            req.isOption1 = false
            req.nonAutomatic = true
            req.scope = 'snsapi_userinfo'
            req.state = 'none'
            req.transaction = 'test111'
            let finished = await this.wxApi.sendReq(getContext(this) as common.UIAbilityContext, req)
            console.log("send request finished: ", finished)
          })

        }
      }
      .padding({left:20,right:20})
      .margin({top:10})
      .backgroundColor($r("app.color.white"))


    }
    .height('100%')
    .width('100%')
    .backgroundColor($r("app.color.system_background_color"))
  }
}