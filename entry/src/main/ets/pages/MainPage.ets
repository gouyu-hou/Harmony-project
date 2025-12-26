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

// 1. 定义扩展接口，增加选中状态 checked
interface ExtendedShopCartItem extends ShopCartItem {
  checked: boolean;
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

  // ✅✅✅ 请将这段代码加在这里 (MainApp 内部)
  aboutToAppear() {
    const params = router.getParams() as Record<string, number>;
    if (params && params['index'] !== undefined) {
      this.currentTabIndex = params['index'];
    }
  }

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
// --- 组件：购物袋 ---
@Component
struct BagPage {
  @StorageLink('token') token: string = '';
  // 使用扩展后的类型 (确保你在文件顶部定义了 interface ExtendedShopCartItem extends ShopCartItem { checked: boolean; })
  @State cartList: ExtendedShopCartItem[] = [];
  @State totalPrice: number = 0;
  @State isAllSelected: boolean = true;
  @State isEditMode: boolean = false; // 【新增】编辑模式状态

  @Prop @Watch('onIndexChange') currentIndex: number = 0;
  @StorageLink('refreshCart') @Watch('onRefreshCartChange') shouldRefresh: boolean = false;

  onRefreshCartChange() {
    if (this.shouldRefresh) {
      this.fetchCartList();
      setTimeout(() => { this.shouldRefresh = false; }, 100);
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

  // --- 数据请求与逻辑处理 ---
  async fetchCartList() {
    if (!this.token) {
      this.cartList = [];
      this.totalPrice = 0;
      return;
    }
    try {
      const res = await CoffeeApi.getShopcartList(this.token);
      if (res.data && Array.isArray(res.data)) {
        let tempList: ExtendedShopCartItem[] = [];
        res.data.forEach((item) => {
          let extendedItem = item as ExtendedShopCartItem;
          extendedItem.checked = true;
          tempList.push(extendedItem);
        });
        this.cartList = tempList;
        this.updateAllSelectedState();
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
      if (item.checked) {
        const price = typeof item.price === 'string' ? parseFloat(item.price) : item.price;
        total += price * item.count;
      }
    });
    this.totalPrice = total;
  }

  updateAllSelectedState() {
    if (this.cartList.length === 0) {
      this.isAllSelected = false;
    } else {
      this.isAllSelected = this.cartList.every(item => item.checked);
    }
  }

  toggleItemSelect(index: number) {
    this.cartList[index].checked = !this.cartList[index].checked;
    this.cartList = this.cartList.slice(); // 触发更新
    this.updateAllSelectedState();
    this.calculateTotal();
  }

  toggleSelectAll() {
    this.isAllSelected = !this.isAllSelected;
    this.cartList.forEach(item => {
      item.checked = this.isAllSelected;
    });
    this.cartList = this.cartList.slice();
    this.calculateTotal();
  }

  async handleCountChange(sid: string, newCount: number) {
    if (newCount < 1) return;
    const index = this.cartList.findIndex(item => item.sid === sid);
    if (index === -1) return;
    try {
      const res: ApiResponse<null> = await CoffeeApi.updateShopcartCount(this.token, sid, newCount);
      if (res.code === 6000 || res.code === 200 || res.code === '200') {
        this.cartList[index].count = newCount;
        this.cartList = this.cartList.slice();
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
        this.updateAllSelectedState();
        this.calculateTotal();
        promptAction.showToast({ message: '已删除商品' });
      } else {
        promptAction.showToast({ message: res.msg || '删除失败' });
      }
    } catch (err) {
      promptAction.showToast({ message: '删除异常' });
    }
  }

  // 批量删除（配合编辑模式）
  async handleBatchDelete() {
    const selectedSids = this.cartList.filter(item => item.checked).map(item => item.sid);
    if (selectedSids.length === 0) {
      promptAction.showToast({ message: '请先选择要删除的商品' });
      return;
    }
    try {
      const res: ApiResponse<null> = await CoffeeApi.deleteShopcart(this.token, selectedSids);
      if (res.code === 7000 || res.code === 6000 || res.code === 200 || res.code === '200' || res.msg === 'Success') {
        this.cartList = this.cartList.filter(item => !item.checked);
        this.updateAllSelectedState();
        this.calculateTotal();
        this.isEditMode = false; // 删除后退出编辑模式
        promptAction.showToast({ message: '已批量删除' });
      }
    } catch (err) {
      promptAction.showToast({ message: '删除失败' });
    }
  }

  @Builder SwipeDeleteMenu(sid: string) {
    Row() {
      Column() {
        Text('删除')
          .fontColor(Color.White)
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
      }
      .width(70)
      .height('100%')
      .justifyContent(FlexAlign.Center)
      .backgroundColor('#D22028')
      .borderRadius({ topRight: 12, bottomRight: 12 })
      .onClick(() => {
        this.handleDelete(sid);
      })
    }
    .padding({ left: 10 })
  }

  @Builder renderCartItem(item: ExtendedShopCartItem, index: number) {
    ListItem() {
      Row() {
        // 勾选圈
        Toggle({ type: ToggleType.Checkbox, isOn: item.checked })
          .selectedColor('#0035AA')
          .width(24)
          .height(24)
          .margin({ right: 10 })
          .onClick(() => {
            this.toggleItemSelect(index);
          })

        // 卡片主体
        Row() {
          Image(item.small_img)
            .width(90).height(90)
            .borderRadius(8).objectFit(ImageFit.Cover).backgroundColor('#F5F5F5')

          Column() {
            Text(item.name)
              .fontSize(16).fontWeight(FontWeight.Bold).fontColor('#333')
              .maxLines(1).textOverflow({ overflow: TextOverflow.Ellipsis })
              .width('100%')

            Text(item.rule)
              .fontSize(12).fontColor('#999').margin({ top: 4, bottom: 4 })
              .maxLines(1).textOverflow({ overflow: TextOverflow.Ellipsis })
              .width('100%')

            Blank()

            Row() {
              Text(`¥${item.price}`)
                .fontSize(18).fontColor('#D22028').fontWeight(FontWeight.Bold)

              Blank()

              // 数量加减
              Row() {
                Text('－')
                  .fontSize(14).fontColor('#0035AA').fontWeight(FontWeight.Bold)
                  .width(24).height(24).textAlign(TextAlign.Center)
                  .border({ width: 1, color: '#0035AA', radius: 12 })
                  .onClick(() => this.handleCountChange(item.sid, item.count - 1))

                Text(`${item.count}`)
                  .fontSize(14).fontColor('#333').margin({ left: 10, right: 10 })

                Text('＋')
                  .fontSize(16).fontColor(Color.White).backgroundColor('#0035AA')
                  .width(24).height(24).textAlign(TextAlign.Center).borderRadius(12)
                  .onClick(() => this.handleCountChange(item.sid, item.count + 1))
              }
            }
            .width('100%').alignItems(VerticalAlign.Center)
          }
          .layoutWeight(1).height(90).margin({ left: 10 }).alignItems(HorizontalAlign.Start)
        }
        .layoutWeight(1)
      }
      .width('100%').padding(12).backgroundColor(Color.White)
      .borderRadius(12).shadow({ radius: 4, color: '#0D000000', offsetY: 2 })
    }
    .margin({ bottom: 12 })
    .swipeAction({ end: this.SwipeDeleteMenu(item.sid) })
  }

  build() {
    Column() {
      // ---------------- 【顶部区域核心修改】 ----------------
      Stack({ alignContent: Alignment.Bottom }) {
        // 1. 背景图 (作为 Header 背景，调整合适高度)
        Image($r('app.media.shopbag_bg'))
          .width('100%')          // 容器宽度100%
          .height('auto')         // 高度自适应（关键：避免拉伸，保证比例）
          .objectFit(ImageFit.Contain) // 完整展示图片（不裁剪，留白填充）
          .opacity(0.45)          // 透明度保持不变
          .backgroundColor('#F0F8FF') // 底色（图片未覆盖的区域会显示这个颜色）

        // 2. 导航栏内容 (返回 | 标题 | 编辑)
        Row() {

          // 中间：标题
          Text('购物袋')
            .fontSize(20)
            .fontColor('#33')
            .layoutWeight(1)
            .margin(
              {
                left:40,

              }
            )
            .textAlign(TextAlign.Center)

          // 右侧：编辑按钮
          Row() {
            Text(this.isEditMode ? '完成' : '编辑')
              .fontSize(16)
              .fontColor('#333')
          }
          .width(50)
          .height('100%')
          .justifyContent(FlexAlign.End)
          .alignItems(VerticalAlign.Center)
          .onClick(() => {
            this.isEditMode = !this.isEditMode;
          })
        }
        .width('100%')
        .height(50) // 导航栏高度
        .padding({ left: 15, right: 15 })
        .margin({ bottom: 10 }) // 稍微离底一点
      }
      .width('100%')
      .height(100) // 整体头部高度，包含状态栏空间
      .backgroundColor(Color.White)
      .zIndex(1)
      // -----------------------------------------------------

      // 列表内容
      if (!this.token) {
        this.EmptyView('您还没有登录哦', '去登录', () => router.pushUrl({ url: 'pages/LoginPage' }))
      } else if (this.cartList.length === 0) {
        this.EmptyView('购物袋空空如也', '去逛逛', () => {
          promptAction.showToast({ message: '请点击底部菜单进行选购' });
        })
      } else {
        List() {
          ForEach(this.cartList, (item: ExtendedShopCartItem, index: number) => {
            this.renderCartItem(item, index)
          }, (item: ExtendedShopCartItem) => `${item.sid}_${item.count}_${item.checked}`)
        }
        .layoutWeight(1)
        .width('100%')
        .padding({ left: 15, right: 15, top: 15 })

        // 底部结算/删除栏
        Row() {
          // 全选
          Row() {
            Toggle({ type: ToggleType.Checkbox, isOn: this.isAllSelected })
              .selectedColor('#0035AA')
              .onClick(() => { this.toggleSelectAll(); })
            Text('全选').fontSize(14).fontColor('#333').margin({ left: 5 })
          }.height('100%').alignItems(VerticalAlign.Center)

          // 右侧操作区 (根据是否编辑模式变化)
          if (this.isEditMode) {
            // 编辑模式：显示删除按钮
            Button(`删除(${this.cartList.filter(i => i.checked).length})`, { type: ButtonType.Normal })
              .width(100).height(40)
              .backgroundColor('#D22028') // 红色删除
              .borderRadius(20)
              .onClick(() => {
                this.handleBatchDelete();
              })
          } else {
            // 正常模式：显示合计和结算
            Row({ space: 15 }) {
              Column() {
                Text('合计').fontSize(12).fontColor('#666')
                Row() {
                  Text('¥').fontSize(12).fontColor('#D22028').fontWeight(FontWeight.Bold).margin({ bottom: 2 })
                  Text(`${this.totalPrice.toFixed(2)}`).fontSize(20).fontColor('#D22028').fontWeight(FontWeight.Bold)
                }.alignItems(VerticalAlign.Bottom)
              }.alignItems(HorizontalAlign.End)

              Button(`去结算(${this.cartList.filter(i => i.checked).length})`, { type: ButtonType.Normal })
                .width(120).height(40)
                .backgroundColor(this.totalPrice > 0 ? '#0035AA' : '#CCCCCC')
                .borderRadius(20)
                .enabled(this.totalPrice > 0)
                .onClick(() => {
                  const selectedSids = this.cartList.filter(item => item.checked).map(item => item.sid);
                  if (selectedSids.length === 0) return;
                  router.pushUrl({
                    url: 'pages/SettlementPage',
                    params: { sids: selectedSids, totalPrice: this.totalPrice }
                  })
                })
            }
          }
        }
        .width('100%').height(70).backgroundColor(Color.White)
        .padding({ left: 20, right: 20 })
        .justifyContent(FlexAlign.SpaceBetween)
        .shadow({ radius: 10, color: '#1A000000', offsetY: -4 })
      }
    }
    .width('100%').height('100%').backgroundColor('#F9F9F9')
  }

  @Builder EmptyView(text: string, btnText: string, action: () => void) {
    Column() {
      Image($r('app.media.shopbag_bg')).width(200).height(200).objectFit(ImageFit.Contain).opacity(0.8)
      Text(text).fontSize(14).fontColor('#999').margin({ top: 10 })
      Button(btnText, { type: ButtonType.Normal })
        .width(140).height(40).backgroundColor('#0035AA').borderRadius(20).margin({ top: 20 })
        .onClick(action)
    }.layoutWeight(1).justifyContent(FlexAlign.Center).width('100%')
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