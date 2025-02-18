import { TitleBar } from '@smarthane/titlebar';
import { router } from '@kit.ArkUI';
import { DateUtils, showToast } from 'base';
import { EnumSurveyVehiclePlateColor } from '../enum/EnumSurveyVehiclePlateColor';
import { EnumTypeOfEnergy } from '../enum/EnumTypeOfEnergy';

@Entry
@Component
struct Pages_CompletionTravelCard {
  @State title: string = '行驶证录入';
  //titleBar组件
  @State model1: TitleBar.Model = new TitleBar.Model()
    .setOnLeftClickListener(() => {
      router.back()
    })
    .setTitleName(this.title)
    .setTitleFontColor($r("app.color.text_color1"))
  scroller: Scroller = new Scroller()
  selectedDate: Date = new Date()
  selectRegistrationDate: Date = new Date()
  selectAnnualReviewDate: Date = new Date()
  selectExpirationDate: Date = new Date()
  private select: number | number[] = 0
  private selectTypeOfEnergy: number | number[] = 0
  @State newEnumPlateColor:string[] =[]//车牌颜色
  @State newEnumTypeOfEnergy:string[] =[]//能源类型
  @State EnumPlateColor:EnumSurveyVehiclePlateColor[] =EnumSurveyVehiclePlateColor.values()
  @State EnumTypeOfEnergy:EnumTypeOfEnergy[] =EnumTypeOfEnergy.values()
  @State registrationDate  :string ="" //车辆注册日期
  @State registration_Date :string ="" //车辆注册日期==>赋值
  @State licensePlateNumber :string = "" //车牌号
  @State bodyColor :string = "" //车身颜色
  @State licensePlateColor :string = "" //车牌颜色
  @State vehicleModel :string = "" //车辆型号
  @State vehicleBrand :string = "" //车辆品牌
  @State typeOfEnergy :string = "" //能源类型
  @State AnnualReviewDate :string = "" //年审日期 -->赋值
  @State Annual_Review_Date :string = "" //年审日期
  @State expirationDate :string = "" //过期日期 -->赋值
  @State expiration_Date :string = "" //过期日期



  @Builder TitleBars(){
    Column(){
      TitleBar({ model: $model1 })
    }

  }


  aboutToAppear(): void {
    // console.log("22222==>"+JSON.stringify(EnumSurveyVehiclePlateColorHelper.values()))
    // console.log("22222==>"+JSON.stringify(this.EnumPlateColor))
    for (let index = 0; index < this.EnumPlateColor.length; index++) {
      this.newEnumPlateColor[index] = this.EnumPlateColor[index].name
    }

    for (let i = 0; i <this.EnumTypeOfEnergy.length; i++) {
      this.newEnumTypeOfEnergy[i] = this.EnumTypeOfEnergy[i].name
    }
    console.log("33333==>"+JSON.stringify(this.newEnumPlateColor))
    console.log("44444==>"+JSON.stringify(this.newEnumTypeOfEnergy))
  }



  build() {
    Flex({direction:FlexDirection.Column}) {
      this.TitleBars()

      Row(){
        Text("请上传信息，仔细核实，如不正确请修改")
          .fontColor($r('app.color.text_h1'))
          .fontSize(12)
      }
      .margin({left:20,top:10,bottom:8})
      .alignItems(VerticalAlign.Center)
      .justifyContent(FlexAlign.Start)

      Flex({direction:FlexDirection.Column}) {
        Scroll(this.scroller) {
          Column() {
            Column() {
              Row({ space: 10 }) {
                Text("行驶证首页")
                  .fontColor($r('app.color.text_color1'))
                  .fontSize(14)
                  .layoutWeight(1)
                Text("行驶证副页")
                  .fontColor($r('app.color.text_color1'))
                  .fontSize(14)
                  .layoutWeight(1)
              }
              .padding(5)

              Row({ space: 10 }) {
                Image("")
                  .layoutWeight(1)
                  .alt($r('app.media.travel'))
                  .onClick(()=>{
                    showToast("点击拍照或者打开相册")
                  })
                Image("")
                  .layoutWeight(1)
                  .alt($r('app.media.travelcard_f'))
                  .onClick(()=>{
                    showToast("点击拍照或者打开相册")
                  })
              }
              .padding(5)

              Row({ space: 10 }) {
                Text("车辆照片")
                  .fontColor($r('app.color.text_color1'))
                  .fontSize(14)
                  .layoutWeight(1)
                Text("行驶证副页")
                  .visibility(Visibility.Hidden)
                  .fontColor($r('app.color.text_color1'))
                  .fontSize(14)
                  .layoutWeight(1)
              }
              .padding(5)
              .margin({ top: 5 })

              Row({ space: 10 }) {
                Image("")
                  .layoutWeight(1)
                  .alt($r('app.media.car_photo_icon'))
                  .onClick(()=>{
                    showToast("点击拍照或者打开相册")
                  })
                Image($r('app.media.card_f'))
                  .visibility(Visibility.Hidden)
                  .layoutWeight(1)
              }
              .padding(5)

              //输入项
              Column({ space: 5 }) {
                //车牌号
                Row() {
                  Row({ space: 5 }) {
                    Text("*")
                      .fontColor($r('app.color.title_required_text_color'))
                      .fontSize(13)
                    Text('车牌号')
                      .fontColor($r('app.color.text_color1'))
                      .fontSize(14)
                  }
                  .margin({ left: 10 })
                  .layoutWeight(1)
                  .alignItems(VerticalAlign.Center)

                  TextInput({ placeholder: "请输入" ,text:this.licensePlateNumber})
                    .placeholderFont({ size: 13 })
                    .type(InputType.Normal)
                    .backgroundColor(Color.Transparent)
                    .fontColor($r('app.color.text_color1'))
                    .fontSize(13)
                    .textAlign(TextAlign.End)
                    .layoutWeight(1)
                    .onChange((value)=>{
                      this.licensePlateNumber = value
                    })

                }

                Divider()
                  .height(1)
                  .margin({ left: 20, right: 20 })
                  .backgroundColor($r('app.color.layout_dividing_lines_bg_color'))
                //车身颜色
                Row() {
                  Row({ space: 5 }) {
                    Text("*")
                      .fontColor($r('app.color.title_required_text_color'))
                      .fontSize(13)
                    Text('车身颜色')
                      .fontColor($r('app.color.text_color1'))
                      .fontSize(14)
                  }
                  .margin({ left: 10 })
                  .layoutWeight(1)
                  .alignItems(VerticalAlign.Center)

                  TextInput({ placeholder: "请输入" })
                    .placeholderFont({ size: 13 })
                    .type(InputType.Normal)
                    .backgroundColor(Color.Transparent)
                    .fontColor($r('app.color.text_color1'))
                    .fontSize(13)
                    .textAlign(TextAlign.End)
                    .layoutWeight(1)
                    .onChange((value)=>{
                      this.bodyColor = value
                    })

                }

                Divider()
                  .height(1)
                  .margin({ left: 20, right: 20 })
                  .backgroundColor($r('app.color.layout_dividing_lines_bg_color'))
                //车牌颜色
                Row() {
                  Row({ space: 5 }) {
                    Text("*")
                      .fontColor($r('app.color.title_required_text_color'))
                      .fontSize(13)
                    Text('车牌颜色')
                      .fontColor($r('app.color.text_color1'))
                      .fontSize(14)
                  }
                  .layoutWeight(1)
                  .alignItems(VerticalAlign.Center)

                  Row({ space: 3 }) {
                    Text(this.licensePlateColor ? this.licensePlateColor : "请选择")
                      .fontColor($r('app.color.text_h1'))
                      .fontSize(13)
                    Image($r('app.media.arrow_bottom'))
                      .width(15)
                      .height(15)
                      .padding(3)
                  }
                  .alignItems(VerticalAlign.Center)
                  .justifyContent(FlexAlign.End)
                  .layoutWeight(1)
                  .onClick(() => {
                    TextPickerDialog.show({
                      range: this.newEnumPlateColor,
                      selected: this.select,
                      onAccept: (value: TextPickerResult) => {
                        // 当弹窗再次弹出时显示选中的是上一次确定的选项
                        this.select = value.index
                        console.log(this.select + '')
                        // 点击确定后，被选到的文本数据展示到页面 {"value":"黄色","index":1}
                        this.licensePlateColor = value.value as string
                      }
                    })
                  })

                }
                .padding(8)

                Divider()
                  .height(1)
                  .margin({ left: 20, right: 20 })
                  .backgroundColor($r('app.color.layout_dividing_lines_bg_color'))

                //车辆型号
                Row() {
                  Row({ space: 5 }) {
                    Text("*")
                      .fontColor($r('app.color.title_required_text_color'))
                      .fontSize(13)
                    Text('车辆型号')
                      .fontColor($r('app.color.text_color1'))
                      .fontSize(14)
                  }
                  .margin({ left: 10 })
                  .layoutWeight(1)
                  .alignItems(VerticalAlign.Center)

                  TextInput({ placeholder: "请输入" })
                    .placeholderFont({ size: 13 })
                    .type(InputType.Normal)
                    .backgroundColor(Color.Transparent)
                    .fontColor($r('app.color.text_color1'))
                    .fontSize(13)
                    .textAlign(TextAlign.End)
                    .layoutWeight(1)
                    .onChange((value)=>{
                      this.vehicleModel = value
                    })

                }

                Divider()
                  .height(1)
                  .margin({ left: 20, right: 20 })
                  .backgroundColor($r('app.color.layout_dividing_lines_bg_color'))

                //车辆品牌
                Row() {
                  Row({ space: 5 }) {
                    Text("*")
                      .fontColor($r('app.color.title_required_text_color'))
                      .fontSize(13)
                    Text('车辆品牌')
                      .fontColor($r('app.color.text_color1'))
                      .fontSize(14)
                  }
                  .margin({ left: 10 })
                  .layoutWeight(1)
                  .alignItems(VerticalAlign.Center)

                  TextInput({ placeholder: "请输入" })
                    .placeholderFont({ size: 13 })
                    .type(InputType.Normal)
                    .backgroundColor(Color.Transparent)
                    .fontColor($r('app.color.text_color1'))
                    .fontSize(13)
                    .textAlign(TextAlign.End)
                    .layoutWeight(1)
                    .onChange((value)=>{
                      this.vehicleBrand = value
                    })

                }

                Divider()
                  .height(1)
                  .margin({ left: 20, right: 20 })
                  .backgroundColor($r('app.color.layout_dividing_lines_bg_color'))

                //能源类型
                Row() {
                  Row({ space: 5 }) {
                    Text("*")
                      .fontColor($r('app.color.title_required_text_color'))
                      .fontSize(13)
                    Text('能源类型')
                      .fontColor($r('app.color.text_color1'))
                      .fontSize(14)
                  }
                  .layoutWeight(1)
                  .alignItems(VerticalAlign.Center)

                  Row({ space: 3 }) {
                    Text(this.typeOfEnergy ? this.typeOfEnergy : "请选择")
                      .fontColor($r('app.color.text_h1'))
                      .fontSize(13)
                    Image($r('app.media.arrow_bottom'))
                      .width(15)
                      .height(15)
                      .padding(3)
                  }
                  .alignItems(VerticalAlign.Center)
                  .justifyContent(FlexAlign.End)
                  .layoutWeight(1)
                  .onClick(() => {
                    TextPickerDialog.show({
                      range: this.newEnumTypeOfEnergy,
                      selected: this.selectTypeOfEnergy,
                      onAccept: (value: TextPickerResult) => {
                        // 当弹窗再次弹出时显示选中的是上一次确定的选项
                        this.selectTypeOfEnergy = value.index
                        console.log(this.selectTypeOfEnergy + '')
                        // 点击确定后，被选到的文本数据展示到页面 {"value":"黄色","index":1}
                        this.typeOfEnergy = value.value as string
                      }
                    })
                  })

                }
                .padding(8)

                Divider()
                  .height(1)
                  .margin({ left: 20, right: 20 })
                  .backgroundColor($r('app.color.layout_dividing_lines_bg_color'))

                //车辆注册日期
                Row() {
                  Row({ space: 5 }) {
                    Text("*")
                      .fontColor($r('app.color.title_required_text_color'))
                      .fontSize(13)
                    Text('车辆注册日期')
                      .fontColor($r('app.color.text_color1'))
                      .fontSize(14)
                  }
                  .layoutWeight(1)
                  .alignItems(VerticalAlign.Center)

                  Row({ space: 3 }) {
                    Text(this.registration_Date ? this.registration_Date : "请选择")
                      .fontColor($r('app.color.text_h1'))
                      .fontSize(13)
                    Image($r('app.media.arrow_bottom'))
                      .width(15)
                      .height(15)
                      .padding(3)
                  }
                  .alignItems(VerticalAlign.Center)
                  .justifyContent(FlexAlign.End)
                  .layoutWeight(1)
                  .onClick(() => {
                    DatePickerDialog.show({
                      start: new Date("2000-1-1"),
                      end: new Date("2100-12-31"),
                      selected: this.selectRegistrationDate,
                      onDateAccept: (value: Date) => {
                        //当弹窗再次弹出时显示选中的是上一次确定的日期
                        this.selectRegistrationDate = value
                        this.registrationDate = DateUtils.formatDate(value,"yyyy-MM-dd")
                      }
                    })
                  })
                }
                .padding(8)

                Divider()
                  .height(1)
                  .margin({ left: 20, right: 20 })
                  .backgroundColor($r('app.color.layout_dividing_lines_bg_color'))

                //年审日期
                Row() {
                  Row({ space: 5 }) {
                    Text("*")
                      .fontColor($r('app.color.title_required_text_color'))
                      .fontSize(13)
                    Text('年审日期')
                      .fontColor($r('app.color.text_color1'))
                      .fontSize(14)
                  }
                  .layoutWeight(1)
                  .alignItems(VerticalAlign.Center)

                  Row({ space: 3 }) {
                    Text(this.AnnualReviewDate ? this.AnnualReviewDate : "请选择")
                      .fontColor($r('app.color.text_h1'))
                      .fontSize(13)
                    Image($r('app.media.arrow_bottom'))
                      .width(15)
                      .height(15)
                      .padding(3)
                  }
                  .alignItems(VerticalAlign.Center)
                  .justifyContent(FlexAlign.End)
                  .layoutWeight(1)
                  .onClick(() => {
                    DatePickerDialog.show({
                      start: new Date("2000-1-1"),
                      end: new Date("2100-12-31"),
                      selected: this.selectAnnualReviewDate,
                      onDateAccept: (value: Date) => {
                        //当弹窗再次弹出时显示选中的是上一次确定的日期
                        this.selectAnnualReviewDate = value
                        this.AnnualReviewDate = DateUtils.formatDate(value,"yyyy-MM-dd")
                      }
                    })
                  })

                }
                .padding(8)

                Divider()
                  .height(1)
                  .margin({ left: 20, right: 20 })
                  .backgroundColor($r('app.color.layout_dividing_lines_bg_color'))


                //过期日期
                Row() {
                  Row({ space: 5 }) {
                    Text("*")
                      .fontColor($r('app.color.title_required_text_color'))
                      .fontSize(13)
                    Text('过期日期')
                      .fontColor($r('app.color.text_color1'))
                      .fontSize(14)
                  }
                  .layoutWeight(1)
                  .alignItems(VerticalAlign.Center)

                  Row({ space: 3 }) {
                    Text(this.expirationDate ? this.expirationDate : "请选择")
                      .fontColor($r('app.color.text_h1'))
                      .fontSize(13)
                    Image($r('app.media.arrow_bottom'))
                      .width(15)
                      .height(15)
                      .padding(3)

                  }
                  .alignItems(VerticalAlign.Center)
                  .onClick(() => {
                    DatePickerDialog.show({
                      start: new Date("2000-1-1"),
                      end: new Date("2100-12-31"),
                      selected: this.selectExpirationDate,
                      onDateAccept: (value: Date) => {
                        //当弹窗再次弹出时显示选中的是上一次确定的日期
                        this.selectExpirationDate = value
                        this.expirationDate = DateUtils.formatDate(value,"yyyy-MM-dd")
                      }
                    })
                  })
                }
                .padding(8)
              }
              .margin({
                left: 8,
                right: 8,
                top: 10,
                bottom: 10
              })
              .borderRadius(8)
              .backgroundColor($r('app.color.enter_the_documents_bg_color'))

              Text("以上信息为自动识别，如信息有误，请修改")
                .width('100%')
                .fontColor($r('app.color.warn_text_color'))
                .fontSize(12)
                .margin({ left: 20, bottom: 15 })


            }
            .margin({ left: 20, right: 20})
            .alignItems(HorizontalAlign.Center)
            .justifyContent(FlexAlign.Center)
            .borderRadius(8)
            .backgroundColor($r('app.color.white'))

            Button("提交")
              .type(ButtonType.Normal)
              .width('80%')
              .margin({ left: 30, right: 30, top: 25 ,bottom:20})
              .borderRadius(8)
              .backgroundColor($r('app.color.color_shubihong'))
          }

          // }
        }
        .scrollBar(BarState.Off)
        .width('100%')
        .height('100%')
        .scrollable(ScrollDirection.Vertical)
      }
      .width('100%')
      .height('100%')

    }
    .height('100%')
    .width('100%')
    .backgroundColor($r("app.color.system_background_color"))
  }
}