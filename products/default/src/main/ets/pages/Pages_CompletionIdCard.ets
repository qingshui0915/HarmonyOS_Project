import { TitleBar } from '@smarthane/titlebar';
import {  router } from '@kit.ArkUI';
import { Api, DateUtils, EventBus, LoadingUtils, NetConstants, showToast } from 'base';
import { JSON } from '@kit.ArkTS';
import { CallbackParam, CardRecognition, CardSide, CardType, ShootingMode } from '@kit.VisionKit';
import { ImageFileNameModel } from 'base/src/main/ets/viewmodel/ImageFileNameModel';
import { OSSPolicyTokenModel } from 'base/src/main/ets/viewmodel/OSSPolicyTokenModel';
import { InquireIdCardModel } from 'base/src/main/ets/viewmodel/InquireIdCardModel';
import { SubmitIdCardModel } from 'base/src/main/ets/viewmodel/SubmitIdCardModel';
import { MMKV } from '@tencent/mmkv';
import { putObject } from '../utils/upload';

/**
 * IDCard 资料填写
 */

// 测试: eventBus 发送和接收的数据模型
interface SendFlushedModule {
  name: string
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
  @State showFrontCard :boolean =false
  @State showBackCard :boolean =false
  @State cardFrontData :Record<string, string> = {}
  @State cardBackData :Record<string, string> = {}
  @State ossPolicyToken :OSSPolicyTokenModel = new OSSPolicyTokenModel()
  @State imageFileName :ImageFileNameModel = new ImageFileNameModel()
  @State inquireIdCard:InquireIdCardModel = new InquireIdCardModel()
  @State submitIdCard:SubmitIdCardModel = new SubmitIdCardModel()
  @State target:string = ""

  @Builder TitleBars(){
    Column(){
      TitleBar({ model: $model1 })
    }

  }


  onPageShow() :void {
    console.log("=====>onPageShow")
  }




  aboutToAppear(): void {
    this.target = router.getParams() as string
    console.log("hhhh===>"+JSON.stringify(this.target))
    MMKV.defaultMMKV().encodeString("TARGET",this.target['value'])
    //默认进来查询回显
      this.InquireIdCardData()
  }

  //查询驾驶证信息数据->回显
  async InquireIdCardData(){
    LoadingUtils.showLoading("加载中...")
    let res = await Api.net().getDriverInfoByIdCard()
    if (res.isSuccessWithData()) {
      this.inquireIdCard =  res.data as InquireIdCardModel
      if (this.inquireIdCard.statusCode == 200) {
        LoadingUtils.hideLoading()
        if (this.inquireIdCard.data.Info) {
          //回显数据赋值
          this.idCard_z_img = this.inquireIdCard.data.Info.IdCardUrl
          this.idCard_f_img = this.inquireIdCard.data.Info.IdCardPersonUrl

          this.userName = this.inquireIdCard.data.Info.Name
          this.gender = this.inquireIdCard.data.Info.Gender
          this.ethnicGroup = this.inquireIdCard.data.Info.Nation
          this.brithDate = this.inquireIdCard.data.Info.Birthday
          this.issuingAuthority = this.inquireIdCard.data.Info.IdcardSignsBy
          this.identificationNumber = this.inquireIdCard.data.Info.IdCardNo
          this.deadline = (this.inquireIdCard.data.Info.IdCardExpiryDate).split(" ")[0]
        }
      }else{
        LoadingUtils.hideLoading()
        showToast(this.inquireIdCard.message)
      }
    }else{
      LoadingUtils.hideLoading()
      showToast(res.message)
    }
  }

  //提交数据
  async submitIdCardData(){
    //判断入参数据this.idCard_z_img
    if (!this.idCard_z_img) {
      showToast("请上传人面像图片信息")
      return
    }
    if (!this.idCard_f_img) {
      showToast("请上传国徽面图片信息")
      return
    }
    if (!this.userName) {
      showToast("请填写姓名信息")
      return
    }
    if (!this.gender) {
      showToast("请填写性别信息")
      return
    }
    if (!this.ethnicGroup) {
      showToast("请填写民族信息")
      return
    }
    if (!this.brithDate) {
      showToast("请填写出生日期信息")
      return
    }
    if (!this.issuingAuthority) {
      showToast("请填写签发机关信息")
      return
    }
    if (!this.identificationNumber) {
      showToast("请填写身份证号信息")
      return
    }
    if (!this.deadline) {
      showToast("请填写身份证有效截止时间信息")
      return
    }
    LoadingUtils.showLoading("加载中...")
    this.submitIdCard.IdCardUrl = this.idCard_z_img
    this.submitIdCard.IdCardPersonUrl = this.idCard_f_img
    this.submitIdCard.Name = this.userName
    this.submitIdCard.Gender = this.gender
    this.submitIdCard.Nation = this.ethnicGroup
    this.submitIdCard.Birthday = this.brithDate
    this.submitIdCard.IdcardSignsBy = this.issuingAuthority
    this.submitIdCard.IdCardNo = this.identificationNumber
    this.submitIdCard.IdCardExpiryDate = this.deadline
    console.log("打印提交数据JSON===>"+JSON.stringify(this.submitIdCard))
    let res = await Api.net().postSaveDriverInfoByIdCard(this.submitIdCard);
    if (res.isSuccessWithData()) { //200
      if (res.data?.statusCode == 200) {
        LoadingUtils.hideLoading()
        showToast("保存成功")
        //TODO:下一步操作 注册:next页面 补齐: finish 具体分析
        if (MMKV.defaultMMKV().decodeString('TARGET') === 'Target') {
          router.pushUrl({
            url:'pages/Pages_CompletionDriverCard'
          })
        }else{
          //测试发送事件
          let eventData: SendFlushedModule = {
            name: '补齐证件',
          }
          EventBus.send('SendFlushedModule', eventData)
          router.back()
        }

      }else{
        LoadingUtils.hideLoading()
        showToast(res.data?.message+"")
      }
    }else{
      LoadingUtils.hideLoading()
      showToast(res.message)
    }
  }

  putObject = async (uri:string,type:number) =>{
    let access_token:string = MMKV.defaultMMKV().decodeString("Token") || ""
    if (access_token == "" || !access_token) {
      access_token = ""
    }
    //获取文件名
    const fileNameData = await Api.net().getOssFileNameRequest()
    const name = fileNameData.data?.data
    const fileName = `${name}.jpg`
    const fileType = "image/jpeg"

    //获取签名
    const SignatureData = await Api.net().getOssParamRequest(fileName ,fileType)
    const SignatureUrl = SignatureData.data?.data as string
    if (type ==  1){
      //上传
      const result = await putObject(uri ,fileType ,SignatureUrl ,fileName)
      const imageUrl = `${NetConstants.OSSPoint}/${fileName}`;
      if (imageUrl) {
        this.idCard_z_img = imageUrl
      }
      console.log(`图片地址 === ` + imageUrl)
      console.log(`图片地址 === ` + JSON.stringify(result))
    }else if (type == 2){
      //上传
      const result = await putObject(uri ,fileType ,SignatureUrl ,fileName)
      const imageUrl = `${NetConstants.OSSPoint}/${fileName}`;
      if (imageUrl) {
        this.idCard_f_img = imageUrl
      }
      console.log(`图片地址 === ` + imageUrl)
      console.log(`图片地址 === ` + JSON.stringify(result))
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
                Image(this.idCard_z_img)
                  .layoutWeight(1)
                  .alt($r('app.media.card_z'))
                  .onClick(()=>{
                    this.showFrontCard = true
                  })
                Image(this.idCard_f_img)
                  .layoutWeight(1)
                  .alt($r('app.media.card_f'))
                  .onClick(()=>{
                    this.showBackCard = true
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

      if (this.showFrontCard){
        CardRecognition({
          // 此处选择身份证类型作为示例
          supportType: CardType.CARD_ID,
          cardSide: CardSide.FRONT,
          cardRecognitionConfig: {
            defaultShootingMode: ShootingMode.MANUAL,
            isPhotoSelectionSupported: true
          },
          callback: ((params: CallbackParam) => {
            if (params.code === -1) {
              // this.pathStack.pop()
            }else if(params.code === 200){
              if (params.cardInfo?.front !== undefined) {
                this.cardFrontData = params.cardInfo?.front
                this.userName = this.cardFrontData.name
                  this.gender = this.cardFrontData.sex
                  this.ethnicGroup = this.cardFrontData.nationality
                  // 处理出生日期格式
                  if (this.cardFrontData.birth) {
                    // 将"1990年6月11日"转换为"1990/06/11"格式
                    const birthMatch = this.cardFrontData.birth.match(/(\d{4})年(\d{1,2})月(\d{1,2})日/)
                    if (birthMatch) {
                      const year = birthMatch[1]
                      const month = birthMatch[2].padStart(2, '0')
                      const day = birthMatch[3].padStart(2, '0')
                      this.brithDate = `${year}/${month}/${day}`
                      // 更新日期选择器的日期
                      this.selectBirthDate = new Date(`${year}/${month}/${day}`)
                    }
                  }
                  this.idCard_z_img = this.cardFrontData.cardImageUri
                if (this.idCard_z_img) {
                    //这里请求OSS
                  this.putObject(this.idCard_z_img,1)
                }
                  this.identificationNumber = this.cardFrontData.idNumber
              }
            }
            this.showFrontCard = false
          })
        })
      }

      if (this.showBackCard){
        CardRecognition({
          // 此处选择身份证类型作为示例
          supportType: CardType.CARD_ID,
          cardSide: CardSide.BACK,
          cardRecognitionConfig: {
            defaultShootingMode: ShootingMode.MANUAL,
            isPhotoSelectionSupported: true
          },
          callback: ((params: CallbackParam) => {
            if (params.code === -1) {
              // this.pathStack.pop()
            }else if(params.code === 200){
              if (params.cardInfo?.back !== undefined) {
                this.cardBackData = params.cardInfo?.back
                this.issuingAuthority = this.cardBackData.authority
                this.idCard_f_img = this.cardBackData.cardImageUri
                if (this.idCard_f_img) {
                  //这里请求OSS
                  this.putObject(this.idCard_f_img,2)
                }
                // 处理有效期限
                if (this.cardBackData.validPeriod) {
                  // 例如："2023.07.07-长期"
                  const periodParts = this.cardBackData.validPeriod.split('-')
                  if (periodParts.length > 0) {
                    const startDateStr = periodParts[0].trim()
                    // 将"2023.07.07"转换为"2023-07-07"格式
                    const dateParts = startDateStr.split('.')
                    if (dateParts.length === 3) {
                      const year = dateParts[0]
                      const month = dateParts[1]
                      const day = dateParts[2]
                      // 如果是"长期"，可以设置一个较远的日期，如20年后
                      if (periodParts[1] && periodParts[1].trim() === "长期") {
                        const endDate = new Date(`${year}/${month}/${day}`)
                        endDate.setFullYear(endDate.getFullYear() + 50)
                        this.deadline = DateUtils.formatDate(endDate, "yyyy/MM/dd")
                        // this.selectedDate = endDate
                      }
                    }
                  }
                }
              }
            }
            this.showBackCard = false
          })
        })
      }

    }
    .height('100%')
    .width('100%')
    .backgroundColor($r("app.color.system_background_color"))




  }
}