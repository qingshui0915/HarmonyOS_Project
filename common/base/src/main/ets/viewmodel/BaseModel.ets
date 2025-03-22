export class BaseModel {
  statusCode: number = 0;
  message: string = "";
  code: string | null =null;
  details: string | null = null;
  data: null| string  = null;
}