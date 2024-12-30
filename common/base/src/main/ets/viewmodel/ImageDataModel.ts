export class ImageDataModel {
    statusCode: number;
    message: string;
    code: any;
    details: any;
    data: Data;
}

export class Data {
    Secret: string;
    Captche: string;
}