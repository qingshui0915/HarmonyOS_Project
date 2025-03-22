import { TitleBar } from '@smarthane/titlebar';
import { Font, router } from '@kit.ArkUI';
import { DateUtils, EventBus, showToast } from 'base';
import { ArrayList, JSON } from '@kit.ArkTS';
import { Type, plainToClass } from 'class-transformer'
import "reflect-metadata"
import { CallbackParam, CardRecognition, CardSide, CardType, ShootingMode } from '@kit.VisionKit';

/**
 * IDCard 资料填写
 */
interface PersonInfo {
  name: string;
  sex: string;
  nationality: string;
  address: string;
  birth: string;
  idNumber: string;
  cardImageUri: string;
  originalImageUri: string;
  authority ?: string;
  validPeriod ?: string;
}


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
  @State brithDate :string ="" //出生日期
  @State userName :string = "" //姓名
  @State gender :string = ""  //性别
  @State ethnicGroup :string = "" //民族
  @State issuingAuthority :string = "" //签发机关
  @State identificationNumber :string = "" //身份证号
  @State idCard_z_img :string = "" //身份证人像面
  @State idCard_f_img :string = "" //身份证国徽面
  @State backEventData :PersonInfo[] = []
  @State showCard :boolean =false
  @State cardFrontData :Record<string, string> = {}
  @State cardBackData :Record<string, string> = {}



  @Builder TitleBars(){
    Column(){
      TitleBar({ model: $model1 })
    }

  }


  onPageShow() :void {
    console.log("=====>onPageShow")

  }


  aboutToAppear(): void {
    console.log("=====>onPageShow")
    EventBus.listen<PersonInfo>('IDCardInfo', (data) => {
      if (data !== undefined) {
        console.log("====》"+data + "<====" +JSON.stringify(data))
        this.userName = data.name
        // for (let i = 0; i < data.length; i++) {
        //   if (i == 0) {
        //     this.userName = `${data[i].name}`
        //   }
        // }
        // let tmpStr: Record<string, string>[] = JSON.parse(JSON.stringify(data)) as Record<string, string>[];
        // const arrayList: ArrayList<string> = new ArrayList();
        // Object.entries(tmpStr).forEach((item) => {
        //   const value = item[1];
        //   arrayList.add(value);
        // })
        //
        // console.log("=====>"+JSON.stringify(arrayList))
        // this.backEventData = data as Record<string, string>[]
        // console.log("页面返回打印数据====>"+JSON.stringify(this.backEventData))
        // this.backEventData.forEach((cardData :Record<string, string>)=>{
        //   this.userName = `${cardData.name}`
        // })
        // console.log("页面返回打印数据====>"+JSON.stringify(data))
        // console.log("页面返回打印数据====>"+JSON.stringify(data[0]))
        // const s  =  JSON.parse(data  as Record<string, string>[])
        // // 解析身份证正面信息
        // if (data.length > 0 && data[0]) {
        //   // JSON.parse()
        //   typeof data
        //   const frontData = data[0]
        //   this.userName = frontData['name'] || ""
        //   this.gender = frontData['sex'] || ""
        //   this.ethnicGroup = frontData['nationality'] || ""
        //
        //   // 处理出生日期格式
        //   if (frontData['birth']) {
        //     // 将"1990年6月11日"转换为"1990/06/11"格式
        //     const birthMatch = frontData['birth'].match(/(\d{4})年(\d{1,2})月(\d{1,2})日/)
        //     if (birthMatch) {
        //       const year = birthMatch[1]
        //       const month = birthMatch[2].padStart(2, '0')
        //       const day = birthMatch[3].padStart(2, '0')
        //       this.brithDate = `${year}/${month}/${day}`
        //       // 更新日期选择器的日期
        //       this.selectBirthDate = new Date(`${year}/${month}/${day}`)
        //     }
        //   }
        //   this.idCard_z_img = frontData['cardImageUri']
        //
        //   this.identificationNumber = frontData['idNumber'] || ""
        // }
        //
        // // 解析身份证背面信息
        // if (data.length > 1 && data[1]) {
        //   const backData = data[1]
        //   this.issuingAuthority = backData['authority'] || ""
        //   this.idCard_f_img = backData['cardImageUri']
        //   // 处理有效期限
        //   if (backData['validPeriod']) {
        //     // 例如："2023.07.07-长期"
        //     const periodParts = backData['validPeriod'].split('-')
        //     if (periodParts.length > 0) {
        //       const startDateStr = periodParts[0].trim()
        //       // 将"2023.07.07"转换为"2023-07-07"格式
        //       const dateParts = startDateStr.split('.')
        //       if (dateParts.length === 3) {
        //         const year = dateParts[0]
        //         const month = dateParts[1]
        //         const day = dateParts[2]
        //
        //         // 如果是"长期"，可以设置一个较远的日期，如20年后
        //         if (periodParts[1] && periodParts[1].trim() === "长期") {
        //           const endDate = new Date(`${year}/${month}/${day}`)
        //           endDate.setFullYear(endDate.getFullYear() + 50)
        //           this.deadline = DateUtils.formatDate(endDate, "yyyy/MM/dd")
        //           // this.selectedDate = endDate
        //         }
        //       }
        //     }
        //   }
        // }

        console.log("更新后的数据=====>", JSON.stringify({
          userName: this.userName,
          gender: this.gender,
          ethnicGroup: this.ethnicGroup,
          brithDate: this.brithDate,
          identificationNumber: this.identificationNumber,
          issuingAuthority: this.issuingAuthority,
          deadline: this.deadline
        }))
      }
    })
  }
  //默认进来查询
  async inquireIdCardData(){

  }

  //提交数据
  async submitIdCardData(){
    //判断入参数据


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
                Image(this.idCard_z_img)
                  .layoutWeight(1)
                  .alt($r('app.media.card_z'))
                  .onClick(()=>{
                    // showToast("点击选择相册or拍照")
                    this.showCard = true
                    // router.pushUrl({
                    //   url:'pages/Pages_IdCard'
                    // })
                  })
                Image(this.idCard_f_img)
                  .layoutWeight(1)
                  .alt($r('app.media.card_f'))
                  .onClick(()=>{
                    showToast("点击选择相册or拍照")
                  })
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

                  TextInput({placeholder:"请输入",text:this.userName})
                    .placeholderFont({size:13})
                    .type(InputType.Normal)
                    .backgroundColor(Color.Transparent)
                    .fontColor($r('app.color.text_color1'))
                    .fontSize(13)
                    .textAlign(TextAlign.End)
                    .layoutWeight(1)
                    .onChange((value)=>{
                      this.userName = value
                    })

                }
                Divider()
                  .height(1)
                  .margin({left:20,right:20})
                  .backgroundColor($r('app.color.layout_dividing_lines_bg_color'))
                //性别
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

                  TextInput({placeholder:"请输入",text:this.gender})
                    .placeholderFont({size:13})
                    .type(InputType.Normal)
                    .backgroundColor(Color.Transparent)
                    .fontColor($r('app.color.text_color1'))
                    .fontSize(13)
                    .textAlign(TextAlign.End)
                    .layoutWeight(1)
                    .onChange((value)=>{
                      this.gender = value
                    })

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
                      start: new Date("1949-1-1"),
                      end: new Date("2100-12-31"),
                      selected: this.selectBirthDate,
                      onDateAccept: (value: Date) => {
                        //当弹窗再次弹出时显示选中的是上一次确定的日期
                        this.selectBirthDate = value
                        this.brithDate = DateUtils.formatDate(value,"yyyy-MM-dd")
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

                  TextInput({placeholder:"请输入",text : this.ethnicGroup})
                    .placeholderFont({size:13})
                    .type(InputType.Normal)
                    .backgroundColor(Color.Transparent)
                    .fontColor($r('app.color.text_color1'))
                    .fontSize(13)
                    .textAlign(TextAlign.End)
                    .layoutWeight(1)
                    .onChange((value)=>{
                      this.ethnicGroup = value
                    })

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
                  .alignItems(VerticalAlign.Center)

                  TextInput({placeholder:"请输入",text : this.issuingAuthority})
                    .placeholderFont({size:13})
                    .type(InputType.Normal)
                    .backgroundColor(Color.Transparent)
                    .fontColor($r('app.color.text_color1'))
                    .fontSize(13)
                    .textAlign(TextAlign.End)
                    .margin({left:10})
                    .layoutWeight(1)
                    .onChange((value) =>{
                      this.issuingAuthority = value
                    })

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

                  TextInput({placeholder:"请输入",text:this.identificationNumber})
                    .placeholderFont({size:13})
                    .type(InputType.Normal)
                    .backgroundColor(Color.Transparent)
                    .fontColor($r('app.color.text_color1'))
                    .fontSize(13)
                    .textAlign(TextAlign.End)
                    .layoutWeight(1)
                    .onChange((value)=>{
                      this.identificationNumber = value
                    })

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
                      start: new Date("1949-1-1"),
                      end: new Date("2100-12-31"),
                      selected: this.selectedDate,
                      onDateAccept: (value: Date) => {
                        //当弹窗再次弹出时显示选中的是上一次确定的日期
                        this.selectedDate = value
                        this.deadline = DateUtils.formatDate(value,"yyyy-MM-dd")
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
              .onClick(()=>{
                //提交数据
                this.submitIdCardData()
              })
          }
        }
      }

      if (this.showCard){
        CardRecognition({
          // 此处选择身份证类型作为示例
          supportType: CardType.CARD_ID,
          cardSide: CardSide.DEFAULT,
          cardRecognitionConfig: {
            defaultShootingMode: ShootingMode.MANUAL,
            isPhotoSelectionSupported: true
          },
          callback: ((params: CallbackParam) => {
            if (params.code === -1) {
              // this.pathStack.pop()
            }
            if (params.cardInfo?.front !== undefined) {
              this.cardFrontData = params.cardInfo?.front
              this.userName = this.cardFrontData.name
            }

            if (params.cardInfo?.back !== undefined) {
              this.cardBackData = params.cardInfo?.back
            }
            this.showCard = false
          })
        })
      }

    }
    .height('100%')
    .width('100%')
    .backgroundColor($r("app.color.system_background_color"))




  }
}