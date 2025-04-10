import { TitleBar } from '@smarthane/titlebar';
import { router } from '@kit.ArkUI';
import { Api, EventBus, LoadingUtils, showToast } from 'base';
import { ProgressDataModel ,Data} from 'base/src/main/ets/viewmodel/ProgressDataModel';
import { ProgressListModel } from '../viewmodel/ProgressListModel';
import { JSON } from '@kit.ArkTS';


@Entry
@Component
struct Pages_PersonalData {
  @State title: string = '个人资料';
  //titleBar组件
  @State model1: TitleBar.Model = new TitleBar.Model()
    .setOnLeftClickListener(() => {
      router.back()
    })
    .setTitleName(this.title)
    .setTitleFontColor($r("app.color.text_color1"))
  @State progressData :ProgressDataModel = new ProgressDataModel()
  @State progressInfoData : Data = new Data()
  @State result :ProgressListModel[] = [];




  @Builder TitleBars(){
    Column(){
      TitleBar({ model: $model1 })
    }

  }

  async getDriverInfoProgressData(){
    LoadingUtils.showLoading("加载中...")
    let res = await Api.net().getDriverInfoProgress();
    if (res.isSuccessWithData()) {
      if (res.data?.statusCode == 200) {
        this.progressInfoData = new Data()
        LoadingUtils.hideLoading()
        this.progressData = res.data as ProgressDataModel
        this.progressInfoData = this.progressData.data
        this.result = []
        // 将每个字段转换为所需的格式并添加到结果数组中
        this.result.push({
          "Id" :"1",
          "Type" :"身份证信息补齐",
          "Content" :"请准备好身份证信息原件",
          "Status": this.progressInfoData.IdCardAuthStatus,
          "IsComplete": this.progressInfoData.IdCardIsComplete
        });
        this.result.push({
          "Id" :"2",
          "Type" :"驾驶证信息补齐",
          "Content" :"请准备好驾驶证信息原件",
          "Status": this.progressInfoData.DriverCardAuthStatus,
          "IsComplete": this.progressInfoData.DriverLicenseIsComplete
        });
        this.result.push({
          "Id" :"3",
          "Type" :"行驶证信息补齐",
          "Content" :"请准备好行驶证信息原件",
          "Status": this.progressInfoData.VehicleCardAuthStatus,
          "IsComplete": this.progressInfoData.DrivingLicenseIsComplete
        });
        this.result.push({
          "Id" :"4",
          "Type" :"营运证资料信息",
          "Content" :"请准备好营运证资料信息原件",
          "Status": this.progressInfoData.OnlineCarAuthStatus,
          "IsComplete": this.progressInfoData.OnelineCarInfoIsComplete
        });
        this.result.push({
          "Id" :"5",
          "Type" :"保险信息",
          "Content" :"请准备好保险信息原件",
          "Status": this.progressInfoData.InsuranceAuthStatus,
          "IsComplete": this.progressInfoData.InsuranceIsComplete
        });
        // console.log("打印封装数据===>" + JSON.stringify(this.result))
      }

    }

  }

  onPageShow(): void {

  }


  onPageHide(): void {
  }


  aboutToAppear(): void {
    LoadingUtils.init(this.getUIContext());
    this.getDriverInfoProgressData()
  }




  build() {
    Column() {
      this.TitleBars()

      //顶部warn
      Row({space:8}){
        Image($r("app.media.warn"))
          .width(18)
          .height(18)
        Text("请尽快补齐资料，避免将来无法出车。(已补齐或更新请忽略)")
          .fontColor($r("app.color.text_color2"))
          .fontSize(11)
      }
      .width('100%')
      .height(30)
      .alignItems(VerticalAlign.Center)
      .justifyContent(FlexAlign.Center)
      .backgroundColor($r("app.color.warn_color_bg"))


      Column(){
        List({space:10}){
          ForEach(this.result,(item: ProgressListModel , index:number)=>{
            ListItem(){
              Row({space:10}){
                Column({space:5}){
                  Text(this.result[index]?.Type)
                    .fontColor($r("app.color.text_color1"))
                    .fontSize(14)
                  Text(this.result[index]?.Content)
                    .fontColor($r("app.color.text_h1"))
                    .fontSize(12)
                }
                .margin({left:16})
                .alignItems(HorizontalAlign.Start)
                .justifyContent(FlexAlign.Center)

                Button(this.result[index]?.Status == 0 ? "审核中" :this.result[index]?.Status == 1 ? "已审核" : this.result[index]?.Status == -1 ? "已驳回" : "去补齐")
                  .type(ButtonType.Normal)
                  .stateEffect(this.result[index]?.Status == 1 ? false : true)
                  .width(70)
                  .height(30)
                  .fontColor($r("app.color.white"))
                  .fontSize(12)
                  .borderRadius(8)
                  .backgroundColor($r("app.color.color_shubihong"))
                  .opacity(this.result[index]?.Status == 1 ? 0.4 : 1)
                  .onClick(()=>{
                    if (this.result[index]?.Status == 1 || this.result[index]?.Status == 0) {
                      return
                    }else{
                      showToast("去填写信息")
                    }
                  })
              }
              .width('90%')
              .padding(8)
              .margin({left:20,right:20})
              .borderRadius(10)
              .backgroundColor($r("app.color.white"))
              .alignItems(VerticalAlign.Center)
              .justifyContent(FlexAlign.SpaceBetween)
            }
            .onClick(()=>{
              if (this.result[index]?.Id == "1") {
                  router.pushUrl({
                    url:"pages/Pages_CompletionIdCard"
                  })
              }else if (this.result[index]?.Id == "2"){
                router.pushUrl({
                  url:"pages/Pages_CompletionDriverCard"
                })
              }else if (this.result[index]?.Id == "3"){
                router.pushUrl({
                  url:"pages/Pages_CompletionTravelCard"
                })
              }
              else if (this.result[index]?.Id == "4"){
                router.pushUrl({
                  url:"pages/Pages_CompletionVehicleLicense"
                })
              }else if (this.result[index]?.Id == "5"){
                router.pushUrl({
                  url:"pages/Pages_CompulsoryTrafficInsurance"
                })
              }
            })
          },(item:ProgressListModel)=>item.Id)
        }
      }
      .margin({top:10})
      .width('100%')

      Column({space:15}){
        Row(){
          Text("姓名")
            .fontColor($r('app.color.text_color1'))
            .fontSize(14)
            .layoutWeight(1)
          Text(this.progressInfoData?.Name)
            .fontColor($r('app.color.text_h1'))
            .fontSize(13)
        }
        .margin({left:10,right:10})
        .alignItems(VerticalAlign.Center)
        .justifyContent(FlexAlign.SpaceBetween)

        Row(){
          Text("手机号码")
            .fontColor($r('app.color.text_color1'))
            .fontSize(14)
            .layoutWeight(1)
          Text(this.progressInfoData?.Phone)
            .fontColor($r('app.color.text_h1'))
            .fontSize(13)
        }
        .margin({left:10,right:10})
        .alignItems(VerticalAlign.Center)
        .justifyContent(FlexAlign.SpaceBetween)
      }
      .padding(15)
      .margin({left:20,right:20,top:25})
      .borderRadius(10)
      .backgroundColor($r('app.color.white'))
    }
    .height('100%')
    .width('100%')
    .backgroundColor($r("app.color.system_background_color"))
  }
}