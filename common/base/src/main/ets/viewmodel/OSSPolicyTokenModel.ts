export class OSSPolicyTokenModel {
    statusCode: number;
    message: string;
    code: any;
    details: any;
    data: Data;
    ext: any;
}

export class Data {
    accessid: string;
    policy: string;
    signature: string;
    dir: string;
    host: string;
    expire: string;
    callback: string;
}