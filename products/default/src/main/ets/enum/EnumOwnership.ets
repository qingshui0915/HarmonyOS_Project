export class EnumOwnership{
  public readonly code: string;
  public readonly name: string;

  constructor(code: string, name: string) {
    this.code = code;
    this.name = name;
  }
  static readonly 公车公营 = new EnumOwnership("0", "公车公营");
  static readonly 承包经营 = new EnumOwnership("1", "承包经营");

  // 根据 name 获取 code
  static getCodeByName(name: string): string {
    const values = [
      EnumOwnership.公车公营,
      EnumOwnership.承包经营,
    ];
    for (const value of values) {
      if (value.name === name) {
        return value.code;
      }
    }
    return "0"; // 如果没有找到，返回 0 或者其他错误码
  }

  // 根据 code 获取 name
  static getNameByCode(code: string): string  {
    const values = [
      EnumOwnership.公车公营,
      EnumOwnership.承包经营,
    ];
    for (const value of values) {
      if (value.code === code) {
        return value.name;
      }
    }
    return ""; // 如果没有找到，返回 null 或者其他错误信息
  }

  // 获取所有枚举值
  static values(): EnumOwnership[] {
    return [
      EnumOwnership.公车公营,
      EnumOwnership.承包经营,
    ];
  }
}