export class AuthFailReasonModel {
  statusCode: number = 200;
  message: string = "";
  code: number =0;
  details: string ="";
  data?: Data[];
}

export class Data {
  AuthType?: number;
  FailReason?: string | null;
}