export class AllOrderListModel {
    data: Data[];
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
    CouponId: any;
    GoTime: string;
    VehicleCompanyName: any;
    DayName: string;
    DayTime: string;
    Name: string;
    Phone: string;
    BookSeat: number;
    Amont: number;
    HistoryBookSeatNum: number;
    BookSeatNum: number;
    DriverAmount: number;
    DiscountMoney: number;
    DriverDiscountAmount: number;
    BizState: number;
    OrderStatus: number;
    Category: any;
    Platform: number;
    PlatformTxt: any;
    UserRemark: string;
    BackRemark: string | null;
    Status: number;
    EndStatus: number;
    IsCountDriverPay: number;
    PayedFee: number;
    CllineId: string;
}