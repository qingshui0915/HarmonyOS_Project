export class UserInfoModel {
    statusCode: number;
    message: string;
    code: any;
    details: any;
    data: Data;
}

export class Data {
    Id: string;
    Name: string;
    Phone: string;
    RawPhone: string;
    OpenId: string;
    Photo: string;
    Balance: number;
    BlockedBalance: number;
    IsEnable: number;
    LastChangeNameTime: any;
    LastChangePhone: any;
    LastLoginTime: string;
    TodayPeople: number;
    MouthPeople: number;
    VerhicheNumber: string;
    IsBindCar: boolean;
    CarStatus: number;
    CarCertificateExpiry: boolean;
    IsBindWxToApp: boolean;
    NickName: string;
    AvatarUrl: string;
    CarId: string;
    PendingEntryAmount: number;
    LastLoginClientId: string;
}