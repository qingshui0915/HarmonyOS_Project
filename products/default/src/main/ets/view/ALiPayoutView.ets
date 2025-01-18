import { showToast } from "base"

@Component
export struct ALiPayoutView {
  @State remark:string = ""
  @State addRemark :Visibility = Visibility.Visible
  @State addRemarkTextInput :Visibility = Visibility.None


  setClicks(){
    this.addRemark = Visibility.None
    this.addRemarkTextInput = Visibility.Visible
  }

  build() {
    Column() {
      Column() {
        Row({ space: 10 }) {
          Image($r("app.media.ali_icon"))
            .width(30)
            .height(30)
          TextInput({ placeholder: "请输入支付宝账号" })
            .placeholderFont({ size: 14 })
            .fontColor($r("app.color.text_color1"))
            .fontSize(14)
            .layoutWeight(1)
            .backgroundColor($r("app.color.white"))

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
          TextInput({ placeholder: "请输入真实姓名" })
            .placeholderFont({ size: 14 })
            .fontColor($r("app.color.text_color1"))
            .fontSize(14)
            .layoutWeight(1)
            .backgroundColor($r("app.color.white"))

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
          TextInput({ placeholder: "可提现金额" })
            .placeholderFont({ size: 14 })
            .fontColor($r("app.color.text_color1"))
            .fontSize(14)
            .layoutWeight(1)
            .backgroundColor($r("app.color.white"))

          Text("全部")
            .fontColor($r("app.color.text_payouts_color"))
            .fontSize(13)
            .width(50)
            .textAlign(TextAlign.Center)
            .onClick(()=>{
              showToast("点击赋值全部金额")
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
            showToast("输入的值===>" + JSON.stringify(value))
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
            showToast("跳转提现记录页面")
          })
      }
      .margin({ right: 20, top: 15 })

    }
    .width("100%")
    .height("100%")
    .backgroundColor($r("app.color.system_background_color"))
  }
}