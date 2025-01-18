import { BreakpointConstants, CommonConstants, Logger, WindowUtil , EventBus} from 'base';
import { router, window } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import { MainPage } from 'home';
//测试EventBus 数据
interface DeliverToPassengerModule {
  name: string
}
interface NoticeChildModule {
  name: string
}

@Entry
@Component
struct Index {
  @Provide(CommonConstants.PAGE_INFOS) pageInfos: NavPathStack = new NavPathStack();
  @StorageLink(BreakpointConstants.IS_SPLIT_MODE) isSplitMode: boolean = false;
  private windowUtil?: WindowUtil;
  private mainWindow?: window.Window;
  @State triggerStatus :boolean = true


  aboutToAppear(): void {
    console.log("token:"+JSON.stringify(AppStorage.get("Token")))

    if (this.isSplitMode) {
      // 跟路由推送页面
    }
  }

  onPageShow(): void {
    EventBus.listen<DeliverToPassengerModule>('DeliverToPassenger', (data) => {
      if (data !== undefined) {
        if (data.name == "送达乘客") {
          console.log("触发了吗===>"+JSON.stringify(data))
          this.triggerStatus = false
        }
      }
    })
  }

  onPageHide(): void {
    //取消订阅
    EventBus.cancel('NoticeChildPages')
  }


  //回调函数跳转页面(跨模块的)
  orderPages =(value:string)=>{
    router.pushUrl({
      url:"pages/Pages_TaskOrder",
      params:{value:value}
    })
  }



  aboutToDisappear(): void {
    if (this.windowUtil === undefined) {
      return;
    }
    this.mainWindow = this.windowUtil.getMainWindow();
    if (this.mainWindow === undefined) {
      return;
    }
    try {
      this.mainWindow.off("windowSizeChange");
      this.mainWindow.off("windowStatusChange");
    } catch (exception) {
      Logger.error("取消监听失败:" + JSON.stringify(exception));
    }
  }
  @State message: string = 'Hello World';

  build() {
    Navigation() {
      // 页面
      MainPage({onCheckItem:this.orderPages,trigger :this.triggerStatus})
    }
    .width(CommonConstants.FULL_WIN)
    .height(CommonConstants.FULL_WIN)
    .mode(NavigationMode.Stack)
    .titleMode(NavigationTitleMode.Full)
    .hideTitleBar(true)
  }
}