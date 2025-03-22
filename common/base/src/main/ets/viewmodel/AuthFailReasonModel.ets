export class AuthFailReasonModel {
  data?: Data[];
}

export class Data {
  AuthType?: number;
  FailReason?: string | null;
}