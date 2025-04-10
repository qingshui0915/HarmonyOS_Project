import { BreakpointConstants, CommonConstants, Logger, WindowUtil , EventBus, Api, showToast} from 'base';
import { router, window } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import { MainPage } from 'home';
import { notificationManager } from '@kit.NotificationKit';
import { common } from '@kit.AbilityKit';
import PushManager, { GTCmdMessage, GTNotificationMessage, GTTransmitMessage } from '@getui/push';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { MMKV } from '@tencent/mmkv';
import { JSON } from '@kit.ArkTS';
import { textToSpeech } from '@kit.CoreSpeechKit';
//测试EventBus 数据
interface DeliverToPassengerModule {
  name: string
}
interface SendFlushedModule {
  name: string
}
interface HomeModule {
  name: string
}
// 创建引擎实例相关参数
let ttsEngine: textToSpeech.TextToSpeechEngine;

@Entry
@Component
struct Index {
  @Provide(CommonConstants.PAGE_INFOS) pageInfos: NavPathStack = new NavPathStack();
  @StorageLink(BreakpointConstants.IS_SPLIT_MODE) isSplitMode: boolean = false;
  private windowUtil?: WindowUtil;
  private mainWindow?: window.Window;
  @State triggerStatus :boolean = true
  private context = getContext(this) as common.UIAbilityContext;
  @State back_Type:Record<string, string> = {}
  @State newOrderText: string = "您有新的定制客运订单,请查看";
  @State unsubscribeText: string = "您的客运订单已退订,请查看";
  @State voiceInfo: string = "";

  aboutToAppear(): void {
    console.log("Index====>aboutToAppear")
    this.createByCallback()
    //
    //初始化GTSDK
    PushManager.initialize({
      context: this.context as common.UIAbilityContext,
      onSuccess: (cid:string) => {
        MMKV.defaultMMKV().encodeString("CID",cid)
        hilog.debug(0x0000, "EntryAbility", '%{public}s', "个推SDK初始化成功，cid = " + cid);
        this.bindGTPush(cid)
      },
      onFailed: (error:string) => {
        hilog.debug(0x0000, "EntryAbility", '%{public}s', "个推SDK初始化失败，error = " + error);
      }
    })
    console.log("token:"+JSON.stringify(AppStorage.get("Token")))
    //权限提醒
    notificationManager.requestEnableNotification(this.context).then(() => {
      console.log("notify", '%{public}s', 'requestEnableNotification success')
    }).catch((err: BusinessError) => {
      console.log("notify", '%{public}s', "error = " + err.message)
    })
    if (this.isSplitMode) {
      // 跟路由推送页面
    }

    PushManager.setPushCallback({
      // 接收 cid
      onReceiveClientId: (clientId:string) => {
        hilog.debug(0x0000, 'EntryAbility', '%{public}s', "clientId = " + clientId);
      },
      //接收厂商token
      onReceiveDeviceToken: (token:string) => {
        hilog.debug(0x0000, 'EntryAbility', '%{public}s', "token = " + token);
      },
      // cid 离线上线通知
      onReceiveOnlineState: (onLine:boolean) => {
        hilog.debug(0x0000, 'EntryAbility', '%{public}s', "onLine = " + onLine);
      },
      //命令相应回复
      onReceiveCommandResult: (result: GTCmdMessage) => {
        hilog.debug(0x0000, 'EntryAbility', '%{public}s', "cmd = " + JSON.stringify(result));
      },
      //sdk 收到透传消息
      onReceiveMessageData: (message: GTTransmitMessage) => {
        hilog.debug(0x0000, 'EntryAbility_收到透传消息', '%{public}s', "message = " + JSON.stringify(message));
        if (message.payload) {
          const msg =  message.payload
          console.log("收到透传消息===>"+JSON.stringify(msg))
          this.back_Type  = JSON.parse(msg) as Record<string, string>
          console.log("收到透传消息222===>"+JSON.stringify(this.back_Type))
          if (this.back_Type?.Type === 'CLDriver_NewOrderAudioTip') {
            // 通知Request对象
            let notificationRequest: notificationManager.NotificationRequest = {
              id: 1,
              content: {
                notificationContentType: notificationManager.ContentType.NOTIFICATION_CONTENT_BASIC_TEXT,
                normal: {
                  title: "哈哈客运司机",
                  text: "您有新的客运订单,请查看",
                  additionalText: ""
                }
              }
            };
            notificationManager.publish(notificationRequest).then(() => {
              console.info(`通知发送成功`);
              this.triggerStatus = false

              this.speak(1);
            }).catch((err: BusinessError) => {
              console.error(`通知发送失败. Code is ${err.code}, message is ${err.message}`);
            });
          }else if (this.back_Type?.Type === 'CLDriver_RefundorderAudioTip'){
            // 通知Request对象
            let notificationRequest: notificationManager.NotificationRequest = {
              id: 1,
              content: {
                notificationContentType: notificationManager.ContentType.NOTIFICATION_CONTENT_BASIC_TEXT,
                normal: {
                  title: "哈哈客运司机",
                  text: "您的客运订单已退订,请查看",
                  additionalText: ""
                }
              }
            };
            notificationManager.publish(notificationRequest).then(() => {
              console.info(`通知发送成功`);
              this.triggerStatus = false

              this.speak(2);
            }).catch((err: BusinessError) => {
              console.error(`通知发送失败. Code is ${err.code}, message is ${err.message}`);
            });
          }
        }

      },
      //通知到达回调
      onNotificationMessageArrived: (message: GTNotificationMessage)  => {
        hilog.debug(0x0000, 'EntryAbility', '%{public}s', "message = " + JSON.stringify(message));
      },
      //通知点击回调, 需要配合PushManager.setClickWant(want)使用
      onNotificationMessageClicked: (message: GTNotificationMessage) => {
        hilog.debug(0x0000, 'EntryAbility', '%{public}s', "message = " + JSON.stringify(message));
      },
    })
  }



  onPageShow(): void {
    console.log("Index====>onPageShow")
    EventBus.listen<SendFlushedModule>('SendFlushedModule', (data) => {
      if (data !== undefined) {
        if (data.name == "补齐证件") {
          console.log("触发了吗===>"+JSON.stringify(data))
          //刷新列表
          this.triggerStatus = false
        }
      }
    })

    EventBus.listen<DeliverToPassengerModule>('DeliverToPassenger', (data) => {
      if (data !== undefined) {
        if (data.name == "送达乘客") {
          console.log("送达乘客触发了吗===>"+JSON.stringify(data))
          this.triggerStatus = false
        }
      }
    })
    //息屏刷新
    EventBus.listen<HomeModule>('HomeModule', (data) => {
      if (data !== undefined) {
        if (data.name == "前台刷新") {
          console.log("前台刷新===>"+JSON.stringify(data))
          this.triggerStatus = false
        }
      }
    })
  }

  onPageHide(): void {
    //取消订阅
    EventBus.cancel('NoticeChildPages')
  }

  //绑定个推
  async bindGTPush(cid:string){
    // const cids =MMKV.defaultMMKV().decodeString("CID") as string
    let cids :Record<string, string> = {
      "cid":cid
    }
    let res = await Api.net().bindGTPush(cids);
    if (res.isSuccessWithData()) {
      if (res.data?.statusCode == 200) {

      }else{
        showToast(res.data?.message+"")
      }
    }else{
      showToast(res.message)
    }
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


  // 创建引擎，通过callback形式返回
  private createByCallback() {
    // 设置创建引擎参数
    let extraParam: Record<string, Object> = {"style": 'interaction-broadcast', "locate": 'CN', "name": 'EngineName'};
    let initParamsInfo: textToSpeech.CreateEngineParams = {
      language: 'zh-CN',
      person: 0,
      online: 1,
      extraParams: extraParam
    };

    // 调用createEngine方法
    textToSpeech.createEngine(initParamsInfo, (err: BusinessError, textToSpeechEngine: textToSpeech.TextToSpeechEngine) => {
      if (!err) {
        console.info('Succeeded in creating engine.');
        // 接收创建引擎的实例
        ttsEngine = textToSpeechEngine;
      } else {
        console.error(`Failed to create engine. Code: ${err.code}, message: ${err.message}.`);
      }
    });
  };

  // 调用speak播报方法
  private speak(type:number) {
    let speakListener: textToSpeech.SpeakListener = {
      // 开始播报回调
      onStart(requestId: string, response: textToSpeech.StartResponse) {
        console.info(`onStart, requestId: ${requestId} response: ${JSON.stringify(response)}`);
      },
      // 完成播报回调
      onComplete(requestId: string, response: textToSpeech.CompleteResponse) {
        console.info(`onComplete, requestId: ${requestId} response: ${JSON.stringify(response)}`);
      },
      // 停止播报完成回调，调用stop方法并完成时会触发此回调
      onStop(requestId: string, response: textToSpeech.StopResponse) {
        console.info(`onStop, requestId: ${requestId} response: ${JSON.stringify(response)}`);
      },
      // 返回音频流
      onData(requestId: string, audio: ArrayBuffer, response: textToSpeech.SynthesisResponse) {
        console.info(`onData, requestId: ${requestId} sequence: ${JSON.stringify(response)} audio: ${JSON.stringify(audio)}`);
      },
      // 错误回调，播报过程发生错误时触发此回调
      onError(requestId: string, errorCode: number, errorMessage: string) {
        console.error(`onError, requestId: ${requestId} errorCode: ${errorCode} errorMessage: ${errorMessage}`);
      }
    };
    // 设置回调
    ttsEngine.setListener(speakListener);
    // 设置播报相关参数
    let extraParam: Record<string, Object> = {"queueMode": 0, "speed": 1, "volume": 2, "pitch": 1, "languageContext": 'zh-CN', "audioType": "pcm", "soundChannel": 3, "playType":1}
    let speakParams: textToSpeech.SpeakParams = {
      requestId: '123456-a', // requestId在同一实例内仅能用一次，请勿重复设置
      extraParams: extraParam
    };
    // 调用speak播报方法
    if (type == 1) {
      ttsEngine.speak(this.newOrderText, speakParams);
    }else if (type == 2){
      ttsEngine.speak(this.unsubscribeText, speakParams);
    }

  };

  // // 查询语种音色信息，以callback形式返回
  // private listVoicesCallback() {
  //   // 设置查询相关参数
  //   let voicesQuery: textToSpeech.VoiceQuery = {
  //     requestId: '123456-b', // requestId在同一实例内仅能用一次，请勿重复设置
  //     online: 1
  //   };
  //
  //   // 调用listVoices方法，以callback返回语种音色查询结果
  //   ttsEngine.listVoices(voicesQuery, (err: BusinessError, voiceInfo: textToSpeech.VoiceInfo[]) => {
  //     if (!err) {
  //       // 接收目前支持的语种音色等信息
  //       this.voiceInfo = JSON.stringify(voiceInfo);
  //       console.info(`Succeeded in listing voices, voiceInfo is ${voiceInfo}`);
  //     } else {
  //       console.error(`Failed to list voices. Code: ${err.code}, message: ${err.message}`);
  //     }
  //   });
  // };
}