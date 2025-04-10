import { TitleBar } from '@smarthane/titlebar';
import { router } from '@kit.ArkUI';
import { Api, LoadingUtils } from 'base';
import { Item, WithdrawalRecordModel } from 'base/src/main/ets/viewmodel/WithdrawalRecordModel';
import { EmptyView } from '../view/EmptyView';
import { showToast } from '@abner/dialog';

/**
 *提现记录
 */
@Entry
@Component
struct Pages_WithdrawalRecord {
  @State message: string = 'Hello World';
  @State model1: TitleBar.Model = new TitleBar.Model()
    .setOnLeftClickListener(() => {
      router.back()
    })
    .setTitleName("提现记录")
    .setTitleFontColor($r("app.color.text_color1"))
  @State showLoading: boolean = false;
  @State index:number = 1
  @State withdrawalRecordList:WithdrawalRecordModel = new WithdrawalRecordModel()
  @State isShowView :Visibility = Visibility.None

  @Builder TitleBars(){
    Column(){
      TitleBar({ model: $model1 })
    }
  }
  @Builder withdrawalRecordsList(){
    Flex({ direction: FlexDirection.Column }) {

      if (this.withdrawalRecordList ?.data?.Item.length === 0){
        EmptyView()
      }else{
        List({space:10}){
          ForEach(this.withdrawalRecordList?.data?.Item,(item:Item,index:number)=>{
            ListItem(){
              Column(){
                Row(){
                  Column({space:8}){
                    Row({space:4}){
                      Text(item?.RealName)
                        .fontColor($r("app.color.text_color1"))
                        .fontSize(15)
                      Text(item?.CreateTime)
                        .fontColor($r("app.color.text_color1"))
                        .fontSize(13)
                    }
                    Text(item?.Money.toString()+"元")
                      .fontColor($r("app.color.text_color1"))
                      .fontSize(14)
                  }
                  .justifyContent(FlexAlign.Center)
                  .alignItems(HorizontalAlign.Start)

                  Column({space:8}){
                    Text(item?.Status == 1 ? "审核中" :item?.Status == 0 ? "已撤回" :item?.Status == -1 ? "不通过" :item?.Status == 2 ?"审核通过":item?.Status == 3?"已发放":"")
                      .fontColor($r("app.color.my_button_cz_color"))
                      .fontSize(14)
                    Button("撤回")
                      .type(ButtonType.Normal)
                      .borderRadius(5)
                      .visibility(item?.Status == 1 ? Visibility.Visible : Visibility.None)
                      .fontColor($r("app.color.white"))
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
                .width("100%")
                .justifyContent(FlexAlign.SpaceBetween)
                .padding(10)
                .borderRadius(10)
                .backgroundColor($r("app.color.white"))


                Column({space:5}){
                  Text("审核意见(2023-02-09 16:25:21):")
                    .fontColor($r("app.color.my_button_cz_color"))
                    .fontSize(13)
                  Text("通过")
                    .fontColor($r("app.color.text_color1"))
                    .fontSize(14)
                }
                .width("100%")
                .padding(10)
                .alignItems(HorizontalAlign.Start)
                .justifyContent(FlexAlign.Center)

              }
              .width("90%")
              .justifyContent(FlexAlign.SpaceBetween)
              .margin({left:20,right:20})
              .borderRadius(10)
              .backgroundColor($r("app.color.white"))
            }


          },(item:Item)=>item.Id)
        }
        .scrollBar(BarState.Off)
      }
    }
    .width("100%")
    .height("100%")
  }



  async getWithdrawalRecordList(){
    LoadingUtils.showLoading('加载中...')
    let res = await Api.net().getWithdrawalHistory(this.index);
    console.log("提现记录数据====>"+JSON.stringify(res.data))
    if (res.isSuccessWithData()) { //200
      LoadingUtils.hideLoading()
      this.withdrawalRecordList = res.data as WithdrawalRecordModel

    }else{
      LoadingUtils.hideLoading()
      showToast(res.message)
    }
  }

  aboutToAppear(): void {
    this.getWithdrawalRecordList()
  }

  build() {
    Column(){
      this.TitleBars()

      this.withdrawalRecordsList()


    }
    .height('100%')
    .width('100%')
    .backgroundColor($r("app.color.system_background_color"))
  }
}