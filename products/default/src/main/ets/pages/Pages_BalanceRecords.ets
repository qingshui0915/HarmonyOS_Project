import { TitleBar } from '@smarthane/titlebar';
import { router } from '@kit.ArkUI';
import { Api, LoadingUtils, showToast } from 'base';
import { BalanceRecordsModel, Item } from 'base/src/main/ets/viewmodel/BalanceRecordsModel';
import { EmptyView } from '../view/EmptyView';

/**
 * Balance records
 * 余额记录
 */
@Entry
@Component
struct Pages_BalanceRecords {
  @State message: string = 'Hello World';
  @State model1: TitleBar.Model = new TitleBar.Model()
    .setOnLeftClickListener(() => {
      router.back()
    })
    .setTitleName("余额记录")
    .setTitleFontColor($r("app.color.text_color1"))
  @State showLoading: boolean = false;
  @State index:number = 1
  @State balanceRecordsList: BalanceRecordsModel = new BalanceRecordsModel()
  @State isShowView :Visibility = Visibility.None

  @Builder TitleBars(){
    Column(){
      TitleBar({ model: $model1 })
    }
  }

  @Builder balanceRecordList(){
    Flex({ direction: FlexDirection.Column }) {
      //this.balanceRecordsList ?.data?.Item[0]?.NowMoney
      Text("当前余额：" + (this.balanceRecordsList ?.data?.Item ? "0" : this.balanceRecordsList ?.data?.Item[0]?.NowMoney))
        .fontColor($r("app.color.text_color1"))
        .fontSize(16)
        .width("100%")
        .textAlign(TextAlign.Center)
        .padding(15)

      if (this.balanceRecordsList ?.data?.Item.length === 0){
        EmptyView()
      }else{
        List({space:10}){
          ForEach(this.balanceRecordsList?.data?.Item,(item:Item,index:number)=>{
            ListItem(){
              Row(){
                Column({space:8}){
                  Text(item?.Note)
                    .fontColor($r("app.color.text_color1"))
                    .fontSize(14)
                  Text(item?.CreateTime)
                    .fontColor($r("app.color.text_color1"))
                    .fontSize(14)
                }
                .alignItems(HorizontalAlign.Start)

                Column(){
                  Text(item?.Money.toString()+"元")
                    .fontColor($r("app.color.text_color1"))
                    .fontSize(14)
                  Text("查看提现记录")
                    .visibility(item?.Note === "提现申请" ? Visibility.Visible : Visibility.None)
                    .fontColor($r("app.color.color_shubihong"))
                    .fontSize(15)
                    .onClick(()=>{
                      router.pushUrl({
                        url:"pages/Pages_WithdrawalRecord"
                      })
                    })
                }
                .alignItems(HorizontalAlign.Center)
                .justifyContent(FlexAlign.Center)



              }
              .width("90%")
              .justifyContent(FlexAlign.SpaceBetween)
              .padding(10)
              .margin({left:20,right:20})
              .borderRadius(10)
              .backgroundColor($r("app.color.white"))
            }


          },(item:Item)=>item.CreateTime)
        }
        .scrollBar(BarState.Off)
      }
    }
    .width("100%")
    .height("100%")
  }




  async getBalanceRecordsList(){
    LoadingUtils.showLoading('加载中...')
    let res = await Api.net().getBalanceRechargeRecord(this.index);
    console.log("余额记录数据====>"+JSON.stringify(res.data))
    if (res.isSuccessWithData()) { //200
      LoadingUtils.hideLoading()
      this.balanceRecordsList = res.data as BalanceRecordsModel
    }else{
      LoadingUtils.hideLoading()
      showToast(res.message)
    }
  }

  aboutToAppear(): void {
     this.getBalanceRecordsList()
  }


  build() {
    Column(){
      this.TitleBars()

      this.balanceRecordList()


    }
    .height('100%')
    .width('100%')
    .backgroundColor($r("app.color.system_background_color"))
  }
}