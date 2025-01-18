
import { MMKV } from '@tencent/mmkv';
import { showToast } from 'base';
import { NetConstants } from 'base/src/main/ets/constants/NetConstants';
import { Data } from 'base/src/main/ets/viewmodel/OrderTaskModel';
import { OrderQrCodeModel } from '../viewmodel/OrderQrCodeModel';

@CustomDialog
export struct QRCodeDialog{

  @State QrUrl :string =""
  @State content :string =""
  @Link itemData :Data
  @State qrCodeBean :OrderQrCodeModel = new OrderQrCodeModel()


  controller: CustomDialogController = new CustomDialogController({
    builder: QRCodeDialog({
      itemData : this.itemData
    }),
  })

  aboutToAppear(): void {
    const userId =   MMKV.defaultMMKV().decodeString("USER_ID")
    const userName =   MMKV.defaultMMKV().decodeString("NAME")
    this.qrCodeBean.shiftId = this.itemData.ShiftId
    this.qrCodeBean.goTime = this.itemData.GoTime
    this.qrCodeBean.startCity = this.itemData.StartCity
    this.qrCodeBean.endCity = this.itemData.EndCity
    let jsonString: string = JSON.stringify(this.qrCodeBean);
    this.QrUrl = NetConstants.QR_BASE_URL + `/customLine/pages/index/index?type=4&id=${userId}&name=${userName?.charAt(0)}师傅&orderinfo=${jsonString}`
  }


  build() {

    Stack(){

      Column({space:30}){
        QRCode(this.QrUrl)
          .backgroundColor(Color.Transparent)
          .width(200)
          .height(200)

        Button("打开微信")
          .type(ButtonType.Normal)
          .fontColor($r("app.color.white"))
          .fontSize(14)
          .width('70%')
          .borderRadius(8)
          .backgroundColor($r("app.color.button_qr_code_bg"))
          .onClick(()=>{
            showToast("跳转微信小程序")
          })
      }
      .width('100%')
      .padding(20)
      .backgroundColor($r('app.color.white'))
      .alignItems(HorizontalAlign.Center)
      .justifyContent(FlexAlign.Center)




    }
    .borderRadius(10)
    .backgroundColor("#4D000000")//黑色背景 透明度约为 30%
  }
}