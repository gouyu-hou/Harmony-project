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
  small_img: string; // 注意：接口返回字段通常是 small_img
  price: number;
  count: number;
  rule: string;
}

export interface OrderItem {
  oid: string;
  date: string;
  address: string;
  amount: number;
  status: number;
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
  result?: T;
  token?: string;
}

// ================== API 类定义 ==================

class CoffeeApi {

  /**
   * 统一处理接口响应
   */
  private static normalize<T>(res: RawResponse<T> | undefined | null): ApiResponse<T> {
    if (!res) {
      console.error('[CoffeeApi] Network Error: response is null');
      return { code: 500, msg: 'Network Error', data: undefined };
    }

    // 1. 获取有效数据：优先取 result，其次取 data
    const validData = res.result !== undefined ? res.result : res.data;

    // ✅ 只要有数据，就强制修正 code 为 200
    if (validData !== undefined && validData !== null) {
      return {
        code: 200, // 强制视为成功
        msg: 'Success',
        data: validData,
        result: validData,
        token: res.token
      };
    }

    // 3. 常规成功判断
    if (res.code === 200 || res.code === '200') {
      return {
        code: 200,
        msg: 'Success',
        data: validData,
        result: validData,
        token: res.token
      };
    }

    // 4. 失败
    return {
      code: res.code,
      msg: res.msg || 'Error',
      data: undefined,
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

  // ✅ 修复 1：移除 unknown 断言，改为显式对象构造
  static async getUserInfo(token: string): Promise<ApiResponse<UserInfo>> {
    const res = await HttpUtil.get<RawResponse<UserInfo[]>>(`/findAccountInfo?appkey=${APP_KEY}&tokenString=${encodeURIComponent(token)}`);
    const normalized = CoffeeApi.normalize(res);

    // 如果返回的是数组，取第一个元素作为 UserInfo 返回
    if ((normalized.code === 200 || normalized.code === '200') && normalized.data && Array.isArray(normalized.data) && normalized.data.length > 0) {
      const userData: UserInfo = normalized.data[0];
      return {
        code: normalized.code,
        msg: normalized.msg,
        data: userData,
        result: userData,
        token: normalized.token
      };
    }

    // 否则返回空数据结构
    return {
      code: normalized.code,
      msg: normalized.msg,
      data: undefined,
      token: normalized.token
    };
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
    const res = await HttpUtil.get<RawResponse<AddressItem[]>>(`/findAddress?appkey=${APP_KEY}&tokenString=${encodeURIComponent(token)}`);
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
    const res = await HttpUtil.get<RawResponse<ProductItem[]>>(`/findAllLike?appkey=${APP_KEY}&tokenString=${encodeURIComponent(token)}`);
    return CoffeeApi.normalize(res);
  }

  static async findLike(token: string, pid: string): Promise<ApiResponse<ProductItem[]>> {
    const res = await HttpUtil.get<RawResponse<ProductItem[]>>(`/findlike?appkey=${APP_KEY}&tokenString=${encodeURIComponent(token)}&pid=${pid}`);
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

  // 1. 添加购物车
  static async addShopcart(token: string, pid: string, count: number, rule: string): Promise<ApiResponse<null>> {
    const res = await HttpUtil.post<RawResponse<null>>('/addShopcart', {
      'appkey': APP_KEY, 'tokenString': token, 'pid': pid, 'count': count, 'rule': rule
    });
    return CoffeeApi.normalize(res);
  }

  // 2. 获取购物车商品条目 (列表)
  static async getShopcartList(token: string): Promise<ApiResponse<ShopCartItem[]>> {
    const res = await HttpUtil.get<RawResponse<ShopCartItem[]>>(`/findAllShopcart?appkey=${APP_KEY}&tokenString=${encodeURIComponent(token)}`);
    return CoffeeApi.normalize(res);
  }

  // 3. 查询购物车商品总数量
  static async getShopcartCount(token: string): Promise<ApiResponse<number>> {
    const res = await HttpUtil.get<RawResponse<number>>(`/shopcartCount?appkey=${APP_KEY}&tokenString=${encodeURIComponent(token)}`);
    return CoffeeApi.normalize(res);
  }

  // 4. 查询用户所有购物车条数
  // ✅ 修复 2：将 ApiResponse<any> 替换为明确的 ApiResponse<ShopCartItem[]>
  static async findAllShopcart(token: string): Promise<ApiResponse<ShopCartItem[]>> {
    const res = await HttpUtil.get<RawResponse<ShopCartItem[]>>(`/findAllShopcart?appkey=${APP_KEY}&tokenString=${encodeURIComponent(token)}`);
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

  static async removeShopcart(token: string, sids: string[]): Promise<ApiResponse<null>> {
    const res = await HttpUtil.post<RawResponse<null>>('/removeShopcart', {
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
    const res = await HttpUtil.get<RawResponse<OrderItem[]>>(`/findOrder?appkey=${APP_KEY}&tokenString=${encodeURIComponent(token)}&status=${status}`);
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

  /**
   * 获取个人中心信息
   * ✅ 修复 3：移除 unknown 断言，改为显式对象构造
   */
  static async findMy(token: string): Promise<ApiResponse<MyData>> {
    // 泛型改为 MyData[] 接收数组
    const res = await HttpUtil.get<RawResponse<MyData[]>>(`/findMy?appkey=${APP_KEY}&tokenString=${encodeURIComponent(token)}`);
    const normalized = CoffeeApi.normalize(res);

    // 判断并提取数组第一项
    if ((normalized.code === 200 || normalized.code === '200') && normalized.data && Array.isArray(normalized.data) && normalized.data.length > 0) {
      const myData: MyData = normalized.data[0];
      return {
        code: normalized.code,
        msg: normalized.msg,
        data: myData,
        result: myData,
        token: normalized.token
      };
    }

    return {
      code: normalized.code,
      msg: normalized.msg,
      data: undefined,
      token: normalized.token
    };
  }

  /**
   * 提交订单页面 - 查询需要购买的商品详情
   */
  static async commitShopcart(token: string, sids: string[]): Promise<ApiResponse<ShopCartItem[]>> {
    const sidsStr = encodeURIComponent(JSON.stringify(sids));
    const res = await HttpUtil.get<RawResponse<ShopCartItem[]>>(
      `/commitShopcart?appkey=${APP_KEY}&tokenString=${encodeURIComponent(token)}&sids=${sidsStr}`
    );
    return CoffeeApi.normalize(res);
  }

  /**
   * 根据 AID 查询单条地址详情
   */
  static async findAddressByAid(token: string, aid: string): Promise<ApiResponse<AddressItem[]>> {
    const res = await HttpUtil.get<RawResponse<AddressItem[]>>(`/findAddressByAid?appkey=${APP_KEY}&tokenString=${encodeURIComponent(token)}&aid=${aid}`);
    return CoffeeApi.normalize(res);
  }

}

export default CoffeeApi;