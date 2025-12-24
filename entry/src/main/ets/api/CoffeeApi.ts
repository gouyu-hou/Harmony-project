// entry/src/main/ets/api/CoffeeApi.ts
import HttpUtil from '../utils/HttpUtil';

const APP_KEY = 'U2FsdGVkX19WSQ59Cg+Fj9jNZPxRC5y0xB1iV06BeNA=';

// ================== 数据模型定义 ==================

export interface LoginData { token?: string; }
export interface BannerItem { bannerImg: string; name: string; pid: string; }
export interface CategoryItem { type: string; typeDesc: string; }
export interface ProductItem { pid: string; name: string; smallImg: string; price: string; enname: string; }

export interface ProductDetail {
  id: number;
  pid: string;
  name: string;
  enname: string;
  price: number;
  desc: string;
  detail_img: string;
  large_img: string;
  tem?: string;
  tem_desc?: string;
  sugar?: string;
  sugar_desc?: string;
  cream?: string;
  cream_desc?: string;
}

export interface UserInfo { userId: string; nickName: string; userImg: string; desc?: string; phone?: string; }
export interface MyData { userBg: string; nickName?: string; userImg?: string; }
export interface AddressItem { aid: string; name: string; tel: string; province: string; city: string; county: string; addressDetail: string; areaCode: string; postalCode: string; isDefault: number; }

export interface ShopCartItem {
  sid: string;
  pid: string;
  name: string;
  small_img: string;
  price: number;
  count: number;
  rule: string;
}

export interface OrderItem {
  oid: string;
  date: string;
  address: string;
  amount: number;
  status: number; // 1: 进行中, 2: 已完成
  products: OrderProduct[];
}

export interface OrderProduct {
  pid: string;
  name: string;
  smallImg: string;
  price: number;
  count: number;
  rule: string;
}

// ================== 响应结构定义 ==================

// 原始响应：后端实际返回的 JSON 结构
interface RawResponse<T> {
  code: number | string;
  msg?: string;
  data?: T;
  result?: T;
  token?: string;
}

// 统一响应：前端业务使用的结构
// ✅ 修复：code 支持 string，增加 result 字段兼容旧代码
export interface ApiResponse<T> {
  code: number | string;
  msg: string;
  data?: T;
  result?: T; // 兼容字段，指向 data
  token?: string;
}

// ================== API 类定义 ==================

class CoffeeApi {

  /**
   * 统一处理接口响应
   */
  private static normalize<T>(res: RawResponse<T> | undefined | null): ApiResponse<T> {
    // 1. 防御性检查
    if (!res) {
      console.error('[CoffeeApi] Network Error: response is null');
      return { code: 500, msg: 'Network Error', data: undefined };
    }

    // 2. 数据归一化：优先取 result，没有则取 data
    const validData = res.result !== undefined ? res.result : res.data;

    return {
      code: res.code, // ✅ 修复：保持原始类型，不要强制转 number
      msg: res.msg || (res.code === 200 || res.code === '200' ? 'Success' : 'Error'),
      data: validData,
      result: validData, // ✅ 修复：填充 result 字段
      token: res.token
    };
  }

  // --- 基础 & 商品接口 ---

  static async register(phone: string, password: string, nickName: string): Promise<ApiResponse<null>> {
    const res = await HttpUtil.post<RawResponse<null>>('/register', { 'appkey': APP_KEY, 'phone': phone, 'password': password, 'nickName': nickName });
    return CoffeeApi.normalize(res);
  }

  static async login(phone: string, password: string): Promise<ApiResponse<LoginData>> {
    const res = await HttpUtil.post<RawResponse<LoginData>>('/login', { 'appkey': APP_KEY, 'phone': phone, 'password': password });
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
    const res = await HttpUtil.get<RawResponse<ProductItem[]>>(`/typeProducts?appkey=${APP_KEY}&key=${key}&value=${value}`);
    return CoffeeApi.normalize(res);
  }

  static async getProductsByType(type: string): Promise<ApiResponse<ProductItem[]>> {
    return await CoffeeApi.getTypeProducts('type', type);
  }

  static async getHotProducts(): Promise<ApiResponse<ProductItem[]>> {
    return await CoffeeApi.getTypeProducts('isHot', 1);
  }

  static async getProductDetail(pid: string): Promise<ApiResponse<ProductDetail[]>> {
    const res = await HttpUtil.get<RawResponse<ProductDetail[]>>(`/productDetail?appkey=${APP_KEY}&pid=${pid}`);
    return CoffeeApi.normalize(res);
  }

  static async search(name: string): Promise<ApiResponse<ProductItem[]>> {
    const res = await HttpUtil.get<RawResponse<ProductItem[]>>(`/search?appkey=${APP_KEY}&name=${encodeURIComponent(name)}`);
    return CoffeeApi.normalize(res);
  }

  // --- 用户 & 安全接口 ---
  static async getUserInfo(token: string): Promise<ApiResponse<UserInfo>> {
    const res = await HttpUtil.get<RawResponse<UserInfo[]>>(`/findAccountInfo?appkey=${APP_KEY}&tokenString=${token}`);
    const normalized = CoffeeApi.normalize(res);
    // 特殊处理：如果返回的是数组，取第一个
    if ((normalized.code === 200 || normalized.code === '200') && Array.isArray(normalized.data) && normalized.data.length > 0) {
      return { ...normalized, data: normalized.data[0] } as unknown as ApiResponse<UserInfo>;
    }
    return normalized as unknown as ApiResponse<UserInfo>;
  }

  static async updatePassword(token: string, oldPassword: string, password: string): Promise<ApiResponse<string>> {
    const res = await HttpUtil.post<RawResponse<string>>('/updatePassword', {
      'appkey': APP_KEY, 'tokenString': token, 'password': password, 'oldPassword': oldPassword
    });
    return CoffeeApi.normalize(res);
  }

  static async destroyAccount(token: string): Promise<ApiResponse<string>> {
    const res = await HttpUtil.post<RawResponse<string>>('/destroyAccount', {
      'appkey': APP_KEY, 'tokenString': token
    });
    return CoffeeApi.normalize(res);
  }

  // --- 地址接口 ---
  static async findAddress(token: string): Promise<ApiResponse<AddressItem[]>> {
    const res = await HttpUtil.get<RawResponse<AddressItem[]>>(`/findAddress?appkey=${APP_KEY}&tokenString=${token}`);
    return CoffeeApi.normalize(res);
  }

  static async addAddress(token: string, address: AddressItem): Promise<ApiResponse<string>> {
    const res = await HttpUtil.post<RawResponse<string>>('/addAddress', { 'appkey': APP_KEY, 'tokenString': token, ...address });
    return CoffeeApi.normalize(res);
  }

  static async editAddress(token: string, address: AddressItem): Promise<ApiResponse<string>> {
    const res = await HttpUtil.post<RawResponse<string>>('/editAddress', { 'appkey': APP_KEY, 'tokenString': token, ...address });
    return CoffeeApi.normalize(res);
  }

  static async deleteAddress(token: string, aid: string): Promise<ApiResponse<string>> {
    const res = await HttpUtil.post<RawResponse<string>>('/deleteAddress', { 'appkey': APP_KEY, 'tokenString': token, 'aid': aid });
    return CoffeeApi.normalize(res);
  }

  // --- 收藏接口 ---
  static async findAllLike(token: string): Promise<ApiResponse<ProductItem[]>> {
    const res = await HttpUtil.get<RawResponse<ProductItem[]>>(`/findAllLike?appkey=${APP_KEY}&tokenString=${token}`);
    return CoffeeApi.normalize(res);
  }

  static async findLike(token: string, pid: string): Promise<ApiResponse<ProductItem[]>> {
    const res = await HttpUtil.get<RawResponse<ProductItem[]>>(`/findlike?appkey=${APP_KEY}&tokenString=${token}&pid=${pid}`);
    return CoffeeApi.normalize(res);
  }

  static async like(token: string, pid: string): Promise<ApiResponse<string>> {
    const res = await HttpUtil.post<RawResponse<string>>('/like', { 'appkey': APP_KEY, 'tokenString': token, 'pid': pid });
    return CoffeeApi.normalize(res);
  }

  static async notLike(token: string, pid: string): Promise<ApiResponse<string>> {
    const res = await HttpUtil.post<RawResponse<string>>('/notlike', { 'appkey': APP_KEY, 'tokenString': token, 'pid': pid });
    return CoffeeApi.normalize(res);
  }

  // --- 购物车 & 订单接口 ---
  static async addShopcart(token: string, pid: string, count: number, rule: string): Promise<ApiResponse<null>> {
    const res = await HttpUtil.post<RawResponse<null>>('/addShopcart', {
      'appkey': APP_KEY, 'tokenString': token, 'pid': pid, 'count': count, 'rule': rule
    });
    return CoffeeApi.normalize(res);
  }

  static async getShopcartList(token: string): Promise<ApiResponse<ShopCartItem[]>> {
    const res = await HttpUtil.get<RawResponse<ShopCartItem[]>>(`/shopcartRows?appkey=${APP_KEY}&tokenString=${token}`);
    return CoffeeApi.normalize(res);
  }

  static async updateShopcartCount(token: string, sid: string, count: number): Promise<ApiResponse<null>> {
    const res = await HttpUtil.post<RawResponse<null>>('/modifyShopcartCount', {
      'appkey': APP_KEY, 'tokenString': token, 'sid': sid, 'count': count
    });
    return CoffeeApi.normalize(res);
  }

  static async deleteShopcart(token: string, sids: string[]): Promise<ApiResponse<null>> {
    const res = await HttpUtil.post<RawResponse<null>>('/deleteShopcart', {
      'appkey': APP_KEY, 'tokenString': token, 'sids': JSON.stringify(sids)
    });
    return CoffeeApi.normalize(res);
  }

  static async pay(token: string, sids: string[], phone: string, address: string, receiver: string): Promise<ApiResponse<string>> {
    const res = await HttpUtil.post<RawResponse<string>>('/pay', {
      'appkey': APP_KEY, 'tokenString': token, 'sids': JSON.stringify(sids), 'phone': phone, 'address': address, 'receiver': receiver
    });
    return CoffeeApi.normalize(res);
  }

  static async findOrder(token: string, status: number): Promise<ApiResponse<OrderItem[]>> {
    const res = await HttpUtil.get<RawResponse<OrderItem[]>>(`/findOrder?appkey=${APP_KEY}&tokenString=${token}&status=${status}`);
    return CoffeeApi.normalize(res);
  }

  static async receiveOrder(token: string, oid: string): Promise<ApiResponse<string>> {
    const res = await HttpUtil.post<RawResponse<string>>('/receive', {
      'appkey': APP_KEY, 'tokenString': token, 'oid': oid
    });
    return CoffeeApi.normalize(res);
  }

  static async removeOrder(token: string, oid: string): Promise<ApiResponse<string>> {
    const res = await HttpUtil.post<RawResponse<string>>('/removeOrder', {
      'appkey': APP_KEY, 'tokenString': token, 'oid': oid
    });
    return CoffeeApi.normalize(res);
  }
}

export default CoffeeApi;