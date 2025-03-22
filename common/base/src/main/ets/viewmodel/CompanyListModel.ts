export class CompanyListModel {
    statusCode: number;
    message: string;
    code: null | number;
    details: null |string;
    data: Data[];
    ext: null;
}

export class Data {
    ShortName: string;
}