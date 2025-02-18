 export class PhoneNumberValidator {
  // 正则表达式用于验证电话号码格式
   private static readonly PHONE_REGEX: RegExp = /^1[3-9]\d{9}$/;

  /**
   * 判断传入的电话号码格式是否正确
   * @param phoneNumber 电话号码
   * @returns 如果电话号码格式正确返回 true，否则返回 false
   */
  public static isValidPhoneNumber(phoneNumber: string): boolean {
    return PhoneNumberValidator.PHONE_REGEX.test(phoneNumber);
  }
}