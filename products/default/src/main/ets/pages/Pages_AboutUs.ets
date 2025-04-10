import { TitleBar } from '@smarthane/titlebar';
import { router } from '@kit.ArkUI';
import { showToast } from 'base';

@Entry
@Component
struct Pages_AboutUs {
  @State message: string = '关于我们';
  @State model1: TitleBar.Model = new TitleBar.Model()
    .setOnLeftClickListener(() => {
      router.back()
    })
    .setTitleName(this.message)
    .setTitleFontColor($r("app.color.text_color1"))

  @Builder TitleBars(){
    Column(){
      TitleBar({ model: $model1 })
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
    Column() {
      this.TitleBars()
      Column({space:30}){
        Row(){
          Row({space:8}){
            Text("隐私协议")
              .fontColor($r("app.color.text_color1"))
              .fontSize(16)
          }
          .alignItems(VerticalAlign.Center)
          .justifyContent(FlexAlign.Center)
          Image($r("app.media.arrow_right"))
            .width(18)
            .height(18)
        }
        .visibility(Visibility.Visible)
        .width("90%")
        .margin({left:20,right:20})
        .alignItems(VerticalAlign.Center)
        .justifyContent(FlexAlign.SpaceBetween)
        .onClick(()=>{
          this.openWebUrl("otherPages/pages/rich-text/rich-text?code=CustomDriverAppPrivacyAgreeme")
        })
        Row(){
          Row({space:8}){
            Text("备案号")
              .fontColor($r("app.color.text_color1"))
              .fontSize(16)
          }
          .alignItems(VerticalAlign.Center)
          .justifyContent(FlexAlign.Center)
          Text('豫ICP备18030969号-6A')
            .fontColor($r('app.color.text_h1'))
            .fontSize(14)
        }
        .visibility(Visibility.Visible)
        .width("90%")
        .margin({left:20,right:20})
        .alignItems(VerticalAlign.Center)
        .justifyContent(FlexAlign.SpaceBetween)

        Row(){
          Row({space:8}){
            Text("版本号")
              .fontColor($r("app.color.text_color1"))
              .fontSize(16)
          }
          .alignItems(VerticalAlign.Center)
          .justifyContent(FlexAlign.Center)
          Text('V1.0.0')
            .fontColor($r('app.color.text_h1'))
            .fontSize(14)
          // Image($r("app.media.arrow_right"))
          //   .width(18)
          //   .height(18)
        }
        .visibility(Visibility.Visible)
        .width("90%")
        .margin({left:20,right:20})
        .alignItems(VerticalAlign.Center)
        .justifyContent(FlexAlign.SpaceBetween)
        .onClick(()=>{
          showToast("检查更新")
        })
      }
      .padding({top:20,bottom:20})
      .borderRadius(10)
      .backgroundColor($r('app.color.white'))
    }
    .height('100%')
    .width('100%')
    .backgroundColor($r("app.color.system_background_color"))
  }
}