import { TitleBar } from '@smarthane/titlebar'
import { router } from '@kit.ArkUI';
import { Api, LoadingUtils, showToast } from 'base';
import { UserInfoModel } from 'base/src/main/ets/viewmodel/UserInfoModel';
import { ImageKnifeComponent, ImageKnifeOption } from '@ohos/imageknife';

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
  @State imgs:string = ""
  @State isBindWx :Visibility = Visibility.None



  @Builder TitleBars(){
    Stack({ alignContent: Alignment.TopStart }){
      Flex({ direction: FlexDirection.Column }) {
        TitleBar({ model: $model1 })
      }
    }
    .width('100%')

  }




  async getUserInfo(){
    LoadingUtils.showLoading("加载中...");
    let res = await Api.net().getUserInfo();
    // console.log("登录用户数据====>"+JSON.stringify(res.data))
    this.userInfoData = (res.data as UserInfoModel)
    if (res.isSuccessWithData()) { //200
      LoadingUtils.hideLoading();
      this.imgs = this.userInfoData.data.Photo;
      // console.log("2222"+JSON.stringify(this.imgs))
      //判断是否绑定微信
      if (!this.userInfoData.data.IsBindWxToApp) {
        this.isBindWx = Visibility.None
      }else{
        this.isBindWx = Visibility.Visible
      }
    }else{
      LoadingUtils.hideLoading();
    }
  }
  //任务订单列表状态布局
  @Builder topTaskInfo(){
    GridRow({columns:{sm:3,md:3,lg:3},gutter:10}){
      GridCol({span:{sm:1,md:1},offset: 0, order: 0}){
        Column(){
          Image($r("app.media.my_order"))
            .width(25)
            .height(25)
          Text("已完成")
            .fontColor($r("app.color.text_color1"))
            .fontSize(15)
            .padding(5)
        }
        .alignItems(HorizontalAlign.Center)
        .justifyContent(FlexAlign.Center)
        .height(70)
      }
      .onClick(()=>{
        router.pushUrl({
          url:"pages/Pages_All_TaskList",
          params:{value:"3"}
        })
      })

      GridCol({span:{sm:1,md:1}}){
        Column(){
          Image($r("app.media.my_order"))
            .width(25)
            .height(25)
          Text("待出发")
            .fontColor($r("app.color.text_color1"))
            .fontSize(15)
            .padding(5)
        }
        .alignItems(HorizontalAlign.Center)
        .justifyContent(FlexAlign.Center)
        .height(70)
      }
      .onClick(()=>{
        router.pushUrl({
          url:"pages/Pages_All_TaskList",
          params:{value:"1"}
        })
      })

      GridCol({span:{sm:1,md:1}}){
        Column(){
          Image($r("app.media.my_order"))
            .width(25)
            .height(25)
          Text("进行中")
            .fontColor($r("app.color.text_color1"))
            .fontSize(15)
            .padding(5)
        }
        .height(70)
        .alignItems(HorizontalAlign.Center)
        .justifyContent(FlexAlign.Center)
      }
      .onClick(()=>{
        router.pushUrl({
          url:"pages/Pages_All_TaskList",
          params:{value:"2"}
        })
      })
    }
    .margin({top:10})
  }

  aboutToAppear(): void {
    LoadingUtils.init(this.getUIContext());
    this.getUserInfo()
  }



  async jumpNextPages() {
    if (!this.userInfoData.data.IsBindCar) {
      showToast("提醒去绑定车辆！")
    }else{
      if (this.userInfoData.data.IsBindWxToApp) {
        router.pushUrl({
          url:"pages/Pages_Recharge"
        })
      }else{
        showToast("请先绑定微信")
      }
    }
  }

  async jumpNextToPayouts() {
    if (!this.userInfoData.data.IsBindCar) {
      showToast("请先绑定车辆信息！")
    }else{
      router.pushUrl({
        url:"pages/Pages_Payouts"
      })
    }
  }


  build() {
    Stack() {
      // Image($r("app.media.my_bg"))
      //   .width("100%")
      //   .height("100%")

      Scroll(this.scroller) {
        Flex({direction:FlexDirection.Column}) {
          Column() {
            this.TitleBars()
          }
          .height(100)
          Row(){
            Row(){
              // //头像
              Image(this.imgs)
                .borderRadius(25)
                .width(50)
                .height(50)
                .alt($r("app.media.user_default"))
              Column({space:5}){
                Text(this.userInfoData?.data?.Name)
                  .fontColor($r("app.color.text_color1"))
                  .fontSize(15)

                Text("优质司机")
                  .fontColor($r("app.color.text_h1"))
                  .fontSize(13)
              }
              .width('80%')
              .margin({left:10})
              .alignItems(HorizontalAlign.Start)
            }

            Image($r("app.media.arrow_right"))
              .margin({right:20})
              .width(18)
              .height(25)
          }
          .alignItems(VerticalAlign.Center)
          .justifyContent(FlexAlign.SpaceBetween)
          .margin({left:20,right:20})
          .height(50)
          .onClick(()=>{
            router.pushUrl({
              url:"pages/Pages_MyInfo"
            })
          })
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
            .layoutWeight(1)
            Row({space:10}){
              Text("本月接乘客数")
                .fontColor($r("app.color.text_color1"))
                .fontSize(15)

              Text(this.userInfoData?.data?.MouthPeople.toString())
                .fontColor($r("app.color.text_h1"))
                .fontSize(20)
            }
            .layoutWeight(1)
          }
          .justifyContent(FlexAlign.SpaceBetween)
          .margin({left:30,right:30,top:10,bottom:10})
          .height(30)

          //账户余额显示
          Column(){
            Stack({alignContent:Alignment.TopStart}){
              Image($r("app.media.union"))
                .width('100%')
                .height(120)
                .borderRadius({topLeft:10,topRight:10})
              Column({space:15}){
                Text("账户余额")
                  .fontColor($r("app.color.text_color1"))
                  .fontSize(17)
                  .margin({top:8})
                Row(){
                  Text(this.userInfoData?.data?.Balance.toString())
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
                  Text(this.userInfoData?.data?.PendingEntryAmount +"元")
                    .fontColor($r("app.color.text_color1"))
                    .fontSize(14)
                }

              }
              .alignItems(HorizontalAlign.Start)
              .margin({left:10})
              .onClick(()=>{
                //余额记录
                router.pushUrl({
                  url:"pages/Pages_BalanceRecords"
                })
              })
              //充值提现
              Stack({alignContent:Alignment.End}){
                Row({space:10}){
                  Button("提现")
                    .width(70)
                    .height(35)
                    .backgroundColor($r("app.color.color_shubihong"))
                    .borderRadius(2)
                    .visibility(this.isBindWx)
                    .onClick(()=>{
                      this.jumpNextToPayouts()
                    })
                  Button("充值")
                    .width(70)
                    .height(35)
                    .backgroundColor($r("app.color.my_button_cz_color"))
                    .borderRadius(2)
                    .onClick(()=>{
                      this.jumpNextPages()
                    })

                }
                .margin({top:30,right:10})
              }
              .width("100%")


            }
            .width("100%")

            //全部
            Row(){
              Text("我的订单")
                .fontColor($r("app.color.title_color"))
                .fontSize(17)
              Row(){
                Text("全部")
                  .fontColor($r("app.color.text_h1"))
                  .fontSize(15)
                  .textAlign(TextAlign.Center)
                Image($r("app.media.arrow_right"))
                  .width(20)
                  .height(20)
              }
              .alignItems(VerticalAlign.Center)
              .justifyContent(FlexAlign.Center)
            }
            .width('90%')
            .margin({left:20,right:20,top:10})
            .alignItems(VerticalAlign.Center)
            .justifyContent(FlexAlign.SpaceBetween)
            .onClick(()=>{
              router.pushUrl({
                url:"pages/Pages_All_TaskList",
                params:{value:"3"}
              })
            })
            //任务列表查看入口
            this.topTaskInfo()
          }
          .borderRadius(10)
          .margin({left:20,right:20})
          .backgroundColor(Color.White)

          //设置列表
          Column(){
            Row(){
              Text("设置")
                .fontColor($r("app.color.text_color1"))
                .fontSize(18)
                .textAlign(TextAlign.Start)
                .width("100%")
            }
            .width("90%")
            .margin({top:10,left:20,right:20})
            .alignItems(VerticalAlign.Center)



            Stack({alignContent:Alignment.Bottom}){
              Column({space:15}){
                Row(){
                  Row({space:8}){
                    Image($r("app.media.vehicle"))
                      .width(20)
                      .height(20)
                    Text("我的车辆")
                      .fontColor($r("app.color.text_color1"))
                      .fontSize(16)
                  }
                  .alignItems(VerticalAlign.Center)
                  .justifyContent(FlexAlign.Center)
                  Image($r("app.media.arrow_right"))
                    .width(18)
                    .height(18)
                }
                .width("90%")
                .margin({left:20,right:20})
                .alignItems(VerticalAlign.Center)
                .justifyContent(FlexAlign.SpaceBetween)
                .onClick(()=>{
                  router.pushUrl({
                    url:"pages/Pages_MyCar"
                  })
                })

                Divider()
                  .visibility(Visibility.Visible)
                  .width("90%")
                  .margin({left:20,right:20})

                Row(){
                  Row({space:8}){
                    Image($r("app.media.certificates"))
                      .width(20)
                      .height(20)
                    Text("个人资料")
                      .fontColor($r("app.color.text_color1"))
                      .fontSize(16)
                  }
                  .alignItems(VerticalAlign.Center)
                  .justifyContent(FlexAlign.Center)
                  Image($r("app.media.arrow_right"))
                    .width(18)
                    .height(18)
                }
                .width("90%")
                .margin({left:20,right:20})
                .alignItems(VerticalAlign.Center)
                .justifyContent(FlexAlign.SpaceBetween)
                .onClick(()=>{
                  router.pushUrl({
                    url:"pages/Pages_PersonalData"
                  })
                })

                Divider()
                  .width("90%")
                  .margin({left:20,right:20})
                  .visibility(Visibility.Visible)


                Row(){
                  Row({space:8}){
                    Image($r("app.media.message"))
                      .width(20)
                      .height(20)
                    Text("关于我们")
                      .fontColor($r("app.color.text_color1"))
                      .fontSize(16)
                  }
                  .alignItems(VerticalAlign.Center)
                  .justifyContent(FlexAlign.Center)
                  Image($r("app.media.arrow_right"))
                    .width(18)
                    .height(18)
                }
                .visibility(Visibility.Visible)
                .width("90%")
                .margin({left:20,right:20,bottom:20})
                .alignItems(VerticalAlign.Center)
                .justifyContent(FlexAlign.SpaceBetween)
                .onClick(()=>{
                  router.pushUrl({
                    url:'pages/Pages_AboutUs'
                  })
                })
              }

            }
            .margin({top:10,bottom:10})
            .width("100%")

          }
          .margin({top:20,left:20,right:20})
          .borderRadius(10)
          .backgroundColor(Color.White)

          //Copyright版本号说明
          Column(){
            Column({space:3}){
              Text("Copyright ©2023")
                .fontColor($r("app.color.text_h1"))
                .fontSize(14)
              Text("哈哈出行版权所有")
                .fontColor($r("app.color.text_h1"))
                .fontSize(14)
              // Text("备案号:豫ICP备18030969号-6A")
              //   .fontColor($r("app.color.text_h1"))
              //   .fontSize(14)
            }
            .width("100%")
            .alignItems(HorizontalAlign.Center)
          }
          .width("100%")
          .margin({top:16, bottom:16})
          .alignItems(HorizontalAlign.Center)
        }
        .width('100%')
        .height('100%')


      }
      .width('100%')
      .height('100%')
      .scrollable(ScrollDirection.Vertical)
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.None)
    }
    .backgroundImage($r("app.media.my_bg"))
    .backgroundImageSize(ImageSize.Cover)
    .width("100%")
    .height('100%')

  }

}