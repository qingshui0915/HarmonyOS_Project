import { TitleBar } from '@smarthane/titlebar';
import { router } from '@kit.ArkUI';
import { Api, showToast } from 'base';
import { MyCarInfoModel } from 'base/src/main/ets/viewmodel/MyCarInfoModel';

/**
 * 我的车辆页面
 */
@Entry
@Component
struct Pages_MyCar {
  @State authStatus: string = '';
  @State model1: TitleBar.Model = new TitleBar.Model()
    .setOnLeftClickListener(() => {
      router.back()
    })
    .setTitleName("我的车辆")
    .setTitleFontColor($r("app.color.text_color1"))
  @State showLoading: boolean = false;
  @State myCarInfo : MyCarInfoModel = new MyCarInfoModel()

  @Builder TitleBars(){
    Column(){
      TitleBar({ model: $model1 })
    }
  }

  async getMyCarInfo(){
    this.showLoading = true;
    let res = await Api.net().getMyCarInfoData();
    this.showLoading = false;
    console.log("车辆信息数据====>"+JSON.stringify(res.data))
    this.myCarInfo = res.data as MyCarInfoModel
    if (res.isSuccessWithData()) { //200
      if (this.myCarInfo.data.AuthStatus == 0) {
        this.authStatus = "车辆未审核(审核中)"
      }else{
        this.authStatus = "车辆审核已通过"
      }
    }else{

    }
  }

  aboutToAppear(): void {
    this.getMyCarInfo()
  }

  build() {
    Column(){
      this.TitleBars()

      Row(){
        Text("车辆审核已通过")
          .fontColor($r("app.color.white"))
          .fontSize(14)
      }
      .width("100%")
      .height(40)
      .justifyContent(FlexAlign.Center)
      .backgroundColor($r("app.color.my_car_bg"))
      Column(){
        Row(){
          Row({space:8}){
            Image($r("app.media.user_name"))
              .width(15)
              .height(15)
            Text("真实姓名")
              .fontColor($r("app.color.text_color1"))
              .fontSize(14)
          }
          .alignItems(VerticalAlign.Center)
          .justifyContent(FlexAlign.Center)
          Text(this.myCarInfo?.data?.DriverName)
            .fontColor($r("app.color.text_color1"))
        }
        .width("90%")
        .margin({left:20,right:20})
        .padding(13)
        .alignItems(VerticalAlign.Center)
        .justifyContent(FlexAlign.SpaceBetween)


        Divider()
          .visibility(Visibility.Visible)
          .width("90%")

        Row(){
          Row({space:8}){
            Image($r("app.media.phone_line"))
              .width(15)
              .height(15)
            Text("手机号码")
              .fontColor($r("app.color.text_color1"))
              .fontSize(14)
          }
          .alignItems(VerticalAlign.Center)
          .justifyContent(FlexAlign.Center)
          Text(this.myCarInfo?.data?.DriverPhone)
            .fontColor($r("app.color.text_color1"))
        }
        .width("90%")
        .margin({left:20,right:20})
        .padding(13)
        .alignItems(VerticalAlign.Center)
        .justifyContent(FlexAlign.SpaceBetween)


        Divider()
          .visibility(Visibility.Visible)
          .width("90%")
          .margin({left:20,right:20})
        Row(){
          Row({space:8}){
            Image($r("app.media.car_seat"))
              .width(15)
              .height(15)
            Text("车座位")
              .fontColor($r("app.color.text_color1"))
              .fontSize(14)
          }
          .alignItems(VerticalAlign.Center)
          .justifyContent(FlexAlign.Center)
          Text(this.myCarInfo?.data?.CarSeat.toString())
            .fontColor($r("app.color.text_color1"))
        }
        .width("90%")
        .margin({left:20,right:20})
        .padding(13)
        .alignItems(VerticalAlign.Center)
        .justifyContent(FlexAlign.SpaceBetween)


        Divider()
          .visibility(Visibility.Visible)
          .width("90%")
          .margin({left:20,right:20})
        Row(){
          Row({space:8}){
            Image($r("app.media.car_brand"))
              .width(15)
              .height(15)
            Text("车品牌型号")
              .fontColor($r("app.color.text_color1"))
              .fontSize(14)
          }
          .alignItems(VerticalAlign.Center)
          .justifyContent(FlexAlign.Center)
          Text(this.myCarInfo?.data?.CarBrand)
            .fontColor($r("app.color.text_color1"))
        }
        .width("90%")
        .margin({left:20,right:20})
        .padding(13)
        .alignItems(VerticalAlign.Center)
        .justifyContent(FlexAlign.SpaceBetween)


        Divider()
          .visibility(Visibility.Visible)
          .width("90%")
          .margin({left:20,right:20})
        Row(){
          Row({space:8}){
            Image($r("app.media.car_number"))
              .width(15)
              .height(15)
            Text("车牌号")
              .fontColor($r("app.color.text_color1"))
              .fontSize(14)
          }
          .alignItems(VerticalAlign.Center)
          .justifyContent(FlexAlign.Center)
          Text(this.myCarInfo?.data?.CarNumber)
            .fontColor($r("app.color.text_color1"))
        }
        .width("90%")
        .margin({left:20,right:20})
        .padding(13)
        .alignItems(VerticalAlign.Center)
        .justifyContent(FlexAlign.SpaceBetween)

        Divider()
          .visibility(Visibility.Visible)
          .width("90%")
          .margin({left:20,right:20})
        Row(){
          Row({space:8}){
            Image($r("app.media.car_color"))
              .width(15)
              .height(15)
            Text("车颜色")
              .fontColor($r("app.color.text_color1"))
              .fontSize(14)
          }
          .alignItems(VerticalAlign.Center)
          .justifyContent(FlexAlign.Center)
          Text(this.myCarInfo?.data?.CarColor)
            .fontColor($r("app.color.text_color1"))
        }
        .width("90%")
        .margin({left:20,right:20})
        .padding(13)
        .alignItems(VerticalAlign.Center)
        .justifyContent(FlexAlign.SpaceBetween)
      }
      .backgroundColor($r("app.color.white"))
      .margin({left:10,right:10,top:10})
      .borderRadius(10)


      Column(){
        Row(){
          Row({space:8}){
            Text("车管公司")
              .fontColor($r("app.color.text_color1"))
              .fontSize(14)
          }
          .alignItems(VerticalAlign.Center)
          .justifyContent(FlexAlign.Center)
          Text(this.myCarInfo?.data?.VehicleCompanyName)
            .fontColor($r("app.color.text_color1"))
        }
        .width("90%")
        .margin({left:20,right:20})
        .padding(15)
        .alignItems(VerticalAlign.Center)
        .justifyContent(FlexAlign.SpaceBetween)
        .onClick(()=>{
          showToast("点击我的车辆")
        })
      }
      .backgroundColor($r("app.color.white"))
      .margin({left:10,right:10,top:20})
      .borderRadius(10)

      Row(){
        Button("返回")
          .type(ButtonType.Normal)
          .backgroundColor($r("app.color.white"))
          .fontColor($r("app.color.text_color1"))
          .width("100%")
          .onClick(()=>{
            router.back()
          })
      }
      .margin({left:30,right:30,top:20})


    }
    .width("100%")
    .height("100%")
    .backgroundColor($r("app.color.system_background_color"))
  }
}