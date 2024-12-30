@Entry
@Component
struct Pages_PlaceOrder {
  @State message: string = '代下单页面';

  build() {
    RelativeContainer() {
      Text(this.message)
        .id('Pages_PlaceOrderHelloWorld')
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