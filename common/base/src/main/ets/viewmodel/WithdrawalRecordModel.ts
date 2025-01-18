export class WithdrawalRecordModel {
    statusCode: number;
    message: string;
    code: any;
    details: any;
    data: Data;
}

export class Item {
    DriverId: string;
    OrderNo: string;
    Money: number;
    RealName: string;
    CreateTime: string;
    Note: any;
    Status: number;
    AuthTime: any;
    AuthUser: any;
    AuthNote: any;
    KefuRemark: any;
    Platform: number;
    Type: number;
    BankName: any;
    BankCode: any;
    BankNo: string;
    ServiceCharge: number;
    AccountingTime: any;
    Id: string;
}

export class Data {
    PageSize: number;
    CurrentPageIndex: number;
    PageCount: number;
    IsLastPage: boolean;
    IsFirstPage: boolean;
    Total: number;
    Item: Item[];
    ConfigurationParams: any;
}