import { BreakpointConstants, CommonConstants, showToast } from 'base';
import { deviceInfo } from '@kit.BasicServicesKit';
import { TitleBar } from '@smarthane/titlebar'
import { router } from '@kit.ArkUI';

@Component
export struct MainPage {
  private scroller: Scroller = new Scroller()
  @State isShow: Visibility = Visibility.None
  @State currentBottomIndex: number = 0;
  @StorageLink(BreakpointConstants.CURRENT_BREAKPOINT) currentBreakpoint: string = BreakpointConstants.BREAKPOINT_LG;
  @StorageLink(CommonConstants.AVOID_RECT_HEIGHT_TOP) TopRectHeight: number = 0;
  //titleBar组件
  @State model9: TitleBar.Model = new TitleBar.Model()
    .setLeftIcon($r("app.media.user"))
    .setLeftIconGravity(TitleBar.IconGravity.TOP)
    .setLeftIconWidth(35)
    .setLeftIconHeight(35)
    .setLeftIconPadding(5)
    .setLeftTitleFontSize(10)
    .setLeftTitleFontColor(Color.Blue)
    .setRightIcon($r("app.media.order"))
    .setRightIconGravity(TitleBar.IconGravity.TOP)
    .setRightIconWidth(35)
    .setRightIconHeight(35)
    .setRightIconPadding(5)
    .setRightTitleFontSize(10)
    .setTitleName("首页")
    .setTitleFontColor($r("app.color.text_color1"))
    .setOnLeftClickListener(() => {
      router.pushUrl({
        url:"pages/Pages_Mine"
      })
    })
    .setOnRightClickListener(() => {
      router.pushUrl({
        url:"pages/Pages_PlaceOrder"
      })
    })

  @Builder TitleBars(){
    Stack({ alignContent: Alignment.TopStart }){
      Flex({ direction: FlexDirection.Column }) {
        TitleBar({ model: $model9 })
      }
      .margin({top:30})
    }
    .width('100%')
    .backgroundColor(Color.White)
  }

  @Builder topMassageInfo(){
      GridRow({columns:{sm:3,md:3,lg:3},gutter:10}){
        GridCol({span:{sm:1,md:1},offset: 0, order: 0}){
          Column(){
            Text("100")
              .fontColor($r("app.color.text_h1"))
              .fontSize(16)
              .fontWeight(FontWeight.Bold)
            Text("今日人数")
              .fontColor($r("app.color.text_color1"))
              .fontSize(16)
              .padding(10)
          }
          .alignItems(HorizontalAlign.Center)
          .justifyContent(FlexAlign.Center)
          .height(90)
        }
        .onClick(()=>{
          showToast("点击今日人数")
        })

        GridCol({span:{sm:1,md:1}}){
          Column(){
            Text("100")
              .fontColor($r("app.color.text_h1"))
              .fontSize(16)
              .fontWeight(FontWeight.Bold)
            Text("今日完单")
              .fontColor($r("app.color.text_color1"))
              .fontSize(16)
              .padding(10)
          }
          .alignItems(HorizontalAlign.Center)
          .justifyContent(FlexAlign.Center)
          .height(90)
        }
        .onClick(()=>{
          showToast("点击今日完单")
        })

        GridCol({span:{sm:1,md:1}}){
          Column(){
            Text("100")
              .fontColor($r("app.color.text_h1"))
              .fontSize(16)
              .fontWeight(FontWeight.Bold)
            Text("今日流水")
              .fontColor($r("app.color.text_color1"))
              .fontSize(16)
              .padding(10)
          }
          .height(90)
          .alignItems(HorizontalAlign.Center)
          .justifyContent(FlexAlign.Center)
        }
        .onClick(()=>{
          showToast("点击今日流水")
        })
      }
  }

  @Builder taskList(){
    GridRow({columns:{sm:2,md:2,lg:2},gutter:10}){
      GridCol({span:{sm:1,md:1},offset: 0, order: 0}){
        Column(){
          Text("总待服务")
            .fontColor($r("app.color.text_color1"))
            .fontSize(22)
          Row(){
            Text("0")
              .fontColor($r("app.color.text_task_color"))
              .fontSize(33)
            Text("单")
              .fontColor($r("app.color.text_h1"))
              .fontSize(13)
            Text("0")
              .fontColor($r("app.color.text_task_color"))
              .fontSize(33)
            Text("货")
              .fontColor($r("app.color.text_h1"))
              .fontSize(13)
          }
          .margin({top:15})
        }
        .padding(18)
        .alignItems(HorizontalAlign.Center)
        .justifyContent(FlexAlign.Center)
      }
      .onClick(()=>{
        showToast("点击今日人数")
      })

      GridCol({span:{sm:1,md:1}}){
        Column(){
          Text("今日待服务")
            .fontColor($r("app.color.text_color1"))
            .fontSize(22)
          Row(){
            Text("0")
              .fontColor($r("app.color.text_task_color"))
              .fontSize(33)
            Text("单")
              .fontColor($r("app.color.text_h1"))
              .fontSize(13)
            Text("0")
              .fontColor($r("app.color.text_task_color"))
              .fontSize(33)
            Text("货")
              .fontColor($r("app.color.text_h1"))
              .fontSize(13)
          }
          .margin({top:15})

        }
        .padding(18)
        .alignItems(HorizontalAlign.Center)
        .justifyContent(FlexAlign.Center)
      }
      .onClick(()=>{
        showToast("点击今日完单")
      })
    }

    List(){

    }
    .lanes(1)
    .edgeEffect(EdgeEffect.Spring) // 边缘效果设置为Spring
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])

  }

  build() {
    Stack({ alignContent: Alignment.TopStart}){
      Scroll(this.scroller){
        Flex({ direction: FlexDirection.Column }){
          Column(){
            this.TitleBars()
          }

          Row(){
            this.topMassageInfo()
          }
          .width("90%")
          .height(90)
          .margin({left:18,right:18,top:10})
          .backgroundColor($r("app.color.start_window_background"))
          .borderRadius(10)
          //有任务时显示  无任务时隐藏
          Row(){
              Image($r("app.media.notice"))
                .width(25)
                .height(25)
            Text("有一个任务在进行，请规划好时间")
              .fontSize(15)
              .fontColor($r("app.color.text_h1"))
              .margin({left:8})
          }
          .padding(8)
          .width("90%")
          .height(35)
          .margin({left:18,right:18,top:10})
          .backgroundColor($r("app.color.start_window_background"))
          .borderRadius(8)
          .visibility(this.isShow)
          //任务列表显示
          Column(){
            this.taskList()
          }
          .width("90%")
          .margin({left:18,right:18,top:10})
          .backgroundColor($r("app.color.start_window_background"))
          .borderRadius(10)



        }

      }
      .scrollable(ScrollDirection.Vertical)
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring)
    }
    .width("100%")
    .height("100%")
    .backgroundColor($r("app.color.system_background_color"))
  }
}
