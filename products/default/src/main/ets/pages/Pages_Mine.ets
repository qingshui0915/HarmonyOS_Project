@Entry
@Component
struct Pages_Mine {
  @State message: string = '我的页面';

  build() {
    RelativeContainer() {
      Text(this.message)
        .id('Pages_MineHelloWorld')
        .fontSize(50)
        .fontWeight(FontWeight.Bold)
        .alignRules({
          center: { anchor: '__container__', align: VerticalAlign.Center },
          middle: { anchor: '__container__', align: HorizontalAlign.Center }
        })
    }
    .height('100%')
    .width('100%')
  }
}