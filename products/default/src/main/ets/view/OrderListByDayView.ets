import { router } from "@kit.ArkUI";
import { Api, DateUtils, LoadingUtils, showToast } from "base";
import { ConfigurationParams, Item, OrderListModel } from "base/src/main/ets/viewmodel/OrderListModel";
import { EmptyView } from "./EmptyView";

interface SevenDateModel {
  year: string;
  week: string;
  date: string;
  count:number;
  select: boolean;
}
@Component
export struct OrderListByDayView {
  @State status:string = ""
  @State indexs:number = 1
  private selectedDate: Date = new Date()
  private scroller: Scroller = new Scroller()
  @State toDays : string = ""
  @State dateList:string[] = ["一","二","三","四","五","六","日"]
  @State sevenDateList : SevenDateModel[] = []
  @State selectCalendarShow :Visibility = Visibility.None
  @State selectImageCalendarShow :Visibility = Visibility.Visible
  @State selectCalendarYear :string = ""
  @State selectCalendarMonthAndDay :string = ""
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

  async getOrderListByDay(status?:string){
    LoadingUtils.showLoading("加载中...")
    this.indexs = 1
    let res = await Api.net().getOrderListByDay(this.indexs,this.toDays);
    if (res.data?.statusCode == 200) {
      LoadingUtils.hideLoading();
      this.orderList = res.data as OrderListModel
      this.orderListConfiguration = this.orderList.data.ConfigurationParams
      this.orderListByDayItem = this.orderList.data.Item
    }else{
      LoadingUtils.hideLoading();
      showToast(res.data?.message +"")
    }

  }

  aboutToAppear(): void {
    const  topDate:string[] =  DateUtils.getTimeList()
    //拿到当前日期
    const nowDate  = DateUtils.formatDateWithLeadingZeros(DateUtils.getCurrentTime("yyyy-MM-dd"))
    this.toDays = nowDate
    //顶部日期List数据封装
    for (let i = 0; i <topDate.length; i++) {
      const month :number = DateUtils.getMonth(new Date())
      const day:number = DateUtils.getDay(new Date())
      const dateParts = topDate[i].split("/");
      const weeks:string =  this.dateList[DateUtils.getWeekIndex(topDate[i],"yyyy-MM-dd")-1]
      const sevenDate: SevenDateModel = {
        year: dateParts[0],
        week: weeks,
        date: `${dateParts[1]}/${dateParts[2]}`,
        count:0,
        select: `${dateParts[1]}/${dateParts[2]}` == `${month}/${day}`
      }
      this.sevenDateList.push(sevenDate)
    }

    this.getOrderListByDay()
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


  build() {
    Column() {
      Flex({direction:FlexDirection.Row,justifyContent:FlexAlign.SpaceBetween}){
        Row(){
          List({space:5,initialIndex:this.sevenDateList.length-1}){
            ForEach(this.sevenDateList,(item:SevenDateModel,index:number)=>{
              ListItem(){
                RelativeContainer(){
                  Column({space:8}){
                    Text(item.week)
                      .fontColor(this.sevenDateList[index].select ? $r("app.color.white"):$r("app.color.text_h1"))
                      .fontSize(12)
                    Text(item.date)
                      .fontColor(this.sevenDateList[index].select ? $r("app.color.white"):$r("app.color.text_h1"))
                      .fontSize(12)
                      .textAlign(TextAlign.Center)
                      .width(40)
                  }
                  .padding(5)
                  .alignRules({
                    middle: { anchor: "__container__", align: HorizontalAlign.Center },
                    center: { anchor: "__container__", align: VerticalAlign.Center },
                  })
                  Column(){
                    Text(this.sevenDateList[index].count.toString())
                      .fontColor($r("app.color.white"))
                      .fontSize(9)
                      .width(12)
                      .height(12)
                      .textAlign(TextAlign.Center)
                      .borderRadius(6)
                      .backgroundColor(Color.Red)
                  }
                  .visibility(this.sevenDateList[index].count != 0 ? Visibility.Visible :Visibility.None)
                  .alignRules({
                    top: { anchor: "__container__", align: VerticalAlign.Top },
                    right: { anchor: "__container__", align: HorizontalAlign.End },
                  })


                }
                .backgroundColor(this.sevenDateList[index].select ? $r("app.color.color_shubihong") :$r("app.color.white"))

                .width(40)
                .height(50)
                .borderRadius(3)
              }
              .onClick(()=>{
                //点击条目改变选中背景色和文字字体
                this.sevenDateList.forEach((date, i) => {
                  this.sevenDateList[i].select = i === index;
                });
                //...(展开运算符) 适用于数组和集合
                this.sevenDateList = [...this.sevenDateList];
                //点击后日期重新赋值
                this.toDays = DateUtils.formatDateWithLeadingZeros(item.year+"/"+item.date)
                //请求数据
                this.getOrderListByDay("1")
                //隐藏布局
                this.selectImageCalendarShow = Visibility.Visible
                this.selectCalendarShow = Visibility.None
              })

            },(item:SevenDateModel)=>item.date)
          }
          // .margin({left:10})
          .layoutWeight(7)
          .lanes(1)
          .scrollBar(BarState.Off)
          .listDirection(Axis.Horizontal)


          Column({space:3}){
            Column({space:3}){
              Image($r("app.media.calendar"))
                .width(20)
                .height(20)
              Image($r("app.media.icon_down"))
                .width(12)
            }
            .visibility(this.selectImageCalendarShow)

            Column({space:2}){
              Text(this.selectCalendarYear)
                .fontColor(this.selectCalendarShow == Visibility.Visible ? $r("app.color.white"): $r("app.color.text_color1"))
                .fontSize(12)
              Text(this.selectCalendarMonthAndDay)
                .fontColor(this.selectCalendarShow == Visibility.Visible ? $r("app.color.white"): $r("app.color.text_color1"))
                .fontSize(12)
            }
            .visibility(this.selectCalendarShow)

          }
          .layoutWeight(1)
          .alignItems(HorizontalAlign.Center)
          .justifyContent(FlexAlign.Center)
          .width(40)
          .height(50)
          // .margin({right:10})
          .backgroundColor(this.selectCalendarShow == Visibility.Visible ?$r("app.color.color_shubihong"):$r("app.color.white"))
          .borderRadius(3)
          // .border({
          //   width:1,
          //   color:Color.Red
          // })
          .onClick(()=>{
            CalendarPickerDialog.show({
              selected: this.selectedDate,
              onAccept: (value) => {
                console.log("选中日期==>" + JSON.stringify(DateUtils.formatDate(value,"yyyy-MM-dd")))
                this.selectImageCalendarShow = Visibility.None
                this.selectCalendarShow = Visibility.Visible
                const selectTime = DateUtils.formatDate(value,"yyyy-MM-dd")
                this.selectCalendarYear = selectTime.split("/")[0]
                this.selectCalendarMonthAndDay = selectTime.split("/")[1] +"/" +selectTime.split("/")[2]
                //这里要更新日期数据
                this.sevenDateList.forEach((date,i)=>{
                  this.sevenDateList[i].select = false;
                })
                this.sevenDateList = [...this.sevenDateList];
                //日期赋值判断=请求要过滤数据
                this.toDays = selectTime
                //刷新列表
                this.getOrderListByDay("1")
              }
            })
          })

        }
        .margin({left:10,right:10})
        .width("100%")
        .height(50)
        .justifyContent(FlexAlign.SpaceBetween)
        .backgroundColor($r("app.color.white"))

      }

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
      .backgroundColor($r("app.color.white"))

      this.listByItem()
    }
    .width("100%")
  }
}