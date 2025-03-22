@Observed
export class MakerInfoModel{
  id:number = 0;
  orderId:string = "";
  goTime:string = "";
  name:string= "";
  phone:string= "";
  num:string= "";
  time:string= "";
  month:string= "";
  startLatLng:string= "";
  endLatLng:string= "";
  startAddress:string= "";
  endAddress:string= "";

  // constructor(orderId: string, goTime: string, name: string, phone: string, num: string, time: string, month: string,
  //   startLatLng: string, endLatLng: string, startAddress: string, endAddress: string) {
  //   this.orderId = orderId;
  //   this.goTime = goTime;
  //   this.name = name;
  //   this.phone = phone;
  //   this.num = num;
  //   this.time = time;
  //   this.month = month;
  //   this.startLatLng = startLatLng;
  //   this.endLatLng = endLatLng;
  //   this.startAddress = startAddress;
  //   this.endAddress = endAddress;
  // }
}

// @Observed
// export class MakerInfoListModel{
//   moneyList: Array<MakerInfoModel>;
//
//   constructor(moneyList: Array<MakerInfoModel>) {
//     this.moneyList = moneyList;
//   }
// }