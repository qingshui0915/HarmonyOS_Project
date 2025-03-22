import { MMKV } from "@tencent/mmkv";
import { Api, EventBus, LoadingUtils, PhoneNumberUtils, showToast } from "base";
import {  Data } from "base/src/main/ets/viewmodel/AllOrderListModel";
import { PickUpPassengerModel } from "base/src/main/ets/viewmodel/PickUpPassengerModel";
import { ServiceToPassengerModel } from "base/src/main/ets/viewmodel/ServiceToPassengerModel";
import { EmptyView } from "./EmptyView";
import call from "@ohos.telephony.call";
import { BusinessError } from "@kit.BasicServicesKit";
import { observer } from "@kit.TelephonyKit";

/**
 * 未检票页面列表View
 */
interface DeliverToPassengerModule {
  name: string
}
@Component
export struct NotTaskListView {
  @Link orderId :string

  @State showLoading: boolean = false;
  @State disposeOrderList:Data[] = []
  //刷新状态变量
  @State refreshing: boolean = false;
  @State refreshOffset: number = 0;
  @State refreshState: RefreshStatus = RefreshStatus.Inactive;
  @State canLoad: boolean = false;
  @State isLoading: boolean = false;
  @State pickUp :PickUpPassengerModel = new PickUpPassengerModel()
  @State serviceTo :ServiceToPassengerModel = new ServiceToPassengerModel()

  async getNotTaskList(){
    const carId = MMKV.defaultMMKV().decodeString("CAR_ID") as string
    this.showLoading = true;
    let res = await Api.net().getOrderData(carId,this.orderId["value1"],this.orderId["value2"]);
    this.showLoading = false;
    if (res.isSuccessWithData()) {
      this.disposeOrderList =  res.data?.data as Data[]
      this.disposeOrderList = this.disposeOrderList.filter((c : Data)=> c.BizState !== 3 && c.BizState !== 4)
    }else{
      showToast(res.message)
    }
  }

  aboutToAppear(): void {
    LoadingUtils.init(this.getUIContext())
    //请求接口(这里数据已经筛选过)
    this.getNotTaskList()

  }

  async getPickUpPassengers(orderId:string){
    LoadingUtils.showLoading("加载中...");
    let res = await Api.net().pickUpPassenger(orderId);
    if (res.isSuccessWithData()) {
      this.pickUp  =  res.data as PickUpPassengerModel
      if (this.pickUp.statusCode == 200) {
        LoadingUtils.hideLoading();
        //刷新列表
        this.getNotTaskList()
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
        this.getNotTaskList()
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

  }



  onPageHide(): void {
    EventBus.cancel('DeliverToPassenger')
    // this.context.eventHub.off("myEvent")
  }



  build() {
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

                      Text(item?.Name.charAt(0)+"**")
                        .fontColor($r("app.color.text_color1"))
                        .fontSize(15)
                        .margin({left:10})
                      Text(PhoneNumberUtils.changPhoneNumber(item?.Phone))
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
                      .visibility(this.disposeOrderList[index].BizState == 4 ? Visibility.None : Visibility.Visible)
                      .fontSize(13)
                      .border({
                        width:1,
                        color:Color.Black
                      })
                      .borderRadius(5)
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
          this.getNotTaskList()
          setTimeout(() => {
            this.refreshing = false;
          }, 4000)
        })

      }
    }
    .width("100%")
  }
}