export class OrderTaskModel {
    statusCode: number;
    message: string;
    code: any;
    details: any;
    data: Data[];

}

export class Data {
    ShiftId: string;
    StartCity: string;
    EndCity: string;
    GoTime: string;
    DayName: string;
    DayDate: string;
    DayTime: string;
    BookCount: number;
    UseCount: number;

}