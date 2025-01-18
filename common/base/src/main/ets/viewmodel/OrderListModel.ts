export class OrderListModel {
    statusCode: number;
    message: string;
    code: any;
    details: any;
    data: Data;
}

export class Item {
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
    BizState: any;
    OrderStatus: number;
    Category: any;
    Platform: number;
    PlatformTxt: string;
    UserRemark: string;
    BackRemark: any;
    Status: number;
    EndStatus: number;
    IsCountDriverPay: number;
    PayedFee: number;
    CllineId: any;
}

export class ConfigurationParams {
    OrderCount: number;
    OrderAmount: number;
    Code: number;
}

export class Data {
    PageSize: number;
    CurrentPageIndex: number;
    PageCount: number;
    IsLastPage: boolean;
    IsFirstPage: boolean;
    Total: number;
    Item: Item[];
    ConfigurationParams: ConfigurationParams;
}