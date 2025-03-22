/**
 * URL查询参数工具类
 * 用于构建和处理URL查询字符串
 */
export class QueryParams {
  private params: Map<string, string> = new Map();

  /**
   * 添加查询参数
   * @param key 参数名
   * @param value 参数值
   */
  append(key: string, value: string): void {
    this.params.set(key, value);
  }

  /**
   * 获取指定参数的值
   * @param key 参数名
   * @returns 参数值，如果不存在则返回null
   */
  get(key: string): string | null {
    return this.params.has(key) ? this.params.get(key)! : null;
  }

  /**
   * 删除指定参数
   * @param key 参数名
   */
  delete(key: string): void {
    this.params.delete(key);
  }

  /**
   * 将参数转换为查询字符串
   * @returns 格式化的查询字符串
   */
  toString(): string {
    const parts: string[] = [];

    this.params.forEach((value, key) => {
      if (value !== undefined && value !== null) {
        // 进行URL编码
        const encodedKey = encodeURIComponent(key);
        const encodedValue = encodeURIComponent(value);
        parts.push(`${encodedKey}=${encodedValue}`);
      }
    });

    return parts.join('&');
  }

  /**
   * 从对象创建查询参数
   * @param obj 包含参数的对象
   * @returns 查询参数实例
   */
  static fromObject(obj: Record<string, string>): QueryParams {
    const params = new QueryParams();

    // 使用Object.keys代替for...in循环
    Object.keys(obj).forEach(key => {
      if (obj[key] !== undefined && obj[key] !== null) {
        params.append(key, obj[key]);
      }
    });

    return params;
  }
}

/**
 * 构建查询字符串的便捷方法
 * @param params 参数对象
 * @returns 格式化的查询字符串
 */
export function buildQueryString(params: Record<string, string>): string {
  return QueryParams.fromObject(params).toString();
}