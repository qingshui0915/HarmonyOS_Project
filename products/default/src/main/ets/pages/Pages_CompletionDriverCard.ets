import { TitleBar } from '@smarthane/titlebar';
import { router } from '@kit.ArkUI';
import { Api, DateUtils, EventBus, LoadingUtils, NetConstants, showToast } from 'base';
import { CallbackParam, CardRecognition, CardSide, CardType, ShootingMode } from '@kit.VisionKit';
import { hide, showDialogBottomList } from '@abner/dialog';
import { camera, cameraPicker } from '@kit.CameraKit';
import { cameraSelect, fileSelect } from '../utils/Camerautils';
import { JSON } from '@kit.ArkTS';
import { InquireDriverCardModel } from 'base/src/main/ets/viewmodel/InquireDriverCardModel';
import { SubmitDriverCardModel } from 'base/src/main/ets/viewmodel/SubmitDriverCardModel';
import { putObject } from '../utils/upload';
import { MMKV } from '@tencent/mmkv';
import { UploadFiles } from '../utils/UploadFiles';


interface SendFlushedModule {
  name: string
}

@Entry
@Component
struct Pages_CompletionDriverCard {
  @State title: string = '驾驶证录入';
  //titleBar组件
  @State model1: TitleBar.Model = new TitleBar.Model()
    .setOnLeftClickListener(() => {
      router.back()
    })
    .setTitleName(this.title)
    .setTitleFontColor($r("app.color.text_color1"))
  selectedEndDate: Date = new Date()
  selectStartDate: Date = new Date()
  @State endDate :string =""
  @State startDate :string =""
  @State showFrontCard :boolean =false
  @State showBackCard :boolean =false
  @State driving_license_z_img:string = ""
  @State driving_license_f_img:string = ""
  @State quasiDrivingType:string = ""
  @State driverCardFrontData :Record<string, string> = {}
  @State cardBackData :Record<string, string> = {}

  @State inquireDriverCard:InquireDriverCardModel = new InquireDriverCardModel()
  @State submitDriverCard:SubmitDriverCardModel = new SubmitDriverCardModel()

  @State imageUri: Resource | string | undefined = undefined;
  private  cameraPosition: Array<camera.CameraPosition> = [
    camera.CameraPosition.CAMERA_POSITION_UNSPECIFIED, camera.CameraPosition.CAMERA_POSITION_BACK,
    camera.CameraPosition.CAMERA_POSITION_FRONT, camera.CameraPosition.CAMERA_POSITION_FOLD_INNER
  ];
  private  mediaType: Array<cameraPicker.PickerMediaType> = [
    cameraPicker.PickerMediaType.PHOTO, cameraPicker.PickerMediaType.VIDEO
  ];

  selectImage() {
    fileSelect().then((uri: string) => {
      this.imageUri = uri || '';
      console.log("打印选取image===>"+JSON.stringify(this.imageUri))
      this.driving_license_f_img = this.imageUri
      this.putObject(this.driving_license_f_img,2)
      hide()
    });
  }

  openPhotos(){
    cameraSelect(this.cameraPosition,this.mediaType,getContext(this)).then((uri: string) => {
      this.imageUri = uri || '';
      console.log("打印拍照image===>"+JSON.stringify(this.imageUri))
      this.driving_license_f_img = this.imageUri
      this.putObject(this.driving_license_f_img,2)
      hide()
    });
  }

  @Builder TitleBars(){
    Column(){
      TitleBar({ model: $model1 })
    }

  }





  //查询驾驶证信息数据->回显
  async inquireDriverCardData(){
    LoadingUtils.showLoading("加载中...")
    let res = await Api.net().getDriverInfoByDriver();
    if (res.isSuccessWithData()) {
      this.inquireDriverCard =  res.data as InquireDriverCardModel
      if (this.inquireDriverCard.statusCode == 200) {
        LoadingUtils.hideLoading()
        if (this.inquireDriverCard.data.Info) {
          //回显数据赋值
          this.driving_license_z_img = this.inquireDriverCard.data.Info?.DriverCardPageUrl
          this.driving_license_f_img = this.inquireDriverCard.data.Info?.DriverCardSidePageUrl
          this.quasiDrivingType = this.inquireDriverCard.data.Info?.ClassMode
          this.startDate = (this.inquireDriverCard.data.Info?.ValidStart).split(" ")[0]
          this.endDate = (this.inquireDriverCard.data.Info?.ValidEnd).split(" ")[0]
        }
      }else{
        LoadingUtils.hideLoading()
        showToast(this.inquireDriverCard.message)
      }
    }else{
      LoadingUtils.hideLoading()
      showToast(res.message)
    }
  }

  //提交填写信息
  async submitDriverCardData(){
    if (!this.driving_license_z_img) {
      showToast("请上传驾驶证图片信息")
      return
    }
    if (!this.driving_license_f_img) {
      showToast("请上传驾驶证副页图片信息")
      return
    }
    if (!this.quasiDrivingType) {
      showToast("请填写准驾车型信息")
      return
    }
    if (!this.startDate) {
      showToast("请填写有效期始信息")
      return
    }
    if (!this.endDate) {
      showToast("请填写有效期止信息")
      return
    }
    LoadingUtils.showLoading("加载中...")
    this.submitDriverCard.DriverCardPageUrl = this.driving_license_z_img
    this.submitDriverCard.DriverCardSidePageUrl = this.driving_license_f_img
    this.submitDriverCard.ClassMode = this.quasiDrivingType
    this.submitDriverCard.ValidStart = this.startDate
    this.submitDriverCard.ValidEnd = this.endDate
    console.log("打印提交数据JSON===>"+JSON.stringify(this.submitDriverCard))
    let res = await Api.net().postSaveDriverInfoByDriver(this.submitDriverCard);
    if (res.isSuccessWithData()) { //200
      if (res.data?.statusCode == 200) {
        LoadingUtils.hideLoading()
        showToast("保存成功")
        console.log("打印TARGET====>"+JSON.stringify(MMKV.defaultMMKV().decodeString('TARGET')))
        //TODO:下一步操作 注册:next页面 补齐: finish 具体分析
        if (MMKV.defaultMMKV().decodeString('TARGET') == 'Target') {
          router.pushUrl({
            url:'pages/Pages_CompletionTravelCard'
          })
        }else if (MMKV.defaultMMKV().decodeString('TARGET') == 'Null'){
          //测试发送事件
          let eventData: SendFlushedModule = {
            name: '补齐证件',
          }
          EventBus.send('SendFlushedModule', eventData)
          router.back()
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

  aboutToAppear(): void {
    //
    this.inquireDriverCardData()
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
        this.driving_license_z_img = imageUrl
      }
      console.log(`图片地址 === ` + imageUrl)
      console.log(`图片地址 === ` + JSON.stringify(result))
    }else if (type == 2){
      //上传
      const result = await putObject(uri ,fileType ,SignatureUrl ,fileName)
      const imageUrl = `${NetConstants.OSSPoint}/${fileName}`;
      if (imageUrl) {
        this.driving_license_f_img = imageUrl
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
                Text("驾驶证")
                  .fontColor($r('app.color.text_color1'))
                  .fontSize(14)
                  .layoutWeight(1)
                Text("驾驶证副页")
                  .fontColor($r('app.color.text_color1'))
                  .fontSize(14)
                  .layoutWeight(1)
              }
              .padding(5)
              .margin({top:10})
              Row({space:10}){
                Image(this.driving_license_z_img)
                  .width(150)
                  .height(83)
                  .alt($r('app.media.driver'))
                  .onClick(()=>{
                    this.showFrontCard = true
                  })
                Image(this.driving_license_f_img)
                  .width(150)
                  .height(83)
                  .alt($r('app.media.drivercard_f'))
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
                          this.openPhotos()

                        }else if (position == 1){//相册
                          this.selectImage()

                        }
                      }
                    })
                  })
              }
              .padding(5)
              //输入项
              Column({space:5}){
                //准驾车型
                Row(){
                  Row({space:5}){
                    Text("*")
                      .fontColor($r('app.color.title_required_text_color'))
                      .fontSize(13)
                    Text('准驾车型')
                      .fontColor($r('app.color.text_color1'))
                      .fontSize(14)
                  }
                  .margin({left:10})
                  .layoutWeight(1)
                  .alignItems(VerticalAlign.Center)

                  TextInput({placeholder:"请输入",text:this.quasiDrivingType})
                    .placeholderFont({size:13})
                    .type(InputType.Normal)
                    .backgroundColor(Color.Transparent)
                    .fontColor($r('app.color.text_color1'))
                    .fontSize(13)
                    .textAlign(TextAlign.End)
                    .layoutWeight(1)
                    .onChange((value)=>{
                      this.quasiDrivingType = value
                    })

                }
                Divider()
                  .height(1)
                  .margin({left:20,right:20})
                  .backgroundColor($r('app.color.layout_dividing_lines_bg_color'))
                //有效期始
                Row(){
                  Row({space:5}){
                    Text("*")
                      .fontColor($r('app.color.title_required_text_color'))
                      .fontSize(13)
                    Text('有效期始')
                      .fontColor($r('app.color.text_color1'))
                      .fontSize(14)
                  }
                  .layoutWeight(1)
                  .alignItems(VerticalAlign.Center)

                  Row({space:3}){
                    Text(this.startDate ? this.startDate : "请选择")
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
                      selected: this.selectStartDate,
                      onDateAccept: (value: Date) => {
                        //当弹窗再次弹出时显示选中的是上一次确定的日期
                        this.selectStartDate = value
                        this.startDate = DateUtils.formatDate(value,"yyyy-MM-dd")
                      }
                    })
                  })

                }
                .padding(8)
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
                    Text('有效期止')
                      .fontColor($r('app.color.text_color1'))
                      .fontSize(14)
                  }
                  .layoutWeight(1)
                  .alignItems(VerticalAlign.Center)
                  Row({space:3}){
                    Text(this.endDate ? this.endDate : "请选择")
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
                      selected: this.selectedEndDate,
                      onDateAccept: (value: Date) => {
                        //当弹窗再次弹出时显示选中的是上一次确定的日期
                        this.selectedEndDate = value
                        this.endDate = DateUtils.formatDate(value,"yyyy-MM-dd")
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
                this.submitDriverCardData()
              })
          }
        }
      }

      if (this.showFrontCard){
        CardRecognition({
          supportType: CardType.CARD_DRIVER_LICENSE,
          // 驾驶证可双面识别
          cardSide: CardSide.FRONT,
          cardRecognitionConfig: {
            defaultShootingMode: ShootingMode.MANUAL,
            isPhotoSelectionSupported: true
          },
          callback: ((params: CallbackParam) => {
            if (params.code == 200) {
              console.log("驾驶证===>"+JSON.stringify(params.cardInfo?.front))
              if (params.cardInfo?.front !== undefined) {
                this.driverCardFrontData = params.cardInfo?.front
                if (this.driverCardFrontData.carClass) {
                  this.quasiDrivingType = this.driverCardFrontData.carClass
                }
                if (this.driverCardFrontData.validPeriodStart) {
                  const dateParts = this.driverCardFrontData.validPeriodStart.split('-')
                  if (dateParts.length === 3) {
                    const year = dateParts[0]
                    const month = dateParts[1]
                    const day = dateParts[2]
                    const newStartDate = new Date(`${year}/${month}/${day}`)
                    this.startDate = DateUtils.formatDate(newStartDate, "yyyy/MM/dd")
                  }
                }
                if (this.driverCardFrontData.validPeriodEnd) {
                  const dateParts = this.driverCardFrontData.validPeriodStart.split('-')
                  if (dateParts.length === 3) {
                    const year = dateParts[0]
                    const month = dateParts[1]
                    const day = dateParts[2]
                    const newEndDate = new Date(`${year}/${month}/${day}`)
                    this.endDate = DateUtils.formatDate(newEndDate, "yyyy/MM/dd")
                  }
                }
                if (this.driverCardFrontData.cardImageUri) {
                  this.driving_license_z_img = this.driverCardFrontData.cardImageUri
                  this.putObject(this.driving_license_z_img,1)
                }
              }
              this.showFrontCard = false
            }else{
              this.showFrontCard = false
              showToast("识别错误,请重试")
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