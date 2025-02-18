export class OrderListDetailModel {
    statusCode: number;
    message: string;
    code: null |number;
    details: null | string |number;
    data: Data;
}

export class Data {
    Code: number;
    Id: string;
    StartCity: string;
    StartPlace: string;
    StartLat: number;
    StartLng: number;
    EndCity: string;
    EndPlace: string;
    EndLat: number;
    EndLng: number;
    CouponId: null | string;
    GoTime: string;
    VehicleCompanyName: null | string;
    DayName: string;
    DayTime: string;
    Name: string;
    Phone: string;
    BookSeat: number;
    Amont: number;
    HistoryBookSeatNum: number;
    BookSeatNum: number;
    DriverAmount: number;
    DiscountMoney: null | string |number;
    DriverDiscountAmount: number;
    BizState: number;
    OrderStatus: number;
    Category: null | string |number;
    Platform: number;
    PlatformTxt: null | string ;
    UserRemark: string;
    BackRemark: null | string ;
    Status: number;
    EndStatus: number;
    IsCountDriverPay: number;
    PayedFee: number;
    CllineId: null | string ;
}