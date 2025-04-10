import { TitleBar } from '@smarthane/titlebar';
import { router } from '@kit.ArkUI';
import { MMKV } from '@tencent/mmkv';

@Entry
@Component
struct Pages_SubmitForRevie {
  //titleBar组件
  @State model9: TitleBar.Model = new TitleBar.Model()
    .setLeftIcon($r("app.media.user"))
    .setLeftIconGravity(TitleBar.IconGravity.TOP)
    .setLeftIconWidth(35)
    .setLeftIconHeight(35)
    .setLeftIconPadding(5)
    .setLeftTitleFontSize(10)
    .setLeftTitleFontColor(Color.Blue)
    .setTitleName("哈哈定制司机")
    .setTitleFontColor($r("app.color.text_color1"))
    .setOnLeftClickListener(() => {
      router.pushUrl({
        url:"pages/Pages_Mine"
      })
    })

  @Builder TitleBars(){
    Column(){
      TitleBar({ model: $model9 })
    }
  }

  aboutToAppear(): void {
    MMKV.defaultMMKV().encodeString("TARGET","UnderReview")
  }


  build() {
    Column() {
      this.TitleBars()

      AlignItemsFlex({ justifyContent:FlexAlign.Center,alignItems: ItemAlign.Center })


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
        Image($r('app.media.submit_review'))
          .width(100)
          .height(100)
        Text("提交成功！")
          .fontColor($r('app.color.text_color1'))
          .fontSize(18)
        Text("相关人员将在1-7个工作日内处理")
          .fontColor($r('app.color.text_color2'))
          .fontSize(15)
          .margin({top:10})
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