import HttpUtil from '../utils/HttpUtil';

// 全局配置的 AppKey
const APP_KEY = 'U2FsdGVkX19WSQ59Cg+Fj9jNZPxRC5y0xB1iV06BeNA=';

// 1. 【新增】定义登录数据接口，明确 data 里可能有什么
export interface LoginData {
  token?: string; // data 对象里也可能包含 token
}

// 通用响应结构
export interface ApiResponse<T> {
  code: string | number;
  msg: string;
  authentication?: string;
  data?: T;
  token?: string; // 外层也可能包含 token
}

class CoffeeApi {

  /**
   * 注册接口
   */
  static async register(phone: string, password: string, nickName: string): Promise<ApiResponse<null>> {
    return await HttpUtil.post<ApiResponse<null>>('/register', {
      'appkey': APP_KEY,
      'phone': phone,
      'password': password,
      'nickName': nickName
    });
  }

  /**
   * 登录接口
   * 【修改点】：泛型改为 LoginData，不再是 null
   */
  static async login(phone: string, password: string): Promise<ApiResponse<LoginData>> {
    return await HttpUtil.post<ApiResponse<LoginData>>('/login', {
      'appkey': APP_KEY,
      'phone': phone,
      'password': password
    });
  }
}

export default CoffeeApi;