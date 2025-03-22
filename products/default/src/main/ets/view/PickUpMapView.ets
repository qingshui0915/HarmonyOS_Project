import { ArrayList, JSON } from '@kit.ArkTS';
import { router } from '@kit.ArkUI';
import { MMKV } from '@tencent/mmkv';
import { Api, CommonConstants, LoadingUtils, showToast } from 'base';
import { AllOrderListModel, Data } from 'base/src/main/ets/viewmodel/AllOrderListModel';
import { MakerInfoModel } from '../viewmodel/MakerInfoModel';
import { AMap,
  BasePointOverlay,
  BitmapDescriptorFactory,
  CameraUpdateFactory,
  InfoWindowListener,
  LatLng,
  LatLngBounds,
  MapsInitializer, MapView, MapViewComponent, MapViewManager,
  Marker,
  MarkerOptions } from '@amap/amap_lbs_map3d';
import { abilityAccessCtrl, common, PermissionRequestResult, Permissions, Want } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { AMapLocationManagerImpl } from '@amap/amap_lbs_location';
import { AMapPrivacyAgreeStatus, AMapPrivacyInfoStatus, AMapPrivacyShowStatus } from '@amap/amap_lbs_common';
import { call, observer } from '@kit.TelephonyKit';
import { showDialogBottomList } from '@abner/dialog';
import { GlobalThis } from '../entryability/GlobalThis';

let globalContext: Context;
/**
 * 接客地图
 */
@Component
export struct PickUpMapView {
  private mapView? : MapView;
  private aMap? : AMap;
  @State ordersId:string = ""
  @State showLoading: boolean = false;
  @State allOrderList:AllOrderListModel = new AllOrderListModel()
  @State disposeOrderList:Data[] = []
  @State markerList :Array<MakerInfoModel> = []
  @State markerModel : MakerInfoModel = new MakerInfoModel()
  //集合数据处理
  @State groupedMarkers: Map<string, Array<MakerInfoModel>> = new Map()
  @State filteredGroups: Array<Array<MakerInfoModel>> = []
  @State markersList: MakerInfoModel[] = []


  async getTaskList(){
    const carId = MMKV.defaultMMKV().decodeString("CAR_ID") as string
    LoadingUtils.showLoading("加载中...");
    let res = await Api.net().getOrderData(carId,this.ordersId["value1"],this.ordersId["value2"]);
    if (res.isSuccessWithData()) {
      LoadingUtils.hideLoading();
      this.allOrderList =  res.data as AllOrderListModel
      this.disposeOrderList = this.allOrderList.data
      this.markerList = []
      for (let i = 0; i < this.disposeOrderList.length; i++) {
        const orderBean = this.disposeOrderList[i]
        const marker = new MakerInfoModel()
        marker.id = (i+1)
        marker.orderId = orderBean.Id
        marker.goTime = orderBean.GoTime
        marker.name = orderBean.Name
        marker.phone = orderBean.Phone
        marker.num = '尾号：' + orderBean.Phone.substring(7, 11)
        marker.time = orderBean.DayTime
        marker.month = orderBean.GoTime.split(" ")[0]
        marker.startLatLng = orderBean.StartLat + "," + orderBean.StartLng
        marker.endLatLng = orderBean.EndLat + "," + orderBean.EndLng
        marker.startAddress = orderBean.StartPlace
        marker.endAddress = orderBean.EndPlace
        this.markerList.push(marker)
      }
      console.log("打印封装marker信息集合===>"+JSON.stringify(this.markerList))
    }else{
      LoadingUtils.hideLoading();
      showToast(res.message)
    }
  }
  private  zoomToSpan() {
    if (this.markerList.length > 0 && this.aMap) {
      for (let i = 0; i <this.markerList.length; i++) {
        let b = LatLngBounds.builder();
        b.include(new LatLng(parseFloat(this.markerList[i].startLatLng.split(",")[0]),parseFloat(this.markerList[i].startLatLng.split(",")[1])))
        this.aMap.moveCamera(CameraUpdateFactory.newLatLngBounds(b.build(),10))
      }
    }
  }


  private mapViewCreateCallback = (mapview?: MapView, mapViewName?: string) => {
    if (!mapview) {
      return;
    }
    this.mapView = mapview;
    this.mapView.onCreate();
    this.mapView.getMapAsync(async (map) => {
      this.aMap = map;
      console.log("打印封装marker信息集合111===>" + JSON.stringify(this.markerList))
      // 这里处理marker数据并展示
      if (this.markerList.length > 0) {
        let markerOptionsList: ArrayList<MarkerOptions> = new ArrayList<MarkerOptions>()
        for (let i = 0; i < this.markerList.length; i++) {
          let options1: MarkerOptions = new MarkerOptions()
            .setPosition(new LatLng(parseFloat(this.markerList[i]?.startLatLng.split(",")[0]),
              parseFloat(this.markerList[i]?.startLatLng.split(",")[1])))
          // let bitmapDes = await BitmapDescriptorFactory.fromRawfilePath(globalContext, "custom_maker.png");
          let bitmapDes = await BitmapDescriptorFactory.fromView(() => {
            this.customMarkerBuilder(this.markerList.length);
          });
          if (bitmapDes) {
            options1.setIcon(bitmapDes);
          }
          options1.setTitle(this.markerList[i].name)
          options1.setSnippet(this.markerList[i].num)
          options1.setClickable(true)
          markerOptionsList.add(options1);
        }
        let marker1 = this.aMap.addMarkers(markerOptionsList, false);
        //所有marker显示在当前页面的可视范围内
        this.zoomToSpan()
        // 初始化分组数据
        let tempMap = new Map<string, Array<MakerInfoModel>>()
        this.markerList.forEach(marker => {
          // 使用相同的格式构建 key
          const lat = parseFloat(marker.startLatLng.split(",")[0])
          const lng = parseFloat(marker.startLatLng.split(",")[1])
          const key = `${lat},${lng}`
          if (!tempMap.has(key)) {
            tempMap.set(key, [])
          }
          tempMap.get(key)?.push(marker)
        })
        this.groupedMarkers = tempMap
        console.log("集合数据处理====>"+JSON.stringify(this.groupedMarkers))

      }
      //infoWindowAdapter
      this.aMap.setInfoWindowAdapter(()=>{
        this.customInfoWindowBuilder()
      })

      this.aMap?.addInfoWindowListener(new InfoWindowListener(
        //show
        (marker:BasePointOverlay)=>{
          const position = marker?.getPosition()
          console.log("marker位置===>", JSON.stringify(position))
          const key = `${position?.latitude},${position?.longitude}`
          const markers = this.groupedMarkers.get(key) || []
          this.markersList = markers
          console.log("找到的markers数量===>", markers.length)
        },
        //hide
        (marker :BasePointOverlay)=>{

        }
      ));
      //marker点击事件
      this.aMap.setOnMarkerClickListener((marker: Marker): boolean => {
        console.log("marker被点击===>")
        marker.showInfoWindow()
        return true
      });

    })
  }



  aboutToAppear(): void {
    LoadingUtils.init(this.getUIContext());
    //本页面请求坐标集合
    this.ordersId =  router.getParams() as string
    console.log("页面传参1111==>"+JSON.stringify(this.ordersId))
    // 等待数据加载完成
    this.getTaskList()


    globalContext = getContext().getApplicationContext();
    MapsInitializer.setApiKey("2d92af4a266beadb78a91b4e6a828363");
    MapsInitializer.setDebugMode(true);
    MapViewManager.getInstance().registerMapViewCreatedCallback(this.mapViewCreateCallback);
  }

  aboutToDisappear(): void {
    if (this.mapViewCreateCallback) {
      MapViewManager.getInstance().unregisterMapViewCreatedCallback(this.mapViewCreateCallback);
    }

    if (this.mapView) {
      this.mapView.onDestroy();
      this.mapView = undefined;
      this.aMap = undefined;
    }
  }

  locationManger?: AMapLocationManagerImpl;
  private context = getContext(this);

  onPageShow() {
    //设置Key
    AMapLocationManagerImpl.setApiKey("2d92af4a266beadb78a91b4e6a828363");

    //初始化隐私政策
    AMapLocationManagerImpl.updatePrivacyShow(AMapPrivacyShowStatus.DidShow, AMapPrivacyInfoStatus.DidContain, getContext(this))
    AMapLocationManagerImpl.updatePrivacyAgree(AMapPrivacyAgreeStatus.DidAgree, getContext(this))
    //创建AMapLocationManagerImpl
    this.locationManger = new AMapLocationManagerImpl(this.context);

  }
  //权限请求
  reqPermissionsFromUser(permissions: Array<Permissions>,address: string, latLng: string): void {
    let context: Context = getContext(this) as common.UIAbilityContext;
    let atManager: abilityAccessCtrl.AtManager = abilityAccessCtrl.createAtManager();
    // requestPermissionsFromUser会判断权限的授权状态来决定是否唤起弹窗
    atManager.requestPermissionsFromUser(context, permissions).then((data: PermissionRequestResult) => {
      let grantStatus: Array<number> = data.authResults;
      let length: number = grantStatus.length;
      for (let i = 0; i < length; i++) {
        if (grantStatus[i] === 0) {
          // 用户授权，可以继续访问目标操作
          showDialogBottomList({
            items: ["高德地图", "华为地图"],
            dialogAttribute: {
              isSystemAnimation: false//取消系统的动画
            },
            itemDivider: {
              height: 0.5
            },
            cancelAttr: {
              paddingBottom: 20
            },
            itemClick: (position: number) => {
              console.log("==========:" + position)
              if (position == 0) {//高德地图
                this.jumpToGaode(latLng.split(",")[1],latLng.split(",")[0],address)
              }else if (position == 1){//华为地图
                this.jumpToPetal(latLng.split(",")[1],latLng.split(",")[0],address)
              }
            }
          })
        } else {
          // 用户拒绝授权，提示用户必须授权才能访问当前页面的功能，并引导用户到系统设置中打开相应的权限
          this.openPermissionsInSystemSettings()
          return;
        }
      }
      // 授权成功
    }).catch((err: BusinessError) => {
      console.error(`Failed to request permissions from user. Code is ${err.code}, message is ${err.message}`);
    })
  }

  openPermissionsInSystemSettings(): void {
    let context: common.UIAbilityContext|undefined  = GlobalThis.getInstance().getContext('context');
    let wantInfo: Want = {
      action: 'action.settings.app.info',
      parameters: {
        settingsParamBundleName: 'com.example.myapplication' // 打开指定应用的详情页面
      }
    }
    context?.startAbility(wantInfo).then(() => {
      // ...
    }).catch((err: BusinessError) => {
      // ...
    })
  }


  @Builder
  customMarkerBuilder(num:number){
    RelativeContainer(){
      Column(){
        Image($r('app.media.custom_maker'))
      }
      .padding(5)
      .alignRules({
        middle: { anchor: "__container__", align: HorizontalAlign.Center },
        center: { anchor: "__container__", align: VerticalAlign.Center },
      })
      Column() {
        Text(num.toString())
          .fontColor($r("app.color.white"))
          .fontSize(9)
          .width(12)
          .height(12)
          .textAlign(TextAlign.Center)
          .borderRadius(6)
          .backgroundColor(Color.Red)
      }
      .visibility(num<=1 ? Visibility.None : Visibility.Visible)
      .alignRules({
        top: { anchor: "__container__", align: VerticalAlign.Top },
        right: { anchor: "__container__", align: HorizontalAlign.End },
      })
    }
    .width(45)
    .height(50)
    .borderRadius(3)
  }

  @Builder
  customInfoWindowBuilder(){
    Column() {
      List() {
        ForEach(this.markersList, (marker: MakerInfoModel) => {
          ListItem() {
            Row() {
              Column({space:5}) {
                Row() {
                  Text(marker?.time)
                    .fontSize(16)
                    .fontWeight(FontWeight.Bold)
                  Text(marker?.month)
                    .fontSize(11)
                    .margin({ left: 5 })
                }
                .alignItems(VerticalAlign.Center)
                .justifyContent(FlexAlign.Center)

                Row() {
                  Text(marker?.name)
                    .fontSize(14)
                    .fontWeight(FontWeight.Bold)
                  Text(marker?.num)
                    .fontSize(12)
                    .fontColor($r('app.color.my_button_cz_color'))
                    .margin({ left: 5 })
                }
                .alignItems(VerticalAlign.Center)
                .justifyContent(FlexAlign.Center)
              }
              .alignItems(HorizontalAlign.Start)

              Row() {
                Image($r('app.media.phone'))
                  .width(35)
                  .height(35)
                  .margin({ right: 16 })
                  .onClick(() => {
                    // 处理拨打电话
                    this.handleCallPhone(marker.phone)
                  })

                Image($r('app.media.location_icon'))
                  .width(35)
                  .height(35)
                  .onClick(() => {
                    // 处理导航
                    this.handleNavigation(marker.startAddress, marker.startLatLng)
                  })
              }
            }
            .justifyContent(FlexAlign.Center)
            .alignItems(VerticalAlign.Center)
            .width('100%')
            .padding(10)
          }
          .backgroundColor(Color.White)
          .borderRadius(8)
          .margin({ bottom: 8 })
        })
      }
      .width('100%')
    }
    .width(250)
    .backgroundColor(Color.White)
    .borderRadius(12)
  }


  // 处理拨打电话
  private handleCallPhone(phone: string) {
    // 实现获取隐私号码并拨打电话的逻辑
    let isSupport = call.hasVoiceCapability();
    if (isSupport) {
      // 如果设备支持呼叫能力，则继续跳转到拨号界面，并显示拨号的号码
      call.makeCall( phone, (err: BusinessError) => {
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
  }

  // 处理导航
  private handleNavigation(address: string, latLng: string) {
    // //获取权限
    // this.reqPermissionsFromUser([
    //   // 'ohos.permission.APPROXIMATELY_LOCATION',
    //   'ohos.permission.LOCATION',
    // ],address,latLng);
    showDialogBottomList({
      items: ["高德地图", "华为地图"],
      dialogAttribute: {
        isSystemAnimation: false//取消系统的动画
      },
      itemDivider: {
        height: 0.5
      },
      cancelAttr: {
        paddingBottom: 20
      },
      itemClick: (position: number) => {
        console.log("==========:" + position)
        if (position == 0) {//高德地图
          this.jumpToGaode(latLng.split(",")[0],latLng.split(",")[1],address)
        }else if (position == 1){//华为地图
          this.jumpToPetal(latLng.split(",")[0],latLng.split(",")[1],address)
        }
      }
    })
  }

  jumpToGaode(lng: string, lat: string, addressName: string){
    let uri = 'amapuri://route/plan?' +
      `dlon=${lng}&dlat=${lat}&dname=${addressName}&t=0&sourceApplication=applicationName`
    let want: Want = { uri: uri }
    const content = getContext(this) as common.UIAbilityContext
    content.startAbility(want, (err: BusinessError) => {
      if (err.code) {
        hilog.debug(1000, 'test', 'err=' + err)
      }
    })
  }

  jumpToPetal(lng: string, lat: string, addressName: string){
    let uri = 'maps://routes'
    let want: Want = {
      bundleName: 'com.huawei.hmos.maps.app',
      uri: uri,
      parameters: {
        linkSource: 'cn.hnxzkj.dz.driver',
        destinationLatitude: lat,
        destinationLongitude: lng,
        destinationName: addressName,
      }
    }
    const content = getContext(this) as common.UIAbilityContext
    content.startAbility(want, (err: BusinessError) => {
      if (err.code) {
        hilog.debug(1000, 'test', 'err=' + err)
      }
    })
  }



  build() {
    Column() {
      Row() {
        MapViewComponent()
          .width('100%')
          .height('100%')
      }
    }
    .width('100%')
    .height('100%')
  }


}