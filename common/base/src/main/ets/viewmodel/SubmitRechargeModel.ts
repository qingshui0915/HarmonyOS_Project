export class SubmitRechargeModel {
    statusCode: number;
    message: string;
    code: any;
    details: any;
    data: Data;
}

export class Data {
    UserId: string;
    OrderNo: string;
    Code: any;
    TradeNo: any;
    PayType: string;
    OrderAmount: number;
    PayableAmount: number;
    PayedAmount: number;
    Status: number;
    Remark: any;
    CreateTime: string;
    CreateUser: any;
    PayTime: any;
    ConfirmTime: any;
    PaymentType: number;
    ReturnMoney: number;
    CouponId: any;
    DiscountMoney: number;
    Id: string;
}