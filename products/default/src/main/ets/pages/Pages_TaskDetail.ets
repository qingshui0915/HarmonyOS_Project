import { TitleBar } from '@smarthane/titlebar';
import { router } from '@kit.ArkUI';
import { JSON } from '@kit.ArkTS';
import { Api, LoadingUtils } from 'base';
import { OrderListDetailModel } from 'base/src/main/ets/viewmodel/OrderListDetailModel';

/**
 *订单详情页面
 */
@Entry
@Component
struct Pages_TaskDetail {
  @State title_text: string = '订单详情';
  //titleBar组件
  @State model1: TitleBar.Model = new TitleBar.Model()
    .setOnLeftClickListener(() => {
      router.back()
    })
    .setTitleName(this.title_text)
    .setTitleFontColor($r("app.color.text_color1"))
  @State orderId:string = ""
  @State showLoading: boolean = false;
  @State orderListDetail:OrderListDetailModel = new OrderListDetailModel()
  @Builder TitleBars(){
    Column(){
      TitleBar({ model: $model1 })
    }
  }


  aboutToAppear(): void {
    this.orderId = router.getParams() as string
    // console.log("====>"+JSON.stringify(this.orderId))
    console.log("====>"+JSON.stringify(this.orderId["value"]))
    this.getOrderListDetail(this.orderId["value"])
  }

  async getOrderListDetail(orderId:string){
    LoadingUtils.showLoading("加载中...");
    this.showLoading = true;
    let res = await Api.net().getOrderListDetail(orderId);
    this.showLoading = false;
    LoadingUtils.hideLoading();
    this.orderListDetail = res.data as OrderListDetailModel
  }


  build() {
    Column() {
      this.TitleBars()

      Row(){
        Text("行程信息")
          .fontColor($r('app.color.text_h1'))
          .fontSize(15)
      }
      .margin({left:30,top:8})
      .width('100%')
      .justifyContent(FlexAlign.Start)

      Column(){
        Row(){
          Text(this.orderListDetail?.data?.GoTime)
            .fontColor($r("app.color.text_h1"))
            .fontSize(13)
          Text(this.orderListDetail?.data?.OrderStatus == 1 ? "待出发" : this.orderListDetail?.data?.OrderStatus == 2 ? "进行中" : this.orderListDetail?.data?.OrderStatus == 3 ? "已完成" : "")
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

            Text(this.orderListDetail?.data?.StartCity+"·"+this.orderListDetail?.data?.StartPlace)
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

            Text(this.orderListDetail?.data?.EndCity+"·"+this.orderListDetail?.data?.EndPlace)
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

            Text(this.orderListDetail?.data?.BookSeat +" 人")
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

            Text(this.orderListDetail?.data?.Amont +"元")
              .fontColor($r("app.color.text_color1"))
              .fontSize(14)
            Text(this.orderListDetail?.data?.EndStatus == 1 ? "[已入账]" :"[未入账]")
              .fontColor($r("app.color.text_order_money_color"))
              .fontSize(14)
          }
          .width("100%")
          .alignItems(VerticalAlign.Center)
          .justifyContent(FlexAlign.Start)
        }
        .margin({top:10,left:16})

      }
      .margin({left:20,right:20,top:10})
      .padding(10)
      .borderRadius(10)
      .backgroundColor($r("app.color.white"))



      Row(){
        Text("乘客信息")
          .fontColor($r('app.color.text_h1'))
          .fontSize(15)
      }
      .margin({left:30,top:8})
      .width('100%')
      .justifyContent(FlexAlign.Start)

      Column(){
        Column({space:10}){
          //姓名
          Row({space:20}){
            Row(){
              Text("姓名")
                .fontColor($r("app.color.text_h1"))
                .fontSize(12)
            }
            .alignItems(VerticalAlign.Center)
            .justifyContent(FlexAlign.Center)

            Text(this.orderListDetail?.data?.Name)
              .fontColor($r("app.color.text_color1"))
              .fontSize(14)
          }
          .width("100%")
          .alignItems(VerticalAlign.Center)
          .justifyContent(FlexAlign.Start)
          //电话
          Row({space:20}){
            Row(){
              Text("电话")
                .fontColor($r("app.color.text_h1"))
                .fontSize(12)
            }
            .alignItems(VerticalAlign.Center)
            .justifyContent(FlexAlign.Center)

            Text(this.orderListDetail?.data?.Phone)
              .fontColor($r("app.color.text_color1"))
              .fontSize(14)
          }
          .width("100%")
          .alignItems(VerticalAlign.Center)
          .justifyContent(FlexAlign.Start)
          //支付状态
          Row({space:20}){
            Row(){
              Text("支付状态")
                .fontColor($r("app.color.text_h1"))
                .fontSize(12)
            }
            .alignItems(VerticalAlign.Center)
            .justifyContent(FlexAlign.Center)

            Text(this.orderListDetail?.data?.DriverDiscountAmount >0 ? `"优惠"+${this.orderListDetail?.data?.DriverDiscountAmount}+"元"`:
            this.orderListDetail?.data?.Status == 2 ? "已微信支付" :this.orderListDetail?.data?.Status != -1 ? "已付款" :this.orderListDetail?.data?.Status == -1 ? "未支付" : "")
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
            .justifyContent(FlexAlign.Start)

            Text(this.orderListDetail?.data?.UserRemark)
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
            .justifyContent(FlexAlign.Start)

            Text(this.orderListDetail?.data?.BackRemark)
              .fontColor($r("app.color.text_color1"))
              .fontSize(14)
          }
          .width("100%")
          .alignItems(VerticalAlign.Center)
          .justifyContent(FlexAlign.Start)
        }
        .margin({top:10,left:16})

      }
      .margin({left:20,right:20,top:10})
      .padding(10)
      .borderRadius(10)
      .backgroundColor($r("app.color.white"))

    }
    .width('100%')
    .height('100%')
    .backgroundColor($r("app.color.system_background_color"))
  }
}