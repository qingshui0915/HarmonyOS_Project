export class BalanceRecordsModel {
    statusCode: number;
    message: string;
    code: any;
    details: any;
    data: Data;
}

export class Item {
    Action: number;
    Money: number;
    NowMoney: number;
    CreateTime: string;
    Note: string;
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