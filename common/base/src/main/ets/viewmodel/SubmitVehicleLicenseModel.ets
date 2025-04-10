export class SubmitVehicleLicenseModel{
  TaxiLicensePhoto:string = ""  //运输证url
  TransportCertsNumber:string = "" //道路运输证号 (不必填)
  TransportCertsOwner:string = ""  //道路运输证业户名称 (不必填)
  TransportCertsIssuer:string = "" //核发机关行政区划代码 (不必填)
  BusinessScope:string = "" //经营范围
  Seats:string = "" //核定载客位
  SignsNmber:string = "" //定制客运标志牌号
  Ownership:string = "" //所有制
  TypeLevel:string = "" //车辆类型等级
  SignsDateStart:string = "" //定制客运标志牌日期起
  SignsDateEnd:string = "" //定制客运标志牌日期止
  TaxiLicenseExpiryDate:string = "" //车辆运输证有效期止YYYY-MM-DD
  QualificationCertificatePhoto:string = "" //从业资格证照片
  LicenseNumber:string = "" //从业资格证号
  LicensePassengerTrans:boolean = true //从业资格是否具备客运资格类别
  QualificationCertificateExpiryDate:string = ""//从业资格证过期时间
}