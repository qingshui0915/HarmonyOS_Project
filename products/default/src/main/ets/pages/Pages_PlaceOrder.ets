import { TitleBar } from '@smarthane/titlebar'
import { componentSnapshot, promptAction, router } from '@kit.ArkUI';
import { showToast } from 'base';
import { MMKV } from "@tencent/mmkv/src/main/ets/utils/MMKV";
import { abilityAccessCtrl, common } from '@kit.AbilityKit';
import image from '@ohos.multimedia.image';
import { photoAccessHelper } from '@kit.MediaLibraryKit';
import { fileIo as fs } from '@kit.CoreFileKit'; // 引入 CoreFileKit 中的文件 I/O 模块
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
    this.QRUrl = `/customLine/pages/index/index?type=3&id=${userId}"&name=${userName?.charAt(0)}师傅`
  }





  build() {
    Stack(){
        Image($r("app.media.code_bg"))
          .width("100%")
          .height("100%")
      Scroll(){
        Flex({ direction: FlexDirection.Column }){
          Column(){
            this.TitleBars()
          }
          Row(){
            RelativeContainer(){
              Stack() {
                QRCode(this.QRUrl)
                  .backgroundColor(Color.Transparent)
                  .width(200)
                  .height(200)
                Row({space:50}){
                  SaveButton()
                    .onClick(async (event: ClickEvent, result: SaveButtonOnClickResult)=>{
                      if (result === SaveButtonOnClickResult.SUCCESS) { // 如果保存成功
                        const context: common.UIAbilityContext = getContext(this) as common.UIAbilityContext; // 获取上下文
                        let helper = photoAccessHelper.getPhotoAccessHelper(context); // 获取照片访问助手
                        try { // 尝试
                          let uri = await helper.createAsset(photoAccessHelper.PhotoType.IMAGE, 'jpg'); // 创建图片资源
                          let file = await fs.open(uri, fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE); // 打开文件
                          componentSnapshot.get(this.QRUrl).then((pixelMap) => { // 获取二维码快照
                            let packOpts: image.PackingOption = { format: 'image/png', quality: 100 } // 打包选项
                            const imagePacker: image.ImagePacker = image.createImagePacker(); // 创建图像打包器
                            return imagePacker.packToFile(pixelMap, file.fd, packOpts).finally(() => { // 打包并保存文件
                              imagePacker.release(); // 释放打包器
                              fs.close(file.fd); // 关闭文件
                              promptAction.showToast({ // 弹出提示消息
                                message: '图片已保存至相册', // 提示内容
                                duration: 2000 // 持续时间
                              });
                            });
                          })
                        } catch (error) { // 捕获错误
                          const err: BusinessError = error as BusinessError; // 转换为业务错误
                          console.error(`Failed to save photo. Code is ${err.code}, message is ${err.message}`); // 打印错误信息
                        }

                      } else { // 如果保存失败
                        showToast("设置权限失败")
                      }
                    })
                  Button("保存相册")
                    .type(ButtonType.Normal)
                    .backgroundColor($r("app.color.color_shubihong"))
                    .onClick(()=>{
                      // this.generateQRCode()
                    })

                  Button("打开微信")
                    .backgroundColor($r("app.color.button_qr_code_bg"))
                    .onClick(()=>{
                      showToast("跳转打开微信")
                    })
                }
                .margin({top:350})
              }
              .height('66%')
              .width('100%')

            }
          }
          .id("qr_code")

        }
      }
    }



    // Stack(){
    //   // Image($r("app.media.code_bg"))
    //   //   .width("100%")
    //   //   .height("100%")
    //   RelativeContainer(){
    //     Column(){
    //       this.TitleBars()
    //     }
    //     Row(){
    //       RelativeContainer(){
    //
    //         Stack() {
    //           QRCode(this.QRUrl)
    //             .backgroundColor(Color.Transparent)
    //             .width(200)
    //             .height(200)
    //           Row({space:50}){
    //             Button("保存相册")
    //               .type(ButtonType.Normal)
    //               .backgroundColor($r("app.color.color_shubihong"))
    //               .onClick(()=>{
    //                 showToast("点击保存相册")
    //               })
    //
    //             Button("打开微信")
    //               .type(ButtonType.Normal)
    //               .backgroundColor($r("app.color.button_qr_code_bg"))
    //               .onClick(()=>{
    //                 showToast("跳转打开微信")
    //               })
    //           }
    //           .margin({top:420})
    //         }
    //         .height('100%')
    //         .width('100%')
    //
    //       }
    //     }
    //     .id("qr_code")
    //
    //     // Row(){
    //     //   Button("保存相册")
    //     //     .type(ButtonType.Normal)
    //     //     .width(80)
    //     //     .backgroundColor($r("app.color.color_shubihong"))
    //     //     .onClick(()=>{
    //     //
    //     //     })
    //     //
    //     //   Button("打开微信")
    //     //     .type(ButtonType.Normal)
    //     //     .width(80)
    //     //     .backgroundColor($r("app.color.button_qr_code_bg"))
    //     //     .onClick(()=>{
    //     //
    //     //     })
    //     // }
    //     // .alignRules({
    //     //   // top: { anchor: "qr_code", align: VerticalAlign.Bottom },
    //     //   bottom: { anchor: "__container__", align: VerticalAlign.Bottom },
    //     //   // left: { anchor: "__container__", align: HorizontalAlign.Start },
    //     //   // right: { anchor: "row1", align: HorizontalAlign.End }
    //     // })
    //   }
    //   .width("100%")
    //   .height("100%")
    //   .alignRules({
    //     center:{anchor:"__container__",align:VerticalAlign.Center}
    //   })
    // }



  }
}