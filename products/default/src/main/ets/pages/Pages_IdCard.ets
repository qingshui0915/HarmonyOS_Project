import { CallbackParam, CardRecognition, CardSide, CardType, ShootingMode } from '@kit.VisionKit'
import { hilog } from '@kit.PerformanceAnalysisKit'
import { showToast } from '@abner/dialog'
import { router } from '@kit.ArkUI'
import { EventBus } from 'base'
import { ArrayList, JSON } from '@kit.ArkTS'

const TAG: string = 'Pages_IdCard'
interface PersonInfo {
  name: string;
  sex: string;
  nationality: string;
  address: string;
  birth: string;
  idNumber: string;
  cardImageUri: string;
  originalImageUri: string;
  authority ?: string;
  validPeriod ?: string;
}
@Entry
@Component
struct Pages_IdCard {
  @State cardDataSource: PersonInfo[] = []
  // @Consume('pathStack') pathStack: NavPathStack

  build() {
    NavDestination() {
      Stack({ alignContent: Alignment.Top }) {
        Stack() {
          // this.cardDataShowBuilder()
        }
        .width('80%')
        .height('80%')

        CardRecognition({
          // 此处选择身份证类型作为示例
          supportType: CardType.CARD_ID,
          cardSide: CardSide.FRONT,
          cardRecognitionConfig: {
            defaultShootingMode: ShootingMode.MANUAL,
            isPhotoSelectionSupported: true
          },
          callback: ((params: CallbackParam) => {
            hilog.info(0x0001, TAG, `params code: ${params.code}`)
            if (params.code === -1) {
              // this.pathStack.pop()
              showToast("识别错误返回页面")
              router.back()
            }else if(params.code === 200){
              if (params.cardInfo?.front !== undefined) {
                let newFront:PersonInfo ={
                  name:params.cardInfo?.front.name,
                  sex:params.cardInfo?.front.sex,
                  nationality:params.cardInfo?.front.nationality,
                  address:params.cardInfo?.front.address,
                  birth:params.cardInfo?.front.birth,
                  idNumber:params.cardInfo?.front.idNumber,
                  cardImageUri:params.cardInfo?.front.cardImageUri,
                  originalImageUri:params.cardInfo?.front.originalImageUri,
                  authority:params.cardInfo?.front?.authority,
                  validPeriod:params.cardInfo?.front?.validPeriod
                }
                EventBus.send("IDCardInfo",newFront)
                router.back({
                  url:'pages/Pages_CompletionIdCard'
                })
                this.cardDataSource.push(newFront)
              }
              if (params.cardInfo?.back !== undefined) {
                let newBack:PersonInfo = {
                  name:params.cardInfo?.back?.name,
                  sex:params.cardInfo?.back?.sex,
                  nationality:params.cardInfo?.back?.nationality,
                  address:params.cardInfo?.back?.address,
                  birth:params.cardInfo?.back?.birth,
                  idNumber:params.cardInfo?.back?.idNumber,
                  cardImageUri:params.cardInfo?.back?.cardImageUri,
                  originalImageUri:params.cardInfo?.back?.originalImageUri,
                  authority:params.cardInfo?.back.authority,
                  validPeriod:params.cardInfo?.back.validPeriod
                }
                this.cardDataSource.push(newBack)

                // this.cardDataSource.push(params.cardInfo?.back)
              }
              console.log("打印发送数据====>" + JSON.stringify(this.cardDataSource))


            }
            hilog.info(0x0001, TAG, `params cardType: ${params.cardType}`)
            hilog.info(0x0001, TAG, `params cardInfo front: ${JSON.stringify(params.cardInfo?.front)}`)
            hilog.info(0x0001, TAG, `params cardInfo back: ${JSON.stringify(params.cardInfo?.back)}`)
          })
        })
      }
      .width('100%')
      .height('100%')
    }
    .width('100%')
    .height('100%')
    .hideTitleBar(true)
  }

  // @Builder
  // cardDataShowBuilder() {
  //   List() {
  //     ForEach(this.cardDataSource, (cardData: Record<string, string>) => {
  //       ListItem() {
  //         Column() {
  //           Image(cardData.cardImageUri)
  //             .objectFit(ImageFit.Contain)
  //             .width(100)
  //             .height(100)
  //
  //           Text(JSON.stringify(cardData))
  //             .width('100%')
  //             .fontSize(12)
  //         }
  //       }
  //     })
  //   }
  //   .listDirection(Axis.Vertical)
  //   .alignListItem(ListItemAlign.Center)
  //   .margin({
  //     top: 50
  //   })
  //   .width('100%')
  //   .height('100%')
  // }
}