import { TitleBar } from '@smarthane/titlebar';
import { router } from '@kit.ArkUI';
import { Api, DateUtils, EventBus, LoadingUtils, NetConstants, showToast } from 'base';
import { EnumSurveyVehiclePlateColor } from '../enum/EnumSurveyVehiclePlateColor';
import { EnumTypeOfEnergy } from '../enum/EnumTypeOfEnergy';
import { CallbackParam, CardRecognition, CardSide, CardType, ShootingMode } from '@kit.VisionKit';
import { hide, showDialogBottomList } from '@abner/dialog';
import { camera, cameraPicker } from '@kit.CameraKit';
import { cameraSelect, fileSelect } from '../utils/Camerautils';
import { InquireTravelCardModel } from 'base/src/main/ets/viewmodel/InquireTravelCardModel';
import { SubmitTravelCardModel } from 'base/src/main/ets/viewmodel/SubmitTravelCardModel';
import { MMKV } from '@tencent/mmkv';
import { putObject } from '../utils/upload';

interface SendFlushedModule {
  name: string
}

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
  @State showFrontCard :boolean =false
  @State travelCard_z_img :string =""
  @State travelCard_f_img :string =""
  @State personCarGroupPhoto :string =""
  @State travelCardFrontData :Record<string, string> = {}
  @State inquireTravelCard:InquireTravelCardModel = new InquireTravelCardModel()
  @State submitTravelCard:SubmitTravelCardModel = new SubmitTravelCardModel()

  @State imageUri: Resource | string | undefined = undefined;
  private  cameraPosition: Array<camera.CameraPosition> = [
    camera.CameraPosition.CAMERA_POSITION_UNSPECIFIED, camera.CameraPosition.CAMERA_POSITION_BACK,
    camera.CameraPosition.CAMERA_POSITION_FRONT, camera.CameraPosition.CAMERA_POSITION_FOLD_INNER
  ];
  private  mediaType: Array<cameraPicker.PickerMediaType> = [
    cameraPicker.PickerMediaType.PHOTO, cameraPicker.PickerMediaType.VIDEO
  ];

  selectImage(type:number) {
    fileSelect().then((uri: string) => {
      if (type == 1) {
        this.imageUri = uri || '';
        console.log("打印选取image===>"+JSON.stringify(this.imageUri))
        this.travelCard_f_img = this.imageUri
        this.putObject(this.travelCard_f_img,2)
        hide()
      }else if (type == 2){
        this.imageUri = uri || '';
        console.log("打印选取image===>"+JSON.stringify(this.imageUri))
        this.personCarGroupPhoto = this.imageUri
        this.putObject(this.personCarGroupPhoto,3)
        hide()
      }

    });
  }
  //
  openPhotos(type:number){
    cameraSelect(this.cameraPosition,this.mediaType,getContext(this)).then((uri: string) => {
      if (type == 1) {
        this.imageUri = uri || '';
        console.log("打印拍照image===>"+JSON.stringify(this.imageUri))
        this.travelCard_f_img = this.imageUri
        this.putObject(this.travelCard_f_img,2)
        hide()
      }else if (type == 2){
        this.imageUri = uri || '';
        console.log("打印拍照image===>"+JSON.stringify(this.imageUri))
        this.personCarGroupPhoto = this.imageUri
        this.putObject(this.personCarGroupPhoto,3)
        hide()
      }

    });
  }

  @Builder TitleBars(){
    Column(){
      TitleBar({ model: $model1 })
    }

  }


  aboutToAppear(): void {
    for (let index = 0; index < this.EnumPlateColor.length; index++) {
      this.newEnumPlateColor[index] = this.EnumPlateColor[index].name
    }

    for (let i = 0; i <this.EnumTypeOfEnergy.length; i++) {
      this.newEnumTypeOfEnergy[i] = this.EnumTypeOfEnergy[i].name
    }
    console.log("33333==>"+JSON.stringify(this.newEnumPlateColor))
    console.log("44444==>"+JSON.stringify(this.newEnumTypeOfEnergy))
    //查询数据
    this.inquireTravelCardData()
  }

  //查询行驶证信息数据->回显
  async inquireTravelCardData(){
    LoadingUtils.showLoading("加载中...")
    let res = await Api.net().getDriverInfoDrivingLicense();
    if (res.isSuccessWithData()) {
      this.inquireTravelCard =  res.data as InquireTravelCardModel
      if (this.inquireTravelCard.statusCode == 200) {
        LoadingUtils.hideLoading()
        if (this.inquireTravelCard.data.Info) {
          //回显数据赋值
          this.travelCard_z_img = this.inquireTravelCard.data.Info?.VehicleCardPageUrl
          this.travelCard_f_img = this.inquireTravelCard.data.Info?.VehicleCardSidePageUrl
          this.personCarGroupPhoto = this.inquireTravelCard.data.Info?.VehiclePictureUrl
          this.licensePlateNumber = this.inquireTravelCard.data.Info?.CarNumber
          this.bodyColor = this.inquireTravelCard.data.Info?.Color
          this.licensePlateColor =  EnumSurveyVehiclePlateColor.getNameByCode(this.inquireTravelCard.data.Info?.PlateColor.toString())
          this.vehicleModel = this.inquireTravelCard.data.Info?.MotorcycleType
          this.vehicleBrand = this.inquireTravelCard.data.Info?.Brand
          this.typeOfEnergy =  EnumTypeOfEnergy.getNameByCode(this.inquireTravelCard.data.Info?.EnergyType.toString())
          this.registrationDate = (this.inquireTravelCard.data.Info?.LicenseRegDate).split(" ")[0]
          this.AnnualReviewDate = (this.inquireTravelCard.data.Info?.InspectAnnuallyDate).split(" ")[0]
          this.expirationDate = (this.inquireTravelCard.data.Info?.VehicleCardExpiryDate).split(" ")[0]
        }
      }else{
        LoadingUtils.hideLoading()
        showToast(this.inquireTravelCard.message)
      }
    }else{
      LoadingUtils.hideLoading()
      showToast(res.message)
    }
  }


  //填写信息数据提交
  async submitTravelCardData(){
    if (!this.travelCard_z_img) {
      showToast("请上传行驶证图片信息")
      return
    }
    if (!this.travelCard_f_img) {
      showToast("请上传行驶证副页图片信息")
      return
    }
    if (!this.personCarGroupPhoto) {
      showToast("请上传车辆图片信息")
      return
    }
    if (!this.licensePlateNumber) {
      showToast("请填写车牌号信息")
      return
    }
    if (!this.bodyColor) {
      showToast("请填写车身颜色信息")
      return
    }
    if (!this.licensePlateColor) {
      showToast("请填写车牌颜色信息")
      return
    }
    if (!this.vehicleModel) {
      showToast("请填写车辆型号信息")
      return
    }
    if (!this.vehicleBrand) {
      showToast("请填写车辆品牌信息")
      return
    }
    if (!this.typeOfEnergy) {
      showToast("请填写能源类型信息")
      return
    }
    if (!this.registrationDate) {
      showToast("请填写车辆注册日期信息")
      return
    }
    if (!this.AnnualReviewDate) {
      showToast("请填写年审日期信息")
      return
    }
    if (!this.expirationDate) {
      showToast("请填写过期信息")
      return
    }
    LoadingUtils.showLoading("加载中...")
    this.submitTravelCard.VehicleCardPageUrl = this.travelCard_z_img
    this.submitTravelCard.VehicleCardSidePageUrl = this.travelCard_f_img
    this.submitTravelCard.VehiclePictureUrl = this.personCarGroupPhoto
    this.submitTravelCard.CarNumber = this.licensePlateNumber
    this.submitTravelCard.Color = this.bodyColor
    this.submitTravelCard.PlateColor = this.licensePlateColor
    this.submitTravelCard.MotorcycleType = this.vehicleModel
    this.submitTravelCard.Brand = this.vehicleBrand
    this.submitTravelCard.EnergyType = this.typeOfEnergy
    this.submitTravelCard.LicenseRegDate = this.registrationDate
    this.submitTravelCard.InspectAnnuallyDate = this.AnnualReviewDate
    this.submitTravelCard.VehicleCardExpiryDate = this.expirationDate
    console.log("打印提交数据JSON===>"+JSON.stringify(this.submitTravelCard))
    let res = await Api.net().postSaveDriverInfoByDrivingLicense(this.submitTravelCard);
    if (res.isSuccessWithData()) { //200
      if (res.data?.statusCode == 200) {
        LoadingUtils.hideLoading()
        showToast("保存成功")
        //TODO:下一步操作 注册:next页面 补齐: finish 具体分析
        if (MMKV.defaultMMKV().decodeString('TARGET') === 'Target') {
          router.pushUrl({
            url:'pages/Pages_CompletionVehicleLicense'
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
        this.travelCard_z_img = imageUrl
      }
      console.log(`图片地址 === ` + imageUrl)
      console.log(`图片地址 === ` + JSON.stringify(result))
    }else if (type == 2){
      //上传
      const result = await putObject(uri ,fileType ,SignatureUrl ,fileName)
      const imageUrl = `${NetConstants.OSSPoint}/${fileName}`;
      if (imageUrl) {
        this.travelCard_f_img = imageUrl
      }
      console.log(`图片地址 === ` + imageUrl)
      console.log(`图片地址 === ` + JSON.stringify(result))
    }else if (type == 3){
      //上传
      const result = await putObject(uri ,fileType ,SignatureUrl ,fileName)
      const imageUrl = `${NetConstants.OSSPoint}/${fileName}`;
      if (imageUrl) {
        this.personCarGroupPhoto = imageUrl
      }
      console.log(`图片地址 === ` + imageUrl)
      console.log(`图片地址 === ` + JSON.stringify(result))
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
                Image(this.travelCard_z_img)
                  .width(150)
                  .height(83)
                  .alt($r('app.media.travel'))
                  .onClick(()=>{
                    this.showFrontCard = true
                  })
                Image(this.travelCard_f_img)
                  .width(155)
                  .height(83)
                  .alt($r('app.media.travelcard_f'))
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
                Image(this.personCarGroupPhoto)
                  .width(160)
                  .height(86)
                  .alt($r('app.media.car_photo_icon'))
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
                          this.openPhotos(2)
                        }else if (position == 1){//相册
                          this.selectImage(2)

                        }
                      }
                    })
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

                  TextInput({ placeholder: "请输入" ,text:this.bodyColor})
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

                  TextInput({ placeholder: "请输入",text:this.vehicleModel})
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

                  TextInput({ placeholder: "请输入" ,text:this.vehicleBrand})
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
                    Text(this.registrationDate ? this.registrationDate : "请选择")
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
              .onClick(()=>{
                this.submitTravelCardData()
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

      if (this.showFrontCard){
        // 行驶证
        CardRecognition({
          supportType: CardType.CARD_VEHICLE_LICENSE,
          // 行驶证可双面识别
          cardSide: CardSide.FRONT,
          cardRecognitionConfig: {
            defaultShootingMode: ShootingMode.MANUAL,
            isPhotoSelectionSupported: true
          },
          callback: ((params: CallbackParam) => {
            if (params.code == 200) {
              console.log("行驶证信息返回=====>"+JSON.stringify(params.cardInfo?.front))
              if (params.cardInfo?.front !== undefined) {
                this.travelCardFrontData = params.cardInfo?.front
                this.licensePlateNumber = this.travelCardFrontData.licensePlateNumber
                this.vehicleModel = this.travelCardFrontData.model
                this.travelCard_z_img = this.travelCardFrontData.cardImageUri
                if (this.travelCard_z_img){
                  this.putObject(this.travelCard_z_img,1)
                }
                if (this.travelCardFrontData.registerDate) {//车辆注册日期
                  const dateParts = this.travelCardFrontData.registerDate.split('-')
                  if (dateParts.length === 3) {
                    const year = dateParts[0]
                    const month = dateParts[1]
                    const day = dateParts[2]
                    const newStartDate = new Date(`${year}/${month}/${day}`)
                    this.registrationDate = DateUtils.formatDate(newStartDate, "yyyy/MM/dd")
                    this.AnnualReviewDate = DateUtils.formatDate(newStartDate, "yyyy/MM/dd")
                  }
                }
              }
            }
          })
        })
      }

    }
    .height('100%')
    .width('100%')
    .backgroundColor($r("app.color.system_background_color"))
  }
}