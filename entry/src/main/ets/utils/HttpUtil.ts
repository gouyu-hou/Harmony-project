import http from '@ohos.net.http';
import { BusinessError } from '@ohos.base';

const BASE_URL = 'https://apis.netstart.cn/coffee';

class HttpUtil {
  /**
   * 发送 GET 请求
   */
  static async get<T>(url: string): Promise<T> {
    const httpRequest = http.createHttp();
    try {
      const fullUrl = `${BASE_URL}${url}`;
      console.info(`[HttpUtil GET] ${fullUrl}`);

      const response = await httpRequest.request(fullUrl, {
        method: http.RequestMethod.GET,
        expectDataType: http.HttpDataType.STRING, // 1. 改为接收字符串
        readTimeout: 10000,
        connectTimeout: 10000
      });

      // 2. 打印原始返回结果，确保有数据
      console.info(`[HttpUtil Response] Code: ${response.responseCode}, Data: ${response.result}`);

      if (response.responseCode === 200) {
        // 3. 手动解析 JSON
        const resultString = response.result as string;
        return JSON.parse(resultString) as T;
      } else {
        throw new Error(`HTTP Error: ${response.responseCode}`);
      }
    } catch (err) {
      const error = err as BusinessError;
      console.error(`[HttpUtil Error] ${error.message}`);
      throw error;
    } finally {
      httpRequest.destroy();
    }
  }

  /**
   * 发送 POST 请求
   */
  static async post<T>(url: string, params: Record<string, string | number | boolean>): Promise<T> {
    const httpRequest = http.createHttp();
    try {
      const fullUrl = `${BASE_URL}${url}`;
      const stringParams = Object.keys(params)
        .map(key => `${encodeURIComponent(key)}=${encodeURIComponent(String(params[key]))}`)
        .join('&');

      console.info(`[HttpUtil POST] ${fullUrl} ? ${stringParams}`);

      const response = await httpRequest.request(fullUrl, {
        method: http.RequestMethod.POST,
        header: {
          'Content-Type': 'application/x-www-form-urlencoded'
        },
        extraData: stringParams,
        expectDataType: http.HttpDataType.STRING, // 改为接收字符串
        readTimeout: 10000,
        connectTimeout: 10000
      });

      console.info(`[HttpUtil Response] Code: ${response.responseCode}, Data: ${response.result}`);

      if (response.responseCode === 200) {
        const resultString = response.result as string;
        return JSON.parse(resultString) as T;
      } else {
        throw new Error(`HTTP Error: ${response.responseCode}`);
      }
    } catch (err) {
      const error = err as BusinessError;
      console.error(`[HttpUtil Error] ${error.message}`);
      throw error;
    } finally {
      httpRequest.destroy();
    }
  }
}

export default HttpUtil;