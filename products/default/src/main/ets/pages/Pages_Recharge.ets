import { TitleBar } from '@smarthane/titlebar';
import { router } from '@kit.ArkUI';
import { MoneyListModel, MoneyModel } from '../viewmodel/MoneyModel';
import { showToast } from 'base';
import { JSON } from '@kit.ArkTS';

/**
 * 充值页面
 */
@Entry
@Component
struct Pages_Recharge {
  @State message: string = 'Hello World';
  @State model1: TitleBar.Model = new TitleBar.Model()
    .setOnLeftClickListener(() => {
      router.back()
    })
    .setTitleName("余额充值")
    .setTitleFontColor($r("app.color.text_color1"))

  @State moneyList: Array<MoneyModel> = [
    new MoneyModel("200", "1"),
    new MoneyModel("100", "0"),
    new MoneyModel("50", "0"),
    new MoneyModel("30", "0"),
    new MoneyModel("20", "0"),
    new MoneyModel("10", "0")
  ];
  @State checkMoneyNum:string = ""

  @Builder TitleBars(){
    Column(){
      TitleBar({ model: $model1 })
    }
  }


  build() {
    Column(){
      this.TitleBars()

      Text("充值金额")
        .fontColor($r("app.color.text_color1"))
        .fontSize(16)
        .width("100%")
        .padding(10)
        .textAlign(TextAlign.Start)
      List({ space: 10 }) {
        ForEach(this.moneyList, (item: MoneyModel, index: number) => {
          ListItem() {
            Row() {
              Text(item.num)
                .height(40)
                .layoutWeight(1)
                .textAlign(TextAlign.Center)
                .fontColor(this.moneyList[index].isCheck == "1" ? $r("app.color.white") : $r("app.color.text_color1"))
                .fontSize(15)
                .backgroundColor(this.moneyList[index].isCheck == "1" ? $r("app.color.color_shubihong") : $r("app.color.white"))
                .onClick(() => {
                  // 切换选中状态
                  this.toggleSelection(index);
                  this.checkMoneyNum = this.moneyList[index].num
                  showToast("点击切换选中金额"+JSON.stringify(this.checkMoneyNum));
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

      Row(){
        Button("立即充值")
          .type(ButtonType.Normal)
          .borderRadius(10)
          .backgroundColor($r("app.color.color_shubihong"))
          .width("100%")
          .onClick(()=>{
            showToast("拉起微信支付")
          })
      }
      .margin({top:20,left:15,right:15})
      .width("90%")


      Row(){
        Text("点击立即充值，即表示已阅读并同意")
          .fontColor($r("app.color.text_h1"))
          .fontSize(12)
        Text("《充值规则》")
          .fontColor($r("app.color.color_shubihong"))
          .fontSize(12)
          .onClick(()=>{
            showToast("点击查看规则")
          })
      }
      .width("90%")
      .margin({left:15,right:15,top:5})
      .alignItems(VerticalAlign.Center)
      .justifyContent(FlexAlign.Start)





    }
    .height('100%')
    .width('100%')
    .backgroundColor($r("app.color.system_background_color"))
  }

  // 切换选中状态的方法
  private toggleSelection(index: number) {
    // 创建一个新的数组，确保引用发生变化
    const newMoneyList = this.moneyList.map((item, i) => {
      return new MoneyModel(item.num, i === index ? "1" : "0");
    });
    // 更新状态
    this.moneyList = newMoneyList;
    console.log("更新===>", JSON.stringify(this.moneyList));
  }

}