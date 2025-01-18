import { TitleBar } from '@smarthane/titlebar';
import { router } from '@kit.ArkUI';
import { Api } from 'base';
import { Data, PayoutsTypeModel } from 'base/src/main/ets/viewmodel/PayoutsTypeModel';
import { WeChatPayoutView } from '../view/WeChatPayoutView';
import { ALiPayoutView } from '../view/ALiPayoutView';

/**
 * 提现页面
 */
@Entry
@Component
struct Pages_Payouts {
  @State message: string = 'Hello World';
  @State showLoading: boolean = false;
  @State model1: TitleBar.Model = new TitleBar.Model()
    .setOnLeftClickListener(() => {
      router.back()
    })
    .setTitleName("余额提现")
    .setTitleFontColor($r("app.color.text_color1"))
  @State payoutsType: PayoutsTypeModel =new PayoutsTypeModel()
  @State fontColor: string = '#182431'
  @State selectedFontColor: string = '#353436'
  @State currentIndex: number = 0
  @State selectedIndex: number = 0
  private controller: TabsController = new TabsController()

  @Builder TitleBars(){
    Column(){
      TitleBar({ model: $model1 })
    }
  }
  @Builder tabBuilder(index: number, name: string) {
    Column() {
      Text(name)
        .fontColor(this.selectedIndex === index ? this.selectedFontColor : this.fontColor)
        .fontSize(16)
        .fontWeight(this.selectedIndex === index ? 500 : 400)
        .lineHeight(22)
        .margin({ top: 17, bottom: 7 })
      Divider()
        .strokeWidth(2)
        .width(20)
        .color($r("app.color.color_shubihong"))
        .opacity(this.selectedIndex === index ? 1 : 0)
    }
    .width('100%')
    .backgroundColor($r("app.color.white"))
  }
  //子布局
  @Builder renderTabContent(index: number, item: Data) {
    if (index === 0) {
      WeChatPayoutView()
    } else if (index === 1) {
      // 第二个TabContent的子布局
      ALiPayoutView()

    } else {
      // 其他TabContent的子布局
      Column() {
        Text("这是其他Tab的内容")
          .fontSize(18)
          .fontColor(Color.Black)
          .margin({ top: 20 })
        // 添加其他组件
      }
      .width("100%")
      .height("100%")
      .backgroundColor(Color.Gray)
    }
  }
  //布局1



  //请求
  async getPayoutsType(){
    this.showLoading = true;
    let res = await Api.net().getWithdrawType();
    this.showLoading = false;
    console.log("余额提现数据====>"+JSON.stringify(res.data))
    this.payoutsType = res.data as PayoutsTypeModel
  }


  aboutToAppear(): void {
    this.getPayoutsType()
  }

  build() {
    Column(){
      this.TitleBars()

      Column(){
        Tabs({ barPosition: BarPosition.Start, index: this.currentIndex, controller: this.controller }) {
          ForEach(this.payoutsType?.data,(item:Data,index:number)=>{
            TabContent() {
              //子组件加载不同布局
              this.renderTabContent(index, item)
            }.tabBar(this.tabBuilder( index, item.TypeName))
          },(item:Data)=>item.TypeName)
        }
        .scrollable(false)
        .vertical(false)
        .barMode(BarMode.Fixed)
        .barWidth(400)
        .barHeight(56)
        .animationDuration(0)
        .onChange((index: number) => {
          // currentIndex控制TabContent显示页签
          this.currentIndex = index
          this.selectedIndex = index
        })
        .width(400)
        .height("90%")
      }
      .width("100%")
      .height("100%")

    }
    .height('100%')
    .width('100%')
    .backgroundColor($r("app.color.system_background_color"))

  }
}