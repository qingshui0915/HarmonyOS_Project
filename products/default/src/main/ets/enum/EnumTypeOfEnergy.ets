export class EnumTypeOfEnergy {
  public readonly code: string;
  public readonly name: string;

  constructor(code: string, name: string) {
    this.code = code;
    this.name = name;
  }
  static readonly 汽油 = new EnumTypeOfEnergy("1", "汽油");
  static readonly 柴油 = new EnumTypeOfEnergy("2", "柴油");
  static readonly 天然气 = new EnumTypeOfEnergy("3", "天然气");
  static readonly 液化气 = new EnumTypeOfEnergy("4", "液化气");
  static readonly 电动 = new EnumTypeOfEnergy("5", "电动");
  static readonly 双燃料 = new EnumTypeOfEnergy("6", "双燃料");
  static readonly 氢 = new EnumTypeOfEnergy("7", "氢");
  static readonly 双燃料CNG = new EnumTypeOfEnergy("8", "双燃料CNG");
  static readonly 其他 = new EnumTypeOfEnergy("9", "其他");
  static readonly 双燃料LNG = new EnumTypeOfEnergy("10", "双燃料LNG");
  static readonly 单燃料CNG = new EnumTypeOfEnergy("11", "单燃料CNG");
  static readonly 单燃料LNG = new EnumTypeOfEnergy("12", "单燃料LNG");
  static readonly 混合动力 = new EnumTypeOfEnergy("14", "混合动力");
  static readonly 甲醇 = new EnumTypeOfEnergy("16", "甲醇");

  // 根据 name 获取 code
  static getCodeByName(name: string): string {
    const values = [
      EnumTypeOfEnergy.汽油,
      EnumTypeOfEnergy.柴油,
      EnumTypeOfEnergy.天然气,
      EnumTypeOfEnergy.液化气,
      EnumTypeOfEnergy.电动,
      EnumTypeOfEnergy.双燃料,
      EnumTypeOfEnergy.氢,
      EnumTypeOfEnergy.双燃料CNG,
      EnumTypeOfEnergy.其他,
      EnumTypeOfEnergy.双燃料LNG,
      EnumTypeOfEnergy.单燃料CNG,
      EnumTypeOfEnergy.单燃料LNG,
      EnumTypeOfEnergy.混合动力,
      EnumTypeOfEnergy.甲醇,
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
      EnumTypeOfEnergy.汽油,
      EnumTypeOfEnergy.柴油,
      EnumTypeOfEnergy.天然气,
      EnumTypeOfEnergy.液化气,
      EnumTypeOfEnergy.电动,
      EnumTypeOfEnergy.双燃料,
      EnumTypeOfEnergy.氢,
      EnumTypeOfEnergy.双燃料CNG,
      EnumTypeOfEnergy.其他,
      EnumTypeOfEnergy.双燃料LNG,
      EnumTypeOfEnergy.单燃料CNG,
      EnumTypeOfEnergy.单燃料LNG,
      EnumTypeOfEnergy.混合动力,
      EnumTypeOfEnergy.甲醇,
    ];
    for (const value of values) {
      if (value.code === code) {
        return value.name;
      }
    }
    return ""; // 如果没有找到，返回 null 或者其他错误信息
  }

  // 获取所有枚举值
  static values(): EnumTypeOfEnergy[] {
    return [
      EnumTypeOfEnergy.汽油,
      EnumTypeOfEnergy.柴油,
      EnumTypeOfEnergy.天然气,
      EnumTypeOfEnergy.液化气,
      EnumTypeOfEnergy.电动,
      EnumTypeOfEnergy.双燃料,
      EnumTypeOfEnergy.氢,
      EnumTypeOfEnergy.双燃料CNG,
      EnumTypeOfEnergy.其他,
      EnumTypeOfEnergy.双燃料LNG,
      EnumTypeOfEnergy.单燃料CNG,
      EnumTypeOfEnergy.单燃料LNG,
      EnumTypeOfEnergy.混合动力,
      EnumTypeOfEnergy.甲醇,
    ];
  }
}