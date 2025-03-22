import { TitleBar } from '@smarthane/titlebar'
import { router } from '@kit.ArkUI'
import { Api, LoadingUtils, showToast } from 'base';
import { JSON } from '@kit.ArkTS';
import { CompanyListModel } from 'base/src/main/ets/viewmodel/CompanyListModel';
import { CompanysModel } from '../viewmodel/CompanysModel';
import { SubmitCompanyModel } from 'base/src/main/ets/viewmodel/SubmitCompanyModel';
import { SelectCompanyModel } from 'base/src/main/ets/viewmodel/SelectCompanyModel';
import { call, observer } from '@kit.TelephonyKit';
import { BusinessError } from '@kit.BasicServicesKit';

/**
 * 选择车管公司
 */
@Entry
@Component
struct Pages_Select_Company {
  //titleBar组件
  @State model9: TitleBar.Model = new TitleBar.Model()
    .setLeftIcon($r("app.media.user"))
    .setLeftIconGravity(TitleBar.IconGravity.TOP)
    .setLeftIconWidth(35)
    .setLeftIconHeight(35)
    .setLeftIconPadding(5)
    .setLeftTitleFontSize(10)
    .setLeftTitleFontColor(Color.Blue)
    .setTitleName("哈哈定制司机")
    .setTitleFontColor($r("app.color.text_color1"))
    .setOnLeftClickListener(() => {
      router.pushUrl({
        url:"pages/Pages_Mine"
      })
    })
  @State selectedCompany: string = '选择车管公司';
  @State companies: string[] = ['公司A', '公司B', '公司C']; // 这里替换为实际的公司列表
  @State companyList :CompanyListModel = new CompanyListModel()
  @State newCompanyList:Array<CompanysModel> = new Array<CompanysModel>()
  @State submitCompany:SubmitCompanyModel = new SubmitCompanyModel()
  @State selectCompany:SelectCompanyModel = new SelectCompanyModel()


  @Builder TitleBars(){
    Stack({ alignContent: Alignment.TopStart }){
      Flex({ direction: FlexDirection.Column }) {
        TitleBar({ model: $model9 })
      }
    }
    .width('100%')
    .backgroundColor(Color.White)
  }

  aboutToAppear(): void {
    LoadingUtils.init(this.getUIContext())
    this.getCompanyList()

  }

  async getCompanyList(){
    LoadingUtils.showLoading('加载中...')
    let res = await Api.net().getCompanyList();
    if (res.isSuccessWithData()) {
      this.companyList = res.data as CompanyListModel
      if (this.companyList.statusCode == 200) {
        LoadingUtils.hideLoading()
        console.log('数据打印=====>'+JSON.stringify(this.companyList.data))
        if (this.companyList.data.length > 0) {
          this.newCompanyList = []
          for (let i = 0; i < this.companyList.data.length; i++) {
              let newCompanyBean = new CompanysModel()
            newCompanyBean.value = this.companyList.data[i].ShortName
            this.newCompanyList.push(newCompanyBean)
          }
        }
      }else{
        LoadingUtils.hideLoading()
        showToast(this.companyList.message)
      }
    }else{
      LoadingUtils.hideLoading()
      showToast(res.message)
    }
  }

  async postSubmitCompany(companyName:string){
    LoadingUtils.showLoading('加载中...')
    this.submitCompany.CompanyName = companyName
    let res = await Api.net().postBindingLineCar(this.submitCompany);
    if (res.isSuccessWithData()) {
      this.selectCompany = res.data as SelectCompanyModel
      if (this.selectCompany.statusCode == 200) {
        LoadingUtils.hideLoading()
        router.pushUrl({
          url:'pages/Pages_CompletionIdCard'
        })
      }else{
        LoadingUtils.hideLoading()
        showToast(this.companyList.message)
      }
    }else{
      LoadingUtils.hideLoading()
      showToast(res.message)
    }
  }



  build() {
      Flex({direction:FlexDirection.Column}){
        Column() {
          this.TitleBars()
        }
        .width('100%')
        .height(100)

        Column(){
          Select(this.newCompanyList)
            .value(this.selectedCompany)
            .fontColor($r('app.color.text_color2'))
            .margin({ bottom: 40 })
            .width('100%')
            .optionWidth(200)
            .menuAlign(MenuAlignType.CENTER, { dx: 0, dy: 0 })
            .arrowPosition(ArrowPosition.END)
            .divider(null)
            .onSelect((index: number, text?: string | undefined) => {
              console.info('Select:' + index)
              if (text) {
                this.selectedCompany = text;
              }
            })

          Button('下一步')
            .width('100%')
            .height(40)
            .backgroundColor('#4E6EF2')
            .margin({ bottom: 20 })
            .onClick(() => {
              // 处理下一步逻辑
              if (this.selectedCompany == '选择车管公司') {
                showToast("请先选择车管公司")
                return;
              }
              this.postSubmitCompany(this.selectedCompany)


            })

          Row() {
            Text('有疑问？')
              .fontSize(14)
              .fontColor('#999999')
            Text('立即咨询')
              .fontSize(14)
              .fontColor('#4E6EF2')
              .margin({ left: 5 })
              .onClick(() => {
                // 处理咨询点击事件
                // 实现拨打电话的逻辑
                let isSupport = call.hasVoiceCapability();
                if (isSupport) {
                  // 如果设备支持呼叫能力，则继续跳转到拨号界面，并显示拨号的号码
                  call.makeCall( '4006662777', (err: BusinessError) => {
                    if (!err) {
                      console.log("make call success.");
                    } else {
                      console.log("make call fail, err is:" + JSON.stringify(err));
                    }
                  });
                  // 订阅通话业务状态变化（可选）
                  class SlotId {slotId: number = 0}
                  class CallStateCallback {
                    state: call.CallState = call.CallState.CALL_STATE_UNKNOWN;
                    number: string = "";
                  }
                  let slotId: SlotId = {slotId: 0}
                  observer.on("callStateChange", slotId, (data: CallStateCallback) => {
                    console.log("call state change, data is:" + JSON.stringify(data));
                  });
                }
              })
          }
        }
        .height(220)
        .borderRadius(8)
        .padding(8)
        .margin({top:20,left:16,right:16})
        .alignItems(HorizontalAlign.Center)
        .justifyContent(FlexAlign.Center)
        .backgroundColor($r('app.color.white'))


    }
    .width('100%')
    .height('100%')
    .backgroundColor('#EFEFF3')
  }
}