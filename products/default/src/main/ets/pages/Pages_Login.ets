import { Api ,showToast,PreferenceUtil,UserData} from "base"
import { router } from "@kit.ArkUI";

@Entry
@Component
export struct Pages_Login {

  @State showLoading: boolean = false;
  @State title: string = "登录";
  private account: string = "";
  private password: string = "";
  @State userData:UserData = new UserData()

  async login(){
    if (!this.account) {
      showToast("请输入用户名");
      return;
    }
    if (!this.password) {
      showToast("请输入密码");
      return;
    }
    this.showLoading = true;
    let res = await Api.net().login(this.account, this.password);
    this.showLoading = false;
    console.log(JSON.stringify(res))
    if (res.isSuccessWithData()) {
      showToast("登录成功");
      this.userData =  res.data as UserData
      AppStorage.setOrCreate("Token",this.userData.data.access_token)
      router.replaceUrl({
        url:"pages/Index"
      })
    } else {
      showToast(res.message);
    }
  }

  build() {

    Stack(){
      Column() {
        TextInput({
          placeholder: "请输入用户名"
        })
          .fontSize(15)
          .fontColor($r("app.color.text_h1"))
          .type(InputType.Email)
          .onChange((value) => {
            this.account = value
          })
        TextInput({
          placeholder: "请输入密码"
        })
          .margin({ top: 16 })
          .fontSize(15)
          .fontColor($r("app.color.text_h1"))
          .type(InputType.Password)
          .onChange((value) => {
            this.password = value
          })
        Button("登录", {
          type: ButtonType.Capsule
        })
          .width('100%')
          .margin({ top: 50 })
          .fontSize(15)
          .fontColor($r("app.color.white"))
          .backgroundColor($r("app.color.color_shubihong"))
          .onClick((e) => {
            this.login();
          })
      }
      .width('100%')
      .margin({ top: 120 })
      .padding({ left: 16, right: 16 })
    }
    .width('100%')
    .height('100%')

  }

}