export class Response<T>{
  statusCode:number = 0
  message: string = ""
  details: string | null =null
  data:T | null = null

  isSuccess():boolean{
    return this.statusCode === 0
  }
  isSuccessWithData(): boolean {
    return this.statusCode === 0 && !!this.data
  }
}
