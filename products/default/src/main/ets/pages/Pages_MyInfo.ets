import { TitleBar } from '@smarthane/titlebar'
import { router } from '@kit.ArkUI';
import { Api, LoadingUtils, showToast } from 'base';
import { UserInfoModel } from 'base/src/main/ets/viewmodel/UserInfoModel';
import { MMKV } from '@tencent/mmkv';

@Entry
@Component
struct Pages_MyInfo {
  @State message: string = '我的信息';
  //titleBar组件
  @State model1: TitleBar.Model = new TitleBar.Model()
    .setOnLeftClickListener(() => {
      router.back()
    })
    .setTitleName("我的信息")
    .setTitleFontColor($r("app.color.text_color1"))
  private scroller: Scroller = new Scroller()
  @State showLoading: boolean = false;
  @State userInfoData:UserInfoModel = new UserInfoModel()
  @State imgs?:string = ""

  @Builder TitleBars(){
    Stack({ alignContent: Alignment.TopStart }){
      Flex({ direction: FlexDirection.Column }) {
        TitleBar({ model: $model1 })
      }
    }
    .width('100%')
  }

  async getUserInfo(){
    LoadingUtils.showLoading("加载中...")
    let res = await Api.net().getUserInfo();
    this.showLoading = false;
    if (res.isSuccessWithData()) { //200
      if (res.data?.statusCode == 200) {
        LoadingUtils.hideLoading()
        this.userInfoData = (res.data as UserInfoModel)
        this.imgs = this.userInfoData.data.Photo;
      }else{
        LoadingUtils.hideLoading()
        showToast(res.data?.message + "")
      }

    }else{
      LoadingUtils.hideLoading()
    }
  }


  aboutToAppear(): void {
    LoadingUtils.init(this.getUIContext());
    this.getUserInfo()
  }


  build() {
    Stack({ alignContent: Alignment.TopStart}){
      Scroll(){
        Flex({ direction: FlexDirection.Column }){
          Column(){
            this.TitleBars()
          }
          Column(){
            Stack({alignContent:Alignment.Bottom}){
              Column({space:15}){
                Row(){
                  Text("头像")
                    .fontColor($r("app.color.text_color1"))
                    .fontSize(16)
                  Row({space:8}){
                    Image(this.userInfoData?.data?.Photo)
                      .width(20)
                      .height(20)
                      .borderRadius(10)

                    Image($r("app.media.arrow_right"))
                      .width(18)
                      .height(18)
                  }
                  .alignItems(VerticalAlign.Center)
                  .justifyContent(FlexAlign.Center)


                }
                .width("90%")
                .margin({left:20,right:20})
                .alignItems(VerticalAlign.Center)
                .justifyContent(FlexAlign.SpaceBetween)
                .onClick(()=>{
                  showToast("点击我的车辆")
                })

                Divider()
                  .visibility(Visibility.Visible)
                  .width("90%")
                  .margin({left:20,right:20})

                Row(){
                  Text("姓名")
                    .fontColor($r("app.color.text_color1"))
                    .fontSize(16)
                  Row({space:8}){
                    Text(this.userInfoData?.data?.Name)
                      .fontColor($r("app.color.text_h1"))
                      .fontSize(15)
                      .textAlign(TextAlign.Center)
                    Image($r("app.media.arrow_right"))
                      .width(18)
                      .height(18)
                  }
                  .alignItems(VerticalAlign.Center)
                  .justifyContent(FlexAlign.Center)

                }
                .width("90%")
                .margin({left:20,right:20})
                .alignItems(VerticalAlign.Center)
                .justifyContent(FlexAlign.SpaceBetween)
                .onClick(()=>{
                  showToast("点击个人资料")
                })

                Divider()
                  .width("90%")
                  .margin({left:20,right:20})
                  .visibility(Visibility.Visible)


                Row(){
                  Text("手机号")
                    .fontColor($r("app.color.text_color1"))
                    .fontSize(16)
                  Row({space:8}){
                    Text(this.userInfoData?.data?.Phone)
                      .fontColor($r("app.color.text_h1"))
                      .fontSize(15)
                      .textAlign(TextAlign.Center)
                    Image($r("app.media.arrow_right"))
                      .width(18)
                      .height(18)
                  }
                  .alignItems(VerticalAlign.Center)
                  .justifyContent(FlexAlign.Center)

                }
                .width("90%")
                .margin({left:20,right:20})
                .alignItems(VerticalAlign.Center)
                .justifyContent(FlexAlign.SpaceBetween)
                .onClick(()=>{
                  showToast("点击新消息通知")
                })

                Divider()
                  .width("90%")
                  .margin({left:20,right:20})
                  .visibility(Visibility.Visible)
                Row(){
                  Text("账号绑定")
                    .fontColor($r("app.color.text_color1"))
                    .fontSize(16)
                  Row({space:8}){
                    Text(this.userInfoData?.data?.IsBindWxToApp ? "已绑" :"未绑")
                      .fontColor($r("app.color.text_h1"))
                      .fontSize(15)
                      .textAlign(TextAlign.Center)
                    Image($r("app.media.arrow_right"))
                      .width(18)
                      .height(18)
                  }
                  .alignItems(VerticalAlign.Center)
                  .justifyContent(FlexAlign.Center)

                }
                .width("90%")
                .margin({left:20,right:20})
                .alignItems(VerticalAlign.Center)
                .justifyContent(FlexAlign.SpaceBetween)
                .onClick(()=>{
                  showToast("点击新消息通知")
                })
              }

            }
            .margin({top:10,bottom:10})
            .width("100%")

          }
          .margin({top:10})
          .width("100%")
          .borderRadius(10)
          .backgroundColor(Color.White)

          Column(){
            Button("退出登录")
              .type(ButtonType.Normal)
              .width("100%")
              .backgroundColor($r("app.color.button_logout_bg"))
              .onClick(()=>{
                //清除mmkv存储数据
                MMKV.defaultMMKV().clearAll()
                //回登录页面
                router.replaceUrl({
                  url:"pages/Pages_Login"
                })
                //清空页面栈 只保留当前页面在栈顶
                router.clear()

              })

          }
          .margin({left:20,right:20,top:20})

        }

      }
      .scrollable(ScrollDirection.Vertical)
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring)
    }
    .width("100%")
    .height("100%")
    .backgroundColor($r("app.color.system_background_color"))
  }
}