import { TitleBar } from '@smarthane/titlebar';
import { router } from '@kit.ArkUI';
import { Api, LoadingUtils, RoutineConstants, showToast } from 'base';
import { ImageDataModel } from 'base/src/main/ets/viewmodel/ImageDataModel';
import { VerificationCodeDialog } from '../view/VerificationCodeDialog';
import { SmsCodeModel } from 'base/src/main/ets/viewmodel/SmsCodeModel';
import { BaseModel } from 'base/src/main/ets/viewmodel/BaseModel';
import { ChangePhoneNumModel } from 'base/src/main/ets/viewmodel/ChangePhoneNumModel';

const TOTAL_COUNT = 60

@Entry
@Component
struct Pages_RevisePhoneNum {
  @State message: string = 'Hello World';
  @State model1: TitleBar.Model = new TitleBar.Model()
    .setOnLeftClickListener(() => {
      router.back()
    })
    .setTitleName("修改手机号")
    .setTitleFontColor($r("app.color.text_color1"))
  private account: string = "";
  private password: string = "";
  private lastNonce: string = "";
  @State imagesUri:string = ""
  @State verificationCode :string ="获取验证码"
  @State count: number = TOTAL_COUNT
  @State imagesDatas:ImageDataModel = new ImageDataModel()
  @State smsRequestData:SmsCodeModel = new SmsCodeModel()
  @State changePhoneNumber:BaseModel = new BaseModel()
  @State changePhoneNum:ChangePhoneNumModel = new ChangePhoneNumModel()
  timerId: number = 0

  dialogController: CustomDialogController = new CustomDialogController({
    builder: VerificationCodeDialog({
      ImagesUri: this.imagesUri,
      swapItOut: () => {
        this.onRefresh()
      },
      confirm: (str: string) => {
        this.verify(str)
      }
    }),
    autoCancel: false, //弹窗是否自动取消
    alignment: DialogAlignment.Center, // 弹窗位置
    cornerRadius: 8,
    width: '90%'// 弹窗宽度
  })

  @Builder TitleBars(){
    Column(){
      TitleBar({ model: $model1 })
    }
  }
  //刷新图形验证码回调
  async onRefresh(){
    LoadingUtils.showLoading("加载中...")
    console.log("点击了回调到页面")
    let res = await Api.net().getImgsCode(this.lastNonce);
    if (res.isSuccessWithData()) {
      console.log(JSON.stringify(res.data))
      this.imagesDatas = (res.data as ImageDataModel)
      if (this.imagesDatas.statusCode == 200) {
        LoadingUtils.hideLoading()
        console.log("======>"+JSON.stringify(this.imagesDatas.data.Captche))
        this.imagesUri = this.imagesDatas.data.Captche
      }else{
        LoadingUtils.hideLoading()
        showToast(this.imagesDatas.message)
      }
    }else{
      LoadingUtils.hideLoading()
      showToast(res.message)
    }
  }

  //输入完图形验证码回调到本页面
  async verify(str:string){
    console.log("返回输入的图形验证码===>"+str)
    if (!this.account) {
      showToast("请输入手机号码");
      return;
    }
    if (!str) {
      showToast("请输入正确的图形验证码");
      return;
    }
    //请求发送验证码入参封装
    this.smsRequestData.Phone = this.account
    this.smsRequestData.EventType = 301
    this.smsRequestData.Code = str
    LoadingUtils.showLoading("加载中...")
    let res = await Api.net().getSmsCode(this.smsRequestData);
    if (res.isSuccessWithData()) {
      LoadingUtils.hideLoading()
      this.verificationCode = `${this.count}s`
      showToast("发送成功");
      this.startTimer()
    }else{
      showToast(res.message);
    }
  }

  //开始倒计时
  startTimer() {
    this.timerId = setInterval(() => {
      this.count--
      this.verificationCode = `${this.count}s`
      if (this.count < 0) {
        clearInterval(this.timerId)
        this.count = TOTAL_COUNT
      }
    }, 1000)
  }


  //图形验证码
  async getImageCode(){
    LoadingUtils.showLoading("加载中...")
    let res = await Api.net().getImgsCode(this.lastNonce);
    if (res.isSuccessWithData()) {
      console.log(JSON.stringify(res.data))
      this.imagesDatas = (res.data as ImageDataModel)
      if (this.imagesDatas.statusCode == 200) {
        LoadingUtils.hideLoading()
        this.imagesUri = this.imagesDatas.data.Captche
        console.log(this.imagesDatas.data.Captche)
        this.dialogController.open()
      }else{
        LoadingUtils.hideLoading()
        showToast(this.imagesDatas.message)
      }
    }else{
      LoadingUtils.hideLoading()
      showToast(res.message)
    }
  }

  async modifyPhone(){
    LoadingUtils.showLoading("加载中...")
    this.changePhoneNum.NewPhoneNum = this.account
    this.changePhoneNum.SmsCode = this.password
    let res = await Api.net().changePhoneNum(this.changePhoneNum);
    if (res.isSuccessWithData()) {
      console.log(JSON.stringify(res.data))
      this.changePhoneNumber = (res.data as BaseModel)
      if (this.changePhoneNumber.statusCode == 200) {
        LoadingUtils.hideLoading()
        showToast("修改成功")
      }else{
        LoadingUtils.hideLoading()
        showToast(this.changePhoneNumber.message)
      }
    }else{
      LoadingUtils.hideLoading()
      showToast(res.message)
    }
  }



  build() {
    Column(){
      this.TitleBars()

      Column() {
        TextInput({
          placeholder: "请输入手机号码"
        })
          .fontSize(15)
          .fontColor($r("app.color.text_h1"))
          .type(InputType.Number)
          .maxLength(11)
          .onChange((value) => {
            this.account = value
          })
        Row({space:10}){
          TextInput({
            placeholder: "请输入验证码"
          })
            .fontSize(15)
            .maxLength(4)
            .type(InputType.Number)
            .fontColor($r("app.color.text_h1"))
            .onChange((value) => {
              this.password = value
            })
            .width(200)
          Button(`${this.verificationCode}`,{
            type:ButtonType.Normal
          })
            .enabled(this.count === RoutineConstants.COUNTDOWN)
            .width(110)
            .height(35)
            .align(Alignment.Center)
            .borderRadius(15)
            .fontSize(14)
            .fontColor($r("app.color.white"))
            .backgroundColor($r("app.color.color_shubihong"))
            .onClick((e)=>{
              //验证码弹框+请求
              this.getImageCode()
            })

        }
        .width('100%')
        .margin({ top: 16 })
        .alignItems(VerticalAlign.Center)
        .justifyContent(FlexAlign.SpaceBetween)

        Button("提交", {
          type: ButtonType.Capsule
        })
          .width('100%')
          .margin({ top: 50 })
          .fontSize(15)
          .fontColor($r("app.color.white"))
          .backgroundColor($r("app.color.color_shubihong"))
          .onClick((e) => {
            //输入手机号、短信验证码请求接口+加上非空效验
            this.modifyPhone();
          })
      }
      .width('100%')
      .padding({ top:10,left: 16, right: 16,bottom:20 })
      .backgroundColor($r('app.color.white'))

    }
    .height('100%')
    .width('100%')
    .backgroundColor($r("app.color.system_background_color"))
  }
}