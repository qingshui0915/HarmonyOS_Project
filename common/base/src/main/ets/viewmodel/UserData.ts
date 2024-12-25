export class UserData {
    statusCode: number;
    message: string;
    code: any;
    details: any;
    data: Data;
}

export class Data {
    access_token: string;
    token_type: string;
    expires_in: number;
    refresh_token: string;
}