// entry/src/main/ets/utils/HttpUtil.ts
import http from '@ohos.net.http';
import { BusinessError } from '@ohos.base';

const BASE_URL = 'https://apis.netstart.cn/coffee';

class HttpUtil {
  /**
   * 发送 POST 请求 (适配 x-www-form-urlencoded)
   */
  static async post<T>(url: string, params: Record<string, string | number | boolean>): Promise<T> {
    const httpRequest = http.createHttp();
    try {
      const fullUrl = `${BASE_URL}${url}`;

      // 参数转换逻辑
      const stringParams = Object.keys(params)
        .map((key: string): string => `${encodeURIComponent(key)}=${encodeURIComponent(String(params[key]))}`)
        .join('&');

      console.info(`[HttpUtil POST] ${fullUrl} ? ${stringParams}`);

      const response = await httpRequest.request(fullUrl, {
        method: http.RequestMethod.POST,
        header: {
          'Content-Type': 'application/x-www-form-urlencoded'
        },
        extraData: stringParams,
        expectDataType: http.HttpDataType.STRING, // 严格模式下先取字符串
        readTimeout: 10000,
        connectTimeout: 10000
      });

      if (response.responseCode === 200) {
        // 将字符串结果解析为 T 类型，注意这里不能出现 any
        const resultString = response.result as string;
        return JSON.parse(resultString) as T;
      } else {
        throw new Error(`HTTP Error: ${response.responseCode}`);
      }
    } catch (err) {
      // 关键修复：在 ArkTS 中，catch 捕获的 err 需显式转换为 BusinessError 或 Error
      const error = err as BusinessError;
      console.error(`[HttpUtil Error] code: ${error.code}, message: ${error.message}`);
      throw error;
    } finally {
      httpRequest.destroy();
    }
  }
}

export default HttpUtil;