export class InquireTravelCardModel {
    statusCode: number;
    message: string;
    code: any;
    details: any;
    data: Data;
    ext: any;
}

export class Info {
    VehicleCardPageUrl: string;
    VehicleCardSidePageUrl: string;
    LicenseRegDate: string;
    InspectAnnuallyDate: string;
    VehiclePictureUrl: string;
    MotorcycleType: string;
    PlateColor: number;
    EnergyType: number;
    Brand: string;
    Color: string;
    CarNumber: string;
    VehicleCardExpiryDate: string;
}

export class Data {
    AuthStatus: number;
    AuthFailReason: string;
    IsComplete: boolean;
    Info: Info;
}