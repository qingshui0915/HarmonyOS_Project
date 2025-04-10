import { Api, LoadingUtils, showToast } from "base"
import { router } from "@kit.ArkUI"
import { UserInfoModel } from "base/src/main/ets/viewmodel/UserInfoModel"
import { SubmitWithdrawModel } from "base/src/main/ets/viewmodel/SubmitWithdrawModel"
import { BaseModel } from "base/src/main/ets/viewmodel/BaseModel"
import { JSON } from "@kit.ArkTS"


@Component
export struct WeChatPayoutView {
  // @Link type :number
  @State remark:string = ""
  @State addRemark :Visibility = Visibility.Visible
  @State addRemarkTextInput :Visibility = Visibility.None
  @State userInfoData:UserInfoModel = new UserInfoModel()
  @State isBindStatus: string = '';
  @State wxName:string = ""
  @State realName:string = ""
  @State amountWithdrawn:string = ""
  @State hintAmountWithdrawn:string = ""
  @State submitWithdrawModel:SubmitWithdrawModel = new SubmitWithdrawModel()
  @State baseModel:BaseModel = new BaseModel()

  setClicks(){
    this.addRemark = Visibility.None
    this.addRemarkTextInput = Visibility.Visible
  }
  // onRequest(){
  //   if (this.type == 2) {
  //     this.getUserInfos()
  //   }
  // }

  aboutToAppear(): void {
    this.getUserInfos()
  }

  onPageShow(): void {
    // console.log("2222"+JSON.stringify(this.type))
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
        if (this.userInfoData?.data?.NickName) {
          this.wxName = this.userInfoData?.data?.NickName
        }
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
    //请绑定微信后再提现
    if (this.isBindStatus == '去绑定') {
      showToast("请绑定微信后再提现")
      return
    }
    //判断输入真实姓名
    if (!this.realName) {
      showToast("请填写微信钱包真实姓名")
      return
    }
    //判断输入金额
    if (!this.amountWithdrawn) {
      showToast("请输入提现金额")
      return
    }
    LoadingUtils.showLoading('加载中...')
    this.submitWithdrawModel.Money = this.amountWithdrawn
    this.submitWithdrawModel.Note = this.remark
    this.submitWithdrawModel.RealName = this.realName
    this.submitWithdrawModel.Type = "2"
    let res = await Api.net().submitWithdraw(this.submitWithdrawModel);
    if (res.isSuccessWithData()) {
      console.log("=====>"+JSON.stringify(res.data))
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
      Column(){
        Row({space:10}){
          Image($r("app.media.new_wechat_icon"))
            .width(30)
            .height(30)
          TextInput({placeholder:"微信昵称",text:this.wxName})
            .placeholderFont({size:14})
            .fontColor($r("app.color.text_color1"))
            .fontSize(14)
            .layoutWeight(1)
            .backgroundColor($r("app.color.white"))

          Text(this.isBindStatus)
            .fontColor($r("app.color.button_logout_bg"))
            .fontSize(13)
            .width(50)
            .textAlign(TextAlign.Center)
            .onClick(()=>{
              router.pushUrl({
                url:'pages/Pages_BindWX'
              })
            })
        }
        .width("100%")
        .padding(8)
        .alignItems(VerticalAlign.Center)
        .justifyContent(FlexAlign.Center)
        Row({space:10}){
          Text("真实姓名")
            .fontColor($r("app.color.text_color1"))
            .fontSize(13)
          TextInput({placeholder:"请输入真实姓名",text:this.realName})
            .placeholderFont({size:14})
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
        Row({space:10}){
          Text("￥")
            .width(20)
            .height(20)
            .fontColor($r("app.color.text_color1"))
          TextInput({placeholder:`可提现金额: ${this.hintAmountWithdrawn}`,text:this.amountWithdrawn})
            .placeholderFont({size:14})
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
      .margin({left:20,right:20})
      .borderRadius(10)
      .backgroundColor($r("app.color.white"))

      Row(){
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
      .onClick(()=>{
        this.setClicks()
        // showToast("点击添加备注")
      })

      Row(){
        TextArea({placeholder:"备注说明",
          text: this.remark
        })
          .fontSize(14)
          .height(200)
          .backgroundColor($r("app.color.white"))
          .wordBreak(WordBreak.BREAK_ALL)
          .onChange((value)=>{
            this.remark = value
          })
      }
      .margin({top:20})
      .visibility(this.addRemarkTextInput)
      .width("90%")
      .alignItems(VerticalAlign.Center)
      .justifyContent(FlexAlign.Center)

      Row(){
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
      .margin({left:20,right:20,top:20})
      .alignItems(VerticalAlign.Center)
      .justifyContent(FlexAlign.Center)

      Row(){
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
      .margin({right:20,top:15})



    }
    .width("100%")
    .height("100%")
    .backgroundColor($r("app.color.system_background_color"))
  }
}