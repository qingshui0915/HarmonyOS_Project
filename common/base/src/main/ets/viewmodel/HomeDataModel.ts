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
    TodayPeople: number | null;
    TodayFinishOrder: number | null;
    TodayMoney: number | null;
    WaitOrderCount: number | null;
    Expire: boolean;
    LineList: LineList[];
}