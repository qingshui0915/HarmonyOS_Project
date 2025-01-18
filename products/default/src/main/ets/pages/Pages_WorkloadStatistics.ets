import { TitleBar } from '@smarthane/titlebar';
import { router } from '@kit.ArkUI';
import { EmptyView } from '../view/EmptyView';
import { Api, DateUtils, LoadingUtils, showToast } from 'base';
import { Item, OrderListModel } from 'base/src/main/ets/viewmodel/OrderListModel';
import { OrderListByDayView } from '../view/OrderListByDayView';
import { OrderListByWeekView } from '../view/OrderListByWeekView';
import { OrderListByMonthView } from '../view/OrderListByMonthView';
import { OrderListByCustomizeView } from '../view/OrderListByCustomizeView';

/**
 * 工作量统计页面
 */
@Entry
@Component
struct Pages_WorkloadStatistics {
  @State message: string = '工作量统计';
  @State fontColor: string = '#182431'
  @State selectedFontColor: string = '#353436'
  @State currentIndex: number = 0
  @State selectedIndex: number = 0
  private controller: TabsController = new TabsController()
  //刷新状态变量
  @State refreshing: boolean = false;
  @State refreshOffset: number = 0;
  @State refreshState: RefreshStatus = RefreshStatus.Inactive;
  @State canLoad: boolean = false;
  @State isLoading: boolean = false;
  @State indexs:number = 1
  //titleBar组件
  @State model1: TitleBar.Model = new TitleBar.Model()
    .setOnLeftClickListener(() => {
      router.back()
    })
    .setTitleName(this.message)
    .setTitleFontColor($r("app.color.text_color1"))
  @State showLoading: boolean = false;
  @State orderList:OrderListModel = new OrderListModel()
  @State orderListItem:Item[] = []
  @State pullLoadOrderList:OrderListModel = new OrderListModel()
  @State status:string = ""
  @State pagesStatus:string = ""




  //titleBar
  @Builder TitleBars(){
    Column(){
      TitleBar({ model: $model1 })
    }
  }

  @Builder tabBuilder(index: number, name: string) {
    Column({space:8}) {
      Text(name)
        .fontColor(this.selectedIndex === index ? this.selectedFontColor : this.fontColor)
        .fontSize(16)
        .fontWeight(this.selectedIndex === index ? 500 : 400)
        .lineHeight(22)
        .margin({ top: 17, bottom:5 })
      Divider()
        .strokeWidth(2)
        .width(20)
        .color($r("app.color.color_shubihong"))
        .opacity(this.selectedIndex === index ? 1 : 0)
    }
    .width('100%')
    .backgroundColor($r("app.color.white"))
  }

  //上拉加载样式
  @Builder footer() {
    Row() {
      LoadingProgress().height(32).width(48)
      Text("加载中")
    }.width("100%")
    .height(64)
    .justifyContent(FlexAlign.Center)
    // 当不处于加载中状态时隐藏组件
    .visibility(this.isLoading ? Visibility.Visible : Visibility.Hidden)
  }


  async getOrderListByDay(status:string){
    LoadingUtils.showLoading("加载中...");
    this.indexs = 1
    const toDay = DateUtils.getCurrentTime("yyyy-MM-dd")
    this.showLoading = true;
    let res = await Api.net().getOrderListByDay(this.indexs,toDay);
    this.showLoading = false;
    LoadingUtils.hideLoading();
    this.orderList = res.data as OrderListModel
    this.orderListItem = this.orderList.data.Item
  }


  async pullUpLoad(status:string){
    LoadingUtils.showLoading("加载中...");
    const toDay = DateUtils.getCurrentTime("yyyy-MM-dd")
    this.indexs = this.indexs + 1
    let res = await Api.net().getOrderListByDay(this.indexs,toDay);
    if (res.isSuccessWithData()) {
      LoadingUtils.hideLoading();
      this.pullLoadOrderList = res.data as OrderListModel
      this.orderListItem = this.orderListItem.concat(this.pullLoadOrderList.data.Item);
    }else{
      LoadingUtils.hideLoading();
      showToast(res.message)
    }


    this.isLoading = false;
  }

  aboutToAppear(): void {
    LoadingUtils.init(this.getUIContext());
    this.status = router.getParams() as string
    this.currentIndex = Number(this.status["value"])
    this.selectedIndex = Number(this.status["value"])
    console.log("页面传值1===>"+JSON.stringify(this.status["value"]))
    //请求
    // this.getOrderListByDay(this.status["value"])
  }





  build() {
    Column() {
      this.TitleBars()


      Column() {
        Tabs({ barPosition: BarPosition.Start, index: this.currentIndex, controller: this.controller }) {
          TabContent() {
            OrderListByDayView()
          }.tabBar(this.tabBuilder( 0, '日数据'))
          TabContent() {
            OrderListByWeekView()
          }.tabBar(this.tabBuilder(1, '周数据'))

          TabContent() {
            OrderListByMonthView()
          }.tabBar(this.tabBuilder(2, '月数据'))

          TabContent() {
            OrderListByCustomizeView()
          }.tabBar(this.tabBuilder(3, '自定义'))
        }
        .scrollable(false)
        .vertical(false)
        .barMode(BarMode.Fixed)
        .barWidth(400)
        .barHeight(56)
        .animationDuration(0)
        .onChange((index: number) => {
          // currentIndex控制TabContent显示页签
          this.currentIndex = index
          this.selectedIndex = index
          console.log("当前显示的是=>>"+JSON.stringify(this.selectedIndex))
          console.log("当前点击的是=>>"+JSON.stringify(this.currentIndex))
        })
        .width("100%")
        .height("90%")
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r("app.color.system_background_color"))
  }
}