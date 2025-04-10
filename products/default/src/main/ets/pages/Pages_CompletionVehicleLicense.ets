import { TitleBar } from '@smarthane/titlebar';
import { router } from '@kit.ArkUI';
import { EnumScopeOfBusiness } from '../enum/EnumScopeOfBusiness';
import { EnumOwnership } from '../enum/EnumOwnership';
import { Api, DateUtils, EventBus, LoadingUtils, NetConstants } from 'base';
import { hide, showDialogBottomList, showToast } from '@abner/dialog';
import { camera, cameraPicker } from '@kit.CameraKit';
import { cameraSelect, fileSelect } from '../utils/Camerautils';
import { InquireVehicleLicenseModel } from 'base/src/main/ets/viewmodel/InquireVehicleLicenseModel';
import { SubmitVehicleLicenseModel } from 'base/src/main/ets/viewmodel/SubmitVehicleLicenseModel';
import { MMKV } from '@tencent/mmkv';
import { putObject } from '../utils/upload';

interface SendFlushedModule {
  name: string
}
/**
 *
 */
@Entry
@Component
struct Pages_CompletionVehicleLicense {
  @State title: string = '营运证信息录入';
  //titleBar组件
  @State model1: TitleBar.Model = new TitleBar.Model()
    .setOnLeftClickListener(() => {
      router.back()
    })
    .setTitleName(this.title)
    .setTitleFontColor($r("app.color.text_color1"))
  scroller: Scroller = new Scroller()
  selectedDate: Date = new Date()
  selectSignageStartDate: Date = new Date()
  selectSignageEndDate: Date = new Date()
  selectExpirationDate: Date = new Date()
  selectExpiration_Date: Date = new Date()
  @State enumScopeOfBusiness:EnumScopeOfBusiness[] =EnumScopeOfBusiness.values()//经营范围枚举类
  @State enumOwnership:EnumOwnership[] =EnumOwnership.values() //所有制枚举类
  @State qualification:string[] =["是","否"] //是否具备客运资格 枚举类
  @State vehicleLicenseQualificationNumber :string =""//车证资格证号-->赋值
  @State issuingAuthority :string =""//发证机构-->赋值
  @State areaCode :string =""//区域代码-->赋值
  @State scopeOfBusiness :string =""//经营范围-->赋值 提交时枚举转换类型
  @State newEnumScopeOfBusiness:string[] =[]
  private selectScopeOfBusiness: number | number[] = 0
  private selectQualification: number | number[] = 0
  @State carSeats :string =""//车座位-->赋值
  @State markingTheGradeNumber :string =""//标志牌号-->赋值
  @State ownership :string =""//所有制-->赋值 提交时枚举转换类型
  @State newEnumOwnership:string[] = []
  private selectOwnership :number | number[] = 0
  @State vehicleTypeClass :string =""//车辆类型等级-->赋值
  @State signageDateStart :string =""//标志牌日期起-->赋值
  @State signDateEnds :string =""//标志牌日期止-->赋值
  @State expirationDate :string =""//有效期止-->赋值
  @State qualificationCertificate :string =""//人证资格证号-->赋值
  @State passengerTransportQualifications :string =""//是否具备客运资格-->赋值 提交时枚举转换类型
  @State qualificationCertificateExpirationDate :string =""//有效期止-->赋值

  @State vehicleLicense_z_img :string =""
  @State vehicleLicense_f_img :string =""

  @State inquireVehicleLicense:InquireVehicleLicenseModel= new InquireVehicleLicenseModel()
  @State submitVehicleLicense:SubmitVehicleLicenseModel= new SubmitVehicleLicenseModel()

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
        console.log("打印选取image===>"+JSON.stringify(this.imageUri))
        // this.vehicleLicense_z_img = this.imageUri
        this.putObject(this.imageUri,1)
        hide()
      }else if (type == 2){
        this.imageUri = uri || '';
        console.log("打印选取image===>"+JSON.stringify(this.imageUri))
        // this.vehicleLicense_f_img = this.imageUri
        this.putObject(this.imageUri,2)
        hide()
      }

    });
  }
  //相机拍照
  openPhotos(type:number){
    cameraSelect(this.cameraPosition,this.mediaType,getContext(this)).then((uri: string) => {
      if (type == 1) {
        this.imageUri = uri || '';
        console.log("打印拍照image===>"+JSON.stringify(this.imageUri))
        // this.vehicleLicense_z_img = this.imageUri
        this.putObject(this.imageUri,1)
        hide()
      }else if (type == 2){
        this.imageUri = uri || '';
        console.log("打印拍照image===>"+JSON.stringify(this.imageUri))
        // this.vehicleLicense_f_img = this.imageUri
        this.putObject(this.imageUri,2)
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
    for (let index = 0; index < this.enumScopeOfBusiness.length; index++) {
      this.newEnumScopeOfBusiness[index] = this.enumScopeOfBusiness[index].name
    }
    for (let i = 0; i < this.enumOwnership.length; i++) {
      this.newEnumOwnership[i] = this.enumOwnership[i].name
    }
    console.log("222===>" + JSON.stringify(this.newEnumScopeOfBusiness))
    console.log("111===>" + JSON.stringify(this.newEnumOwnership))
    //查询数据
    this.inquireVehicleLicenseData()
  }

  //查询数据回显
  async inquireVehicleLicenseData(){
    LoadingUtils.showLoading("加载中...")
    let res = await Api.net().getDriverInfoByCarInfo();
    if (res.isSuccessWithData()) {
     this.inquireVehicleLicense =  res.data as InquireVehicleLicenseModel
      if (this.inquireVehicleLicense.statusCode == 200) {
        LoadingUtils.hideLoading()
        if (this.inquireVehicleLicense.data.Info) {
          //回显数据赋值
          this.vehicleLicense_z_img = this.inquireVehicleLicense.data.Info?.TaxiLicensePhoto
          this.vehicleLicense_f_img = this.inquireVehicleLicense.data.Info?.QualificationCertificatePhoto
          this.vehicleLicenseQualificationNumber = this.inquireVehicleLicense.data.Info?.TransportCertsNumber
          this.issuingAuthority = this.inquireVehicleLicense.data.Info?.TransportCertsOwner
          this.areaCode = this.inquireVehicleLicense.data.Info?.TransportCertsIssuer
          this.scopeOfBusiness= this.inquireVehicleLicense.data.Info?.BusinessScope
          this.carSeats= (this.inquireVehicleLicense.data.Info?.Seats).toString()
          this.markingTheGradeNumber= this.inquireVehicleLicense.data.Info?.SignsNmber
          this.ownership= EnumOwnership.getNameByCode(this.inquireVehicleLicense.data.Info?.Ownership.toString())
          this.vehicleTypeClass= this.inquireVehicleLicense.data.Info?.TypeLevel
          this.signageDateStart= (this.inquireVehicleLicense.data.Info?.SignsDateStart).split(" ")[0]
          this.signDateEnds= (this.inquireVehicleLicense.data.Info?.SignsDateEnd).split(" ")[0]
          this.expirationDate= (this.inquireVehicleLicense.data.Info?.TaxiLicenseExpiryDate).split(" ")[0]
          this.qualificationCertificate= this.inquireVehicleLicense.data.Info?.LicenseNumber
          this.passengerTransportQualifications= this.inquireVehicleLicense.data.Info?.LicensePassengerTrans ? "是" :"否"
          this.qualificationCertificateExpirationDate= (this.inquireVehicleLicense.data.Info?.QualificationCertificateExpiryDate).split(" ")[0]
        }
      }else{
        LoadingUtils.hideLoading()
        showToast(this.inquireVehicleLicense.message)
      }
    }else{
      LoadingUtils.hideLoading()
      showToast(res.message)
    }
  }


  //提交数据
  async submitVehicleLicenseData(){
    //判断入参数据
    if (!this.vehicleLicense_z_img) {
      showToast("请上传营运证(车证)图片信息")
      return
    }
    if ( !this.vehicleLicense_f_img ) {
      showToast("请上传从业资格证(认证)图片信息")
      return
    }
    if (!this.scopeOfBusiness ) {
      showToast("请选择经营范围信息")
      return
    }
    if ( !this.carSeats ) {
      showToast("请填写车座位信息")
      return
    }
    if (!this.markingTheGradeNumber) {
      showToast("请填写标志牌号信息")
      return
    }
    if (!this.ownership) {
      showToast("请选择所有制信息")
      return
    }
    if (!this.vehicleTypeClass) {
      showToast("请填写车辆类型等级信息")
      return
    }
    if (!this.signageDateStart ) {
      showToast("请选择标志牌日期起信息")
      return
    }
    if (!this.signDateEnds ) {
      showToast("请选择标志牌日期止信息")
      return
    }
    if (!this.expirationDate ) {
      showToast("请选择营运证有效期止信息")
      return
    }
    if (!this.qualificationCertificate ) {
      showToast("请填写人证资格证号信息")
      return
    }
    if (!this.passengerTransportQualifications) {
      showToast("请选择客运资格信息")
      return
    }
    if (!this.qualificationCertificateExpirationDate) {
      showToast("请选择人证有效期止信息")
      return
    }
    this.submitVehicleLicense.TaxiLicensePhoto = this.vehicleLicense_z_img
    this.submitVehicleLicense.QualificationCertificatePhoto = this.vehicleLicense_f_img
    this.submitVehicleLicense.TransportCertsNumber = this.vehicleLicenseQualificationNumber
    this.submitVehicleLicense.TransportCertsOwner = this.issuingAuthority
    this.submitVehicleLicense.TransportCertsIssuer = this.areaCode
    this.submitVehicleLicense.BusinessScope = this.scopeOfBusiness
    this.submitVehicleLicense.Seats = this.carSeats
    this.submitVehicleLicense.SignsNmber = this.markingTheGradeNumber
    this.submitVehicleLicense.Ownership = EnumOwnership.getCodeByName(this.ownership)
    this.submitVehicleLicense.TypeLevel = this.vehicleTypeClass
    this.submitVehicleLicense.SignsDateStart = this.signageDateStart
    this.submitVehicleLicense.SignsDateEnd = this.signDateEnds
    this.submitVehicleLicense.TaxiLicenseExpiryDate = this.expirationDate
    this.submitVehicleLicense.LicenseNumber = this.qualificationCertificate
    this.submitVehicleLicense.LicensePassengerTrans =  this.passengerTransportQualifications == "是" ? true : false
    this.submitVehicleLicense.QualificationCertificateExpiryDate = this.qualificationCertificateExpirationDate
    console.log("打印提交数据JSON===>"+JSON.stringify(this.submitVehicleLicense))
    let res = await Api.net().postSaveDriverInfoByCarInfo(this.submitVehicleLicense);
    if (res.isSuccessWithData()) { //200
      if (res.data?.statusCode == 200) {
        LoadingUtils.hideLoading()
        showToast("保存成功")
        //TODO:下一步操作 注册:next页面 补齐: finish 具体分析
        if (MMKV.defaultMMKV().decodeString('TARGET') === 'Target') {
          router.pushUrl({
            url:'pages/Pages_CompulsoryTrafficInsurance'
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
        this.vehicleLicense_z_img = imageUrl
      }
      console.log(`图片地址 === ` + imageUrl)
      console.log(`图片地址 === ` + JSON.stringify(result))
    }else if (type == 2){
      //上传
      const result = await putObject(uri ,fileType ,SignatureUrl ,fileName)
      const imageUrl = `${NetConstants.OSSPoint}/${fileName}`;
      if (imageUrl) {
        this.vehicleLicense_f_img = imageUrl
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
                Text("营运证信息(车证)")
                  .fontColor($r('app.color.text_color1'))
                  .fontSize(14)
                  .layoutWeight(1)

              }
              .padding(5)

              Row({ space: 10 }) {
                Image(this.vehicleLicense_z_img)
                  .layoutWeight(1)
                  .alt($r('app.media.new_carcard'))
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
                //车证资格证号
                Row() {
                  Row({ space: 5 }) {
                    Text('车证资格证号')
                      .fontColor($r('app.color.text_color1'))
                      .fontSize(14)
                  }
                  .margin({ left: 10 })
                  .alignItems(VerticalAlign.Center)

                  TextInput({ placeholder: "请输入" ,text:this.vehicleLicenseQualificationNumber})
                    .placeholderFont({ size: 13 })
                    .type(InputType.Normal)
                    .backgroundColor(Color.Transparent)
                    .fontColor($r('app.color.text_color1'))
                    .fontSize(13)
                    .textAlign(TextAlign.End)
                    .layoutWeight(1)
                    .onChange((value)=>{
                      this.vehicleLicenseQualificationNumber = value
                    })

                }

                Divider()
                  .height(1)
                  .margin({ left: 20, right: 20 })
                  .backgroundColor($r('app.color.layout_dividing_lines_bg_color'))
                //发证机构
                Row() {
                  Row({ space: 5 }) {
                    Text('发证机构')
                      .fontColor($r('app.color.text_color1'))
                      .fontSize(14)
                  }
                  .margin({ left: 10 })
                  .alignItems(VerticalAlign.Center)

                  TextInput({ placeholder: "请输入" ,text: this.issuingAuthority? this.issuingAuthority :""})
                    .placeholderFont({ size: 13 })
                    .type(InputType.Normal)
                    .backgroundColor(Color.Transparent)
                    .fontColor($r('app.color.text_color1'))
                    .fontSize(13)
                    .textAlign(TextAlign.End)
                    .layoutWeight(1)
                    .onChange((value)=>{
                      this.issuingAuthority = value
                    })

                }

                Divider()
                  .height(1)
                  .margin({ left: 20, right: 20 })
                  .backgroundColor($r('app.color.layout_dividing_lines_bg_color'))
                //核发机关行政区域代码
                Row() {
                  Row() {
                    Text('核发机关行政区域代码')
                      .fontColor($r('app.color.text_color1'))
                      .fontSize(14)
                      .margin({left:5})
                  }
                  .alignItems(VerticalAlign.Center)

                  TextInput({ placeholder: "请输入",text:this.areaCode ? this.areaCode : "" })
                    .placeholderFont({ size: 13 })
                    .type(InputType.Normal)
                    .backgroundColor(Color.Transparent)
                    .fontColor($r('app.color.text_color1'))
                    .fontSize(13)
                    .textAlign(TextAlign.End)
                    .layoutWeight(1)
                    .onChange((value)=>{
                      this.areaCode = value
                    })

                }


                Divider()
                  .height(1)
                  .margin({ left: 20, right: 20 })
                  .backgroundColor($r('app.color.layout_dividing_lines_bg_color'))

                //经营范围
                Row() {
                  Row({ space: 5 }) {
                    Text("*")
                      .fontColor($r('app.color.title_required_text_color'))
                      .fontSize(13)
                    Text('经营范围')
                      .fontColor($r('app.color.text_color1'))
                      .fontSize(14)
                  }
                  .layoutWeight(1)
                  .alignItems(VerticalAlign.Center)

                  Row({ space: 3 }) {
                    Text(this.scopeOfBusiness ? this.scopeOfBusiness : "请选择")
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
                      range: this.newEnumScopeOfBusiness,
                      selected: this.selectScopeOfBusiness,
                      onAccept: (value: TextPickerResult) => {
                        // 当弹窗再次弹出时显示选中的是上一次确定的选项
                        this.selectScopeOfBusiness = value.index
                        console.log(this.selectScopeOfBusiness + '')
                        // 点击确定后，被选到的文本数据展示到页面 {"value":"黄色","index":1}
                        this.scopeOfBusiness = value.value as string
                      }
                    })
                  })

                }
                .padding(8)

                Divider()
                  .height(1)
                  .margin({ left: 20, right: 20 })
                  .backgroundColor($r('app.color.layout_dividing_lines_bg_color'))

                //车座位
                Row() {
                  Row({ space: 5 }) {
                    Text("*")
                      .fontColor($r('app.color.title_required_text_color'))
                      .fontSize(13)
                    Text('车座位')
                      .fontColor($r('app.color.text_color1'))
                      .fontSize(14)
                  }
                  .margin({ left: 10 })
                  .layoutWeight(1)
                  .alignItems(VerticalAlign.Center)

                  TextInput({ placeholder: "请输入",text:this.carSeats ? this.carSeats : ""})
                    .placeholderFont({ size: 13 })
                    .type(InputType.Normal)
                    .backgroundColor(Color.Transparent)
                    .fontColor($r('app.color.text_color1'))
                    .fontSize(13)
                    .textAlign(TextAlign.End)
                    .layoutWeight(1)
                    .onChange((value)=>{
                      this.carSeats = value
                    })

                }

                Divider()
                  .height(1)
                  .margin({ left: 20, right: 20 })
                  .backgroundColor($r('app.color.layout_dividing_lines_bg_color'))

                //标志牌号
                Row() {
                  Row({ space: 5 }) {
                    Text("*")
                      .fontColor($r('app.color.title_required_text_color'))
                      .fontSize(13)
                    Text('标志牌号')
                      .fontColor($r('app.color.text_color1'))
                      .fontSize(14)
                  }
                  .margin({left:10})
                  .alignItems(VerticalAlign.Center)

                  TextInput({ placeholder: "请输入" ,text:this.markingTheGradeNumber ?this.markingTheGradeNumber : ""})
                    .placeholderFont({ size: 13 })
                    .type(InputType.Normal)
                    .backgroundColor(Color.Transparent)
                    .fontColor($r('app.color.text_color1'))
                    .fontSize(13)
                    .textAlign(TextAlign.End)
                    .layoutWeight(1)
                    .onChange((value)=>{
                      this.markingTheGradeNumber = value
                    })

                }

                Divider()
                  .height(1)
                  .margin({ left: 20, right: 20 })
                  .backgroundColor($r('app.color.layout_dividing_lines_bg_color'))

                //所有制
                Row() {
                  Row({ space: 5 }) {
                    Text("*")
                      .fontColor($r('app.color.title_required_text_color'))
                      .fontSize(13)
                    Text('所有制')
                      .fontColor($r('app.color.text_color1'))
                      .fontSize(14)
                  }
                  .layoutWeight(1)
                  .alignItems(VerticalAlign.Center)

                  Row({ space: 3 }) {
                    Text(this.ownership ? this.ownership : "请选择")
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
                      range: this.newEnumOwnership,
                      selected: this.selectOwnership,
                      onAccept: (value: TextPickerResult) => {
                        // 当弹窗再次弹出时显示选中的是上一次确定的选项
                        this.selectOwnership = value.index
                        console.log(this.selectOwnership + '')
                        // 点击确定后，被选到的文本数据展示到页面 {"value":"黄色","index":1}
                        this.ownership = value.value as string
                      }
                    })
                  })
                }
                .padding(8)

                Divider()
                  .height(1)
                  .margin({ left: 20, right: 20 })
                  .backgroundColor($r('app.color.layout_dividing_lines_bg_color'))

                //车辆类型等级
                Row() {
                  Row({ space: 5 }) {
                    Text("*")
                      .fontColor($r('app.color.title_required_text_color'))
                      .fontSize(13)
                    Text('车辆类型等级')
                      .fontColor($r('app.color.text_color1'))
                      .fontSize(14)
                  }
                  .margin({left:10})
                  .layoutWeight(1)
                  .alignItems(VerticalAlign.Center)

                  TextInput({ placeholder: "请输入",text:this.vehicleTypeClass ?this.vehicleTypeClass: "" })
                    .placeholderFont({ size: 13 })
                    .type(InputType.Normal)
                    .backgroundColor(Color.Transparent)
                    .fontColor($r('app.color.text_color1'))
                    .fontSize(13)
                    .textAlign(TextAlign.End)
                    .layoutWeight(1)
                    .onChange((value)=>{
                      this.vehicleTypeClass =value
                    })
                }

                Divider()
                  .height(1)
                  .margin({ left: 20, right: 20 })
                  .backgroundColor($r('app.color.layout_dividing_lines_bg_color'))
                //标志牌日期起
                Row() {
                  Row({ space: 5 }) {
                    Text("*")
                      .fontColor($r('app.color.title_required_text_color'))
                      .fontSize(13)
                    Text('标志牌日期起')
                      .fontColor($r('app.color.text_color1'))
                      .fontSize(14)
                  }
                  .layoutWeight(1)
                  .alignItems(VerticalAlign.Center)

                  Row({ space: 3 }) {
                    Text(this.signageDateStart ? this.signageDateStart : "请选择")
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
                      selected: this.selectSignageStartDate,
                      onDateAccept: (value: Date) => {
                        //当弹窗再次弹出时显示选中的是上一次确定的日期
                        this.selectSignageStartDate = value
                        this.signageDateStart = DateUtils.formatDate(value,"yyyy-MM-dd")
                      }
                    })
                  })

                }
                .padding(8)

                Divider()
                  .height(1)
                  .margin({ left: 20, right: 20 })
                  .backgroundColor($r('app.color.layout_dividing_lines_bg_color'))
                //标志牌日期止
                Row() {
                  Row({ space: 5 }) {
                    Text("*")
                      .fontColor($r('app.color.title_required_text_color'))
                      .fontSize(13)
                    Text('标志牌日期止')
                      .fontColor($r('app.color.text_color1'))
                      .fontSize(14)
                  }
                  .layoutWeight(1)
                  .alignItems(VerticalAlign.Center)

                  Row({ space: 3 }) {
                    Text(this.signDateEnds ? this.signDateEnds : "请选择")
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
                      selected: this.selectSignageEndDate,
                      onDateAccept: (value: Date) => {
                        //当弹窗再次弹出时显示选中的是上一次确定的日期
                        this.selectSignageEndDate = value
                        this.signDateEnds = DateUtils.formatDate(value,"yyyy-MM-dd")
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
                      start: new Date("1949-1-1"),
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


              Row({ space: 10 }) {
                Text("从业资格证信息(人证)")
                  .fontColor($r('app.color.text_color1'))
                  .fontSize(14)
                  .layoutWeight(1)

              }
              .padding(5)

              Row({ space: 10 }) {
                Image(this.vehicleLicense_f_img)
                  .layoutWeight(1)
                  .height(160)
                  .alt($r('app.media.new_carcard2'))
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
              }
              .padding(5)

              //输入项
              Column({ space: 5 }) {
                //人证资格证号
                Row() {
                  Row({ space: 5 }) {
                    Text("*")
                      .fontColor($r('app.color.title_required_text_color'))
                      .fontSize(13)
                    Text('人证资格证号')
                      .fontColor($r('app.color.text_color1'))
                      .fontSize(14)
                  }
                  .margin({ left: 10 })
                  .alignItems(VerticalAlign.Center)

                  TextInput({ placeholder: "请输入",text:this.qualificationCertificate ? this.qualificationCertificate :"" })
                    .placeholderFont({ size: 13 })
                    .type(InputType.Normal)
                    .backgroundColor(Color.Transparent)
                    .fontColor($r('app.color.text_color1'))
                    .fontSize(13)
                    .textAlign(TextAlign.End)
                    .layoutWeight(1)
                    .onChange((value)=>{
                      this.qualificationCertificate = value
                    })

                }

                Divider()
                  .height(1)
                  .margin({ left: 20, right: 20 })
                  .backgroundColor($r('app.color.layout_dividing_lines_bg_color'))
                //是否具备客运资格
                Row() {
                  Row({ space: 5 }) {
                    Text("*")
                      .fontColor($r('app.color.title_required_text_color'))
                      .fontSize(13)
                    Text('是否具备客运资格')
                      .fontColor($r('app.color.text_color1'))
                      .fontSize(14)
                  }
                  .layoutWeight(1)
                  .alignItems(VerticalAlign.Center)

                  Row({ space: 3 }) {
                    Text(this.passengerTransportQualifications ? this.passengerTransportQualifications : "请选择")
                      .fontColor($r('app.color.text_h1'))
                      .fontSize(13)
                    Image($r('app.media.arrow_bottom'))
                      .width(15)
                      .height(15)
                      .padding(3)

                  }
                  .alignItems(VerticalAlign.Center)
                  .onClick(() => {
                    TextPickerDialog.show({
                      range: this.qualification,
                      selected: this.selectQualification,
                      onAccept: (value: TextPickerResult) => {
                        // 当弹窗再次弹出时显示选中的是上一次确定的选项
                        this.selectQualification = value.index
                        console.log(this.selectQualification + '')
                        // 点击确定后，被选到的文本数据展示到页面 {"value":"黄色","index":1}
                        this.passengerTransportQualifications = value.value as string
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
                    Text(this.qualificationCertificateExpirationDate ? this.qualificationCertificateExpirationDate : "请选择")
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
                      selected: this.selectExpiration_Date,
                      onDateAccept: (value: Date) => {
                        //当弹窗再次弹出时显示选中的是上一次确定的日期
                        this.selectExpiration_Date = value
                        this.qualificationCertificateExpirationDate = DateUtils.formatDate(value,"yyyy-MM-dd")
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
                // showToast("点击提交数据")
                this.submitVehicleLicenseData()
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