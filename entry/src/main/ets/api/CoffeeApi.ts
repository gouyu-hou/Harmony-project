import HttpUtil from '../utils/HttpUtil';

const APP_KEY = 'U2FsdGVkX19WSQ59Cg+Fj9jNZPxRC5y0xB1iV06BeNA=';

// ================== 数据模型定义 ==================

export interface LoginData {
  token?: string;
}

export interface BannerItem {
  bannerImg: string;
  name: string;
  pid: string;
}

export interface CategoryItem {
  type: string;
  typeDesc: string;
}

export interface ProductItem {
  pid: string;
  name: string;
  smallImg: string;
  price: string;
  enname: string;
}

export interface ProductDetail {
  pid: string;
  name: string;
  enname: string;
  price: string;
  desc: string;
  large_img: string;
  tem?: string;
  sugar?: string;
  cream?: string;
}

export interface UserInfo {
  userId: string;
  nickName: string;
  userImg: string;
  desc?: string;
  phone?: string;
}

export interface MyData {
  userBg: string;
  nickName?: string;
  userImg?: string;
}

// ================== 响应结构定义 ==================

// 1. 修改 RawResponse 允许 code 为字符串 (兼容 "B001")
interface RawResponse<T> {
  code: number | string;
  msg?: string;
  data?: T;
  result?: T;
  token?: string;
}

export interface ApiResponse<T> {
  code: number | string;
  msg: string;
  data?: T;
  token?: string;
}

// ================== API 类定义 ==================

class CoffeeApi {

  private static normalize<T>(res: RawResponse<T>): ApiResponse<T> {
    const validData = res.result || res.data;
    if (validData) {
      return {
        code: 200,
        msg: 'Success',
        data: validData,
        token: res.token
      };
    }
    return {
      code: res.code,
      msg: res.msg || 'Unknown Error',
      data: res.data,
      token: res.token
    };
  }

  static async register(phone: string, password: string, nickName: string): Promise<ApiResponse<null>> {
    const res = await HttpUtil.post<RawResponse<null>>('/register', {
      'appkey': APP_KEY, 'phone': phone, 'password': password, 'nickName': nickName
    });
    return CoffeeApi.normalize(res);
  }

  static async login(phone: string, password: string): Promise<ApiResponse<LoginData>> {
    const res = await HttpUtil.post<RawResponse<LoginData>>('/login', {
      'appkey': APP_KEY, 'phone': phone, 'password': password
    });
    return CoffeeApi.normalize(res);
  }

  static async getBanner(): Promise<ApiResponse<BannerItem[]>> {
    const res = await HttpUtil.get<RawResponse<BannerItem[]>>(`/banner?appkey=${APP_KEY}`);
    return CoffeeApi.normalize(res);
  }

  static async getTypes(): Promise<ApiResponse<CategoryItem[]>> {
    const res = await HttpUtil.get<RawResponse<CategoryItem[]>>(`/type?appkey=${APP_KEY}`);
    return CoffeeApi.normalize(res);
  }

  static async getTypeProducts(key: string, value: string | number): Promise<ApiResponse<ProductItem[]>> {
    const res = await HttpUtil.get<RawResponse<ProductItem[]>>(
      `/typeProducts?appkey=${APP_KEY}&key=${key}&value=${value}`
    );
    return CoffeeApi.normalize(res);
  }

  static async getProductsByType(type: string): Promise<ApiResponse<ProductItem[]>> {
    return await CoffeeApi.getTypeProducts('type', type);
  }

  static async getHotProducts(): Promise<ApiResponse<ProductItem[]>> {
    return await CoffeeApi.getTypeProducts('isHot', 1);
  }

  static async getProductDetail(pid: string): Promise<ApiResponse<ProductDetail>> {
    const res = await HttpUtil.get<RawResponse<ProductDetail[]>>(`/productDetail?appkey=${APP_KEY}&pid=${pid}`);
    const normalized = CoffeeApi.normalize(res);
    if (normalized.code === 200 && Array.isArray(normalized.data) && normalized.data.length > 0) {
      return { ...normalized, data: normalized.data[0] } as unknown as ApiResponse<ProductDetail>;
    }
    return normalized as unknown as ApiResponse<ProductDetail>;
  }

  /**
   * 获取个人资料 (修复版)
   */
  static async getUserInfo(token: string): Promise<ApiResponse<UserInfo>> {
    const res = await HttpUtil.get<RawResponse<UserInfo[]>>(
      `/findAccountInfo?appkey=${APP_KEY}&tokenString=${token}`
    );
    const normalized = CoffeeApi.normalize(res);

    // 【关键修复】接口返回的是数组，必须取第 0 个！
    if (normalized.code === 200 && Array.isArray(normalized.data) && normalized.data.length > 0) {
      return { ...normalized, data: normalized.data[0] } as unknown as ApiResponse<UserInfo>;
    }
    return normalized as unknown as ApiResponse<UserInfo>;
  }

  /**
   * ✅ 修改点3：获取我的页面信息
   * 同样提取数组第 0 个
   */
  static async findMy(token: string): Promise<ApiResponse<MyData>> {
    const res = await HttpUtil.get<RawResponse<MyData[]>>(
      `/findMy?appkey=${APP_KEY}&tokenString=${token}`
    );
    const normalized = CoffeeApi.normalize(res);

    if (normalized.code === 200 && Array.isArray(normalized.data) && normalized.data.length > 0) {
      return { ...normalized, data: normalized.data[0] } as unknown as ApiResponse<MyData>;
    }
    return normalized as unknown as ApiResponse<MyData>;
  }
}

export default CoffeeApi;