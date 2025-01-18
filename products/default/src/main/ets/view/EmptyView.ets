
@Component
export struct EmptyView {
  build() {
      RelativeContainer(){
        Image($r("app.media.no_info_blue"))
          .width(200)
          .height(200)
          .alignRules({
            center: { anchor: "__container__", align:VerticalAlign.Center },
            middle: { anchor: "__container__", align: HorizontalAlign.Center }
          })
          .id("img_empty")
        Text("暂无数据")
          .fontColor($r("app.color.text_h1"))
          .fontSize(16)
          .alignRules({
            middle: { anchor: "img_empty", align: HorizontalAlign.Center },
            bottom:{ anchor :"img_empty" ,align:VerticalAlign.Bottom}
          })
      }
    .width("100%")
    .height("90%")
  }
}