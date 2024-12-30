export class Response<T>{
  statusCode:number = 0
  message: string = ""
  details: string | null =null
  data:T | Data<T> | null = null

  isSuccess():boolean{
    return this.statusCode === 0
  }
  isSuccessWithData(): boolean {
    return this.isSuccess() && !!this.data
  }
}

export class Data<T> {
  statusCode: number = 0;
  message: string = "";
  code:number = 0;
  details: string | null = null;
  data: T[] = [];
}