export class ProgressDataModel {
    statusCode: number;
    message: string;
    code: any;
    details: any;
    data: Data;
}

export class Data {
    DriverId: string;
    Name: string;
    Phone: string;
    IdCardAuthStatus: number;
    IdCardIsComplete: boolean;
    DriverCardAuthStatus: number;
    DriverLicenseIsComplete: boolean;
    VehicleCardAuthStatus: number;
    DrivingLicenseIsComplete: boolean;
    OnlineCarAuthStatus: number;
    OnelineCarInfoIsComplete: boolean;
    InsuranceAuthStatus: number;
    InsuranceIsComplete: boolean;
}