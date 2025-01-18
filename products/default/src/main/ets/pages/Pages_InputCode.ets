import { TitleBar } from '@smarthane/titlebar'
import { router } from '@kit.ArkUI'
import { JSON } from '@kit.ArkTS'
import { Api, CommonConstants, showToast } from 'base'
import { CheckTicketModel } from 'base/src/main/ets/viewmodel/CheckTicketModel'
import { MMKV } from '@tencent/mmkv'
import { common } from '@kit.AbilityKit'
import { window } from '@kit.ArkUI'

@Entry
@Component
struct Pages_InputCode {
  //titleBar组件
  @State model1: TitleBar.Model = new TitleBar.Model()
    .setOnLeftClickListener(() => {
      router.back()
    })
    .setTitleName("输码检票")
    .setTitleFontColor($r("app.color.text_color1"))
  @State shiftId :string = ""
  @State inputCode :string = ""
  @State showLoading: boolean = false;
  @State checkTicketParams :CheckTicketModel = new CheckTicketModel()
  @State topHeight : number = 0
  @State bottomHeight : number = 0




  @Builder TitleBars(){
    Column(){
      TitleBar({ model: $model1 })
    }

  }

  aboutToAppear(): void {
    this.topHeight =  AppStorage.get(CommonConstants.AVOID_RECT_HEIGHT_TOP) as number
    this.bottomHeight =  AppStorage.get(CommonConstants.AVOID_RECT_HEIGHT_BOTTOM) as number


    this.shiftId = router.getParams() as string
    console.log("页面传值====>" +JSON.stringify(this.shiftId))


    console.log("上高度===>"+JSON.stringify(AppStorage.get(CommonConstants.AVOID_RECT_HEIGHT_TOP)))
    console.log("下高度===>"+JSON.stringify(AppStorage.get(CommonConstants.AVOID_RECT_HEIGHT_BOTTOM)))

  }

  async submitInputCode(){
    if (!this.inputCode) {
      showToast("请输入检票码")
      return
    }
    this.showLoading = true;
    const carId = MMKV.defaultMMKV().decodeString("CAR_ID") as string
    this.checkTicketParams.carId = carId
    this.checkTicketParams.shiftId = this.shiftId["value"]
    this.checkTicketParams.code = this.inputCode
    let res = await Api.net().getCheckTicket(this.checkTicketParams);
    this.showLoading = false;
    if (res.isSuccessWithData()) {
      console.log("检票==>"+JSON.stringify(res.data))

    }else{
      showToast(res.message)
    }

  }



  build() {

    Column(){
      this.TitleBars()

      Text("请输入检票码")
        .fontColor($r("app.color.text_color1"))
        .fontSize(18)
        .width('100%')
        .padding(10)
        .textAlign(TextAlign.Start)
      Row(){
        TextInput({placeholder:"请输入检票码"})
          .type(InputType.Number)
          .placeholderFont({size:14})
          .fontColor($r("app.color.text_color1"))
          .fontSize(15)
          .borderRadius(10)
          .width('100%')
          .backgroundColor($r("app.color.white"))
          .onChange((value)=>{
            this.inputCode = value
          })
      }

      .margin({left:20,right:20,top:10})


      Row(){
        Button("确定")
          .width("100%")
          .type(ButtonType.Normal)
          .fontColor($r("app.color.white"))
          .fontSize(16)
          .backgroundColor($r("app.color.color_shubihong"))
          .borderRadius(3)
          .onClick(()=>{
            this.submitInputCode()
          })
      }
      .margin({left:20,right:20,top:30})
      .alignItems(VerticalAlign.Center)
      .justifyContent(FlexAlign.Center)

    }
    .width('100%')
    .height('100%')
    .backgroundColor($r("app.color.system_background_color"))
  }
}