export class HomeIndexModel {
    statusCode: number;
    message: string;
    code: any;
    details: any;
    data: Data;
}

export class LineList {
    Id: string;
    StartCity: string;
    EndCity: string;
    OrderCount: number;
}

export class Data {
    Code: number;
    TodayPeople: number;
    TodayFinishOrder: number;
    TodayMoney: number;
    WaitOrderCount: number;
    TodayWaitOrderCount: number ;
    TodaySmall: number ;
    WaitSmallOrderCount: number;
    TodayWaitSmallOrderCount: number;
    VehicleState: number;
    LineList: LineList[];
    Expire: boolean;
    LastLoginClientId: string;
}