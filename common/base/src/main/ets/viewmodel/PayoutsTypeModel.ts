export class PayoutsTypeModel {
    statusCode: number;
    message: string;
    code: any;
    details: any;
    data: Data[];
}

export class Data {
    Platform: number;
    Type: number;
    TypeName: string;
    MinWithdrawMoney: number;
    MaxWithdrawMoney: number;
    WithdrawAccountInfo: any;
}