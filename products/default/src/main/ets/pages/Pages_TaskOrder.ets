import { router } from '@kit.ArkUI';
import { TitleBar } from '@smarthane/titlebar';
import { Api, DateUtils, EventBus, showToast } from 'base';
import { JSON } from '@kit.ArkTS';
import { MMKV } from '@tencent/mmkv/src/main/ets/utils/MMKV';
import { Data, OrderTaskModel } from 'base/src/main/ets/viewmodel/OrderTaskModel';
import { EmptyView } from '../view/EmptyView';
import { QRCodeDialog } from '../view/QRCodeDialog';


interface SevenDateModel {
  year: string;
  week: string;
  date: string;
  count:number;
  select: boolean;
}
interface DeliverToPassengerModule {
  name: string
}
@Entry
@Component
struct Pages_TaskOrder {

  private selectedDate: Date = new Date()
  private executed:boolean = false; // 布尔变量来标记是否已经执行过
  @State message: string = '任务订单';
  @State orderId :string =""
  @State model1: TitleBar.Model = new TitleBar.Model()
    .setOnLeftClickListener(() => {
      router.back()
    })
    .setTitleName(this.message)
    .setTitleFontColor($r("app.color.text_color1"))
  @State dateList:string[] = ["一","二","三","四","五","六","日"]
  @State toDays : string = ""
  @State sevenDateList : SevenDateModel[] = []
  @State showLoading: boolean = false;
  @State orderTaskList:OrderTaskModel = new OrderTaskModel();
  @State orderTaskItem: Data = new Data();
  @State count:number = 0
  @State selectCalendarShow :Visibility = Visibility.None
  @State selectImageCalendarShow :Visibility = Visibility.Visible
  @State selectCalendarYear :string = ""
  @State selectCalendarMonthAndDay :string = ""
  //二维码弹框
  QRDialogController: CustomDialogController = new CustomDialogController({
    builder: QRCodeDialog({
      itemData:this.orderTaskItem
    }),
    autoCancel: true, //弹窗是否自动取消
    alignment: DialogAlignment.Center, // 弹窗位置
    cornerRadius: 8,
    width: '90%'// 弹窗宽度
  })


  @Builder TitleBars(){
    Column(){
      TitleBar({ model: $model1 })
    }
  }

  @Builder listAndItem(){
    Flex({ direction: FlexDirection.Column }) {
      if (this.orderTaskList?.data?.length === 0){
        EmptyView()
      }else{
        List({space:10}){
          ForEach(this.orderTaskList?.data,(item:Data,index:number)=>{
            ListItem(){
              Column(){
                Row(){
                  Text(item.DayTime + " " + item.DayName)
                    .fontColor($r("app.color.text_h1"))
                    .fontSize(13)
                  Image($r("app.media.order"))
                    .width(30)
                    .height(30)
                    .onClick(()=>{
                      this.orderTaskItem = this.orderTaskList?.data[index]
                      this.QRDialogController.open()
                    })
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

                    Text(item?.StartCity)
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

                    Text(item?.EndCity)
                      .fontColor($r("app.color.text_color1"))
                      .fontSize(14)
                  }
                  .width("100%")
                  .alignItems(VerticalAlign.Center)
                  .justifyContent(FlexAlign.Start)
                }
                .margin({top:10,left:16})

                Divider()
                  .height(2)
                  .visibility(Visibility.Visible)
                  .width("100%")
                  .margin({top:10,bottom:10,})

                Row(){
                  Row(){
                    Row({space:8}){
                      Text("总票")
                        .fontColor($r("app.color.text_h1"))
                        .fontSize(13)
                      Text(item?.BookCount.toString())
                        .fontColor($r("app.color.text_h1"))
                        .fontSize(13)
                    }
                    .padding(10)
                    Row({space:8}){
                      Text("未检")
                        .fontColor($r("app.color.text_h1"))
                        .fontSize(13)
                      Text((item?.BookCount - item?.UseCount).toString())
                        .fontColor($r("app.color.not_checked_text_color"))
                        .fontSize(13)
                    }
                    .padding(10)
                    Row({space:8}){
                      Text("已检")
                        .fontColor($r("app.color.text_h1"))
                        .fontSize(13)
                      Text(item?.UseCount.toString())
                        .fontColor($r("app.color.text_h1"))
                        .fontSize(13)
                    }
                    .padding(10)
                  }

                  Button("去检票")
                    .borderRadius(3)
                    .backgroundColor($r("app.color.color_shubihong"))
                    .type(ButtonType.Normal)
                    .onClick(()=>{
                      router.pushUrl({
                        url:"pages/Pages_TaskList",
                        params:{value1:this.orderId["value"],value2:item.ShiftId }
                      })
                      // showToast("点击跳转去检票")
                    })
                }
                .justifyContent(FlexAlign.SpaceBetween)
                .width("100%")

              }
              .margin({left:20,right:20,top:10})
              .padding(10)
              .borderRadius(10)
              .backgroundColor($r("app.color.white"))
            }


          },(item:Data)=>item.ShiftId)
        }
        .scrollBar(BarState.Off)
        .onReachEnd(()=>{

        })
      }
    }
    .width("100%")
  }

  onPageShow(): void {
    EventBus.listen<DeliverToPassengerModule>('DeliverToPassenger', (data) => {
      if (data !== undefined) {
        if (data.name == "送达乘客") {
          //刷新列表数据
          this.getFlushedData()
        }
      }
    })
  }

  onPageHide(): void {
    //取消订阅
    EventBus.cancel('NoticeChildPages')
  }



  aboutToAppear(): void {
    const  topDate:string[] =  DateUtils.get7date("y/M/d")
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
    //页面传值接收
    this.orderId = router.getParams() as string
    //默认一进来请求
    this.getFlushedData()
  }

  //点击事件调用=>请求接口
  async getFlushedData(item?:SevenDateModel){
    const carId = MMKV.defaultMMKV().decodeString("CAR_ID") as string
    this.showLoading = true;
    let res = await Api.net().getOrderTaskList(carId,this.orderId["value"]);
    this.showLoading = false;
    if (res.isSuccessWithData()) { //200
      this.orderTaskList = res.data as OrderTaskModel
      console.log("打印数据集合====>"+JSON.stringify(this.orderTaskList))
      if (!this.executed){
        this.executed = true
        //这里要过滤小红点
        const dateBookCounts:Map<string,number> = new Map();
        this.orderTaskList.data.forEach(item => {
          const date = new Date(item.GoTime.split(" ")[0]);
          const dateStr = `${date.getMonth() + 1}/${date.getDate()}`;
          dateBookCounts.set(dateStr, (dateBookCounts.get(dateStr) || 0) + item.BookCount);
        });
        this.sevenDateList.forEach(item => {
          const count = dateBookCounts.get(item.date) || 0;
          item.count = count;
        });

        this.sevenDateList = [...this.sevenDateList];
        console.log("匹配过滤顶部日期集合1===>"+JSON.stringify(this.sevenDateList))
      }
      //请求成功匹配过滤数据 拿当前日期和接口返回数据过滤
      this.orderTaskList.data  = this.orderTaskList.data.filter((item:Data)=>{
        return item.GoTime.split(" ")[0] === this.toDays
      })
    }else{
      showToast(res.message);
    }
  }

  build() {
    Column(){
      this.TitleBars()

      Flex({direction:FlexDirection.Row,justifyContent:FlexAlign.SpaceBetween}){
        Row(){
          List({space:4}){
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
                this.getFlushedData(this.sevenDateList[index])
                //隐藏布局
                this.selectImageCalendarShow = Visibility.Visible
                this.selectCalendarShow = Visibility.None
              })

            },(item:SevenDateModel)=>item.date)
          }
          .margin({left:10})
          .layoutWeight(7)
          .lanes(1)
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
          .margin({right:10})
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
                this.getFlushedData()
              }
            })
          })

        }
        .width("100%")
        .height(50)
        .justifyContent(FlexAlign.SpaceBetween)
        .backgroundColor($r("app.color.white"))

      }

      this.listAndItem()
    }
    .height('100%')
    .width('100%')
    .backgroundColor($r("app.color.system_background_color"))

  }
}