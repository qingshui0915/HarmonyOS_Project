export class SevenDateModel{




  private _week: string = ""

  public set week(value: string) {
    this._week = value
  }

  public get week(): string {
    return this._week
  }

  private _year: string = ""

  public set year(value: string) {
    this._year = value
  }

  public get year(): string {
    return this._year
  }

  private _date: string = ""

  public set date(value: string) {
    this._date = value
  }

  public get date(): string {
    return this._date
  }

  private _time: string = ""

  public set time(value: string) {
    this._time = value
  }

  public get time(): string {
    return this._time
  }

  private _count: number = 0

  public set count(value: number) {
    this._count = value
  }

  public get count(): number {
    return this._count
  }

  private _isSelect: boolean = true

  public set isSelect(value: boolean) {
    this._isSelect = value
  }

  public get isSelect(): boolean {
    return this._isSelect
  }



}