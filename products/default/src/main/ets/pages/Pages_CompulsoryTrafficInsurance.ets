import { TitleBar } from '@smarthane/titlebar';
import { router } from '@kit.ArkUI';
import { Api, DateUtils, EventBus, LoadingUtils, NetConstants, showToast } from 'base';
import { camera, cameraPicker } from '@kit.CameraKit';
import { cameraSelect, fileSelect } from '../utils/Camerautils';
import { hide, showDialogBottomList } from '@abner/dialog';
import { SubmitTrafficInsuranceModel } from 'base/src/main/ets/viewmodel/SubmitTrafficInsuranceModel';
import { BaseModel } from 'base/src/main/ets/viewmodel/BaseModel';
import { JSON } from '@kit.ArkTS';
import { InquireTrafficInsuranceModel } from 'base/src/main/ets/viewmodel/InquireTrafficInsuranceModel';
import { MMKV } from '@tencent/mmkv';
import { putObject } from '../utils/upload';
interface SendFlushedModule {
  name: string
}
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
  selectedDateOne: Date = new Date()
  selectedDateTwo: Date = new Date()
  selectedDateThree: Date = new Date()
  selectedStartDate: Date = new Date()
  @State deadlineOne :string =""
  @State deadlineTwo :string =""
  @State deadlineThree :string =""
  @State startDateOne :string =""
  //保险公司
  @State insuranceCompanyOne :string = ""
  @State insuranceCompanyTwo :string = ""
  @State insuranceCompanyThree :string = ""
  //图片
  @State insurancePhotoOne :string = ""  //图片1
  @State insurancePhotoTwo :string = ""  //图片2
  @State insurancePhotoThree :string = "" //图片3

  @State submitTrafficInsurance:SubmitTrafficInsuranceModel = new SubmitTrafficInsuranceModel()
  @State baseBean:BaseModel = new BaseModel()
  @State inquireTrafficInsurance:InquireTrafficInsuranceModel = new InquireTrafficInsuranceModel();

  @State imageUri: Resource | string | undefined = undefined;

  private  cameraPosition: Array<camera.CameraPosition> = [
    camera.CameraPosition.CAMERA_POSITION_UNSPECIFIED, camera.CameraPosition.CAMERA_POSITION_BACK,
    camera.CameraPosition.CAMERA_POSITION_FRONT, camera.CameraPosition.CAMERA_POSITION_FOLD_INNER
  ];
  private  mediaType: Array<cameraPicker.PickerMediaType> = [
    cameraPicker.PickerMediaType.PHOTO, cameraPicker.PickerMediaType.VIDEO
  ];

  //相册选择
  selectImage(type:number) {
    fileSelect().then((uri: string) => {
      if (type == 1) {
        this.imageUri = uri || '';
        this.putObject(this.imageUri,1)
        hide()
      }else if (type == 2){
        this.imageUri = uri || '';
        // this.insurancePhotoTwo = this.imageUri
        this.putObject(this.imageUri,2)
        hide()
      }else if (type == 3){
        this.imageUri = uri || '';
        // this.insurancePhotoThree = this.imageUri
        this.putObject(this.imageUri,3)
        hide()
      }

    });
  }
  //相机拍照
  openPhotos(type:number){
    cameraSelect(this.cameraPosition,this.mediaType,getContext(this)).then((uri: string) => {
      if (type == 1) {
        this.imageUri = uri || '';
        this.putObject(this.imageUri,1)
        hide()
      }else if (type == 2){
        this.imageUri = uri || '';
        this.putObject(this.imageUri,2)
        hide()
      }else if (type == 3){
        this.imageUri = uri || '';
        this.putObject(this.imageUri,3)
        hide()
      }
    });
  }

  //默认进来查询数据->回显
  async inquireTrafficInsuranceData(){
    LoadingUtils.showLoading("加载中...")
    let res = await Api.net().getDriverInfoByInsuranceInfo();
    if (res.isSuccessWithData()) {
      this.inquireTrafficInsurance = res.data as InquireTrafficInsuranceModel
      // console.log("数据打印===>"+JSON.stringify(res.data))
      if (this.inquireTrafficInsurance.statusCode == 200) {
        LoadingUtils.hideLoading()
        if (this.inquireTrafficInsurance.data.Info) {
          //图片回显
          this.insurancePhotoOne =this.inquireTrafficInsurance.data.Info.Clivtaphoto
          this.insurancePhotoTwo =this.inquireTrafficInsurance.data.Info.VehicleInsurancePhoto
          this.insurancePhotoThree =this.inquireTrafficInsurance.data.Info.CarriersInsurancePhoto
          //开始时间回显
          this.startDateOne = this.inquireTrafficInsurance.data.Info.ClivtaexpiryStartDate
          //保险公司回显
          this.insuranceCompanyOne = this.inquireTrafficInsurance.data.Info.ClivateCompany
          this.insuranceCompanyTwo = this.inquireTrafficInsurance.data.Info.VehicleInsuranceCompany
          this.insuranceCompanyThree = this.inquireTrafficInsurance.data.Info.InsureCompany
          //截止时间回显
          this.deadlineOne = this.inquireTrafficInsurance.data.Info.ClivtaexpiryDate
          this.deadlineTwo = this.inquireTrafficInsurance.data.Info.VehicleInsuranceExpiryDate
          this.deadlineThree = this.inquireTrafficInsurance.data.Info.CarriersInsuranceExpiryDate
        }
      }else{
        LoadingUtils.hideLoading()
        showToast(this.inquireTrafficInsurance.message)
      }
    }else{
      LoadingUtils.hideLoading()
      showToast(res.message)
    }

  }

  //提交数据
  async submitTrafficInsuranceData(){
    //判断入参数据
    if (!this.insuranceCompanyOne) {
      showToast("请上传交强险图片信息")
      return
    }
    if (!this.insuranceCompanyTwo) {
      showToast("请上传责任险图片信息")
      return
    }
    if (!this.insuranceCompanyThree) {
      showToast("请上传商业险图片信息")
      return
    }
    if (!this.startDateOne) {
      showToast('请选择交强险有效期始时间')
      return
    }
    if (!this.deadlineOne) {
      showToast('请选择交强险有效期止时间')
      return
    }
    if (!this.deadlineTwo) {
      showToast('请选择责任险有效期止时间')
      return
    }
    if (!this.deadlineThree) {
      showToast('请选择商业险有效期止时间')
      return
    }
    LoadingUtils.showLoading("加载中...")
    this.submitTrafficInsurance.Clivtaphoto = this.insurancePhotoOne
    this.submitTrafficInsurance.ClivateCompany = this.insuranceCompanyOne
    this.submitTrafficInsurance.ClivtaexpiryStartDate = this.startDateOne
    this.submitTrafficInsurance.ClivtaexpiryDate = this.deadlineOne
    this.submitTrafficInsurance.VehicleInsurancePhoto = this.insurancePhotoTwo
    this.submitTrafficInsurance.VehicleInsuranceCompany = this.insuranceCompanyTwo
    this.submitTrafficInsurance.VehicleInsuranceExpiryDate = this.deadlineTwo
    this.submitTrafficInsurance.CarriersInsurancePhoto = this.insurancePhotoThree
    this.submitTrafficInsurance.InsureCompany = this.insuranceCompanyThree
    this.submitTrafficInsurance.CarriersInsuranceExpiryDate = this.deadlineThree
    console.log("打印提交数据JSON===>"+JSON.stringify(this.submitTrafficInsurance))
    let res = await Api.net().postSaveDriverInfoByInsuranceInfo(this.submitTrafficInsurance);
    if (res.isSuccessWithData()) { //200
      if (res.data?.statusCode == 200) {
        LoadingUtils.hideLoading()
        showToast("保存成功")//Pages_SubmitForRevie
        MMKV.defaultMMKV().encodeString("TARGET","Audit")
        if (MMKV.defaultMMKV().decodeString('TARGET') === 'Audit') {
          router.pushUrl({
            url:'pages/Pages_SubmitForRevie'
          })
        }else{
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
        this.insurancePhotoOne = imageUrl
      }
      console.log(`图片地址 === ` + imageUrl)
      console.log(`图片地址 === ` + JSON.stringify(result))
    }else if (type == 2){
      //上传
      const result = await putObject(uri ,fileType ,SignatureUrl ,fileName)
      const imageUrl = `${NetConstants.OSSPoint}/${fileName}`;
      if (imageUrl) {
        this.insurancePhotoTwo = imageUrl
      }
      console.log(`图片地址 === ` + imageUrl)
      console.log(`图片地址 === ` + JSON.stringify(result))
    }else if (type == 3){
      //上传
      const result = await putObject(uri ,fileType ,SignatureUrl ,fileName)
      const imageUrl = `${NetConstants.OSSPoint}/${fileName}`;
      if (imageUrl) {
        this.insurancePhotoThree = imageUrl
      }
      console.log(`图片地址 === ` + imageUrl)
      console.log(`图片地址 === ` + JSON.stringify(result))
    }
  }


  aboutToAppear(): void {
    //
    this.inquireTrafficInsuranceData()
  }


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
                Image(this.insurancePhotoOne)
                  .alt($r('app.media.insurance'))
                  .layoutWeight(1)
                  .height(160)
                  .onClick(()=>{
                    showDialogBottomList({
                      items: ["相机", "相册"],
                      dialogAttribute: {
                        isSystemAnimation: false//取消系统的动画
                      },
                      itemDivider: {
                        height: 0.5
                      },
                      cancelAttr: {
                        paddingBottom: 20
                      },
                      itemClick: (position: number) => {
                        console.log("==========:" + position)
                        if (position == 0) {//相机
                          this.openPhotos(1)
                        }else if (position == 1){//相册
                          this.selectImage(1)

                        }
                      }
                    })
                  })
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

                  TextInput({ placeholder: "请输入",text:this.insuranceCompanyOne?this.insuranceCompanyOne:"" })
                    .placeholderFont({ size: 13 })
                    .type(InputType.Normal)
                    .backgroundColor(Color.Transparent)
                    .fontColor($r('app.color.text_color1'))
                    .fontSize(13)
                    .textAlign(TextAlign.End)
                    .layoutWeight(1)
                    .onChange((value)=>{
                      this.insuranceCompanyOne = value
                    })

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
                    Text(this.startDateOne ? this.startDateOne : "请选择")
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
                      start: new Date("1949-1-1"),
                      end: new Date("2100-12-31"),
                      selected: this.selectedStartDate,
                      onDateAccept: (value: Date) => {
                        //当弹窗再次弹出时显示选中的是上一次确定的日期
                        this.selectedStartDate = value
                        this.startDateOne = DateUtils.formatDate(value,"yyyy-MM-dd")
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
                    Text(this.deadlineOne ? this.deadlineOne : "请选择")
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
                      start: new Date("1949-1-1"),
                      end: new Date("2100-12-31"),
                      selected: this.selectedDateOne,
                      onDateAccept: (value: Date) => {
                        //当弹窗再次弹出时显示选中的是上一次确定的日期
                        this.selectedDateOne = value
                        this.deadlineOne = DateUtils.formatDate(value,"yyyy-MM-dd")
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
                Image(this.insurancePhotoTwo)
                  .alt($r('app.media.insurance1'))
                  .layoutWeight(1)
                  .height(160)
                  .onClick(()=>{
                    showDialogBottomList({
                      items: ["相机", "相册"],
                      dialogAttribute: {
                        isSystemAnimation: false//取消系统的动画
                      },
                      itemDivider: {
                        height: 0.5
                      },
                      cancelAttr: {
                        paddingBottom: 20
                      },
                      itemClick: (position: number) => {
                        if (position == 0) {//相机
                          this.openPhotos(2)
                        }else if (position == 1){//相册
                          this.selectImage(2)

                        }
                      }
                    })
                  })
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

                  TextInput({ placeholder: "请输入",text:this.insuranceCompanyTwo?this.insuranceCompanyTwo:"" })
                    .placeholderFont({ size: 13 })
                    .type(InputType.Normal)
                    .backgroundColor(Color.Transparent)
                    .fontColor($r('app.color.text_color1'))
                    .fontSize(13)
                    .textAlign(TextAlign.End)
                    .layoutWeight(1)
                    .onChange((value)=>{
                      this.insuranceCompanyTwo = value
                    })

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
                    Text(this.deadlineTwo ? this.deadlineTwo : "请选择")
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
                      start: new Date("1949-1-1"),
                      end: new Date("2100-12-31"),
                      selected: this.selectedDateTwo,
                      onDateAccept: (value: Date) => {
                        //当弹窗再次弹出时显示选中的是上一次确定的日期
                        this.selectedDateTwo = value
                        this.deadlineTwo =DateUtils.formatDate(value,"yyyy-MM-dd")
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
                Image(this.insurancePhotoThree)
                  .alt($r('app.media.insurance2'))
                  .layoutWeight(1)
                  .height(160)
                  .onClick(()=>{
                    showDialogBottomList({
                      items: ["相机", "相册"],
                      dialogAttribute: {
                        isSystemAnimation: false//取消系统的动画
                      },
                      itemDivider: {
                        height: 0.5
                      },
                      cancelAttr: {
                        paddingBottom: 20
                      },
                      itemClick: (position: number) => {
                        console.log("==========:" + position)
                        if (position == 0) {//相机
                          this.openPhotos(3)
                        }else if (position == 1){//相册
                          this.selectImage(3)

                        }
                      }
                    })
                  })
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

                  TextInput({ placeholder: "请输入",text:this.insuranceCompanyThree?this.insuranceCompanyThree:"" })
                    .placeholderFont({ size: 13 })
                    .type(InputType.Normal)
                    .backgroundColor(Color.Transparent)
                    .fontColor($r('app.color.text_color1'))
                    .fontSize(13)
                    .textAlign(TextAlign.End)
                    .layoutWeight(1)
                    .onChange((value)=>{
                      this.insuranceCompanyThree  = value
                    })

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
                    Text(this.deadlineThree ? this.deadlineThree : "请选择")
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
                      start: new Date("1949-1-1"),
                      end: new Date("2100-12-31"),
                      selected: this.selectedDateThree,
                      onDateAccept: (value: Date) => {
                        //当弹窗再次弹出时显示选中的是上一次确定的日期
                        this.selectedDateThree = value
                        this.deadlineThree = DateUtils.formatDate(value,"yyyy-MM-dd")
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
              .onClick(()=>{
                this.submitTrafficInsuranceData()
              })
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