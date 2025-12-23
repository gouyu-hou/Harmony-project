import http from '@ohos.net.http';

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
        expectDataType: http.HttpDataType.OBJECT,
        readTimeout: 10000,
        connectTimeout: 10000
      });

      if (response.responseCode === 200) {
        // 强制类型转换，假设服务器返回的格式符合 T
        return response.result as T;
      } else {
        throw new Error(`HTTP Error: ${response.responseCode}`);
      }
    } finally {
      httpRequest.destroy();
    }
  }

  /**
   * 发送 POST 请求 (适配 x-www-form-urlencoded)
   * @param url 接口路径
   * @param params 参数对象 (严格限制类型，禁止 any)
   */
  static async post<T>(url: string, params: Record<string, string | number | boolean>): Promise<T> {
    const httpRequest = http.createHttp();
    try {
      const fullUrl = `${BASE_URL}${url}`;

      // 参数转换逻辑
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
        expectDataType: http.HttpDataType.OBJECT,
        readTimeout: 10000,
        connectTimeout: 10000
      });

      if (response.responseCode === 200) {
        return response.result as T;
      } else {
        throw new Error(`HTTP Error: ${response.responseCode}`);
      }
    } catch (err) {
      // 错误处理中避免使用 JSON.stringify(err) 导致类型问题，改为简单提示
      console.error(`[HttpUtil Error] Request failed`);
      throw err;
    } finally {
      httpRequest.destroy();
    }
  }
}

export default HttpUtil;