import { TitleBar } from '@smarthane/titlebar'
import { router } from '@kit.ArkUI'
import { Api, LoadingUtils, showToast } from 'base'
import { Item, OrderListModel } from 'base/src/main/ets/viewmodel/OrderListModel'
import { JSON } from '@kit.ArkTS'
import { EmptyView } from '../view/EmptyView'

@Entry
@Component
struct Pages_All_TaskList {
  @State fontColor: string = '#182431'
  @State selectedFontColor: string = '#353436'
  @State currentIndex: number = 0
  @State selectedIndex: number = 0
  private controller: TabsController = new TabsController()
  //titleBar组件
  @State model1: TitleBar.Model = new TitleBar.Model()
    .setOnLeftClickListener(() => {
      router.back()
    })
    .setTitleName("订单列表")
    .setTitleFontColor($r("app.color.text_color1"))
  @State showLoading: boolean = false;
  @State orderList:OrderListModel = new OrderListModel()
  @State orderListItem:Item[] = []
  @State pullLoadOrderList:OrderListModel = new OrderListModel()
  @State status:string = ""
  @State pagesStatus:string = ""
  //刷新状态变量
  @State refreshing: boolean = false;
  @State refreshOffset: number = 0;
  @State refreshState: RefreshStatus = RefreshStatus.Inactive;
  @State canLoad: boolean = false;
  @State isLoading: boolean = false;
  @State indexs:number = 1




  orderLists(list:OrderListModel){
    console.log("数据变化了吗"+JSON.stringify(list.data.Item))
  }

  @Builder TitleBars(){
    Column(){
      TitleBar({ model: $model1 })
    }
  }

  @Builder tabBuilder(index: number, name: string) {
    Column() {
      Text(name)
        .fontColor(this.selectedIndex === index ? this.selectedFontColor : this.fontColor)
        .fontSize(16)
        .fontWeight(this.selectedIndex === index ? 500 : 400)
        .lineHeight(22)
        .margin({ top: 17, bottom: 7 })
      Divider()
        .strokeWidth(2)
        .width(20)
        .color($r("app.color.color_shubihong"))
        .opacity(this.selectedIndex === index ? 1 : 0)
    }.width('100%')
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



  @Builder listAndItem(){
    Flex({ direction: FlexDirection.Column }) {
      if (this.orderListItem.length === 0){
        EmptyView()
      }else{
        Refresh({refreshing:$$this.refreshing}){
          List({space:10}){
            ForEach(this.orderListItem,(item:Item,index:number)=>{

              ListItem(){
                Column(){
                  Row(){
                    Text(this.orderListItem[index].DayName + " " +item.DayTime)
                      .fontColor($r("app.color.text_h1"))
                      .fontSize(13)
                    Text(this.orderListItem[index].OrderStatus == 1 ? "待出发" : item.OrderStatus == 2 ? "进行中" : item.OrderStatus == 3 ? "已完成" : "")
                      .fontColor($r("app.color.text_color1"))
                      .fontSize(15)
                  }
                  .width("100%")
                  .alignItems(VerticalAlign.Center)
                  .justifyContent(FlexAlign.SpaceBetween)

                  Column({space:10}){
                    //出发地
                    Row({space:20}){
                      Row(){
                        Text("出发地")
                          .fontColor($r("app.color.text_h1"))
                          .fontSize(12)
                      }
                      .alignItems(VerticalAlign.Center)
                      .justifyContent(FlexAlign.Center)

                      Text(this.orderListItem[index]?.StartCity+"·"+this.orderListItem[index]?.StartPlace)
                        .fontColor($r("app.color.text_color1"))
                        .fontSize(14)
                    }
                    .width("100%")
                    .alignItems(VerticalAlign.Center)
                    .justifyContent(FlexAlign.Start)
                    //目的地
                    Row({space:20}){
                      Row(){
                        Text("目的地")
                          .fontColor($r("app.color.text_h1"))
                          .fontSize(12)
                      }
                      .alignItems(VerticalAlign.Center)
                      .justifyContent(FlexAlign.Center)

                      Text(this.orderListItem[index]?.EndCity+"·"+this.orderListItem[index]?.EndPlace)
                        .fontColor($r("app.color.text_color1"))
                        .fontSize(14)
                    }
                    .width("100%")
                    .alignItems(VerticalAlign.Center)
                    .justifyContent(FlexAlign.Start)
                    //人数
                    Row({space:20}){
                      Row(){
                        Text("人数")
                          .fontColor($r("app.color.text_h1"))
                          .fontSize(12)
                      }
                      .alignItems(VerticalAlign.Center)
                      .justifyContent(FlexAlign.Center)

                      Text(this.orderListItem[index]?.BookSeat +" 人")
                        .fontColor($r("app.color.text_color1"))
                        .fontSize(14)
                    }
                    .width("100%")
                    .alignItems(VerticalAlign.Center)
                    .justifyContent(FlexAlign.Start)
                    //票款
                    Row({space:20}){
                      Row(){
                        Text("票款")
                          .fontColor($r("app.color.text_h1"))
                          .fontSize(12)
                      }
                      .alignItems(VerticalAlign.Center)
                      .justifyContent(FlexAlign.Start)

                      Text(this.orderListItem[index].Amont +"元")
                        .fontColor($r("app.color.text_color1"))
                        .fontSize(14)
                      Text(this.orderListItem[index].EndStatus == 1 ? "[已入账]" :"[未入账]")
                        .fontColor($r("app.color.text_order_money_color"))
                        .fontSize(14)
                    }
                    .width("100%")
                    .alignItems(VerticalAlign.Center)
                    .justifyContent(FlexAlign.Start)
                  }
                  .margin({top:10,left:16})

                }
                .padding(10)
                .borderRadius(10)
                .backgroundColor($r("app.color.white"))
              }

            },(item:Item)=>item.Id)

            ListItem() {
              this.footer();
            }
          }
          .onScrollIndex((start:number,end:number)=>{
            // 当达到列表末尾时，触发新数据加载
            if (this.canLoad && end >= this.orderListItem.length - 1) {
              // console.log("触发新数据加载===>")
              this.canLoad = false;
              this.isLoading = true;
              //请求新数据加载
              this.pullUpLoad(this.status["value"] == "3" ? "0": this.status["value"]); // 调用上拉加载方法
            }
          })
          .onScrollFrameBegin((offset: number, state: ScrollState)=>{
            // 只有当向上滑动时触发新数据加载
            if (offset > 5 && !this.isLoading) {
              this.canLoad = true;
            }
            return { offsetRemain: offset };
          })
          .height('100%')
          .scrollBar(BarState.Off)
          // 开启边缘滑动效果
          .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
        }
        .width('100%')
        .height('100%')
        .onOffsetChange((offset: number) => {
          this.refreshOffset = offset;
        })
        .onStateChange((state: RefreshStatus) => {
          this.refreshState = state;
        })
        .onRefreshing(() => {
          //数据刷新
          setTimeout(() => {
            this.refreshing = false;
          }, 3000)
        })

      }
    }
  }




  async getOrderListData(status:string){
    LoadingUtils.showLoading("加载中...");
    this.indexs = 1
    this.showLoading = true;
    let res = await Api.net().getOrderListData(status,this.indexs);
    this.showLoading = false;
    LoadingUtils.hideLoading();
    this.orderList = res.data as OrderListModel
    this.orderListItem = this.orderList.data.Item
  }


  async pullUpLoad(status:string){
    LoadingUtils.showLoading("加载中...");
    this.indexs = this.indexs + 1
    let res = await Api.net().getOrderListData(status,this.indexs);
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
    // console.log("页面传值2===>"+JSON.stringify(this.currentIndex))
    // console.log("页面传值3===>"+JSON.stringify(this.selectedIndex))
    //请求
    this.getOrderListData(this.status["value"] == "3" ? "0": this.status["value"])
  }





  build() {
    Column() {
      this.TitleBars()

      Column() {
        Tabs({ barPosition: BarPosition.Start, index: this.currentIndex, controller: this.controller }) {
          TabContent() {
            this.listAndItem()
          }.tabBar(this.tabBuilder( 0, '已完成'))
          TabContent() {
            this.listAndItem()
          }.tabBar(this.tabBuilder(1, '待出发'))

          TabContent() {
            this.listAndItem()
          }.tabBar(this.tabBuilder(2, '进行中'))

          TabContent() {
            this.listAndItem()
          }.tabBar(this.tabBuilder(3, '全部'))
        }
        .scrollable(false)
        .vertical(false)
        .barMode(BarMode.Fixed)
        .barWidth(360)
        .barHeight(56)
        .animationDuration(0)
        .onChange((index: number) => {
          console.log("22222"+JSON.stringify(index))
          // currentIndex控制TabContent显示页签
          this.currentIndex = index
          this.selectedIndex = index
          console.log("当前显示的是=>>"+JSON.stringify(this.selectedIndex))
          console.log("当前点击的是=>>"+JSON.stringify(this.currentIndex))
          this.getOrderListData(this.currentIndex.toString())
        })
        .width(360)
        .height("90%")
      }
      .width('100%')
    }
    .width("100%")
    .backgroundColor($r("app.color.system_background_color"))
  }
}


