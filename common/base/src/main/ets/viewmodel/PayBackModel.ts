export class PayBackModel {
    statusCode: number;
    message: string;
    code: any;
    details: any;
    data: Data;
    ext: any;
}

export class PaymentTypes {
    Type: number;
    PaymentType: number;
    SubPaymentType: number;
}

export class Data {
    Status: number;
    OrderNo: string;
    Amount: number;
    DiscountAmount: number;
    PayedAmount: number;
    CouponId: any;
    DiscountDescribe: any;
    PaymentTypes: PaymentTypes[];
}