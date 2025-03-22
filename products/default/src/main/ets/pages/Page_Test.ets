import { MakerInfoModel } from '../viewmodel/MakerInfoModel';

@Entry
@Component
struct Page_Test {
  @State message: string = 'Hello World';

  build() {
    RelativeContainer(){
      Column(){
        Image($r('app.media.custom_maker'))
      }
      .padding(5)
      .alignRules({
        middle: { anchor: "__container__", align: HorizontalAlign.Center },
        center: { anchor: "__container__", align: VerticalAlign.Center },
      })
      Column() {
        Text("2")
          .fontColor($r("app.color.white"))
          .fontSize(9)
          .width(12)
          .height(12)
          .textAlign(TextAlign.Center)
          .borderRadius(6)
          .backgroundColor(Color.Red)
      }
      .alignRules({
        top: { anchor: "__container__", align: VerticalAlign.Top },
        right: { anchor: "__container__", align: HorizontalAlign.End },
      })
    }
    .width(45)
    .height(50)
    .borderRadius(3)
  }
}