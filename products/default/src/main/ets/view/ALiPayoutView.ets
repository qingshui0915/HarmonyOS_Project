import { Api, LoadingUtils, showToast } from "base"
import { BaseModel } from "base/src/main/ets/viewmodel/BaseModel"
import { SubmitWithdrawModel } from "base/src/main/ets/viewmodel/SubmitWithdrawModel"
import { UserInfoModel } from "base/src/main/ets/viewmodel/UserInfoModel"
import { router } from "@kit.ArkUI"
import { JSON } from "@kit.ArkTS"

@Component
export struct ALiPayoutView {
  @State remark:string = ""
  @State addRemark :Visibility = Visibility.Visible
  @State addRemarkTextInput :Visibility = Visibility.None
  @State userInfoData:UserInfoModel = new UserInfoModel()
  @State isBindStatus: string = '';
  @State zfbAccount:string = ""
  @State realName:string = ""
  @State amountWithdrawn:string = ""
  @State hintAmountWithdrawn:string = ""
  @State submitWithdrawModel:SubmitWithdrawModel = new SubmitWithdrawModel()
  @State baseModel:BaseModel = new BaseModel()

  setClicks(){
    this.addRemark = Visibility.None
    this.addRemarkTextInput = Visibility.Visible
  }

  aboutToAppear(): void {
    this.getUserInfos()
  }

  //获取个人信息
  async getUserInfos(){
    LoadingUtils.showLoading('加载中...')
    let res = await Api.net().getUserInfo();
    // console.log("获取个人信息-==="+JSON.stringify(res))
    if (res.isSuccessWithData()) {//200
      this.userInfoData = (res.data as UserInfoModel)
      if (res.data?.statusCode == 200) {
        LoadingUtils.hideLoading()
        this.hintAmountWithdrawn = (this.userInfoData?.data?.Balance).toString()
      }else {
        LoadingUtils.hideLoading()
        showToast(this.userInfoData.message)
      }
    }else{
      LoadingUtils.hideLoading()
      showToast(res.message);
    }
  }

  //点击提现
  async getSubmitWithdraw(){
    //请输入支付宝账号
    if (!this.zfbAccount) {
      showToast("请输入支付宝账号")
      return
    }
    //判断输入支付宝真实姓名
    if (!this.realName) {
      showToast("请填写支付宝真实姓名")
      return
    }
    //判断输入金额
    if (!this.amountWithdrawn) {
      showToast("请输入提现金额")
      return
    }
    LoadingUtils.showLoading('加载中...')
    this.submitWithdrawModel.Money = this.amountWithdrawn
    this.submitWithdrawModel.AlipayLoginAccount = this.zfbAccount
    this.submitWithdrawModel.Note = this.remark
    this.submitWithdrawModel.RealName = this.realName
    this.submitWithdrawModel.Type = "5"
    console.log("===》"+JSON.stringify(this.submitWithdrawModel))
    let res = await Api.net().submitWithdraw(this.submitWithdrawModel);
    if (res.isSuccessWithData()) {
      // console.log("=====>"+JSON.stringify(res.data))
      this.baseModel = (res.data as BaseModel)
      if (this.baseModel.statusCode == 200) {
        LoadingUtils.hideLoading()
        showToast("提现成功")
      }else{
        LoadingUtils.hideLoading()
        showToast(this.baseModel.message)
      }
    }else{
      LoadingUtils.hideLoading()
      showToast(res.data?.message+"")
    }

  }



  build() {
    Column() {
      Column() {
        Row({ space: 10 }) {
          Image($r("app.media.ali_icon"))
            .width(30)
            .height(30)
          TextInput({ placeholder: "请输入支付宝账号",text:this.zfbAccount })
            .placeholderFont({ size: 14 })
            .fontColor($r("app.color.text_color1"))
            .fontSize(14)
            .layoutWeight(1)
            .backgroundColor($r("app.color.white"))
            .onChange((value)=>{
              this.zfbAccount = value
            })

          Text("*必填")
            .fontColor($r("app.color.button_logout_bg"))
            .fontSize(13)
            .width(50)
            .textAlign(TextAlign.Center)
        }
        .width("100%")
        .padding(8)
        .alignItems(VerticalAlign.Center)
        .justifyContent(FlexAlign.Center)

        Row({ space: 10 }) {
          Text("真实姓名")
            .fontColor($r("app.color.text_color1"))
            .fontSize(13)
          TextInput({ placeholder: "请输入真实姓名" ,text:this.realName})
            .placeholderFont({ size: 14 })
            .fontColor($r("app.color.text_color1"))
            .fontSize(14)
            .layoutWeight(1)
            .backgroundColor($r("app.color.white"))
            .onChange((value)=>{
              this.realName = value
            })

          Text("*必填")
            .fontColor($r("app.color.button_logout_bg"))
            .fontSize(13)
            .width(50)
            .textAlign(TextAlign.Center)
        }
        .width("100%")
        .padding(8)
        .alignItems(VerticalAlign.Center)
        .justifyContent(FlexAlign.Center)

        Row({ space: 10 }) {
          Text("￥")
            .width(20)
            .height(20)
            .fontColor($r("app.color.text_color1"))
          TextInput({ placeholder: `可提现金额: ${this.hintAmountWithdrawn}`,text:this.amountWithdrawn })
            .placeholderFont({ size: 14 })
            .fontColor($r("app.color.text_color1"))
            .fontSize(14)
            .layoutWeight(1)
            .backgroundColor($r("app.color.white"))
            .onChange((value)=>{
              this.amountWithdrawn = value
            })

          Text("全部")
            .fontColor($r("app.color.text_payouts_color"))
            .fontSize(13)
            .width(50)
            .textAlign(TextAlign.Center)
            .onClick(()=>{
              this.amountWithdrawn = (this.userInfoData?.data?.Balance).toString()
            })
        }
        .width("100%")
        .padding(8)
        .alignItems(VerticalAlign.Center)
        .justifyContent(FlexAlign.Center)
      }
      .width("90%")
      .margin({ left: 20, right: 20 })
      .borderRadius(10)
      .backgroundColor($r("app.color.white"))

      Row() {
        Text("添加备注")
          .fontColor($r("app.color.color_shubihong"))
          .fontSize(14)
          .width("90%")
          .textAlign(TextAlign.Start)
          .padding(10)
      }
      .visibility(this.addRemark)
      .alignItems(VerticalAlign.Center)
      .justifyContent(FlexAlign.Start)
      .onClick(() => {
        this.setClicks()
      })

      Row() {
        TextArea({
          placeholder: "备注说明",
          text: this.remark
        })
          .fontSize(14)
          .height(200)
          .backgroundColor($r("app.color.white"))
          .wordBreak(WordBreak.BREAK_ALL)
          .onChange((value) => {
            this.remark = value
          })
      }
      .margin({ top: 20 })
      .visibility(this.addRemarkTextInput)
      .width("90%")
      .alignItems(VerticalAlign.Center)
      .justifyContent(FlexAlign.Center)

      Row() {
        Button("立即提现")
          .width("100%")
          .type(ButtonType.Normal)
          .fontColor($r("app.color.white"))
          .fontSize(16)
          .backgroundColor($r("app.color.color_shubihong"))
          .borderRadius(3)
          .onClick(()=>{
            this.getSubmitWithdraw()
          })
      }
      .margin({ left: 20, right: 20, top: 20 })
      .alignItems(VerticalAlign.Center)
      .justifyContent(FlexAlign.Center)

      Row() {
        Text("提现记录>")
          .fontColor($r("app.color.color_shubihong"))
          .fontSize(13)
          .width("100%")
          .textAlign(TextAlign.End)
          .onClick(()=>{
            router.pushUrl({
              url:'pages/Pages_WithdrawalRecord'
            })
          })
      }
      .margin({ right: 20, top: 15 })

    }
    .width("100%")
    .height("100%")
    .backgroundColor($r("app.color.system_background_color"))
  }
}