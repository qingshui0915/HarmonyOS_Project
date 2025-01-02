import { TitleBar } from '@smarthane/titlebar'
import { router } from '@kit.ArkUI';
import { Api } from 'base';
import { UserInfoModel } from 'base/src/main/ets/viewmodel/UserInfoModel';

/**
 * 我的页面==>个人中心
 */
@Entry
@Component
struct Pages_Mine {
  @State message: string = '我的页面';
  private scroller: Scroller = new Scroller()
  //titleBar组件
  @State model1: TitleBar.Model = new TitleBar.Model()
    .setLeftTitleStateNormalStyleColor(Color.Transparent)
    .setOnLeftClickListener(() => {
      router.back()
    })
    .setTitleName("我的")
    .setTitleFontColor($r("app.color.text_color1"))
    .setTitleBarBackground(Color.Transparent)
  @State showLoading: boolean = false;
  @State userInfoData:UserInfoModel = new UserInfoModel()
  @State pictures ?: string = ""




  @Builder TitleBars(){
    Stack({ alignContent: Alignment.TopStart }){
      Flex({ direction: FlexDirection.Column }) {
        TitleBar({ model: $model1 })
      }
      .margin({top:30})
    }
    .width('100%')
  }


  async getUserInfo(){
    this.showLoading = true;
    let res = await Api.net().getUserInfo();
    this.showLoading = false;
    console.log("登录用户数据====>"+JSON.stringify(res.data))
    this.userInfoData = (res.data as UserInfoModel)
    if (res.isSuccessWithData()) { //200
      this.pictures = this.userInfoData.data.Photo
    }else{

    }
  }


  aboutToAppear(): void {
    this.getUserInfo()
  }

  build() {
    Stack({alignContent:Alignment.TopStart}) {
      Image($r("app.media.my_bg"))
        .width("100%")
        .height("100%")
      Scroll(this.scroller) {
        Flex({ direction: FlexDirection.Column }) {
          Column() {
            this.TitleBars()
          }
          Row(){
            Image(this.pictures)
              .borderRadius(25)
              .width(50)
              .height(50)
            Column({space:5}){
              Text(this.userInfoData?.data?.Name)
                .fontColor($r("app.color.text_color1"))
                .fontSize(15)

               Text("优质司机")
                 .fontColor($r("app.color.text_h1"))
                 .fontSize(13)
            }
            .alignItems(HorizontalAlign.Start)
          }
          .margin({left:20,right:20})
          .width("90%")
          .height(50)
          //接客
          Row({space:20}){
            Row({space:10}){
              Text("今日接乘客数")
                .fontColor($r("app.color.text_color1"))
                .fontSize(15)

              Text(this.userInfoData?.data?.TodayPeople.toString())
                .fontColor($r("app.color.text_h1"))
                .fontSize(20)
            }
            Row({space:10}){
              Text("本月接乘客数")
                .fontColor($r("app.color.text_color1"))
                .fontSize(15)

              Text(this.userInfoData?.data?.MouthPeople.toString())
                .fontColor($r("app.color.text_h1"))
                .fontSize(20)
            }
          }
          .justifyContent(FlexAlign.SpaceBetween)
          .margin({left:30,right:30,top:10})
          .width("83%")
          .height(30)

          //账户余额显示
          Stack({alignContent:Alignment.TopStart}){
            Image($r("app.media.union"))
              .height(120)
            Column({space:10}){
              Text("账户余额")
                .fontColor($r("app.color.text_color1"))
                .fontSize(17)
                .margin({top:8})
              Row(){
                Text("0.00")
                  .fontColor($r("app.color.my_text_money_color"))
                  .fontSize(25)
                Text("元")
                  .fontColor($r("app.color.text_color1"))
                  .fontSize(15)
                  .margin({left:3})
              }
              Row(){
                Text("待入账金额:")
                  .fontColor($r("app.color.text_color1"))
                  .fontSize(14)
                Text("0元")
                  .fontColor($r("app.color.text_color1"))
                  .fontSize(14)
              }

            }
            .alignItems(HorizontalAlign.Start)
            .margin({left:10})

            Stack({alignContent:Alignment.End}){
              Row({space:10}){
                Button("提现")
                  .width(70)
                  .height(35)
                  .backgroundColor($r("app.color.color_shubihong"))
                  .borderRadius(2)
                  .visibility(Visibility.None)
                Button("充值")
                  .width(70)
                  .height(35)
                  .backgroundColor($r("app.color.my_button_cz_color"))
                  .borderRadius(2)

              }
              .margin({top:30,right:10})
            }
            .width("100%")


          }
          .width("100%")
          .border({
            width:1,
            color:Color.Red
          })

        }
      }
      .scrollable(ScrollDirection.Vertical)
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring)
    }
    .width("100%")
    .height("100%")


  }
}