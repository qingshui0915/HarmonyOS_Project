export class EnumSurveyVehiclePlateColor {
  public readonly code: string;
  public readonly name: string;

  constructor(code: string, name: string) {
    this.code = code;
    this.name = name;
  }
  static readonly 蓝色 = new EnumSurveyVehiclePlateColor("1", "蓝色");
  static readonly 黄色 = new EnumSurveyVehiclePlateColor("2", "黄色");
  static readonly 黑色 = new EnumSurveyVehiclePlateColor("3", "黑色");
  static readonly 白色 = new EnumSurveyVehiclePlateColor("4", "白色");
  static readonly 绿色 = new EnumSurveyVehiclePlateColor("5", "绿色");
  static readonly 其他 = new EnumSurveyVehiclePlateColor("9", "其他");
  static readonly 农黄色 = new EnumSurveyVehiclePlateColor("91", "农黄色");
  static readonly 农绿色 = new EnumSurveyVehiclePlateColor("92", "农绿色");
  static readonly 黄绿色 = new EnumSurveyVehiclePlateColor("93", "黄绿色");
  static readonly 渐变绿 = new EnumSurveyVehiclePlateColor("94", "渐变绿");

  // 根据 name 获取 code
  static getCodeByName(name: string): string {
    const values = [
      EnumSurveyVehiclePlateColor.蓝色,
      EnumSurveyVehiclePlateColor.黄色,
      EnumSurveyVehiclePlateColor.黑色,
      EnumSurveyVehiclePlateColor.白色,
      EnumSurveyVehiclePlateColor.绿色,
      EnumSurveyVehiclePlateColor.其他,
      EnumSurveyVehiclePlateColor.农黄色,
      EnumSurveyVehiclePlateColor.农绿色,
      EnumSurveyVehiclePlateColor.黄绿色,
      EnumSurveyVehiclePlateColor.渐变绿,
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
      EnumSurveyVehiclePlateColor.蓝色,
      EnumSurveyVehiclePlateColor.黄色,
      EnumSurveyVehiclePlateColor.黑色,
      EnumSurveyVehiclePlateColor.白色,
      EnumSurveyVehiclePlateColor.绿色,
      EnumSurveyVehiclePlateColor.其他,
      EnumSurveyVehiclePlateColor.农黄色,
      EnumSurveyVehiclePlateColor.农绿色,
      EnumSurveyVehiclePlateColor.黄绿色,
      EnumSurveyVehiclePlateColor.渐变绿,
    ];
    for (const value of values) {
      if (value.code === code) {
        return value.name;
      }
    }
    return ""; // 如果没有找到，返回 null 或者其他错误信息
  }

  // 获取所有枚举值
  static values(): EnumSurveyVehiclePlateColor[] {
    return [
      EnumSurveyVehiclePlateColor.蓝色,
      EnumSurveyVehiclePlateColor.黄色,
      EnumSurveyVehiclePlateColor.黑色,
      EnumSurveyVehiclePlateColor.白色,
      EnumSurveyVehiclePlateColor.绿色,
      EnumSurveyVehiclePlateColor.其他,
      EnumSurveyVehiclePlateColor.农黄色,
      EnumSurveyVehiclePlateColor.农绿色,
      EnumSurveyVehiclePlateColor.黄绿色,
      EnumSurveyVehiclePlateColor.渐变绿,
    ];
  }
}