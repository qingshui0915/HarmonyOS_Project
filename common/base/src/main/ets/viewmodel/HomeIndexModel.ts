export class HomeIndexModel {
    statusCode: number;
    message: string;
    code: any;
    details: any;
    data: Data;
}

export class Data {
    Code: number;
    VehicleState: number;
    CarId: string;
    CarVehicleCompanyName: string;
}