import { Api, DateUtils, LoadingUtils, showToast } from "base";
import { ConfigurationParams, Item, OrderListModel } from "base/src/main/ets/viewmodel/OrderListModel";
import { EmptyView } from "./EmptyView";

@Component
export struct OrderListByCustomizeView {

  @State orderList:OrderListModel = new OrderListModel()
  @State orderListByDayItem:Item[] = []
  @State orderListConfiguration :ConfigurationParams = new ConfigurationParams()
  @State pullLoadOrderList:OrderListModel = new OrderListModel()
  //刷新状态变量
  @State refreshing: boolean = false;
  @State refreshOffset: number = 0;
  @State refreshState: RefreshStatus = RefreshStatus.Inactive;
  @State canLoad: boolean = false;
  @State isLoading: boolean = false;
  //默认进来选中本周
  @State selectWeek :boolean = true
  @State selectLastWeek :boolean = false
  //
  @State indexs:number = 1
  private selectedDate: Date = new Date()
  @State startTime :string = ""
  @State endTime :string = ""

  async getOrderListByCustomize(){
    if (!this.startTime) {
      showToast("请选择开始日期！")
      return
    }
    if (!this.endTime) {
      showToast("请选择结束日期！")
      return
    }
    LoadingUtils.showLoading("加载中...")
    this.indexs = 1
    let res = await Api.net().getOrderListByCustomize(this.indexs,this.startTime,this.endTime);
    if (res.data?.statusCode == 200) {
      LoadingUtils.hideLoading();
      this.orderList = res.data as OrderListModel
      this.orderListConfiguration = this.orderList.data.ConfigurationParams
      this.orderListByDayItem = this.orderList.data.Item
    }else{
      LoadingUtils.hideLoading();
      showToast(res.data?.message + "")
    }

  }



  aboutToAppear(): void {
    // this.getOrderListByCustomize()
    //

  }

  @Builder listByItem(){
    Flex({ direction: FlexDirection.Column }) {
      if (this.orderListByDayItem.length === 0){
        EmptyView()
      }else{
        Refresh({refreshing:$$this.refreshing}){
          List({space:10}){
            ForEach(this.orderListByDayItem,(item:Item,index:number)=>{

              ListItem(){
                Column(){
                  Row(){
                    Text(this.orderListByDayItem[index].DayName + " " +item.DayTime)
                      .fontColor($r("app.color.text_h1"))
                      .fontSize(13)
                    Text(this.orderListByDayItem[index].OrderStatus == 1 ? "待出发" : item.OrderStatus == 2 ? "进行中" : item.OrderStatus == 3 ? "已完成" : "")
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

                      Text(this.orderListByDayItem[index]?.StartCity+"·"+this.orderListByDayItem[index]?.StartPlace)
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

                      Text(this.orderListByDayItem[index]?.EndCity+"·"+this.orderListByDayItem[index]?.EndPlace)
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

                      Text(this.orderListByDayItem[index]?.BookSeat +" 人")
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

                      Text(this.orderListByDayItem[index].Amont +"元")
                        .fontColor($r("app.color.text_color1"))
                        .fontSize(14)
                      Text(this.orderListByDayItem[index].EndStatus == 1 ? "[已入账]" :"[未入账]")
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
              .margin({left:20,right:20})

            },(item:Item)=>item.Id)

            ListItem() {
              this.footer();
            }
          }
          .onScrollIndex((start:number,end:number)=>{
            // 当达到列表末尾时，触发新数据加载
            if (this.canLoad && end >= this.orderListByDayItem.length - 1) {
              // console.log("触发新数据加载===>")
              this.canLoad = false;
              this.isLoading = true;
              //请求新数据加载
              // this.pullUpLoad(this.status["value"] == "3" ? "0": this.status["value"]); // 调用上拉加载方法
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
    .margin({top:10})
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

  build() {
    Column() {
      //点击切换
      Row({space:20}){
        Button(this.startTime ?  this.startTime : "开始日期")
          .width(120)
          .height(30)
          .type(ButtonType.Normal)
          .fontColor($r("app.color.text_h1"))
          .fontSize(13)
          .backgroundColor($r("app.color.white"))
          .borderRadius(5)
          .onClick(()=>{
            CalendarPickerDialog.show({
              selected: this.selectedDate,
              onAccept: (value) => {
                console.log("选中开始日期==>" + JSON.stringify(DateUtils.formatDate(value,"yyyy-MM-dd")))
                this.startTime = DateUtils.formatDate(value,"yyyy-MM-dd")
                this.getOrderListByCustomize()
              }
            })
          })

        Button(this.endTime ?  this.endTime : "结束日期")
          .width(120)
          .height(30)
          .type(ButtonType.Normal)
          .fontColor($r("app.color.text_h1"))
          .fontSize(13)
          .backgroundColor($r("app.color.white"))
          .borderRadius(5)
          .onClick(()=>{
            CalendarPickerDialog.show({
              selected: this.selectedDate,
              onAccept: (value) => {
                console.log("选中结束日期==>" + JSON.stringify(DateUtils.formatDate(value,"yyyy-MM-dd")))
                this.endTime = DateUtils.formatDate(value,"yyyy-MM-dd")
                this.getOrderListByCustomize()
              }
            })
          })
      }
      .margin({top:10})
      .width('80%')
      .alignItems(VerticalAlign.Center)
      .justifyContent(FlexAlign.SpaceBetween)

      //数量展示
      GridRow({columns:{sm:2,md:2,lg:2},gutter:10}){
        GridCol({span:{sm:1,md:1},offset: 0, order: 0}){
          Column(){
            Text(this.orderListConfiguration?.OrderCount?.toString())
              .fontColor($r("app.color.text_h1"))
              .fontSize(16)
              .fontWeight(FontWeight.Bold)
            Text("总人数")
              .fontColor($r("app.color.text_color1"))
              .fontSize(16)
              .padding(10)
          }
          .padding(5)
          .alignItems(HorizontalAlign.Center)
          .justifyContent(FlexAlign.Center)
          .height(60)
        }

        GridCol({span:{sm:1,md:1}}){
          Column(){
            Text(this.orderListConfiguration?.OrderAmount?.toString())
              .fontColor($r("app.color.text_h1"))
              .fontSize(16)
              .fontWeight(FontWeight.Bold)
            Text("总票款")
              .fontColor($r("app.color.text_color1"))
              .fontSize(16)
              .padding(10)
          }
          .padding(5)
          .alignItems(HorizontalAlign.Center)
          .justifyContent(FlexAlign.Center)
          .height(60)
        }
      }
      .margin({top:10,left:20,right:20})
      .borderRadius(8)
      // .border({
      //   width:1,
      //   color:Color.Red
      // })
      .backgroundColor($r("app.color.white"))
      //数据列表
      this.listByItem()




    }
    .width("100%")
    .backgroundColor($r("app.color.system_background_color"))
  }
}