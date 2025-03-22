export class SelectCompanyModel {
    statusCode: number;
    message: string;
    code: null | number;
    details: null | string;
    data: Data;
    ext: null;
}

export class Data {
    CarId: string;
    Status: number;
}