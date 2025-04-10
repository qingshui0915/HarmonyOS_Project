import { AbilityConstant, bundleManager, common, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';
import { BreakpointConstants, CommonConstants, DBUtil,
  EventBus,
  KvUtil, PreferenceUtil, showToast, WindowUtil } from 'base';
import { BusinessError, deviceInfo } from '@kit.BasicServicesKit';
import { MMKV } from '@tencent/mmkv/src/main/ets/utils/MMKV';
import { JSON } from '@kit.ArkTS';
import PushManager, { GTCmdMessage, GTNotificationMessage, GTTransmitMessage } from '@getui/push';
import { pushService } from '@kit.PushKit';
import { WXApi, WXEventHandler } from '../model/WXApiWrap';
import { DialogHelper } from '@pura/harmony-dialog';
interface HomeModule {
  name: string
}
export default class EntryAbility extends UIAbility {
  private windowObject?: window.Window;
  private windowUtil?: WindowUtil;
  private prefUtil?: PreferenceUtil;
  private kvUtil?: KvUtil;
  private dbUtil?: DBUtil;
  private onWindowSizeChange: (windowSize: window.Size) => void = (windowSize: window.Size) => {
    this.windowUtil?.updateBreakpoint(windowSize.width);
    AppStorage.setOrCreate(BreakpointConstants.WINDOW_WIDTH, windowSize.width);
  }
  private onWindowStatusChange: (windowStatusType: window.WindowStatusType) => void =
    (windowStatusType: window.WindowStatusType) => {
    this.windowUtil?.updateWindowStatusType(windowStatusType);
  }
  async onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): Promise<void> {
    this.windowUtil = WindowUtil.getInstance();
    this.prefUtil = PreferenceUtil.getInstance();
    this.kvUtil = KvUtil.getInstance();
    this.dbUtil = DBUtil.getInstance();
    //MMKV 存储库初始化
    let appCtx = this.context.getApplicationContext();
    let mmkvRootDir = MMKV.initialize(appCtx);
    // console.info('mmkv rootDir: ', mmkvRootDir);
    // hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onCreate');
    //
    DialogHelper.setDefaultConfig((config) => {
      config.uiAbilityContext = this.context;
    })

    // 获取Push Token
    try {
      const pushToken: string = await pushService.getToken();
      hilog.info(0x0000, 'testTag', 'Get push token successfully: %{public}s', pushToken);
    } catch (err) {
      let e: BusinessError = err as BusinessError; hilog.error(0x0000, 'testTag', 'Get push token catch error: %{public}d %{public}s', e.code, e.message);
    }
    //微信
    this.handleWeChatCallIfNeed(want)

    let flag = bundleManager.BundleFlag.GET_BUNDLE_INFO_WITH_SIGNATURE_INFO;
    let bundleInfo = bundleManager.getBundleInfoForSelfSync(flag)
    let appId = bundleInfo.signatureInfo.appId;
    console.log("=====>"+JSON.stringify(appId))
  }

  onDestroy(): void {
    // hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onDestroy');
  }

  async onWindowStageCreate(windowStage: window.WindowStage): Promise<void> {
    // Main window is created, set main page for this ability
    // hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onWindowStageCreate');
    windowStage.getMainWindow().then((data: window.Window) => {
      this.windowObject = data;
      this.windowUtil?.updateBreakpoint(this.windowObject.getWindowProperties().windowRect.width);
      AppStorage.setOrCreate(BreakpointConstants.WINDOW_WIDTH, this.windowObject.getWindowProperties().windowRect.width);
      this.windowObject.on("windowSizeChange", this.onWindowSizeChange);
      this.windowObject.on("windowStatusChange", this.onWindowStatusChange);
    })
    if (this.windowUtil !== undefined) {
      this.windowUtil.setWindowStage(windowStage);
      await this.windowUtil.setMainWindow();
      if (deviceInfo.deviceType !== CommonConstants.DEVICE_TYPES[0]) {
        // console.log("走这里了吗")
        this.windowUtil.setFullScreen();
      }
      this.windowUtil.setAvoidRectHeight();
    }
    // 用户首选项初始化
    this.prefUtil?.loadPreference(this.context);
    // 键值数据库初始化
    this.kvUtil?.initKv(this.context);
    this.dbUtil?.initDB(this.context);
    MMKV.defaultMMKV().decodeString("IsLogins")
    if (MMKV.defaultMMKV().decodeString("IsLogins") == "IsLogin"){
      if (MMKV.defaultMMKV().decodeInt32("CAR_STATUS") == -1 ){//审核驳回
        windowStage.loadContent('pages/Pages_AuditFailed', (err) => {
          if (err.code) {
            // hilog.error(0x0000, 'testTag', 'Failed to load the content. Cause: %{public}s', JSON.stringify(err) ?? '');
            return;
          }
          // hilog.info(0x0000, 'testTag', 'Succeeded in loading the content.');
        });
      }else if (MMKV.defaultMMKV().decodeInt32("CAR_STATUS") == 0) {//未审核
        windowStage.loadContent('pages/Pages_SubmitForRevie', (err) => {
          if (err.code) {
            // hilog.error(0x0000, 'testTag', 'Failed to load the content. Cause: %{public}s', JSON.stringify(err) ?? '');
            return;
          }
          // hilog.info(0x0000, 'testTag', 'Succeeded in loading the content.');
        });
      }else if (MMKV.defaultMMKV().decodeInt32("CAR_STATUS") == 1) {//已审核
        windowStage.loadContent('pages/Index', (err) => {
          if (err.code) {
            // hilog.error(0x0000, 'testTag', 'Failed to load the content. Cause: %{public}s', JSON.stringify(err) ?? '');
            return;
          }
          // hilog.info(0x0000, 'testTag', 'Succeeded in loading the content.');
        });
      }else if (MMKV.defaultMMKV().decodeInt32("CAR_STATUS") == 99 ){//未绑定车辆
        windowStage.loadContent('pages/Pages_Select_Company', (err) => {
          if (err.code) {
            // hilog.error(0x0000, 'testTag', 'Failed to load the content. Cause: %{public}s', JSON.stringify(err) ?? '');
            return;
          }
          // hilog.info(0x0000, 'testTag', 'Succeeded in loading the content.');
        });
      }else{//其他
        windowStage.loadContent('pages/Index', (err) => {
          if (err.code) {
            // hilog.error(0x0000, 'testTag', 'Failed to load the content. Cause: %{public}s', JSON.stringify(err) ?? '');
            return;
          }
          // hilog.info(0x0000, 'testTag', 'Succeeded in loading the content.');
        });
      }
    }else{
      windowStage.loadContent('pages/Pages_Login', (err) => {
        if (err.code) {
          // hilog.error(0x0000, 'testTag', 'Failed to load the content. Cause: %{public}s', JSON.stringify(err) ?? '');
          return;
        }
        // hilog.info(0x0000, 'testTag', 'Succeeded in loading the content.');
      });
    }
  }

  onWindowStageDestroy(): void {
    // Main window is destroyed, release UI related resources
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onWindowStageDestroy');
  }

  onForeground(): void {
    // Ability has brought to foreground
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onForeground');
    //刷新首页数据
    let eventData: HomeModule = {
      name: '前台刷新',
    }
    EventBus.send('HomeModule', eventData)
  }

  onBackground(): void {
    // showToast("返回后台===>")
    // Ability has back to background
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onBackground');
  }

  //微信支付 || 登录
  onNewWant(want: Want, _launchParam: AbilityConstant.LaunchParam): void {
    this.handleWeChatCallIfNeed(want)
  }

  private handleWeChatCallIfNeed(want: Want) {
    WXApi.handleWant(want, WXEventHandler)
  }
}
