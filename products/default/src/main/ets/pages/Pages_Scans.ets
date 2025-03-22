import { ResultState, Scanner, ScannerController } from '@coner/scanner'
import { scanCore } from '@kit.ScanKit'
import { promptAction, router } from '@kit.ArkUI'
import { MMKV } from '@tencent/mmkv'
import { Api, EventBus, LoadingUtils, showToast } from 'base'
import { BaseModel } from 'base/src/main/ets/viewmodel/BaseModel'
// 输码后: eventBus 发送和接收的数据模型
interface InputCodeModule {
  name: string
}
/**
 * 扫码检票
 */
@Entry
@Component
struct Pages_Scans {
  scannerController: ScannerController = new ScannerController()
  @State shiftId :string = ""
  @State baseModel :BaseModel = new BaseModel()



  onPageShow(): void {
    this.scannerController.rescan()
  }

  aboutToAppear(): void {
    LoadingUtils.init(this.getUIContext());
    this.shiftId = router.getParams() as string
  }
  async submitInputCode(code:string){
    const carId = MMKV.defaultMMKV().decodeString("CAR_ID") as string
    const  params: Record<string, string> = {
      'carId':carId,
      'shiftId' :this.shiftId["value"],
      'code' :code
    };
    console.log("入参数据打印===>"+JSON.stringify(params))
    LoadingUtils.showLoading("加载中...");
    let res = await Api.net().getCheckTicket(params);
    this.baseModel =  res.data  as BaseModel
    if (res.isSuccessWithData()) {
      if (this.baseModel.statusCode == 200) {
        LoadingUtils.hideLoading()
        console.log("检票==>"+JSON.stringify(res.data))
        //检票成功发送事件
        let eventData: InputCodeModule = {
          name: '检票成功',
        }
        EventBus.send('InputCodeModule', eventData)
        showToast("检票成功！")
        router.back()
      }else{
        LoadingUtils.hideLoading()
        showToast(this.baseModel.message)
      }
    }else{
      LoadingUtils.hideLoading()
      showToast(res.message)
    }
  }

  build() {
    Column() {
      RelativeContainer() {
        Text('扫一扫')
          .height(44)
          .id('title')
          .alignRules({
            middle: {
              anchor: '__container__',
              align: HorizontalAlign.Center
            }
          })
      }.width('100%')
      .height(80)
      .padding({ right: 10, top: 36 })

      Scanner({
        scanTypes: [scanCore.ScanType.QR_CODE],
        controller: this.scannerController,
        lightShow: false,
        albumsShow: false,
        // maskColor: Color.Transparent,
        // cornerLineShow: false,
        // scanLineShow: false,
        // tipsShow: false,
        // safeAreaType: [SafeAreaType.SYSTEM],
        // safeAreaEdge: [SafeAreaEdge.TOP],
        // luminanceListener: (percent) => {
        //   promptAction.showToast({message: percent >= 1 ? '显示手电筒' : '隐藏手电筒'})
        // },
        onScanResult: (code: ResultState, value: string) => {
          if (code == ResultState.Success) {
            if (value) {
              this.submitInputCode(value)
            }
            // promptAction.showToast({ message: value })
          }
        },
        onCameraReject: () => {
          showToast('摄像头权限被拒绝')
        }
      })
        // .width('100%')
        // .height(200)
        .layoutWeight(1)
    }.width('100%')
    .height('100%')
  }


  /**
   * 扫描图片uri
   * 扫码页面使用扫一扫能力，扫描结果通过Scanner组件回调
   * @param url
   */
  scanUri(uri: string) {
    this.scannerController.scanUri(uri)
  }

  /**
   * 扫描网络图片
   * 扫码页面使用扫一扫能力，扫描结果通过Scanner组件回调
   * @param url
   */
  scanNetImage(url: string) {
    this.scannerController.scanUrl(url)
  }

}