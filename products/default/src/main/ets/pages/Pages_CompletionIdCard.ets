import { TitleBar } from '@smarthane/titlebar';
import { Font, router } from '@kit.ArkUI';
import { showToast } from 'base';

/**
 * IDCard 资料填写
 */
@Entry
@Component
struct Pages_CompletionIdCard {
  @State title: string = '身份证录入';
  //titleBar组件
  @State model1: TitleBar.Model = new TitleBar.Model()
    .setOnLeftClickListener(() => {
      router.back()
    })
    .setTitleName(this.title)
    .setTitleFontColor($r("app.color.text_color1"))
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
    Column() {
      this.TitleBars()

      Row(){
        Text("请上传信息，仔细核实，如不正确请修改")
          .fontColor($r('app.color.text_h1'))
          .fontSize(12)
      }
      .margin({top:10})
      .alignItems(VerticalAlign.Center)
      .justifyContent(FlexAlign.Start)

      Flex({direction:FlexDirection.Column}){
        Scroll(){
          Column(){
            Column(){
              Row({space:10}){
                Text("人像面")
                  .fontColor($r('app.color.text_color1'))
                  .fontSize(14)
                  .layoutWeight(1)
                Text("国徽面")
                  .fontColor($r('app.color.text_color1'))
                  .fontSize(14)
                  .layoutWeight(1)
              }
              .padding(5)
              .margin({top:10})
              Row({space:10}){
                Image($r('app.media.card_z'))
                  .layoutWeight(1)
                Image($r('app.media.card_f'))
                  .layoutWeight(1)
              }
              .padding(5)
              //输入项
              Column({space:5}){
                //姓名
                Row(){
                  Row({space:5}){
                    Text("*")
                      .fontColor($r('app.color.title_required_text_color'))
                      .fontSize(13)
                    Text('姓名')
                      .fontColor($r('app.color.text_color1'))
                      .fontSize(14)
                  }
                  .margin({left:10})
                  .layoutWeight(1)
                  .alignItems(VerticalAlign.Center)

                  TextInput({placeholder:"请输入"})
                    .placeholderFont({size:13})
                    .type(InputType.Normal)
                    .backgroundColor(Color.Transparent)
                    .fontColor($r('app.color.text_color1'))
                    .fontSize(13)
                    .textAlign(TextAlign.End)
                    .layoutWeight(1)

                }
                Divider()
                  .height(1)
                  .margin({left:20,right:20})
                  .backgroundColor($r('app.color.layout_dividing_lines_bg_color'))
                //姓别
                Row(){
                  Row({space:5}){
                    Text("*")
                      .fontColor($r('app.color.title_required_text_color'))
                      .fontSize(13)
                    Text('性别')
                      .fontColor($r('app.color.text_color1'))
                      .fontSize(14)
                  }
                  .margin({left:10})
                  .layoutWeight(1)
                  .alignItems(VerticalAlign.Center)

                  TextInput({placeholder:"请输入"})
                    .placeholderFont({size:13})
                    .type(InputType.Normal)
                    .backgroundColor(Color.Transparent)
                    .fontColor($r('app.color.text_color1'))
                    .fontSize(13)
                    .textAlign(TextAlign.End)
                    .layoutWeight(1)

                }
                Divider()
                  .height(1)
                  .margin({left:20,right:20})
                  .backgroundColor($r('app.color.layout_dividing_lines_bg_color'))
                //出生日期
                Row(){
                  Row({space:5}){
                    Text("*")
                      .fontColor($r('app.color.title_required_text_color'))
                      .fontSize(13)
                    Text('出生日期')
                      .fontColor($r('app.color.text_color1'))
                      .fontSize(14)
                  }
                  .layoutWeight(1)
                  .alignItems(VerticalAlign.Center)

                  Row({space:3}){
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
                  .onClick(()=>{
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
                  .margin({left:20,right:20})
                  .backgroundColor($r('app.color.layout_dividing_lines_bg_color'))

                //民族
                Row(){
                  Row({space:5}){
                    Text("*")
                      .fontColor($r('app.color.title_required_text_color'))
                      .fontSize(13)
                    Text('民族')
                      .fontColor($r('app.color.text_color1'))
                      .fontSize(14)
                  }
                  .margin({left:10})
                  .layoutWeight(1)
                  .alignItems(VerticalAlign.Center)

                  TextInput({placeholder:"请输入"})
                    .placeholderFont({size:13})
                    .type(InputType.Normal)
                    .backgroundColor(Color.Transparent)
                    .fontColor($r('app.color.text_color1'))
                    .fontSize(13)
                    .textAlign(TextAlign.End)
                    .layoutWeight(1)

                }
                Divider()
                  .height(1)
                  .margin({left:20,right:20})
                  .backgroundColor($r('app.color.layout_dividing_lines_bg_color'))

                //签发机关
                Row(){
                  Row({space:5}){
                    Text("*")
                      .fontColor($r('app.color.title_required_text_color'))
                      .fontSize(13)
                    Text('签发机关')
                      .fontColor($r('app.color.text_color1'))
                      .fontSize(14)
                  }
                  .margin({left:10})
                  .layoutWeight(1)
                  .alignItems(VerticalAlign.Center)

                  TextInput({placeholder:"请输入"})
                    .placeholderFont({size:13})
                    .type(InputType.Normal)
                    .backgroundColor(Color.Transparent)
                    .fontColor($r('app.color.text_color1'))
                    .fontSize(13)
                    .textAlign(TextAlign.End)
                    .layoutWeight(1)

                }
                Divider()
                  .height(1)
                  .margin({left:20,right:20})
                  .backgroundColor($r('app.color.layout_dividing_lines_bg_color'))

                //身份证号
                Row(){
                  Row({space:5}){
                    Text("*")
                      .fontColor($r('app.color.title_required_text_color'))
                      .fontSize(13)
                    Text('身份证号')
                      .fontColor($r('app.color.text_color1'))
                      .fontSize(14)
                  }
                  .margin({left:10})
                  .layoutWeight(1)
                  .alignItems(VerticalAlign.Center)

                  TextInput({placeholder:"请输入"})
                    .placeholderFont({size:13})
                    .type(InputType.Normal)
                    .backgroundColor(Color.Transparent)
                    .fontColor($r('app.color.text_color1'))
                    .fontSize(13)
                    .textAlign(TextAlign.End)
                    .layoutWeight(1)

                }
                Divider()
                  .height(1)
                  .margin({left:20,right:20})
                  .backgroundColor($r('app.color.layout_dividing_lines_bg_color'))

                //身份证有效截至时间
                Row(){
                  Row({space:5}){
                    Text("*")
                      .fontColor($r('app.color.title_required_text_color'))
                      .fontSize(13)
                    Text('身份证有效截至时间')
                      .fontColor($r('app.color.text_color1'))
                      .fontSize(14)
                  }
                  .layoutWeight(1)
                  .alignItems(VerticalAlign.Center)
                  Row({space:3}){
                    Text(this.deadline ? this.deadline : "请选择")
                      .fontColor($r('app.color.text_h1'))
                      .fontSize(13)
                    Image($r('app.media.arrow_bottom'))
                      .width(15)
                      .height(15)
                      .padding(3)

                  }
                  .alignItems(VerticalAlign.Center)
                  .onClick(()=>{
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
              .margin({left:8,right:8,top:10,bottom:10})
              .borderRadius(8)
              .backgroundColor($r('app.color.enter_the_documents_bg_color'))

              Text("以上信息为自动识别，如信息有误，请修改")
                .width('100%')
                .fontColor($r('app.color.warn_text_color'))
                .fontSize(12)
                .margin({left:20,bottom:15})



            }
            .margin({left:20,right:20,top:10})
            .alignItems(HorizontalAlign.Center)
            .justifyContent(FlexAlign.Center)
            .borderRadius(8)
            .backgroundColor($r('app.color.white'))

            Button("提交")
              .type(ButtonType.Normal)
              .width('80%')
              .margin({left:30,right:30,top:25})
              .borderRadius(8)
              .backgroundColor($r('app.color.color_shubihong'))
          }
        }
      }


    }
    .height('100%')
    .width('100%')
    .backgroundColor($r("app.color.system_background_color"))
  }
}