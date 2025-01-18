import { TitleBar } from '@smarthane/titlebar';
import { router } from '@kit.ArkUI';

/**
 *保险信息录入
 */
@Entry
@Component
struct Pages_CompulsoryTrafficInsurance {
  @State title: string = '保险信息录入';

  //titleBar组件
  @State model1: TitleBar.Model = new TitleBar.Model()
    .setOnLeftClickListener(() => {
      router.back()
    })
    .setTitleName(this.title)
    .setTitleFontColor($r("app.color.text_color1"))
  scroller: Scroller = new Scroller()
  selectedDate: Date = new Date()
  selectBirthDate: Date = new Date()
  @State deadline :string =""
  @State brithDate :string =""



  @Builder TitleBars(){
    Column(){
      TitleBar({ model: $model1 })
    }

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
                Text("交强险")
                  .fontColor($r('app.color.text_color1'))
                  .fontSize(14)
                  .layoutWeight(1)

              }
              .padding(5)

              Row({ space: 10 }) {
                Image("")
                  .alt($r('app.media.insurance'))
                  .layoutWeight(1)
              }
              .padding(5)

              //输入项
              Column({ space: 5 }) {
                //保险公司
                Row() {
                  Row({ space: 5 }) {

                    Text('保险公司')
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

                }

                Divider()
                  .height(1)
                  .margin({ left: 20, right: 20 })
                  .backgroundColor($r('app.color.layout_dividing_lines_bg_color'))
                //有效期始
                Row() {
                  Row({ space: 5 }) {
                    Text("*")
                      .fontColor($r('app.color.title_required_text_color'))
                      .fontSize(13)
                    Text('有效期始')
                      .fontColor($r('app.color.text_color1'))
                      .fontSize(14)
                  }
                  .layoutWeight(1)
                  .alignItems(VerticalAlign.Center)

                  Row({ space: 3 }) {
                    Text(this.brithDate ? this.brithDate : "请选择")
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
                      selected: this.selectBirthDate,
                      onDateAccept: (value: Date) => {
                        //当弹窗再次弹出时显示选中的是上一次确定的日期
                        this.selectBirthDate = value
                        this.brithDate = value.toLocaleDateString()
                      }
                    })
                  })

                }
                .padding(8)

                Divider()
                  .height(1)
                  .margin({ left: 20, right: 20 })
                  .backgroundColor($r('app.color.layout_dividing_lines_bg_color'))
                //有效期止
                Row() {
                  Row({ space: 5 }) {
                    Text("*")
                      .fontColor($r('app.color.title_required_text_color'))
                      .fontSize(13)
                    Text('有效期止')
                      .fontColor($r('app.color.text_color1'))
                      .fontSize(14)
                  }
                  .layoutWeight(1)
                  .alignItems(VerticalAlign.Center)

                  Row({ space: 3 }) {
                    Text(this.deadline ? this.deadline : "请选择")
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
                      selected: this.selectedDate,
                      onDateAccept: (value: Date) => {
                        //当弹窗再次弹出时显示选中的是上一次确定的日期
                        this.selectedDate = value
                        this.deadline = value.toLocaleDateString()
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

              //责任险
              Row({ space: 10 }) {
                Text("责任险")
                  .fontColor($r('app.color.text_color1'))
                  .fontSize(14)
                  .layoutWeight(1)

              }
              .padding(5)

              Row({ space: 10 }) {
                Image($r('app.media.insurance1'))
                  .layoutWeight(1)
              }
              .padding(5)

              //输入项
              Column({ space: 5 }) {
                //保险公司
                Row() {
                  Row({ space: 5 }) {
                    Text('保险公司')
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

                }

                Divider()
                  .height(1)
                  .margin({ left: 20, right: 20 })
                  .backgroundColor($r('app.color.layout_dividing_lines_bg_color'))

                //有效期止
                Row() {
                  Row({ space: 5 }) {
                    Text("*")
                      .fontColor($r('app.color.title_required_text_color'))
                      .fontSize(13)
                    Text('有效期止')
                      .fontColor($r('app.color.text_color1'))
                      .fontSize(14)
                  }
                  .layoutWeight(1)
                  .alignItems(VerticalAlign.Center)

                  Row({ space: 3 }) {
                    Text(this.deadline ? this.deadline : "请选择")
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
                      selected: this.selectedDate,
                      onDateAccept: (value: Date) => {
                        //当弹窗再次弹出时显示选中的是上一次确定的日期
                        this.selectedDate = value
                        this.deadline = value.toLocaleDateString()
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


              //商业险
              Row({ space: 10 }) {
                Text("商业险")
                  .fontColor($r('app.color.text_color1'))
                  .fontSize(14)
                  .layoutWeight(1)

              }
              .padding(5)

              Row({ space: 10 }) {
                Image($r('app.media.insurance2'))
                  .layoutWeight(1)
              }
              .padding(5)

              //输入项
              Column({ space: 5 }) {
                //保险公司
                Row() {
                  Row({ space: 5 }) {
                    Text('保险公司')
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

                }

                Divider()
                  .height(1)
                  .margin({ left: 20, right: 20 })
                  .backgroundColor($r('app.color.layout_dividing_lines_bg_color'))

                //有效期止
                Row() {
                  Row({ space: 5 }) {
                    Text("*")
                      .fontColor($r('app.color.title_required_text_color'))
                      .fontSize(13)
                    Text('有效期止')
                      .fontColor($r('app.color.text_color1'))
                      .fontSize(14)
                  }
                  .layoutWeight(1)
                  .alignItems(VerticalAlign.Center)

                  Row({ space: 3 }) {
                    Text(this.deadline ? this.deadline : "请选择")
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
                      selected: this.selectedDate,
                      onDateAccept: (value: Date) => {
                        //当弹窗再次弹出时显示选中的是上一次确定的日期
                        this.selectedDate = value
                        this.deadline = value.toLocaleDateString()
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