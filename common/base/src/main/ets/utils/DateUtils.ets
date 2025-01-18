export class DateUtils {
  /**
   * 获取当前时间的字符串表示
   * @param format 日期格式，默认为 "yyyy-MM-dd HH:mm:ss"
   * @returns 当前时间的字符串
   */
  static getCurrentTime(format: string = "yyyy-MM-dd"): string {
    const date = new Date();
    return DateUtils.formatDate(date, format);
  }

  /**
   * 获取从当前时间开始的一周日期列表
   * @param format 日期格式，默认为 "yyyy-MM-dd"
   * @returns 一周日期的字符串数组
   */
  static getWeekDatesFromNow(format: string = "yyyy-MM-dd"): string[] {
    const dates: string[] = [];
    const currentDate = new Date();

    for (let i = 0; i < 7; i++) {
      const date = new Date(currentDate);
      date.setDate(currentDate.getDate() + i);
      dates.push(DateUtils.formatDate(date, format));
    }

    return dates;
  }

  /**
   * 传入类型为y/M/d 年月日格式
   * 将 "2025/1/8" 格式的日期转换为 "2025/01/08"
   * @param dateStr 日期字符串，例如 "2025/1/8"
   * @returns 格式化后的日期字符串，例如 "2025/01/08"
   */
  static formatDateWithLeadingZeros(dateStr: string): string {
    const parts = dateStr.split("/");
    if (parts.length !== 3) {
      throw new Error("Invalid date format. Expected format: y/M/d");
    }

    const year = parts[0];
    const month = parts[1].padStart(2, "0"); // 补零
    const day = parts[2].padStart(2, "0"); // 补零

    return `${year}/${month}/${day}`;
  }


  /**
   * 获取从当前时间开始的 7 天日期列表
   * @param format 日期格式，默认为 "y/M/d"
   * @returns 7 天日期的字符串数组
   */
  static get7date(format: string = "y/M/d"): string[] {
    const dates: string[] = [];
    const currentDate = new Date();

    for (let i = 0; i < 7; i++) {
      const date = new Date(currentDate);
      date.setDate(currentDate.getDate() + i);
      dates.push(DateUtils.formatDate(date, format));
    }

    return dates;
  }

  /**
   * 获取从当前日期开始的过去 30 天日期列表，格式为 "M/d"
   * @returns 过去 30 天的日期字符串数组
   */
  static getTimeList(): string[] {
    const dates: string[] = [];
    const currentDate = new Date();

    for (let i = 0; i < 30; i++) {
      const date = new Date(currentDate);
      date.setDate(currentDate.getDate() - i);
      dates.push(DateUtils.formatDate(date, "y/M/d"));
    }

    // 反转数组，使日期从旧到新排列
    dates.reverse();

    return dates;
  }

  /**
   * 获取本周周一的日期
   * @param format 日期格式，默认为 "yyyy-MM-dd"
   * @returns 本周周一的日期字符串
   */
  static getThisWeekMonday(format: string = "yyyy-MM-dd"): string {
    const currentDate = new Date();
    const dayOfWeek = currentDate.getDay(); // 获取当前是星期几（0-6，0 表示周日）
    const diff = currentDate.getDate() - dayOfWeek + (dayOfWeek === 0 ? -6 : 1); // 计算周一的日期
    const monday = new Date(currentDate);
    monday.setDate(diff);
    return DateUtils.formatDate(monday, format);
  }

  /**
   * 获取上周周一的日期
   * @param format 日期格式，默认为 "yyyy-MM-dd"
   * @returns 上周周一的日期字符串
   */
  static getLastWeekMonday(format: string = "yyyy-MM-dd"): string {
    const currentDate = new Date();
    const dayOfWeek = currentDate.getDay(); // 获取当前是星期几（0-6，0 表示周日）
    const diff = currentDate.getDate() - dayOfWeek + (dayOfWeek === 0 ? -6 : 1) - 7; // 计算上周周一的日期
    const lastMonday = new Date(currentDate);
    lastMonday.setDate(diff);
    return DateUtils.formatDate(lastMonday, format);
  }
  /**
   * 获取本月第一天的日期
   * @param format 日期格式，默认为 "yyyy-MM-dd"
   * @returns 本月第一天的日期字符串
   */
  static getFirstDayOfThisMonth(format: string = "yyyy-MM-dd"): string {
    const currentDate = new Date();
    const firstDay = new Date(currentDate.getFullYear(), currentDate.getMonth(), 1); // 本月第一天
    return DateUtils.formatDate(firstDay, format);
  }

  /**
   * 获取上月第一天的日期
   * @param format 日期格式，默认为 "yyyy-MM-dd"
   * @returns 上月第一天的日期字符串
   */
  static getFirstDayOfLastMonth(format: string = "yyyy-MM-dd"): string {
    const currentDate = new Date();
    const firstDayOfLastMonth = new Date(currentDate.getFullYear(), currentDate.getMonth() - 1, 1); // 上月第一天
    return DateUtils.formatDate(firstDayOfLastMonth, format);
  }

  /**
   * 获取传入日期的月份和日
   * @param date 日期对象
   * @returns 包含月份和日的对象，例如 { month: 10, day: 25 }
   */
  static getMonth(date: Date): number {
    const month = date.getMonth() + 1; // getMonth() 返回 0-11，需要加 1
    // const day = date.getDate();
    return month;
  }

  static getDay(date: Date): number {
    // const month = date.getMonth() + 1; // getMonth() 返回 0-11，需要加 1
    const day = date.getDate();
    return day;
  }

  /**
   * 格式化日期
   * @param date 日期对象
   * @param format 日期格式
   * @returns 格式化后的日期字符串
   */
   static formatDate(date: Date, format: string): string {
    const options: Intl.DateTimeFormatOptions = {
      year: format.includes("y") ? "numeric" : undefined,
      month: format.includes("M") ? "numeric" : undefined,
      day: format.includes("d") ? "numeric" : undefined,
      hour: format.includes("H") ? "numeric" : undefined,
      minute: format.includes("m") ? "numeric" : undefined,
      second: format.includes("s") ? "numeric" : undefined,
    };

    return new Intl.DateTimeFormat("zh-CN", options).format(date);
  }

  /**
   * 将日期字符串转换为 Date 对象
   * @param time 日期字符串
   * @param format 日期格式
   * @returns Date 对象
   */
  private static stringToDate(time: string, format: string): Date {
    // 这里假设格式是标准的 ISO 8601 格式（如 "yyyy-MM-dd"）
    // 如果需要支持自定义格式，可以使用第三方库（如 date-fns 或 moment.js）
    return new Date(time);
  }

  /**
   * 获取星期索引
   * <p>注意：周日的 Index 是 1，周六为 7</p>
   * @param time 时间字符串
   * @param format 时间格式
   * @returns 1...7
   */
  static getWeekIndex(time: string, format: string): number {
    const date = DateUtils.stringToDate(time, format);
    const dayIndex = date.getDay(); // JavaScript 中周日是 0，周六是 6
    return dayIndex === 0 ? 7 : dayIndex; // 将周日从 0 调整为 7
  }


}