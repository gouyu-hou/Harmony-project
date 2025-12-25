import router from '@ohos.router';
import { MenuPage } from './MenuPage';
import CoffeeApi, { BannerItem, ProductItem, UserInfo, ShopCartItem, ApiResponse,MyData } from '../api/CoffeeApi';
import promptAction from '@ohos.promptAction';

// --- 本地数据模型 ---
interface Product {
  id: string;
  name: string;
  enName: string;
  price: number;
  isHot?: boolean;
  category: string;
  smallImg?: string;
}

// 模拟数据库
const PRODUCT_DB: Product[] = [
  { id: '1', name: '焦糖拿铁', enName: 'Caramel Latte', price: 28.00, isHot: true, category: '热卖推荐' },
  { id: '2', name: '榛果拿铁', enName: 'Hazelnut Latte', price: 28.00, isHot: true, category: '热卖推荐' },
  { id: '3', name: '标准美式', enName: 'Americano', price: 22.00, isHot: false, category: '咖啡' },
  { id: '4', name: '生椰拿铁', enName: 'Coconut Latte', price: 29.00, isHot: true, category: '拿铁' },
  { id: '5', name: '奥瑞白', enName: 'Flat White', price: 28.00, isHot: true, category: '咖啡' },
  { id: '6', name: '黑糖波波拿铁', enName: 'Brown Sugar Latte', price: 28.00, isHot: true, category: '拿铁' },
  { id: '7', name: '满杯百香果', enName: 'Passion Fruit', price: 25.00, isHot: true, category: '水果茶' },
  { id: '8', name: '椰子冰', enName: 'Coconut Ice', price: 28.00, isHot: true, category: '瑞纳冰' },
];

@Entry
@Component
struct MainApp {
  @State isSearchActive: boolean = false;
  @State currentTabIndex: number = 0;

  build() {
    Stack() {
      Tabs({ index: this.currentTabIndex }) {
        TabContent() {
          HomePage({
            onSearchClick: () => {
              animateTo({ duration: 300 }, () => { this.isSearchActive = true; })
            }
          })
        }
        .tabBar(this.TabBuilder(0, '首页', $r('app.media.home'), $r('app.media.home_active')))

        TabContent() {
          MenuPage({
            onSearchClick: () => {
              animateTo({ duration: 300 }, () => { this.isSearchActive = true; })
            }
          })
        }
        .tabBar(this.TabBuilder(1, '菜单', $r('app.media.menu'), $r('app.media.menu_active')))

        TabContent() {
          BagPage({ currentIndex: this.currentTabIndex })
        }
        .tabBar(this.TabBuilder(2, '购物袋', $r('app.media.shopbag'), $r('app.media.shopbag_active')))

        TabContent() {
          MineView()
        }
        .tabBar(this.TabBuilder(3, '我的', $r('app.media.my'), $r('app.media.my_active')))
      }
      .barPosition(BarPosition.End)
      .onChange((index) => {
        this.currentTabIndex = index;
      })

      if (this.isSearchActive) {
        SearchPage({
          onBack: () => {
            animateTo({ duration: 300 }, () => { this.isSearchActive = false; })
          }
        })
          .zIndex(999)
          .transition({ type: TransitionType.All, opacity: 0 })
      }
    }
    .width('100%')
    .height('100%')
  }

  @Builder TabBuilder(index: number, title: string, icon: Resource, activeIcon: Resource) {
    Column() {
      Image(this.currentTabIndex === index ? activeIcon : icon)
        .width(24)
        .height(24)
        .margin({ bottom: 4 })
        .objectFit(ImageFit.Contain) // 确保图片不失真

      Text(title)
        .fontSize(10)
        .fontColor(this.currentTabIndex === index ? '#0035AA' : '#999999')
    }
    .width('100%')
    .height(50)
    .justifyContent(FlexAlign.Center)
  }
}

// --- 组件：首页 ---
@Component
struct HomePage {
  onSearchClick: () => void = () => {};

  @StorageLink('userInfo') userInfoStr: string = '{}';

  get user(): UserInfo {
    const defaultUser: UserInfo = { userId: '', nickName: 'Guest', userImg: '' };
    if (!this.userInfoStr || this.userInfoStr === '{}') {
      return defaultUser;
    }
    try {
      const parsed = JSON.parse(this.userInfoStr) as UserInfo;
      return parsed ? parsed : defaultUser;
    } catch {
      return defaultUser;
    }
  }

  @State banners: BannerItem[] = [];
  @State hotProducts: Product[] = [];

  aboutToAppear() {
    this.fetchBanners();
    this.fetchHotProducts();
  }

  async fetchBanners() {
    try {
      const res = await CoffeeApi.getBanner();
      if (res.data && Array.isArray(res.data)) {
        this.banners = res.data;
      }
    } catch (err) {
      console.error('[HomePage] Banner 获取失败');
    }
  }

  // ✅ 修改后的 fetchHotProducts
  async fetchHotProducts() {
    console.info('【Debug】开始调用 getHotProducts 接口...');
    try {
      const res = await CoffeeApi.getHotProducts();

      if (res && res.data && Array.isArray(res.data)) {
        this.hotProducts = res.data.map((item: ProductItem) => {
          return {
            id: item.pid,         // ❌ 去掉 parseInt()，直接赋值字符串
            name: item.name,
            enName: item.enname,
            price: parseFloat(item.price), // 价格通常是数字字符串，保留 parseFloat
            isHot: true,
            category: '热卖推荐',
            smallImg: item.smallImg
          } as Product;
        });
        console.info('【Debug】数据转换成功，首个商品ID:', this.hotProducts[0]?.id);
      }
    } catch (err) {
      console.error('【Debug】热卖商品请求异常: ' + JSON.stringify(err));
    }
  }

  build() {
    Column() {
      // 顶部用户信息栏 (保持不变)
      Row() {
        Column() {
          Text('下午好').fontSize(14).fontColor('#333')
          Text(this.user?.nickName ?? 'Guest')
            .fontSize(16).fontWeight(FontWeight.Bold).fontColor('#0035AA')
        }
        .alignItems(HorizontalAlign.Start).margin({ right: 15 })

        Row() {
          Text('🔍').fontSize(14).fontColor('#999').margin({ left: 10, right: 5 })
          Text('请输入搜索关键词').fontSize(14).fontColor('#CCC')
        }
        .layoutWeight(1).height(35).backgroundColor('#F5F5F5').borderRadius(18)
        .onClick(() => { this.onSearchClick(); })
      }
      .width('100%').padding({ left: 15, right: 15, top: 10, bottom: 10 }).backgroundColor(Color.White)

      // 位置：HomePage 组件 -> build() -> Scroll() 内部
      Scroll() {
        Column() {
          // --- Banner 轮播修改 ---
          if (this.banners.length > 0) {
            Swiper() {
              ForEach(this.banners, (item: BannerItem) => {
                Image(item.bannerImg)
                  .width('100%').height(200).backgroundColor('#F0F0F0')
                  .borderRadius(8).objectFit(ImageFit.Cover)
                // ✅ 新增：点击 Banner 跳转详情页
                  .onClick(() => {
                    if (item.pid) {
                      router.pushUrl({
                        url: 'pages/ProductDetailPage',
                        params: { pid: item.pid }
                      })
                    }
                  })
              }, (item: BannerItem, index: number) => item.pid ? `${item.pid}` : `${index}`)
            }
            .width('100%').height(200).autoPlay(true).indicator(true)
          } else {
            Row().width('100%').height(200).backgroundColor('#F0F0F0').borderRadius(8)
          }

          Text('猜你喜欢').fontSize(18).fontWeight(FontWeight.Bold).width('100%').padding(15)

          // 列表渲染 (保持不变，逻辑在 ProductGrid 中修改)
          if (this.hotProducts.length > 0) {
            ProductGrid({ products: this.hotProducts })
          } else {
            Column() {
              LoadingProgress().width(40).height(40).color('#0035AA')
              Text('加载数据中...').fontSize(12).fontColor('#999').margin({ top: 10 })
            }.width('100%').padding(20).justifyContent(FlexAlign.Center)
          }
        }
      }
      .layoutWeight(1).scrollBar(BarState.Off)
    }
    .width('100%').height('100%').backgroundColor(Color.White)
  }
}

// --- 组件：购物袋 ---
@Component
struct BagPage {
  @StorageLink('token') token: string = '';
  @State cartList: ShopCartItem[] = [];
  @State totalPrice: number = 0;

  @Prop @Watch('onIndexChange') currentIndex: number = 0;

  // ✅✅✅ 新增：监听全局刷新信号
  // 当 SettlementPage 将其设为 true 时，这里会自动触发 onRefreshCartChange
  @StorageLink('refreshCart') @Watch('onRefreshCartChange') shouldRefresh: boolean = false;

  // ✅✅✅ 新增：监听回调函数
  onRefreshCartChange() {
    if (this.shouldRefresh) {
      console.info('【Debug】收到刷新信号，正在刷新购物袋...');
      this.fetchCartList(); // 重新拉取数据

      // 重置信号，防止重复触发 (设为 false)
      // 注意：直接修改 @StorageLink 变量会同步回 AppStorage，下次支付成功再次变 true 时又能触发
      setTimeout(() => {
        this.shouldRefresh = false;
      }, 100);
    }
  }

  onIndexChange() {
    if (this.currentIndex === 2) {
      this.fetchCartList();
    }
  }

  aboutToAppear() {
    this.fetchCartList();
  }

  // ... 下面的 fetchCartList, calculateTotal, handleCountChange 等保持不变 ...
  async fetchCartList() {
    if (!this.token) {
      this.cartList = [];
      this.totalPrice = 0;
      return;
    }
    try {
      const res = await CoffeeApi.getShopcartList(this.token);
      if (res.data && Array.isArray(res.data)) {
        this.cartList = res.data;
        this.calculateTotal();
      } else {
        this.cartList = [];
        this.totalPrice = 0;
      }
    } catch (err) {
      console.error('[BagPage] 刷新购物车失败:', JSON.stringify(err));
      this.cartList = [];
      this.totalPrice = 0;
    }
  }

  calculateTotal() {
    let total = 0;
    this.cartList.forEach((item) => {
      // 价格安全转换
      const price = typeof item.price === 'string' ? parseFloat(item.price) : item.price;
      total += price * item.count;
    });
    this.totalPrice = total;
  }

  async handleCountChange(sid: string, newCount: number) {
    if (newCount < 1) return;

    const index = this.cartList.findIndex(item => item.sid === sid);
    if (index === -1) return;

    try {
      const res: ApiResponse<null> = await CoffeeApi.updateShopcartCount(this.token, sid, newCount);
      console.info('接口返回码:', res.code);

      if (res.code === 6000 || res.code === 200 || res.code === '200') {
        let newItem = this.cartList[index];
        newItem.count = newCount;
        this.cartList.splice(index, 1, newItem);
        this.cartList = [...this.cartList];
        this.calculateTotal();
      } else {
        promptAction.showToast({ message: res.msg || '修改失败' });
      }
    } catch (err) {
      console.error('修改数量异常', JSON.stringify(err));
    }
  }

  async handleDelete(sid: string) {
    try {
      const res: ApiResponse<null> = await CoffeeApi.deleteShopcart(this.token, [sid]);
      if (res.code === 7000 || res.code === 6000 || res.code === 200 || res.code === '200' || res.msg === 'Success') {
        this.cartList = this.cartList.filter(item => item.sid !== sid);
        this.calculateTotal();
        promptAction.showToast({ message: '已删除' });
      } else {
        promptAction.showToast({ message: res.msg || '删除失败' });
      }
    } catch (err) {
      promptAction.showToast({ message: '删除异常' });
    }
  }

  @Builder renderCartItem(item: ShopCartItem) {
    ListItem() {
      Row() {
        Image(item.small_img).width(80).height(80).borderRadius(8).objectFit(ImageFit.Cover).backgroundColor('#F5F5F5')

        Column() {
          Text(item.name).fontSize(16).fontWeight(FontWeight.Bold).maxLines(1).textOverflow({ overflow: TextOverflow.Ellipsis })
          Text(item.rule).fontSize(12).fontColor('#999').margin({ top: 5 })
          Blank()
          Row() {
            Text(`¥${item.price}`).fontSize(16).fontColor('#D22028').fontWeight(FontWeight.Bold)
            Blank()
            Row() {
              Text('－').fontSize(15).fontColor('#0035AA').padding({ left: 10, right: 10 })
                .onClick(() => this.handleCountChange(item.sid, item.count - 1))
              Text(`${item.count}`).fontSize(14)
              Text('＋').fontSize(20).fontColor('#0035AA').padding({ left: 10, right: 10 })
                .onClick(() => this.handleCountChange(item.sid, item.count + 1))
            }
          }.width('100%')
        }
        .layoutWeight(1).height(80).margin({ left: 10 }).alignItems(HorizontalAlign.Start)

        Text('×').fontSize(24).fontColor('#999').padding(10)
          .onClick(() => {
            AlertDialog.show({
              title: '提示',
              message: '确定删除该商品吗？',
              primaryButton: { value: '取消', action: () => {} },
              secondaryButton: { value: '删除', fontColor: 'red', action: () => this.handleDelete(item.sid) }
            })
          })
      }
      .width('100%').padding(10).backgroundColor(Color.White).borderRadius(8)
    }
  }

  build() {
    Column() {
      Row() {
        Text('购物袋').fontSize(18).fontWeight(FontWeight.Bold)
      }
      .width('100%').height(50).justifyContent(FlexAlign.Center).backgroundColor(Color.White)

      if (!this.token) {
        Column() {
          Image($r('app.media.shopbag_bg')).width(200).height(200).objectFit(ImageFit.Contain)
          Text('您还没有登录哦').fontSize(14).fontColor('#999').margin({ top: 10 })
          Button('去登录', { type: ButtonType.Normal }).width(120).height(40).backgroundColor('#0035AA').borderRadius(20).margin({ top: 20 })
            .onClick(() => { router.pushUrl({ url: 'pages/LoginPage' }) })
        }.layoutWeight(1).justifyContent(FlexAlign.Center)
      } else if (this.cartList.length === 0) {
        Column() {
          Image($r('app.media.shopbag_bg')).width(200).height(200).objectFit(ImageFit.Contain)
          Text('购物袋空空如也').fontSize(14).fontColor('#999').margin({ top: 10 })
          Button('去逛逛', { type: ButtonType.Normal }).width(120).height(40).backgroundColor('#0035AA').borderRadius(20).margin({ top: 20 })
            .onClick(() => { promptAction.showToast({ message: '请点击底部菜单进行选购' }); })
        }.layoutWeight(1).justifyContent(FlexAlign.Center)
      } else {
        List({ space: 10 }) {
          ForEach(this.cartList, (item: ShopCartItem) => {
            this.renderCartItem(item)
          }, (item: ShopCartItem) => `${item.sid}_${item.count}`)
        }.layoutWeight(1).padding(10).width('100%')

        Row() {
          Text(`应付合计: ¥${this.totalPrice}`).fontSize(16).fontWeight(FontWeight.Bold).fontColor('#333')
          Button('去结算', { type: ButtonType.Normal })
            .width(100).height(40).backgroundColor('#0035AA').borderRadius(20)
            .onClick(() => {
              if (this.cartList.length === 0) return;
              const sids = this.cartList.map(item => item.sid);
              router.pushUrl({
                url: 'pages/SettlementPage',
                params: {
                  sids: sids,
                  totalPrice: this.totalPrice
                }
              })
            })
        }
        .width('100%').height(60).backgroundColor(Color.White).padding({ left: 15, right: 15 })
        .justifyContent(FlexAlign.SpaceBetween)
        .shadow({ radius: 10, color: '#1A000000', offsetY: -2 })
      }
    }
    .width('100%').height('100%').backgroundColor('#F5F5F5')
  }
}

// ... MineView 和 SearchPage 保持不变，请确保文件后半部分包含它们 ...
// 为了代码完整性，这里补全剩余部分

// entry/src/main/ets/pages/MainPage.ets

// ... (前面的代码)

@Component
struct MineView {
  @StorageLink('token') token: string = '';
  @StorageLink('userInfo') userInfoStr: string = '{}';

  // 定义状态变量
  @State myData: MyData = { userBg: '' };

  // ✅✅✅ 修改 1：同时调用两个接口
  aboutToAppear() {
    if (this.token) {
      this.fetchMyData();     // 获取背景图
      this.fetchUserInfo();   // 获取昵称、头像、签名
    }
  }

  // ✅✅✅ 新增方法：获取用户基本信息并更新全局缓存
  async fetchUserInfo() {
    try {
      const res = await CoffeeApi.getUserInfo(this.token);
      // 只要 code 是 200，就说明获取成功
      if (res.code === 200 || res.code === '200') {
        if (res.data) {
          console.info('【Debug】获取用户信息成功:', res.data.nickName);
          // 更新 AppStorage，这会自动刷新 this.user 以及页面上的显示
          AppStorage.SetOrCreate('userInfo', JSON.stringify(res.data));
        }
      }
    } catch (err) {
      console.error('获取用户信息失败', JSON.stringify(err));
    }
  }

  // 获取背景图的方法 (保持不变)
  async fetchMyData() {
    console.info('【Debug】准备调用 /findMy 接口...');
    try {
      const res = await CoffeeApi.findMy(this.token);
      if (res.code === 200 || res.code === '200') {
        if (res.data) {
          this.myData = res.data;
        }
      }
    } catch (err) {
      console.error('【Debug】/findMy 接口异常:', JSON.stringify(err));
    }
  }

  // 计算属性 (保持不变)
  get user(): UserInfo {
    const defaultUser: UserInfo = { userId: '', nickName: '', userImg: '' };
    if (!this.userInfoStr || this.userInfoStr === '{}') {
      return defaultUser;
    }
    try {
      const parsed = JSON.parse(this.userInfoStr) as UserInfo;
      return parsed ? parsed : defaultUser;
    } catch {
      return defaultUser;
    }
  }

  build() {
    Column() {
      Stack({ alignContent: Alignment.BottomStart }) {

        // 背景图 (保持不变)
        if (this.myData.userBg) {
          Image(this.myData.userBg)
            .width('100%').height(200).objectFit(ImageFit.Cover).backgroundColor('#333')
        } else {
          Column().width('100%').height(200).backgroundColor('#333')
        }

        Row() {
          Stack({ alignContent: Alignment.Center }) {
            // 头像：优先用 user.userImg (UserInfo接口更准)，其次用 myData
            Image(this.token && (this.user?.userImg || this.myData.userImg) ? (this.user?.userImg || this.myData.userImg) : $r('app.media.home'))
              .width(60).height(60).borderRadius(30).backgroundColor(Color.White)
              .objectFit(ImageFit.Cover)
              .alt($r('app.media.home'))
          }.margin({ right: 15 })

          Column() {
            // ✅✅✅ 修改 2：昵称显示逻辑
            // 优先取 user.nickName (fetchUserInfo 更新的)，其次取 myData.nickName
            Text(this.token ? (this.user?.nickName || this.myData.nickName || '用户') : '点击登录')
              .fontSize(18).fontWeight(FontWeight.Bold).fontColor(Color.White).margin({ bottom: 5 })
              .onClick(() => {
                if (!this.token) router.pushUrl({ url: 'pages/LoginPage' });
              })

            // ✅✅✅ 修改 3：个性签名显示逻辑
            // 优先取 user.desc
            Text(this.token ? (this.user?.desc || '欢迎回来') : '登录享受更多权益')
              .fontSize(12).fontColor('#EEE')
          }
          .alignItems(HorizontalAlign.Start)
        }
        .width('100%').padding({ left: 20, bottom: 30 })
      }
      .width('100%').height(200)

      // ... 下面的菜单代码保持不变 ...
      Column() {
        this.MenuItem('个人资料', () => { if (this.checkLogin()) router.pushUrl({ url: 'pages/UserInfoPage' }) })
        Divider().color('#F5F5F5')
        this.MenuItem('我的订单', () => { if (this.checkLogin()) router.pushUrl({ url: 'pages/MyOrderPage' }) })
        Divider().color('#F5F5F5')
        this.MenuItem('我的收藏', () => { if (this.checkLogin()) router.pushUrl({ url: 'pages/MyFavoritePage' }) })
        Divider().color('#F5F5F5')
        this.MenuItem('地址管理', () => { if (this.checkLogin()) router.pushUrl({ url: 'pages/AddressListPage' }) })
        Divider().color('#F5F5F5')
        this.MenuItem('安全中心', () => { if (this.checkLogin()) router.pushUrl({ url: 'pages/SecurityPage' }) })

        if (this.token) {
          Divider().color('#F5F5F5')
          Row() {
            Text('退出登录').fontSize(16).fontColor('#D22028')
          }
          .width('100%').height(55).justifyContent(FlexAlign.Center)
          .backgroundColor(Color.White)
          .onClick(() => {
            this.handleLogout();
          })
        }
      }
      .width('100%').backgroundColor(Color.White).borderRadius({ topLeft: 12, topRight: 12 })
      .margin({ top: -15 }).padding({ top: 10, bottom: 10 })
    }
    .width('100%').height('100%').backgroundColor('#F5F5F5')
  }

  // ... (MenuItem, checkLogin, handleLogout 等方法保持不变)
  @Builder MenuItem(title: string, onClick: () => void) {
    Row() {
      Text(title).fontSize(16).fontColor('#333')
      Text('>').fontSize(16).fontColor('#999')
    }
    .width('100%').height(55).justifyContent(FlexAlign.SpaceBetween).padding({ left: 20, right: 20 })
    .backgroundColor(Color.White).onClick(onClick)
  }

  checkLogin(): boolean {
    if (!this.token) {
      router.pushUrl({ url: 'pages/LoginPage' });
      return false;
    }
    return true;
  }

  handleLogout() {
    AlertDialog.show({
      title: '提示',
      message: '确定要退出登录吗？',
      primaryButton: { value: '取消', action: () => {} },
      secondaryButton: {
        value: '退出', fontColor: '#D22028',
        action: () => {
          AppStorage.SetOrCreate('token', '');
          AppStorage.SetOrCreate('userInfo', '{}');
          router.replaceUrl({ url: 'pages/LoginPage' });
        }
      }
    })
  }
}

// --- 组件：搜索页 ---
@Component
struct SearchPage {
  onBack: () => void = () => {};
  @State searchText: string = '';
  @State searchHistory: string[] = ['拿铁', '美式'];
  @State searchResults: Product[] = [];

  build() {
    Column() {
      Row() {
        Text('<').fontSize(24).fontWeight(FontWeight.Bold).fontColor('#333').padding({ right: 10 }).onClick(() => this.onBack())
        TextInput({ placeholder: '请输入咖啡名称', text: this.searchText })
          .layoutWeight(1).height(35).backgroundColor('#F5F5F5').borderRadius(18).margin({ left: 10, right: 10 }).padding({ left: 15 })
          .enterKeyType(EnterKeyType.Search)
          .onChange((value) => { this.searchText = value; })
          .onSubmit(() => { this.performSearch(this.searchText); })

        Text('搜索').fontSize(16).fontColor('#0035AA').onClick(() => { this.performSearch(this.searchText); })
      }
      .width('100%').padding({ left: 15, right: 15, top: 10, bottom: 10 }).backgroundColor(Color.White)

      if (this.searchResults.length === 0) {
        Column() {
          Flex({ wrap: FlexWrap.Wrap }) {
            ForEach(this.searchHistory, (item: string, index: number) => {
              Row() {
                Text(item).fontSize(14).fontColor('#666')
                Text('×').fontSize(14).fontColor('#999').margin({ left: 5 }).onClick(() => { this.searchHistory.splice(index, 1); })
              }
              .padding({ left: 12, right: 12, top: 6, bottom: 6 }).backgroundColor('#F5F5F5').borderRadius(4).margin({ right: 10, bottom: 10 })
              .onClick(() => { this.searchText = item; this.performSearch(item); })
            }, (item: string, index: number) => `${item}_${index}`)
          }
          .padding({ top: 10, bottom: 20 })
          if (this.searchHistory.length > 0) {
            Button('清除所有搜索历史', { type: ButtonType.Normal }).backgroundColor('#F0F0F0').fontColor('#999').fontSize(12).width(150).height(30).borderRadius(15).onClick(() => { this.searchHistory = []; })
          }
        }
        .width('100%').padding(15).alignItems(HorizontalAlign.Center)
      } else {
        Scroll() { ProductGrid({ products: this.searchResults }) }.layoutWeight(1)
      }
    }
    .width('100%').height('100%').backgroundColor(Color.White)
  }

  async performSearch(keyword: string) {
    if (!keyword || keyword.trim() === '') {
      this.searchResults = [];
      return;
    }

    // 记录历史
    if (!this.searchHistory.includes(keyword)) {
      this.searchHistory.unshift(keyword);
    }

    // ✅ 调用 API 搜索
    try {
      const res = await CoffeeApi.search(keyword);
      // 兼容字符串类型的 code
      if ((res.code === 200 || res.code === '200') && res.data) {
        this.searchResults = res.data.map((item: ProductItem): Product => {
          return {
            id: item.pid,
            name: item.name,
            enName: item.enname,
            price: parseFloat(item.price),
            smallImg: item.smallImg,
            category: 'Search',
            isHot: false
          };
        });
      } else {
        this.searchResults = [];
      }
    } catch (err) {
      console.error('搜索失败');
      this.searchResults = [];
    }
  }
}

// --- 组件：商品网格 ---
// --- 组件：商品网格 ---
// 位置：文件最底部
@Component
struct ProductGrid {
  @Prop products: Product[] = [];

  build() {
    // ✅ 修改1：使用 Flex 替换 Grid，解决显示不全问题
    Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.SpaceBetween }) {
      ForEach(this.products, (item: Product) => {
        Column() {
          // 1. 图片部分
          Stack({ alignContent: Alignment.TopStart }) {
            Image(item.smallImg)
              .width('100%')
              .height(150)
              .objectFit(ImageFit.Contain)
              .backgroundColor('#F9F9F9')
              .borderRadius({ topLeft: 8, topRight: 8 })
              .alt($r('app.media.shopbag_bg'))

            if (item.isHot) {
              Text('热卖')
                .fontSize(10)
                .fontColor(Color.White)
                .backgroundColor('#FF4400')
                .padding({ left: 6, right: 6, top: 2, bottom: 2 })
                .borderRadius({ topLeft: 8, bottomRight: 8 })
            }
          }

          // 2. 文字与价格部分
          Column() {
            Text(item.name)
              .fontSize(16)
              .fontWeight(FontWeight.Bold)
              .fontColor('#333')
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
              .width('100%')

            Text(item.enName)
              .fontSize(12)
              .fontColor('#999')
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
              .width('100%')
              .margin({ top: 2, bottom: 10 })

            Row() {
              Text(`¥${item.price.toFixed(2)}`)
                .fontSize(16)
                .fontColor('#D22028')
                .fontWeight(FontWeight.Bold)

              // 只是视觉符号，点击事件已提升到整个卡片
              Text('⊕')
                .fontSize(24)
                .fontColor('#0035AA')
            }
            .width('100%').justifyContent(FlexAlign.SpaceBetween)
          }
          .padding(10).backgroundColor(Color.White)
        }
        .width('48%') // 设置宽度适配两列布局
        .borderRadius(8)
        .backgroundColor(Color.White)
        .margin({ bottom: 10 })
        .shadow({ radius: 4, color: '#1A000000', offsetX: 0, offsetY: 2 })
        // ✅ 修改2：将点击事件绑定在整个 Item (Column) 上
        .onClick(() => {
          router.pushUrl({
            url: 'pages/ProductDetailPage',
            params: { pid: item.id }
          })
        })
      }, (item: Product) => `${item.id}`)
    }
    .width('100%')
    .padding(10)
    // 注意：不要设置 .height('100%')，让内容自动撑开
  }
}