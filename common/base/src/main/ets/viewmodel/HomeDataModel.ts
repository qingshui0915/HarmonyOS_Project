export class HomeDataModel {
    statusCode: number;
    message: string;
    code: string | null;
    details: string | null;
    data: Data;
}

export class LineList {
    Id: string;
    StartCity: string;
    EndCity: string;
    OrderCount: number;
}

export class Data {
    TodayPeople: number;
    TodayFinishOrder: number;
    TodayMoney: number;
    WaitOrderCount: number;
    Expire: boolean;
    LineList: LineList[];
}