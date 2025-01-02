import { Api ,showToast,PreferenceUtil,UserData,RoutineConstants} from "base"
import { router } from "@kit.ArkUI";
import { VerificationCodeDialog } from "../view/VerificationCodeDialog"
import { TestModel } from "base/src/main/ets/viewmodel/TestModel";
import { ImageDataModel } from "base/src/main/ets/viewmodel/ImageDataModel";
import { SmsCodeModel } from "base/src/main/ets/viewmodel/SmsCodeModel";
import { JSON } from "@kit.ArkTS";
import { MMKV } from "@tencent/mmkv/src/main/ets/utils/MMKV";
import { UserInfoModel } from "base/src/main/ets/viewmodel/UserInfoModel";
import PrivacyPolicyDialog  from "../view/PrivacyPolicyDialog"
import { common } from "@kit.AbilityKit";

const TOTAL_COUNT = 60

@Entry
@Component
export struct Pages_Login {
  @State showAgreePrivacyPolicy:boolean = true;
  @State showLoading: boolean = false;
  @State isChecked: boolean = false;
  @State title: string = "登录";
  private account: string = "";
  private password: string = "";
  private lastNonce: string = "";
  @State verificationCode :string ="获取验证码"
  @State count: number = TOTAL_COUNT
  @State imagesUri:string = ""
  @State userData:UserData = new UserData()
  @State imagesDatas:ImageDataModel = new ImageDataModel()
  @State smsRequestData:SmsCodeModel = new SmsCodeModel()
  @State userInfoData:UserInfoModel = new UserInfoModel()
  @State lists :TestModel[] = []
  timerId: number = 0
  //
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




  //刷新图形验证码回调
  async onRefresh(){
    console.log("点击了回调到页面")
    this.showLoading = true;
    let res = await Api.net().getImgsCode(this.lastNonce);
    this.showLoading = false;
    if (res.isSuccessWithData()) {
      console.log(JSON.stringify(res.data))
      this.imagesDatas = (res.data as ImageDataModel)
      console.log("======>"+JSON.stringify(this.imagesDatas.data.Captche))
      this.imagesUri = this.imagesDatas.data.Captche
      console.log(this.imagesDatas.data.Captche)
    }else{
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
    this.smsRequestData.EventType =200
    this.smsRequestData.Code = str
    this.showLoading = true;
    // console.log("请求入参==="+JSON.stringify(this.smsRequestData))
    let res = await Api.net().getSmsCode(this.smsRequestData);
    this.showLoading = false;
    console.log(JSON.stringify(res))
    if (res.isSuccessWithData()) {
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

  //销毁清空
  aboutToDisappear(): void {
    clearInterval(this.timerId)
  }

  //登录请求
  async login(){
    if (!this.account) {
      showToast("请输入手机号码");
      return;
    }
    if (!this.password) {
      showToast("请输入验证码");
      return;
    }
    if (!this.isChecked) {
      showToast("请勾选同意用户隐私政策")
      return
    }
    this.showLoading = true;
    let res = await Api.net().login(this.account, this.password);
    this.showLoading = false;
    console.log(JSON.stringify(res))
    if (res.isSuccessWithData()) {
      showToast("登录成功");
      this.userData =res.data as UserData
      AppStorage.setOrCreate("Token", `Bearer ${this.userData.data.access_token}`)
      MMKV.defaultMMKV().encodeString("Token",`Bearer ${this.userData.data.access_token}`)
      // let res = await Api.net().getBanner("SpecialLineDriverBanner");
      // this.lists = (res.data as Data<TestModel>).data
      // console.log("===="+JSON.stringify(this.lists))
      this.getUserInfos()
    } else {
      showToast(res.message);
    }
  }

  //获取个人信息
  async getUserInfos(){
    this.showLoading = true;
    let res = await Api.net().getUserInfo();
    this.showLoading = false;
    console.log("获取个人信息-==="+JSON.stringify(res))
    if (res.isSuccessWithData()) {//200
      this.userInfoData = (res.data as UserInfoModel)
      MMKV.defaultMMKV().encodeString("USER_ID",this.userInfoData.data.Id)
      MMKV.defaultMMKV().encodeString("NAME",this.userInfoData.data.Name)
      MMKV.defaultMMKV().encodeBool("IS_BIND_CAR",this.userInfoData.data.IsBindCar)
      MMKV.defaultMMKV().encodeInt32("CAR_STATUS",this.userInfoData.data.CarStatus)
      MMKV.defaultMMKV().encodeString("PHONE",this.userInfoData.data.Phone)
      MMKV.defaultMMKV().encodeString("CAR_ID",this.userInfoData.data.CarId)
      // MMKV.defaultMMKV().encodeString("LoginClientId",this.userInfoData.data.LastLoginClientId)
      //存储登录状态
      MMKV.defaultMMKV().encodeString("IsLogins","IsLogin")
      if (!this.userInfoData.data.IsBindCar) {
        showToast("跳转绑定车辆信息页面")
      }else{
        if (this.userInfoData.data.CarStatus == 1) {
          showToast("登录成功!")
          router.replaceUrl({
            url:"pages/Index"
          })
        }else if (this.userInfoData.data.CarStatus == 0){
          showToast("跳转到审核中页面")
        }else if (this.userInfoData.data.CarStatus == -1){//审核驳回
          showToast("跳转到审核驳回页面")
        }else{//999状态
          showToast("跳转到审核驳回页面")
        }
      }
    }else{
      showToast(res.message);
    }
  }
  //图形验证码
  async getImageCode(){
    this.showLoading = true;
    let res = await Api.net().getImgsCode(this.lastNonce);
    this.showLoading = false;
    if (res.isSuccessWithData()) {
      console.log(JSON.stringify(res.data))
      this.imagesDatas = (res.data as ImageDataModel)
      // console.log("======>"+JSON.stringify(this.imagesDatas.data.Captche))
      this.imagesUri = this.imagesDatas.data.Captche
      console.log(this.imagesDatas.data.Captche)

      this.dialogController.open()
    }else{
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
    Stack({alignContent:Alignment.TopStart}){
      RelativeContainer(){
        Column({space:8}){
          Text("登录")
            .fontColor($r("app.color.text_color1"))
            .fontSize(30)
          Text("欢迎您的到来")
            .fontColor($r("app.color.text_h1"))
            .fontSize(16)
        }
        .margin({left:16})
        .alignItems(HorizontalAlign.Start)
        .justifyContent(FlexAlign.Start)
      }
      .height(100)
      .width(200)
      .margin({top:150})
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

        Button("登录", {
          type: ButtonType.Capsule
        })
          .width('100%')
          .margin({ top: 50 })
          .fontSize(15)
          .fontColor($r("app.color.white"))
          .backgroundColor($r("app.color.color_shubihong"))
          .onClick((e) => {
            //输入手机号、短信验证码请求接口+加上非空效验
            this.login();
          })
        Row(){
          Checkbox()
            .select(this.isChecked)
            .onChange((value:boolean)=>{
              if (value) {
                this.isChecked = true
              }else{
                this.isChecked = false
              }
            })
          Text("我已阅读并同意")
            .fontSize(14)
            .fontColor($r("app.color.text_h1"))
          Text("《隐私政策》")
            .fontSize(14)
            .fontColor($r("app.color.color_shubihong"))
            .onClick(()=>{
              this.openWebUrl("otherPages/pages/rich-text/rich-text?id=3718b9b6-6b7a-4d9f-9556-fc63a3ecdf86")
              // showToast("点击跳转查看隐私协议")
            })
        }
        .width("100%")
        .alignItems(VerticalAlign.Center)
        .justifyContent(FlexAlign.Center)
        .margin({top:10})

      }
      .width('100%')
      .margin({ top: 360 })
      .padding({ left: 16, right: 16 })
      if(this.showAgreePrivacyPolicy){//通过变量控制隐私政策弹窗是否显示
        PrivacyPolicyDialog({
          cancel:this.onCancel.bind(this),//取消按钮点击
          confirm:this.onAgree.bind(this),//确定按钮点击
        })
      }
    }
    .width('100%')
    .height('100%')

  }


  onCancel():void {
    (getContext(this) as common.UIAbilityContext)?.terminateSelf()
  }

  onAgree():void {//同意隐私政策
    this.showAgreePrivacyPolicy = false;
  }


  aboutToAppear(): void {

  }

}