import { promptAction, router } from '@kit.ArkUI';
import { TitleBar } from '@smarthane/titlebar';
import { MMKV } from '@tencent/mmkv';
import { Api, EventBus, LoadingUtils, PhoneNumberUtils, showToast } from 'base';
import { AllOrderListModel, Data } from 'base/src/main/ets/viewmodel/AllOrderListModel';
import { PickUpPassengerModel } from 'base/src/main/ets/viewmodel/PickUpPassengerModel';
import { ServiceToPassengerModel } from 'base/src/main/ets/viewmodel/ServiceToPassengerModel';
import { AlreadyTaskListView } from '../view/AlreadyTaskListView';
import { EmptyView } from '../view/EmptyView';
import { NotTaskListView } from '../view/NotTaskListView';
import { common } from '@kit.AbilityKit';
import { AsyncCallback, BusinessError } from '@kit.BasicServicesKit';
import { call, observer } from '@kit.TelephonyKit';
import { PickUpMapView } from '../view/PickUpMapView'
import { DropOffMapView } from '../view/DropOffMapView';
import { JSON } from '@kit.ArkTS';
import { MapsInitializer } from '@amap/amap_lbs_map3d';

// 测试: eventBus 发送和接收的数据模型
interface DeliverToPassengerModule {
  name: string
}
interface InputCodeModule {
  name: string
}
@Entry
@Component
struct Pages_TaskList {
  private context = getContext(this) as common.UIAbilityContext;
  @State message: string = '任务列表(带地图的)';
  @State fontColor: string = '#182431'
  @State selectedFontColor: string = '#353436'
  @State currentIndex: number = 0
  @State selectedIndex: number = 0
  @State taskCurrentIndex: number = 0
  @State taskSelectedIndex: number = 0
  private controller: TabsController = new TabsController()
  private taskController: TabsController = new TabsController()
  @State model1: TitleBar.Model = new TitleBar.Model()
    .setOnLeftClickListener(() => {
      router.back()
    })
    .setTitleName("任务订单")
    .setTitleFontColor($r("app.color.text_color1"))
  @State showLoading: boolean = false;
  @State orderId :string =""
  @State allOrderList:AllOrderListModel = new AllOrderListModel()
  @State disposeOrderList:Data[] = []
  //刷新状态变量
  @State refreshing: boolean = false;
  @State refreshOffset: number = 0;
  @State refreshState: RefreshStatus = RefreshStatus.Inactive;
  @State canLoad: boolean = false;
  @State isLoading: boolean = false;
  @State pickUp :PickUpPassengerModel = new PickUpPassengerModel()
  @State serviceTo :ServiceToPassengerModel = new ServiceToPassengerModel()


  async getTaskList(){
    const carId = MMKV.defaultMMKV().decodeString("CAR_ID") as string
    LoadingUtils.showLoading("加载中...");
    let res = await Api.net().getOrderData(carId,this.orderId["value1"],this.orderId["value2"]);
    if (res.isSuccessWithData()) {
      this.allOrderList =  res.data as AllOrderListModel
      if (this.allOrderList.statusCode == 200) {
        LoadingUtils.hideLoading();
        this.disposeOrderList = this.allOrderList?.data
        console.log("打印列表数据集合===>"+JSON.stringify(this.disposeOrderList))
      }else{
        LoadingUtils.hideLoading();
        showToast(this.allOrderList.message)
      }
    }else{
      LoadingUtils.hideLoading();
      showToast(res.message)
    }
  }

  async getPickUpPassengers(orderId:string){
    LoadingUtils.showLoading("加载中...");
    let res = await Api.net().pickUpPassenger(orderId);
    if (res.isSuccessWithData()) {
      this.pickUp  =  res.data as PickUpPassengerModel
      if (this.pickUp.statusCode == 200) {
        LoadingUtils.hideLoading();
        //刷新列表
        this.getTaskList()
      }else{
        LoadingUtils.hideLoading();
        showToast(this.pickUp.message)
      }
    }else{
      LoadingUtils.hideLoading();
      showToast(res.message)
    }

  }


  async getDeliverToPassengers(orderId:string){
    LoadingUtils.showLoading("加载中...");
    let res = await Api.net().serviceToPassenger(orderId);
    if (res.isSuccessWithData()) {
      this.serviceTo = res.data as ServiceToPassengerModel
      if (this.serviceTo.statusCode == 200) {
        LoadingUtils.hideLoading();
        //刷新列表
        this.getTaskList()
        //测试发送事件
        let eventData: DeliverToPassengerModule = {
          name: '送达乘客',
        }
        EventBus.send('DeliverToPassenger', eventData)
      } else {
        LoadingUtils.hideLoading();
        showToast(this.serviceTo.message)
      }
    }else{
      LoadingUtils.hideLoading();
      showToast(res.message)
    }
  }


  onPageShow() :void {
    console.log("Pages_TaskList===>"+'onPageShow')
    EventBus.listen<InputCodeModule>('InputCodeModule', (data) => {
      if (data !== undefined) {
        if (data.name == "检票成功") {
          console.log("触发了吗===>"+JSON.stringify(data))
          //刷新列表
          this.getTaskList()
        }
      }
    })
  }



  onPageHide(): void {
    EventBus.cancel('DeliverToPassenger')
    // this.context.eventHub.off("myEvent")
  }


  aboutToAppear(): void {
    console.log("Pages_TaskList===>"+'aboutToAppear')
    this.orderId =  router.getParams() as string
    console.log("页面传参==>"+JSON.stringify(this.orderId))
    this.getTaskList()

  }

  //titleBar
  @Builder TitleBars(){
    Column(){
      TitleBar({ model: $model1 })
    }
  }

  //外层tabs
  @Builder tabBuilder(index: number, name: string) {
    Column() {
      Text(name)
        .fontColor(this.selectedIndex === index ? this.selectedFontColor : this.fontColor)
        .fontSize(16)
        .fontWeight(this.selectedIndex === index ? 500 : 400)
        .lineHeight(22)
        .margin({ top: 17, bottom:7 })
      Divider()
        .strokeWidth(2)
        .width(20)
        .color($r("app.color.color_shubihong"))
        .opacity(this.selectedIndex === index ? 1 : 0)
    }
    .width('100%')
    .backgroundColor($r("app.color.white"))
  }
  //内层tabs
  @Builder taskTabBuilder(index: number, name: string) {
    Column({space:8}) {
      Text(name)
        .fontColor(this.taskSelectedIndex === index ? this.selectedFontColor : this.fontColor)
        .fontSize(13)
        .fontWeight(this.taskSelectedIndex === index ? 500 : 400)
        .lineHeight(22)

      Divider()
        .strokeWidth(2)
        .width(20)
        .color($r("app.color.color_shubihong"))
        .opacity(this.taskSelectedIndex === index ? 1 : 0)
    }
    .padding(5)
    .width('100%')
    .backgroundColor($r("app.color.white"))
  }

  //任务列表View
  @Builder taskView(){
    Column(){
      Tabs({ barPosition: BarPosition.Start, index: this.taskCurrentIndex, controller: this.taskController }) {
        TabContent() {
          this.allListItem()
        }.tabBar(this.taskTabBuilder( 0, '全部'))
        TabContent() {
          NotTaskListView({orderId: this.orderId})
        }.tabBar(this.taskTabBuilder(1, '未检票'))

        TabContent() {
          AlreadyTaskListView({orderId: this.orderId})
        }.tabBar(this.taskTabBuilder(2, '已检票'))

      }
      .scrollable(false)
      .vertical(false)
      .barMode(BarMode.Fixed)
      // .barWidth(400)
      .barHeight(40)
      .animationDuration(200)
      .onChange((index: number) => {
        // currentIndex控制TabContent显示页签
        this.taskCurrentIndex = index
        this.taskSelectedIndex = index

      })
      .width("100%")
      .height("90%")
    }
  }

  //内层的全部页面View加List
  @Builder allListItem(){
    Flex({ direction: FlexDirection.Column }) {
      if (this.disposeOrderList.length === 0){
        EmptyView()
      }else{
        Refresh({refreshing:$$this.refreshing}){
          List({space:10}){
            ForEach(this.disposeOrderList,(item:Data,index:number)=>{
              ListItem(){
                Column(){
                  Row(){
                    Text(item.DayTime + " " + item.DayName)
                      .fontColor($r("app.color.text_color1"))
                      .fontSize(18)
                      .fontWeight(FontWeight.Bold)
                    Column({space:5}){
                      Image($r("app.media.address"))
                        .width(30)
                        .height(30)
                      Text("导航到出发地")
                        .fontColor($r("app.color.text_h1"))
                        .fontSize(13)
                    }

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

                      Text(item?.StartCity + "·" +item?.StartPlace)
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

                      Text(item?.EndCity + "·" +item?.EndPlace)
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

                      Text(item?.BookSeat + "人")
                        .fontColor($r("app.color.text_color1"))
                        .fontSize(14)
                    }
                    .width("100%")
                    .alignItems(VerticalAlign.Center)
                    .justifyContent(FlexAlign.Start)
                    //金额
                    Row({space:20}){
                      Row(){
                        Text("金额")
                          .fontColor($r("app.color.text_h1"))
                          .fontSize(12)
                      }
                      .alignItems(VerticalAlign.Center)
                      .justifyContent(FlexAlign.Center)

                      Text(item?.Amont +"元")
                        .fontColor($r("app.color.text_color1"))
                        .fontSize(14)
                    }
                    .width("100%")
                    .alignItems(VerticalAlign.Center)
                    .justifyContent(FlexAlign.Start)
                    //乘客备注
                    Row({space:20}){
                      Row(){
                        Text("乘客备注")
                          .fontColor($r("app.color.text_h1"))
                          .fontSize(12)
                      }
                      .alignItems(VerticalAlign.Center)
                      .justifyContent(FlexAlign.Center)

                      Text(item?.UserRemark!="" ? item?.UserRemark :"无")
                        .fontColor($r("app.color.text_color1"))
                        .fontSize(14)
                    }
                    .width("100%")
                    .alignItems(VerticalAlign.Center)
                    .justifyContent(FlexAlign.Start)
                    //客服备注
                    Row({space:20}){
                      Row(){
                        Text("客服备注")
                          .fontColor($r("app.color.text_h1"))
                          .fontSize(12)
                      }
                      .alignItems(VerticalAlign.Center)
                      .justifyContent(FlexAlign.Center)

                      Text(item?.BackRemark!=null ? item?.BackRemark : "无")
                        .fontColor($r("app.color.text_color1"))
                        .fontSize(14)
                    }
                    .width("100%")
                    .alignItems(VerticalAlign.Center)
                    .justifyContent(FlexAlign.Start)
                  }
                  .margin({top:10,left:16,bottom:10})


                  Row(){
                    Row({space:10}){
                      Image($r("app.media.user_default"))
                        .width(40)
                        .height(40)
                        .margin({left:10})
                        .borderRadius(20)

                      Text(this.disposeOrderList[index]?.Name.charAt(0)+"**")
                        .fontColor($r("app.color.text_color1"))
                        .fontSize(15)
                        .margin({left:10})
                      Text(PhoneNumberUtils.changPhoneNumber(this.disposeOrderList[index]?.Phone))
                        .fontColor($r("app.color.text_color1"))
                        .fontSize(15)
                        .margin({left:10})
                    }

                    Image($r("app.media.phone"))
                      .width(40)
                      .height(40)
                      .margin({right:15})
                      .onClick(()=>{
                        // showToast("这里调用拨号功能！")
                        let isSupport = call.hasVoiceCapability();
                        if (isSupport) {
                          // 如果设备支持呼叫能力，则继续跳转到拨号界面，并显示拨号的号码
                          call.makeCall( this.disposeOrderList[index]?.Phone, (err: BusinessError) => {
                            if (!err) {
                              console.log("make call success.");
                            } else {
                              console.log("make call fail, err is:" + JSON.stringify(err));
                            }
                          });
                          // 订阅通话业务状态变化（可选）
                          class SlotId {slotId: number = 0}
                          class CallStateCallback {
                            state: call.CallState = call.CallState.CALL_STATE_UNKNOWN;
                            number: string = "";
                          }
                          let slotId: SlotId = {slotId: 0}
                          observer.on("callStateChange", slotId, (data: CallStateCallback) => {
                            console.log("call state change, data is:" + JSON.stringify(data));
                          });
                        }

                      })
                  }
                  .borderRadius(8)
                  .height(55)
                  .width("100%")
                  .backgroundColor($r("app.color.task_list_item_bg"))
                  .margin({left:20,right:20})
                  .alignItems(VerticalAlign.Center)
                  .justifyContent(FlexAlign.SpaceBetween)

                  Stack({alignContent:Alignment.End}){
                    Button(this.disposeOrderList[index].BizState == 3 ? "送达乘客"  : "接到乘客")
                      .type(ButtonType.Normal)
                      .backgroundColor(this.disposeOrderList[index].BizState == 3 ? $r("app.color.my_button_cz_color"):$r("app.color.white"))
                      .fontColor(this.disposeOrderList[index].BizState == 3 ? $r("app.color.white") : $r("app.color.text_color1"))
                      .fontSize(13)
                      .visibility(this.disposeOrderList[index].BizState == 4 ? Visibility.None : Visibility.Visible)
                      .border({
                        width:1,
                        color:this.disposeOrderList[index].BizState == 3 ? $r("app.color.transparente_color") :$r("app.color.text_h1")
                      })
                      .borderRadius(5)
                      .margin({top:10})
                      .width(100)
                      .onClick(()=>{
                        //TODO:请求处理 刷新列表
                        if (this.disposeOrderList[index].BizState != 3) {
                          this.getPickUpPassengers(item.Id)
                        }else if (this.disposeOrderList[index].BizState == 3){
                          this.getDeliverToPassengers(item.Id)
                        }
                      })

                  }
                  .width("100%")
                  .height(50)
                  .alignContent(Alignment.End)
                }
                .margin({left:20,right:20,top:10})
                .padding(10)
                .borderRadius(10)
                .backgroundColor($r("app.color.white"))
              }


            },(item:Data)=>item.Id)
          }
          .onScrollFrameBegin((offset: number, state: ScrollState)=>{
            // 只有当向上滑动时触发新数据加载
            if (offset > 5 && !this.isLoading) {
              this.canLoad = true;
            }
            return { offsetRemain: offset };
          })
          .margin({bottom:30})
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
          this.getTaskList()
          setTimeout(() => {
            this.refreshing = false;
          }, 3000)
        })

      }
    }
    .width("100%")
  }

  build() {
    Column() {
      //顶部
      this.TitleBars()
      //tabs
      Column() {
        Tabs({ barPosition: BarPosition.Start, index: this.currentIndex, controller: this.controller }) {
          TabContent() {
            Column(){
              this.taskView()

              Stack({alignContent:Alignment.Bottom}){
                Row(){
                  Button("输码检票")
                    .type(ButtonType.Normal)
                    .layoutWeight(1)
                    .fontColor($r("app.color.color_shubihong"))
                    .backgroundColor($r("app.color.white"))
                    .fontSize(14)
                    .onClick(()=>{
                      //TODO:====Jump to the page
                      router.pushUrl({
                        url:"pages/Pages_InputCode",
                        params:{"value":this.orderId["value2"]}
                      })
                      // showToast("跳转去输码检票")
                    })
                  Button("扫码检票")
                    .type(ButtonType.Normal)
                    .layoutWeight(1)
                    .fontColor($r("app.color.white"))
                    .backgroundColor($r("app.color.color_shubihong"))
                    .fontSize(14)
                    .onClick(()=>{
                      //TODO:====Jump to the page
                      router.pushUrl({
                        url:"pages/Pages_Scans",
                        params:{"value":this.orderId["value2"]}
                      })
                    })
                }
                .margin({bottom:40})
                .alignItems(VerticalAlign.Center)
                .justifyContent(FlexAlign.SpaceBetween)
                .width("100%")
                .height('100%')
              }
              .width("100%")
              .height(60)


            }
            .width("100%")
            .height("100%")


          }.tabBar(this.tabBuilder( 0, '任务列表'))
          TabContent() {
            //地图展示View
            PickUpMapView()//{OrderId:this.ordersId}
          }.tabBar(this.tabBuilder(1, '接客地图'))

          TabContent() {
            //地图展示View
            DropOffMapView()
          }.tabBar(this.tabBuilder(2, '送客地图'))

        }
        .scrollable(false)
        .vertical(false)
        .barMode(BarMode.Fixed)
        // .barWidth(400)
        .barHeight(50)
        .animationDuration(0)
        .onChange((index: number) => {
          // console.log("22222==>"+JSON.stringify(index))
          // currentIndex控制TabContent显示页签
          this.currentIndex = index
          this.selectedIndex = index
        })
        .width("100%")
        .height("90%")
      }


    }
    .height('100%')
    .width('100%')
    .backgroundColor($r("app.color.system_background_color"))
  }
}