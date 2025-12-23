// entry/src/main/ets/api/CoffeeApi.ts
import HttpUtil from '../utils/HttpUtil';

const APP_KEY = 'U2FsdGVkX19WSQ59Cg+Fj9jNZPxRC5y0xB1iV06BeNA=';

// 定义具体的 Data 接口
export interface LoginData {
  token?: string;
  nickName?: string;
}

// 定义通用的响应接口
export interface ApiResponse<T> {
  code: number;
  msg: string;
  data?: T;
  token?: string; // 根据日志，token 可能直接在最外层
}

class CoffeeApi {
  static async register(phone: string, password: string, nickName: string): Promise<ApiResponse<null>> {
    const params: Record<string, string | number | boolean> = {
      'appkey': APP_KEY,
      'phone': phone,
      'password': password,
      'nickName': nickName
    };
    return await HttpUtil.post<ApiResponse<null>>('/register', params);
  }

  static async login(phone: string, password: string): Promise<ApiResponse<LoginData>> {
    const params: Record<string, string | number | boolean> = {
      'appkey': APP_KEY,
      'phone': phone,
      'password': password
    };
    return await HttpUtil.post<ApiResponse<LoginData>>('/login', params);
  }
}

export default CoffeeApi;