export class InquireIdCardModel {
    statusCode: number;
    message: string;
    code: any;
    details: any;
    data: Data;
    ext: any;
}

export class Info {
    IdCardPersonUrl: string;
    IdCardUrl: string;
    Name: string;
    IdCardNo: string;
    Gender: string;
    Nation: string;
    Birthday: string;
    Nationality: string;
    IdcardSignsBy: string;
    IdCardExpiryDate: string;
    Telephone: any;
}

export class Data {
    AuthStatus: number;
    AuthFailReason: string;
    IsComplete: boolean;
    Info: Info;
}