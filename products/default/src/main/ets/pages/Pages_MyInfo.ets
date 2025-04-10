import { TitleBar } from '@smarthane/titlebar'
import { router } from '@kit.ArkUI';
import { Api, LoadingUtils, NetConstants, showToast } from 'base';
import { UserInfoModel } from 'base/src/main/ets/viewmodel/UserInfoModel';
import { MMKV } from '@tencent/mmkv';
import { hide, showDialog, showDialogConfirm } from '@abner/dialog';
import { DialogAction, DialogHelper } from '@pura/harmony-dialog';
import { BaseModel } from 'base/src/main/ets/viewmodel/BaseModel';
import { ChangeInfoModel } from 'base/src/main/ets/viewmodel/ChangeInfoModel';

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
  @State userInfos:BaseModel = new BaseModel()
  @State imgs?:string = ""
  @State inputText:string = ""
  @State changesInfo:ChangeInfoModel = new ChangeInfoModel()

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
      showToast(res.message)
    }
  }


  aboutToAppear(): void {
    LoadingUtils.init(this.getUIContext());
    this.getUserInfo()
  }

  async changeUserInfos(newName:string){
    LoadingUtils.showLoading("加载中...")
    this.changesInfo.NewName = newName
    this.changesInfo.IsReg = true
    let res = await Api.net().changeUserInfo(this.changesInfo);
    if (res.isSuccessWithData()) { //200
      if (res.data?.statusCode == 200) {
        LoadingUtils.hideLoading()
        this.getUserInfo()
      }else{
        LoadingUtils.hideLoading()
        showToast(res.data?.message + "")
      }
    }else{
      LoadingUtils.hideLoading()
      showToast(res.message)
    }
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
                    Image(this.userInfoData?.data?.AvatarUrl)
                      .alt($r('app.media.head'))
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
                // .onClick(()=>{
                //   showToast("点击我的车辆")
                // })

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
                  //单行文本输入弹出框
                  DialogHelper.showTextInputDialog({
                    title:"修改姓名",
                    text: this.inputText,
                    onAction: (action, dialogId, content) => {
                      if (action == DialogAction.SURE) {
                        if (content) {
                          this.inputText = content;
                          this.changeUserInfos(this.inputText)
                        }else{
                          showToast("请输入要修改的姓名")
                        }
                      }
                    }
                  })
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
                  router.pushUrl({
                    url:'pages/Pages_RevisePhoneNum'
                  })
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
                  router.pushUrl({
                    url:'pages/Pages_BindWX'
                  })
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
              .borderRadius(5)
              .backgroundColor($r("app.color.button_logout_bg"))
              .onClick(()=>{
                // showDialog(wrapBuilder(BuilderDialog))
                showDialogConfirm({
                  title: "确认要退出登录吗？",
                  message: "",
                  clickCancel: () => {
                    //取消
                    hide()
                  },
                  clickConfirm: () => {
                    //确认
                    //清除mmkv存储数据
                    MMKV.defaultMMKV().clearAll()
                    //回登录页面
                    router.replaceUrl({
                      url:"pages/Pages_Login"
                    })
                    //清空页面栈 只保留当前页面在栈顶
                    router.clear()
                    hide() //隐藏
                  }
                })
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

/*
* Author:AbnerMing
* Describe:自定义弹窗,布局自己定义
*/
@Builder
function BuilderDialog() {
  Column() {
    Text("确认要退出登录吗？")
      .fontColor($r('app.color.text_color1'))
      .fontSize(17)
      .margin({ top: 30 })
    Row() {
      Button("取消").onClick(() => {
        //隐藏dialog
        hide()
      })
      Button("确定")
        .margin({ left: 30 })
        .onClick(()=>{
          //确认
          //清除mmkv存储数据
          MMKV.defaultMMKV().clearAll()
          //回登录页面
          router.replaceUrl({
            url:"pages/Pages_Login"
          })
          //清空页面栈 只保留当前页面在栈顶
          router.clear()
          hide() //隐藏
        })
    }.margin({ top: 20 })
    .margin({ top: 30 })
  }.backgroundColor(Color.White)
  .width("60%")
}
