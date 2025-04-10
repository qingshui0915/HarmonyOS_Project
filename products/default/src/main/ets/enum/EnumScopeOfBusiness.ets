export class EnumScopeOfBusiness {
  public readonly code: string;
  public readonly name: string;

  constructor(code: string, name: string) {
    this.code = code;
    this.name = name;
  }
  static readonly 省际班车客运 = new EnumScopeOfBusiness("01104", "省际班车客运");
  static readonly 市际班车客运 = new EnumScopeOfBusiness("01103", "市际班车客运");
  static readonly 县际班车客运 = new EnumScopeOfBusiness("01102", "县际班车客运");
  static readonly 县内班车客运 = new EnumScopeOfBusiness("01101", "县内班车客运");
  static readonly 省际包车客运 = new EnumScopeOfBusiness("01204", "省际包车客运");
  static readonly 市际包车客运 = new EnumScopeOfBusiness("01203", "市际包车客运");
  static readonly 县际包车客运 = new EnumScopeOfBusiness("01202", "县际包车客运");
  static readonly 县内包车客运 = new EnumScopeOfBusiness("01201", "县内包车客运");

  // 根据 name 获取 code
  static getCodeByName(name: string): string {
    const values = [
      EnumScopeOfBusiness.省际班车客运,
      EnumScopeOfBusiness.市际班车客运,
      EnumScopeOfBusiness.县际班车客运,
      EnumScopeOfBusiness.县内班车客运,
      EnumScopeOfBusiness.省际包车客运,
      EnumScopeOfBusiness.县际包车客运,
      EnumScopeOfBusiness.县内包车客运,
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
      EnumScopeOfBusiness.省际班车客运,
      EnumScopeOfBusiness.市际班车客运,
      EnumScopeOfBusiness.县际班车客运,
      EnumScopeOfBusiness.县内班车客运,
      EnumScopeOfBusiness.省际包车客运,
      EnumScopeOfBusiness.县际包车客运,
      EnumScopeOfBusiness.县内包车客运,
    ];
    for (const value of values) {
      if (value.code === code) {
        return value.name;
      }
    }
    return ""; // 如果没有找到，返回 null 或者其他错误信息
  }

  // 获取所有枚举值
  static values(): EnumScopeOfBusiness[] {
    return [
      EnumScopeOfBusiness.省际班车客运,
      EnumScopeOfBusiness.市际班车客运,
      EnumScopeOfBusiness.县际班车客运,
      EnumScopeOfBusiness.县内班车客运,
      EnumScopeOfBusiness.省际包车客运,
      EnumScopeOfBusiness.县际包车客运,
      EnumScopeOfBusiness.县内包车客运,
    ];
  }
}