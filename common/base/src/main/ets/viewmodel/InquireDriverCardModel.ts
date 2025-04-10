export class InquireDriverCardModel {
    statusCode: number;
    message: string;
    code: any;
    details: any;
    data: Data;
    ext: any;
}

export class Info {
    DriverCardPageUrl: string;
    DriverCardSidePageUrl: string;
    ClassMode: string;
    ValidStart: string;
    ValidEnd: string;
}

export class Data {
    AuthStatus: number;
    AuthFailReason: string;
    IsComplete: boolean;
    Info: Info;
}