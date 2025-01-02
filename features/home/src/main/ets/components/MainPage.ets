import { Api, BreakpointConstants, CommonConstants, showToast } from 'base';
import { TitleBar } from '@smarthane/titlebar'
import { router } from '@kit.ArkUI';
import { JSON } from '@kit.ArkTS';
import { HomeIndexModel } from 'base/src/main/ets/viewmodel/HomeIndexModel';
import { MMKV } from '../../../../../../common/base/oh_modules/@tencent/mmkv/src/main/ets/utils/MMKV';
import { HomeDataModel, LineList } from 'base/src/main/ets/viewmodel/HomeDataModel';
import { Data } from 'base/src/main/ets/api/Response';

@Component
export struct MainPage {
  private scroller: Scroller = new Scroller()
  @State isShow: Visibility = Visibility.Visible
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
  @State showLoading: boolean = false;
  @State carId :string | undefined = ""
  @State indexData:HomeIndexModel = new HomeIndexModel()
  @State homeData:HomeDataModel = new HomeDataModel()

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
            Text(this.homeData?.data?.TodayPeople.toString())
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
            Text(this.homeData?.data?.TodayFinishOrder.toString())
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
            Text(this.homeData?.data?.TodayMoney.toString())
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
    GridRow({columns:{sm:1,md:1,lg:1},gutter:10}){
      GridCol({span:{sm:1,md:1},offset: 0, order: 0}){
        Column(){
          Text("总待服务订单数")
            .fontColor($r("app.color.text_color1"))
            .fontSize(22)
          Row(){
            Text(this.homeData?.data?.WaitOrderCount.toString())
              .fontColor($r("app.color.text_task_color"))
              .fontSize(33)
            Text("单")
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
    }

    List(){
      ForEach(this.homeData?.data?.LineList,(item:LineList, index:number)=>{
        ListItem(){
          Row(){
            RelativeContainer(){
              Row(){
                Text(index.toString())
                  .fontColor($r("app.color.white"))
                  .fontSize(12)
                  .width(20)
                  .height(20)
                  .textAlign(TextAlign.Center)
                  .backgroundColor($r("app.color.text_task_number_color2"))
              }
              .alignRules({
                top: { anchor: "__container__", align: VerticalAlign.Top },
                left: { anchor: "__container__", align: HorizontalAlign.Start }
              })
            }
            .width(45)
            .height(45)


            Flex({direction:FlexDirection.Row}){
              Row(){
                Text(item.StartCity)
                  .fontColor($r("app.color.text_color1"))
                  .fontSize(17)

                Image($r("app.media.right"))
                  .width(25)
                  .height(20)

                Text(item.EndCity)
                  .fontColor($r("app.color.text_color1"))
                  .fontSize(17)
              }
              .width("55%")
              .height(45)
              .justifyContent(FlexAlign.Start)
              .alignItems(VerticalAlign.Center)

              Row(){
                Text("查看订单")
                  .fontColor($r("app.color.text_color1"))
                  .fontSize(22)
                Image($r("app.media.right_jt_copy"))
                  .backgroundColor($r("app.color.color_shubihong"))
                  .width(20)
                  .height(30)

              }
              .width("35%")
              .height(45)
              .justifyContent(FlexAlign.Center)
              .alignItems(VerticalAlign.Center)

            }
            .width("90%")
            .height(45)

          }
          .margin({left:10,bottom:20})
          .width("94%")
          .height(45)
          .backgroundColor($r("app.color.text_task_list_bg"))
        }
        .onClick(()=>{
          showToast("点击条目事件调用")
        })
      },(item:LineList)=>item.Id)
    }
    .lanes(1)
    .edgeEffect(EdgeEffect.Spring) // 边缘效果设置为Spring
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
  }

  aboutToAppear(): void {
    this.getIndexData()
  }



  //请求首页数据
  async getIndexData(){
    console.log("啥啥啥===>"+JSON.stringify(MMKV.defaultMMKV().decodeString("CAR_ID")))
    this.showLoading = true;
    let res = await Api.net().getHomeIndexData();
    this.showLoading = false;
    console.log("首页数据====>"+JSON.stringify(res.data))
    this.indexData = (res.data as HomeIndexModel);
    console.log("首页数据====>"+JSON.stringify(this.indexData.data.Code))
    if (this.indexData.data.Code != 302) {
      MMKV.defaultMMKV().encodeString("CAR_ID",this.indexData.data.CarId)
      //请求首页待服务数据展示
      this.getHomeDatas(this.indexData.data.CarId)
    }else if (this.indexData.data.Code ==302){//未绑定车辆
      this.isShow = Visibility.None
    }
  }

  async getHomeDatas(carId:string){
    this.showLoading = true;
    let res = await Api.net().getHomeDatas(carId);
    this.showLoading = false;
    console.log("首页待服务数据====>"+JSON.stringify(res.data))
    this.homeData = res.data as HomeDataModel
    console.log("首页待服务数据2222====>"+JSON.stringify(this.homeData.data.LineList))
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
