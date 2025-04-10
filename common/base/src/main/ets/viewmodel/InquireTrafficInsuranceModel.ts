export class InquireTrafficInsuranceModel {
    statusCode: number;
    message: string;
    code: any;
    details: any;
    data: Data;
    ext: any;
}

export class Info {
    Clivtaphoto: string;
    ClivtaexpiryDate: string;
    ClivtaexpiryStartDate: string;
    VehicleInsurancePhoto: string;
    VehicleInsuranceExpiryDate: string;
    CarriersInsurancePhoto: string;
    CarriersInsuranceExpiryDate: string;
    InsureCompany: string;
    ClivateCompany: string;
    VehicleInsuranceCompany: string;
    InsurePdf: string;
}

export class Data {
    AuthStatus: number;
    AuthFailReason: string;
    IsComplete: boolean;
    Info: Info;
}