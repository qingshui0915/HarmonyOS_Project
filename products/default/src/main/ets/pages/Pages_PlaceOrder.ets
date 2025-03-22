import { TitleBar } from '@smarthane/titlebar'
import { componentSnapshot, promptAction, router } from '@kit.ArkUI';
import { NetConstants, showToast } from 'base';
import { MMKV } from "@tencent/mmkv/src/main/ets/utils/MMKV";
import { abilityAccessCtrl, common } from '@kit.AbilityKit';
import image from '@ohos.multimedia.image';
import { photoAccessHelper } from '@kit.MediaLibraryKit';
import { fileIo, fileIo as fs, fileUri } from '@kit.CoreFileKit'; // 引入 CoreFileKit 中的文件 I/O 模块
import { BusinessError } from '@kit.BasicServicesKit';

@Entry
@Component
struct Pages_PlaceOrder {
  @State message: string = '代下单页面';
  @State model1: TitleBar.Model = new TitleBar.Model()
    .setLeftTitleStateNormalStyleColor(Color.Transparent)
    .setOnLeftClickListener(() => {
      router.back()
    })
    .setTitleName("代下单")
    .setTitleFontColor($r("app.color.text_color1"))
    .setTitleBarBackground(Color.Transparent)
  @State QRUrl:string = ""
  private qrCodeId: string = "qrCodeId" // 二维码 ID
  private appContext: common.Context = getContext(this);
  private atManager = abilityAccessCtrl.createAtManager();
  @State pixelMap: image.PixelMap | undefined = undefined;
  // qrcode = new QRCodes();

  // async generateQRCode() {
  //   this.pixelMap = await this.qrcode.encode(this.QRUrl, 200, 200);
  // }


  @Builder TitleBars(){
    Stack({ alignContent: Alignment.TopStart }){
      Flex({ direction: FlexDirection.Column }) {
        TitleBar({ model: $model1 })
      }
    }
    .width('100%')
  }

  aboutToAppear(): void {
    let userId =  MMKV.defaultMMKV().decodeString("USER_ID")
    let userName = MMKV.defaultMMKV().decodeString("NAME")
    this.QRUrl = NetConstants.QR_BASE_URL+`/customLine/pages/index/index?type=3&id=${userId}"&name=${userName?.charAt(0)}师傅`
  }

  //保存方法
  async saveImg() {
    try {
      //截图生成像素图
      const pixelMap = await componentSnapshot.get('share')
      const imagePacker = image.createImagePacker()
      //将像素图打包成二进制数据
      const arrayBuffer = await imagePacker.packing(pixelMap, { format: 'image/jpeg', quality: 100 })
      //缓存路径
      const filePath = `${getContext().cacheDir}/${Date.now()}.jpeg`
      const file = fileIo.openSync(filePath, fileIo.OpenMode.CREATE | fileIo.OpenMode.READ_WRITE)
      //将图片写入到沙箱相册
      fileIo.writeSync(file.fd, arrayBuffer)
      fileIo.closeSync(file.fd)
      const uri = fileUri.getUriFromPath(filePath)
      const phAccessHelper = photoAccessHelper.getPhotoAccessHelper(getContext(this))
      //相册管理模块创建资源变更申请保存到相册
      const assetChangeRequest =
        photoAccessHelper.MediaAssetChangeRequest.createImageAssetRequest(getContext(this), uri)
      //提交申请
      await phAccessHelper.applyChanges(assetChangeRequest)
      promptAction.showToast({ message: '保存成功' })
    } catch (err) {
      AlertDialog.show({ message: JSON.stringify(err), alignment: DialogAlignment.Center })
    }
  }



  build() {
    Stack({alignContent:Alignment.TopStart}){
        // Image($r("app.media.code_bg"))
        //   .width("100%")

      Scroll(){
        Flex({ direction: FlexDirection.Column }){
          Column(){
            this.TitleBars()
          }
          Row(){
            RelativeContainer(){
              Stack() {
                Column(){
                  QRCode(this.QRUrl)
                    .backgroundColor(Color.White)
                    .width(200)
                    .height(200)
                }
                .width('80%')
                .height(400)
                .justifyContent(FlexAlign.Center)
                .backgroundColor(Color.White)  // 添加白色背景
                .id('share')

                Row({space:50}){
                  SaveButton()
                    .backgroundColor($r("app.color.color_shubihong"))
                    .onClick(async (event: ClickEvent, result: SaveButtonOnClickResult)=> {
                      if (result === SaveButtonOnClickResult.SUCCESS) { // 如果保存成功
                          this.saveImg()
                      }
                    })
                  Button("打开微信")
                    .backgroundColor($r("app.color.button_qr_code_bg"))
                    .onClick(()=>{
                      showToast("跳转打开微信")
                    })
                }
                .margin({top:350})
              }
              .width('100%')

            }
          }
        }
      }
      .scrollable(ScrollDirection.Vertical)
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.None)
      .width('100%')
      .height('100%')
    }
    .width('100%')
    .height('100%')




  }
}