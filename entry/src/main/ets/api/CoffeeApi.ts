import HttpUtil from '../utils/HttpUtil';

const APP_KEY = 'U2FsdGVkX19WSQ59Cg+Fj9jNZPxRC5y0xB1iV06BeNA=';

// ================== 数据模型定义 ==================

export interface LoginData { token?: string; }
export interface BannerItem { bannerImg: string; name: string; pid: string; }
export interface CategoryItem { type: string; typeDesc: string; }
export interface ProductItem { pid: string; name: string; smallImg: string; price: string; enname: string; }
export interface ProductDetail { pid: string; name: string; enname: string; price: string; desc: string; large_img: string; tem?: string; sugar?: string; cream?: string; }
export interface UserInfo { userId: string; nickName: string; userImg: string; desc?: string; phone?: string; }
export interface MyData { userBg: string; nickName?: string; userImg?: string; }
export interface AddressItem { aid: string; name: string; tel: string; province: string; city: string; county: string; addressDetail: string; areaCode: string; postalCode: string; isDefault: number; }



// 购物车商品
export interface ShopCartItem {
  sid: string;
  pid: string;
  name: string;
  small_img: string;
  price: number;
  count: number;
  rule: string;
}

// ================== 响应结构定义 ==================



// 内部使用的原始响应结构
interface RawResponse<T> {
  code: number | string;
  msg?: string;
  data?: T;
  result?: T;
  token?: string;
}

// ✅ 【重点】必须 export 导出这个接口，ProductDetailPage 才能引用
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
      return { code: 200, msg: 'Success', data: validData, token: res.token };
    }
    return { code: res.code, msg: res.msg || 'Unknown Error', data: res.data, token: res.token };
  }

  // --- 基础接口 ---
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

  static async getProductDetail(pid: string): Promise<ApiResponse<ProductDetail>> {
    const res = await HttpUtil.get<RawResponse<ProductDetail[]>>(`/productDetail?appkey=${APP_KEY}&pid=${pid}`);
    const normalized = CoffeeApi.normalize(res);
    if (normalized.code === 200 && Array.isArray(normalized.data) && normalized.data.length > 0) {
      return { ...normalized, data: normalized.data[0] } as unknown as ApiResponse<ProductDetail>;
    }
    return normalized as unknown as ApiResponse<ProductDetail>;
  }

  // --- 用户 & 地址接口 ---
  static async getUserInfo(token: string): Promise<ApiResponse<UserInfo>> {
    const res = await HttpUtil.get<RawResponse<UserInfo[]>>(`/findAccountInfo?appkey=${APP_KEY}&tokenString=${token}`);
    const normalized = CoffeeApi.normalize(res);
    if (normalized.code === 200 && Array.isArray(normalized.data) && normalized.data.length > 0) {
      return { ...normalized, data: normalized.data[0] } as unknown as ApiResponse<UserInfo>;
    }
    return normalized as unknown as ApiResponse<UserInfo>;
  }

  static async findMy(token: string): Promise<ApiResponse<MyData>> {
    const res = await HttpUtil.get<RawResponse<MyData[]>>(`/findMy?appkey=${APP_KEY}&tokenString=${token}`);
    const normalized = CoffeeApi.normalize(res);
    if (normalized.code === 200 && Array.isArray(normalized.data) && normalized.data.length > 0) {
      return { ...normalized, data: normalized.data[0] } as unknown as ApiResponse<MyData>;
    }
    return normalized as unknown as ApiResponse<MyData>;
  }

  static async findAddress(token: string): Promise<ApiResponse<AddressItem[]>> {
    const res = await HttpUtil.get<RawResponse<AddressItem[]>>(`/findAddress?appkey=${APP_KEY}&tokenString=${token}`);
    return CoffeeApi.normalize(res);
  }

  static async addAddress(token: string, address: AddressItem): Promise<ApiResponse<string>> {
    const res = await HttpUtil.post<RawResponse<string>>('/addAddress', {
      'appkey': APP_KEY, 'tokenString': token, ...address
    });
    return CoffeeApi.normalize(res);
  }

  static async editAddress(token: string, address: AddressItem): Promise<ApiResponse<string>> {
    const res = await HttpUtil.post<RawResponse<string>>('/editAddress', {
      'appkey': APP_KEY, 'tokenString': token, ...address
    });
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

  // --- 购物车接口 ---
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
    const res = await HttpUtil.post<RawResponse<null>>('/removeShopcart', {
      'appkey': APP_KEY, 'tokenString': token, 'sids': JSON.stringify(sids)
    });
    return CoffeeApi.normalize(res);
  }
}

export default CoffeeApi;