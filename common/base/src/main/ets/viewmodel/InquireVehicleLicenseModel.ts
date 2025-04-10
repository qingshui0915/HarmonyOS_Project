export class InquireVehicleLicenseModel {
    statusCode: number;
    message: string;
    code: any;
    details: any;
    data: Data;
    ext: any;
}

export class Info {
    TaxiLicensePhoto: string;
    TaxiLicenseExpiryDate: string;
    Brand: string;
    LicenseNumber: string;
    Seats: number;
    QualificationCertificatePhoto: string;
    QualificationCertificateNo: string;
    LicensePassengerTrans: boolean;
    TransportCertsNumber: string;
    TransportCertsOwner: string;
    TransportCertsIssuer: string;
    HasExtinguishers: number;
    HasHammer: number;
    HasSecurityDevice: number;
    BusinessScope: string;
    TypeLevel: string;
    SignsNmber: string;
    SignsDateStart: string;
    SignsDateEnd: string;
    Ownership: number;
    QualificationCertificateExpiryDate: string;
}

export class Data {
    AuthStatus: number;
    AuthFailReason: string;
    IsComplete: boolean;
    Info: Info;
}