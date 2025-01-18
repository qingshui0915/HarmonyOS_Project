export class PhoneNumberUtils {
  /**
   * 将手机号码 18033339999 转换为 180****9999
   *
   * @param phoneNumber 手机号码
   * @return 转换后的手机号码
   */
  static changPhoneNumber(phoneNumber: string): string {
    if (phoneNumber.length > 10) {
      const frontThreeString = phoneNumber.substring(0, 3);
      const lastFourString = phoneNumber.substring(phoneNumber.length - 4);
      return `${frontThreeString}****${lastFourString}`;
    } else {
      return phoneNumber;
    }
  }
}