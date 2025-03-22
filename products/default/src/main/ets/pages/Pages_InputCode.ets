import { TitleBar } from '@smarthane/titlebar'
import { router } from '@kit.ArkUI'
import { JSON } from '@kit.ArkTS'
import { Api, CommonConstants, EventBus, LoadingUtils, showToast } from 'base'
// import { CheckTicketModel } from 'base/src/main/ets/viewmodel/CheckTicketModel'
import { MMKV } from '@tencent/mmkv'
import { BaseModel } from 'base/src/main/ets/viewmodel/BaseModel';
// 输码后: eventBus 发送和接收的数据模型
interface InputCodeModule {
  name: string
}
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
  @State topHeight : number = 0
  @State bottomHeight : number = 0
  @State baseModel :BaseModel = new BaseModel()



  @Builder TitleBars(){
    Column(){
      TitleBar({ model: $model1 })
    }

  }

  aboutToAppear(): void {
    LoadingUtils.init(this.getUIContext());
    this.topHeight =  AppStorage.get(CommonConstants.AVOID_RECT_HEIGHT_TOP) as number
    this.bottomHeight =  AppStorage.get(CommonConstants.AVOID_RECT_HEIGHT_BOTTOM) as number


    this.shiftId = router.getParams() as string
    console.log("页面传值====>" +JSON.stringify(this.shiftId))


    console.log("上高度===>"+JSON.stringify(AppStorage.get(CommonConstants.AVOID_RECT_HEIGHT_TOP)))
    console.log("下高度===>"+JSON.stringify(AppStorage.get(CommonConstants.AVOID_RECT_HEIGHT_BOTTOM)))

  }

  onPageHide(): void {
    EventBus.cancel('InputCodeModule')
    // this.context.eventHub.off("myEvent")
  }



  async submitInputCode(){
    if (!this.inputCode) {
      showToast("请输入检票码")
      return
    }
    const carId = MMKV.defaultMMKV().decodeString("CAR_ID") as string
    const  params: Record<string, string> = {
      'carId':carId,
      'shiftId' :this.shiftId["value"],
      'code' :this.inputCode.trim()
    };
    console.log("入参数据打印===>"+JSON.stringify(params))
    LoadingUtils.showLoading("加载中...");
    let res = await Api.net().getCheckTicket(params);
    this.baseModel =  res.data  as BaseModel
    if (res.isSuccessWithData()) {
      if (this.baseModel.statusCode == 200) {
        LoadingUtils.hideLoading()
        console.log("检票==>"+JSON.stringify(res.data))
        //检票成功发送事件
        let eventData: InputCodeModule = {
          name: '检票成功',
        }
        EventBus.send('InputCodeModule', eventData)
        showToast("检票成功！")
      }else{
        LoadingUtils.hideLoading()
        showToast(this.baseModel.message)
      }
    }else{
      LoadingUtils.hideLoading()
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