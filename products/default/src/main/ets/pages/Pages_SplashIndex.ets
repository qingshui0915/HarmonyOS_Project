import { updateManager } from '@kit.StoreKit';
import { common } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { router } from '@kit.ArkUI';

let context: common.UIAbilityContext = getContext() as common.UIAbilityContext;
@Entry
@Component
struct Pages_SplashIndex {
  @State message: string = 'Hello World';
  jumpToMain() {
    setTimeout(() => {
      // 检查更新
      try {
        updateManager.checkAppUpdate(context)
          .then((checkResult: updateManager.CheckUpdateResult) => {
            hilog.info(0, 'TAG', "Succeeded in checking Result updateAvailable:" + checkResult.updateAvailable);
            try {
              updateManager.showUpdateDialog(context)
                .then((resultCode: updateManager.ShowUpdateResultCode) => {
                  hilog.info(0, 'TAG', "Succeeded in showing UpdateDialog resultCode:" + resultCode);
                })
                .catch((error: BusinessError) => {
                  hilog.error(0, 'TAG', `showUpdateDialog onError.code is ${error.code}, message is ${error.message}`);
                });
            } catch (error) {
              hilog.error(0, 'TAG', `showUpdateDialog onError.code is ${error.code}, message is ${error.message}`);
            }
          }).catch((error: BusinessError) => {
          hilog.error(0, 'TAG', `checkAppUpdate onError.code is ${error.code}, message is ${error.message}`);
        });
      } catch (error) {
        hilog.error(0, 'TAG', `checkAppUpdate onError.code is ${error.code}, message is ${error.message}`);
      }

      router.replaceUrl({url: "pages/Index"})
    }, 2000)
  }

  aboutToAppear(): void {
    this.jumpToMain()
  }


  aboutToDisappear() {
    clearTimeout()
  }
  build() {
    RelativeContainer(){
      Row({space:10}){
        Image($r('app.media.new_ic_app')).width(60).height(60)

        Column({space:5}){
          Text("APP名称").fontSize(22).fontColor("#333333")
          Text("APP简介").fontSize(14).fontColor("#999999")
        }.alignItems(HorizontalAlign.Start)
      }.alignRules({
        bottom: {anchor: "__container__", align: VerticalAlign.Bottom},
        middle: { anchor: '__container__', align: HorizontalAlign.Center }
      }).margin({
        bottom:30
      })

    }
    .width('100%')
    .height('100%').backgroundColor(Color.White)
  }
}