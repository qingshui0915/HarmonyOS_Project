export class SubmitDriverCardModel{
  DriverCardPageUrl:string = ""//	驾驶证主页照片
  DriverCardSidePageUrl:string = ""// 	驾驶证副页照片
  ClassMode:string = ""//准驾车型
  ValidStart:string = ""//有效期 起
  ValidEnd:string = ""//有效期 止(长期有效默认+10年)
}