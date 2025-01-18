import { MoneyListModel, MoneyModel } from "../viewmodel/MoneyModel";

@Component
export struct RechargeView{
  @ObjectLink moneyListModel: MoneyListModel;
  onItemClick: (index: number) =>void = () =>  {};


  build() {

    List({ space: 10 }) {
      ForEach(this.moneyListModel.moneyList, (item: MoneyModel, index: number) => {
        ListItem() {
          Row() {
            Text(item.num)
              .height(40)
              .layoutWeight(1)
              .textAlign(TextAlign.Center)
              .fontColor(item.isCheck == "1" ? $r("app.color.white") : $r("app.color.text_color1"))
              .fontSize(15)
              .backgroundColor(item.isCheck == "1" ? $r("app.color.color_shubihong") : $r("app.color.white"))
              .onClick(() => {
                this.onItemClick(index);
              });
          }
          .margin({ left: 10, right: 10 })
          .border({
            width: 1,
            color: "#F7F7F7"
          })
          .width("90%");
        }
      }, (item: MoneyModel) => item.num);
    }
    .lanes(2)
    .padding({ top: 15, bottom: 15 })
    .backgroundColor($r("app.color.white"));
  }
}