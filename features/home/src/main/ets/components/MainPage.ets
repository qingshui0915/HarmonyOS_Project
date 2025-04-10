import { Api, BreakpointConstants, CommonConstants, EventBus, LoadingUtils, showToast } from 'base';
import { TitleBar } from '@smarthane/titlebar'
import { router } from '@kit.ArkUI';
import { JSON } from '@kit.ArkTS';
import { HomeIndexModel } from 'base/src/main/ets/viewmodel/HomeIndexModel';
import { MMKV } from '@tencent/mmkv';
import { HomeDataModel, Data,LineList } from 'base/src/main/ets/viewmodel/HomeDataModel';
import { common } from '@kit.AbilityKit';

interface SendFlushedModule {
  name: string
}
@Component
export struct MainPage {
  private context = getContext(this) as common.UIAbilityContext;
  private scroller: Scroller = new Scroller()
  @State isShow: Visibility = Visibility.None
  @State currentBottomIndex: number = 0;
  @StorageLink(BreakpointConstants.CURRENT_BREAKPOINT) currentBreakpoint: string = BreakpointConstants.BREAKPOINT_LG;
  @StorageLink(CommonConstants.AVOID_RECT_HEIGHT_TOP) TopRectHeight: number = 0;
  //titleBar组件
  @State model9: TitleBar.Model = new TitleBar.Model()
    .setLeftIcon($r("app.media.user"))
    .setLeftIconGravity(TitleBar.IconGravity.TOP)
    .setLeftIconWidth(35)
    .setLeftIconHeight(35)
    .setLeftIconPadding(5)
    .setLeftTitleFontSize(10)
    .setLeftTitleFontColor(Color.Blue)
    .setRightIcon($r("app.media.order"))
    .setRightIconGravity(TitleBar.IconGravity.TOP)
    .setRightIconWidth(35)
    .setRightIconHeight(35)
    .setRightIconPadding(5)
    .setRightTitleFontSize(10)
    .setTitleName("首页")
    .setTitleFontColor($r("app.color.text_color1"))
    .setOnLeftClickListener(() => {
      router.pushUrl({
        url:"pages/Pages_Mine"
      })
    })
    .setOnRightClickListener(() => {
      router.pushUrl({
        url:"pages/Pages_PlaceOrder"
      })
    })
  @State carId :string | undefined = ""
  @State indexData:HomeIndexModel = new HomeIndexModel()
  @State homeData:HomeDataModel = new HomeDataModel()
  @State homeTop:Data = new Data()
  @State homeItemData:LineList[] = []
  private onCheckItem = (value:string)=>{}
  @State toBeCompleted :Visibility =Visibility.None
  @Link @Watch("onFlushed") trigger :boolean


  onFlushed(){
    if (!this.trigger) {
      this.getIndexData()
    }

  }
  @Builder TitleBars(){
    Stack({ alignContent: Alignment.TopStart }){
      Flex({ direction: FlexDirection.Column }) {
        TitleBar({ model: $model9 })
      }
    }
    .width('100%')
    .backgroundColor(Color.White)
  }

  @Builder topMassageInfo(){
      GridRow({columns:{sm:3,md:3,lg:3},gutter:10}){
        GridCol({span:{sm:1,md:1},offset: 0, order: 0}){
          Column(){
            Text(this.homeData?.data?.TodayPeople?.toString() !=null ?this.homeData?.data?.TodayPeople?.toString() : "0")
              .fontColor($r("app.color.text_h1"))
              .fontSize(16)
              .fontWeight(FontWeight.Bold)
            Text("今日人数")
              .fontColor($r("app.color.text_color1"))
              .fontSize(16)
              .padding(10)
          }
          .alignItems(HorizontalAlign.Center)
          .justifyContent(FlexAlign.Center)
          .height(90)
        }
        // .onClick(()=>{
        //   router.pushUrl({
        //     url:"pages/Pages_WorkloadStatistics",
        //     params:{value:"0"}
        //   })
        // })

        GridCol({span:{sm:1,md:1}}){
          Column(){
            Text(this.homeData?.data?.TodayFinishOrder?.toString() != null ?this.homeData?.data?.TodayFinishOrder?.toString() : "0" )
              .fontColor($r("app.color.text_h1"))
              .fontSize(16)
              .fontWeight(FontWeight.Bold)
            Text("今日完单")
              .fontColor($r("app.color.text_color1"))
              .fontSize(16)
              .padding(10)
          }
          .alignItems(HorizontalAlign.Center)
          .justifyContent(FlexAlign.Center)
          .height(90)
        }
        // .onClick(()=>{
        //   showToast("点击今日完单")
        // })

        GridCol({span:{sm:1,md:1}}){
          Column(){
            Text(this.homeData?.data?.TodayMoney?.toString() != null ? this.homeData?.data?.TodayMoney?.toString() : "0" )
              .fontColor($r("app.color.text_h1"))
              .fontSize(16)
              .fontWeight(FontWeight.Bold)
            Text("今日流水")
              .fontColor($r("app.color.text_color1"))
              .fontSize(16)
              .padding(10)
          }
          .height(90)
          .alignItems(HorizontalAlign.Center)
          .justifyContent(FlexAlign.Center)
        }
        // .onClick(()=>{
        //   showToast("点击今日流水")
        // })
      }
      .onClick(()=>{
        router.pushUrl({
          url:"pages/Pages_WorkloadStatistics",
          params:{value:"0"}
        })
      })
  }

  @Builder taskList(){
    GridRow({columns:{sm:1,md:1,lg:1},gutter:10}){
      GridCol({span:{sm:1,md:1},offset: 0, order: 0}){
        Column(){
          Text("总待服务订单数")
            .fontColor($r("app.color.text_color1"))
            .fontSize(22)
          Row(){
            Text(this.homeTop.WaitOrderCount?.toString() != null ? this.homeTop.WaitOrderCount?.toString() : "0")
              .fontColor($r("app.color.text_task_color"))
              .fontSize(33)
            Text("单")
              .fontColor($r("app.color.text_h1"))
              .fontSize(13)
          }
          .margin({top:15})
        }
        .padding(18)
        .alignItems(HorizontalAlign.Center)
        .justifyContent(FlexAlign.Center)
      }
      // .onClick(()=>{
      //   showToast("点击今日人数")
      // })
    }

    List(){
      ForEach(this.homeItemData,(item:LineList, index:number)=>{
        ListItem(){
          Row(){
            RelativeContainer(){
              Row(){
                Text(this.homeData.data.LineList[index].OrderCount.toString())
                  .fontColor($r("app.color.white"))
                  .fontSize(12)
                  .width(20)
                  .height(20)
                  .textAlign(TextAlign.Center)
                  .borderRadius(3)
                  .backgroundColor($r("app.color.text_task_number_color2"))
              }
              .alignRules({
                top: { anchor: "__container__", align: VerticalAlign.Top },
                left: { anchor: "__container__", align: HorizontalAlign.Start }
              })
            }
            .width(45)
            .height(45)


            Flex({direction:FlexDirection.Row}){
              Row(){
                Text(this.homeItemData[index].StartCity)
                  .fontColor($r("app.color.text_color1"))
                  .fontSize(17)

                Image($r("app.media.right"))
                  .width(25)
                  .height(20)

                Text(this.homeItemData[index].EndCity)
                  .fontColor($r("app.color.text_color1"))
                  .fontSize(17)
              }
              .width("55%")
              .height(45)
              .justifyContent(FlexAlign.Start)
              .alignItems(VerticalAlign.Center)

              Row({space:5}){
                Text("查看订单")
                  .fontColor($r("app.color.text_h1"))
                  .fontSize(19)
                Image($r("app.media.right_jt_copy"))
                  .backgroundColor($r("app.color.color_shubihong"))
                  .width(25)
                  .height(25)
                  .borderRadius(3)

              }
              .width("35%")
              .height(45)
              .justifyContent(FlexAlign.Center)
              .alignItems(VerticalAlign.Center)

            }
            .width("90%")
            .height(45)

          }
          .margin({left:10,bottom:20})
          .width("94%")
          .height(45)
          .backgroundColor($r("app.color.text_task_list_bg"))
          .borderRadius(3)
        }
        .onClick(()=>{
          // showToast("点击条目事件调用")
          this.onCheckItem(this.homeItemData[index].Id)
        })
      },(item:LineList)=>item.Id)
    }
    .lanes(1)
    .edgeEffect(EdgeEffect.Spring) // 边缘效果设置为Spring
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
  }



  aboutToAppear(): void {
    LoadingUtils.init(this.getUIContext());
    console.log("过期token===>"+JSON.stringify(MMKV.defaultMMKV().decodeString("Token")))
    this.getIndexData()


  }



  //请求首页数据
  async getIndexData(){
    LoadingUtils.showLoading("加载中...");
    let res = await Api.net().getHomeIndexData();
    if (res.isSuccessWithData()) {
      this.indexData = (res.data as HomeIndexModel);

      if (this.indexData.data.Code == 200) {
        LoadingUtils.hideLoading();
        MMKV.defaultMMKV().encodeString("CAR_ID",this.indexData.data.CarId)
        console.log("打印首页数据请求1====>"+JSON.stringify(this.indexData))
        //请求首页待服务数据展示
        this.getHomeDatas(this.indexData.data.CarId)
      }else if (this.indexData.data.Code ==302){//未绑定车辆
        this.isShow = Visibility.None
      }
    }else{
      LoadingUtils.hideLoading();
      showToast(res.message)
    }


  }

  async getHomeDatas(carId:string){
    LoadingUtils.showLoading("加载中...");
    let res = await Api.net().getHomeDatas(carId);
    if (res.isSuccessWithData()) { //200
      if (res.data?.statusCode==200) {
        console.log("打印首页数据请求2====>"+JSON.stringify(res.data?.data))
        LoadingUtils.hideLoading();
        this.homeData = res.data as HomeDataModel
        this.homeTop = this.homeData.data
        this.homeItemData = this.homeData.data.LineList
        if (this.homeTop.Expire) {
          this.toBeCompleted = Visibility.Visible
        }
        if (this.homeItemData.length>0) {
          this.isShow = Visibility.Visible
        }
      }else{
        LoadingUtils.hideLoading();
        showToast((res.data?.message as string))
      }
    }else{
      LoadingUtils.hideLoading();
      showToast(res.message);
    }
  }




  build() {
    Stack({ alignContent: Alignment.TopStart}){
      Scroll(this.scroller){
        Flex({ direction: FlexDirection.Column }){
          Column(){
            this.TitleBars()
          }

          Row(){
            this.topMassageInfo()
          }
          .height(90)
          .margin({left:18,right:18,top:10})
          .backgroundColor($r("app.color.start_window_background"))
          .borderRadius(10)
          //有任务时显示  无任务时隐藏
          Row(){
              Image($r("app.media.notice"))
                .width(25)
                .height(25)
            Text("有一个任务在进行，请规划好时间")
              .fontSize(15)
              .fontColor($r("app.color.text_h1"))
              .margin({left:8})
              .layoutWeight(1)
          }
          .alignItems(VerticalAlign.Center)
          .justifyContent(FlexAlign.Center)
          .padding(8)
          .height(35)
          .margin({left:18,right:18,top:10})
          .backgroundColor($r("app.color.start_window_background"))
          .borderRadius(8)
          .visibility(this.isShow)
          //任务列表显示
          Column(){
            this.taskList()
          }
          .margin({left:18,right:18,top:10})
          .backgroundColor($r("app.color.start_window_background"))
          .borderRadius(10)



          Column(){
            Stack(){

              RelativeContainer(){
                Row(){
                  Text("待补齐")
                    .fontColor($r("app.color.white"))
                    .fontSize(14)
                    .width(60)
                    .height(30)
                    .textAlign(TextAlign.Center)
                    .backgroundColor($r("app.color.text_task_number_color2"))
                    .borderRadius({topLeft:8,bottomRight:8})
                }

              }

              Stack({alignContent:Alignment.Center}){
                Row(){
                  Column({space:5}){
                    Text("请尽快完成司机信息")
                      .fontColor($r("app.color.text_color1"))
                      .fontSize(13)
                    Text("为了避免影响出车接单，请尽快更新您的资料信息")
                      .fontColor($r("app.color.text_color1"))
                      .fontSize(13)
                  }
                  .layoutWeight(1)
                  .alignItems(HorizontalAlign.Start)
                  Text("去补齐")
                    .fontColor($r("app.color.white"))
                    .fontSize(14)
                    .width(60)
                    .height(30)
                    .borderRadius(8)
                    .textAlign(TextAlign.Center)
                    .backgroundColor($r("app.color.text_task_number_color2"))
                }
                .margin({left:20,right:10})
                .justifyContent(FlexAlign.SpaceBetween)
              }
              .onClick(()=>{
                router.pushUrl({
                  url:"pages/Pages_DocumentReview"
                })
              })
            }
          }
          .visibility(this.toBeCompleted)
          .height(120)
          .margin({left:18,right:18,top:10})
          .backgroundColor($r("app.color.start_window_background"))
          .borderRadius(10)
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
