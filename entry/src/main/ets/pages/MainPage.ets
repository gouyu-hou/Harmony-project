import router from '@ohos.router';
import { MenuPage } from './MenuPage';
import CoffeeApi, { BannerItem, ProductItem, UserInfo, ShopCartItem, ApiResponse } from '../api/CoffeeApi';
import promptAction from '@ohos.promptAction';

// --- 本地数据模型 ---
interface Product {
  id: number;
  name: string;
  enName: string;
  price: number;
  isHot?: boolean;
  category: string;
  smallImg?: string;
}

// 模拟数据库
const PRODUCT_DB: Product[] = [
  { id: 1, name: '焦糖拿铁', enName: 'Caramel Latte', price: 28.00, isHot: true, category: '热卖推荐' },
  { id: 2, name: '榛果拿铁', enName: 'Hazelnut Latte', price: 28.00, isHot: true, category: '热卖推荐' },
  { id: 3, name: '标准美式', enName: 'Americano', price: 22.00, isHot: false, category: '咖啡' },
  { id: 4, name: '生椰拿铁', enName: 'Coconut Latte', price: 29.00, isHot: true, category: '拿铁' },
  { id: 5, name: '奥瑞白', enName: 'Flat White', price: 28.00, isHot: true, category: '咖啡' },
  { id: 6, name: '黑糖波波拿铁', enName: 'Brown Sugar Latte', price: 28.00, isHot: true, category: '拿铁' },
  { id: 7, name: '满杯百香果', enName: 'Passion Fruit', price: 25.00, isHot: true, category: '水果茶' },
  { id: 8, name: '椰子冰', enName: 'Coconut Ice', price: 28.00, isHot: true, category: '瑞纳冰' },
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
        .tabBar(this.TabBuilder(0, '首页', '🏠'))

        TabContent() {
          MenuPage({
            onSearchClick: () => {
              animateTo({ duration: 300 }, () => { this.isSearchActive = true; })
            }
          })
        }
        .tabBar(this.TabBuilder(1, '菜单', '☕'))

        TabContent() {
          BagPage()
        }
        .tabBar(this.TabBuilder(2, '购物袋', '🛍️'))

        TabContent() {
          MineView()
        }
        .tabBar(this.TabBuilder(3, '我的', '👤'))
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

  @Builder TabBuilder(index: number, title: string, iconEmoji: string) {
    Column() {
      Text(iconEmoji).fontSize(24).margin({ bottom: 4 })
        .opacity(this.currentTabIndex === index ? 1 : 0.4)
      Text(title).fontSize(10)
        .fontColor(this.currentTabIndex === index ? '#0035AA' : '#999999')
    }
    .width('100%').height(50).justifyContent(FlexAlign.Center)
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

  aboutToAppear() {
    this.fetchBanners();
  }

  async fetchBanners() {
    try {
      const res = await CoffeeApi.getBanner();
      if (res.code === 200 && res.data) {
        this.banners = res.data;
      }
    } catch (err) {
      console.error('[HomePage Error] Banner 获取失败');
    }
  }

  build() {
    Column() {
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

      Scroll() {
        Column() {
          if (this.banners.length > 0) {
            Swiper() {
              ForEach(this.banners, (item: BannerItem) => {
                Image(item.bannerImg)
                  .width('100%').height(200).backgroundColor('#F0F0F0')
                  .borderRadius(8).objectFit(ImageFit.Cover)
              }, (item: BannerItem, index: number) => item.pid ? `${item.pid}` : `${index}`)
            }
            .width('100%').height(200).autoPlay(true).indicator(true)
          } else {
            Row().width('100%').height(200).backgroundColor('#F0F0F0').borderRadius(8)
          }

          Text('猜你喜欢').fontSize(18).fontWeight(FontWeight.Bold).width('100%').padding(15)
          ProductGrid({ products: PRODUCT_DB })
        }
      }
      .layoutWeight(1).scrollBar(BarState.Off)
    }
    .width('100%').height('100%').backgroundColor(Color.White)
  }
}

// --- 组件：购物袋 (完全修复版) ---
@Component
struct BagPage {
  @StorageLink('token') token: string = '';
  @State cartList: ShopCartItem[] = [];
  @State totalPrice: number = 0;

  onPageShow() {
    this.fetchCartList();
  }

  aboutToAppear() {
    this.fetchCartList();
  }

  async fetchCartList() {
    if (!this.token) {
      this.cartList = [];
      this.totalPrice = 0;
      return;
    }
    try {
      const res: ApiResponse<ShopCartItem[]> = await CoffeeApi.getShopcartList(this.token);
      if (res.code === 200 && res.data) {
        // ✅ 安全校验：确保 data 是数组
        this.cartList = Array.isArray(res.data) ? res.data : [];
        this.calculateTotal();
      } else {
        this.cartList = [];
        this.totalPrice = 0;
      }
    } catch (err) {
      console.error('获取购物车失败');
      this.cartList = [];
    }
  }

  calculateTotal() {
    let total = 0;
    this.cartList.forEach((item) => {
      total += item.price * item.count;
    });
    this.totalPrice = total;
  }

  async handleCountChange(sid: string, newCount: number) {
    if (newCount < 1) return;
    try {
      const res: ApiResponse<null> = await CoffeeApi.updateShopcartCount(this.token, sid, newCount);
      if (res.code === 200 || res.code === 'B001' || res.msg === 'Success') {
        const item = this.cartList.find(i => i.sid === sid);
        if (item) {
          item.count = newCount;
          this.calculateTotal();
        }
      }
    } catch (err) {
      console.error('修改数量失败');
    }
  }

  async handleDelete(sid: string) {
    try {
      const res: ApiResponse<null> = await CoffeeApi.deleteShopcart(this.token, [sid]);
      if (res.code === 200 || res.code === 'B001' || res.msg === 'Success') {
        this.cartList = this.cartList.filter(item => item.sid !== sid);
        this.calculateTotal();
        promptAction.showToast({ message: '已删除' });
      }
    } catch (err) {
      promptAction.showToast({ message: '删除失败' });
    }
  }

  // ✅ 核心修复：将 ListItem 提取为 @Builder
  // 这能解决 ForEach 内部 "is not callable" 的上下文丢失问题
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
              Text('－').fontSize(20).fontColor('#0035AA').padding({ left: 10, right: 10 })
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
          Button('去登录', { type: ButtonType.Normal })
            .width(120).height(40).backgroundColor('#0035AA').borderRadius(20).margin({ top: 20 })
            .onClick(() => { router.pushUrl({ url: 'pages/LoginPage' }) })
        }.layoutWeight(1).justifyContent(FlexAlign.Center)
      } else if (this.cartList.length === 0) {
        Column() {
          Image($r('app.media.shopbag_bg')).width(200).height(200).objectFit(ImageFit.Contain)
          Text('购物袋空空如也').fontSize(14).fontColor('#999').margin({ top: 10 })
          Button('去逛逛', { type: ButtonType.Normal })
            .width(120).height(40).backgroundColor('#0035AA').borderRadius(20).margin({ top: 20 })
            .onClick(() => {
              promptAction.showToast({ message: '请点击底部菜单进行选购' });
            })
        }.layoutWeight(1).justifyContent(FlexAlign.Center)
      } else {
        List({ space: 10 }) {
          // ✅ 修复：在 ForEach 中直接调用 @Builder
          ForEach(this.cartList, (item: ShopCartItem) => {
            this.renderCartItem(item)
          }, (item: ShopCartItem, index: number) => {
            // 确保 Key 是字符串
            return item.sid ? `${item.sid}` : `cart_item_${index}`;
          })
        }.layoutWeight(1).padding(10).width('100%')

        Row() {
          Text(`应付合计: ¥${this.totalPrice}`).fontSize(16).fontWeight(FontWeight.Bold).fontColor('#333')
          Button('去结算', { type: ButtonType.Normal })
            .width(100).height(40).backgroundColor('#0035AA').borderRadius(20)
            .onClick(() => {
              promptAction.showToast({ message: '结算功能待开发' });
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

// --- 组件：我的页面 ---
@Component
struct MineView {
  @StorageLink('token') token: string = '';
  @StorageLink('userInfo') userInfoStr: string = '{}';

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
        Column().width('100%').height(200).backgroundColor('#333')

        Row() {
          Stack({ alignContent: Alignment.Center }) {
            Image(this.token && this.user?.userImg ? this.user.userImg : $r('app.media.home'))
              .width(60).height(60).borderRadius(30).backgroundColor(Color.White)
              .objectFit(ImageFit.Cover)
              .alt($r('app.media.home'))
          }.margin({ right: 15 })

          Column() {
            Text(this.token ? (this.user?.nickName ?? '用户') : '点击登录')
              .fontSize(18).fontWeight(FontWeight.Bold).fontColor(Color.White).margin({ bottom: 5 })
              .onClick(() => {
                if (!this.token) router.pushUrl({ url: 'pages/LoginPage' });
              })

            Text(this.token ? (this.user?.desc ?? '欢迎回来') : '登录享受更多权益')
              .fontSize(12).fontColor('#EEE')
          }
          .alignItems(HorizontalAlign.Start)
        }
        .width('100%').padding({ left: 20, bottom: 30 })
      }
      .width('100%').height(200)

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
      if (res.code === 200 && res.data) {
        // ✅ 修复点：移除 as unknown，显式指定 map 的返回类型为 Product
        this.searchResults = res.data.map((item: ProductItem): Product => {
          return {
            id: parseInt(item.pid),        // 将 string 转 number
            name: item.name,
            enName: item.enname,
            price: parseFloat(item.price), // 将 string 转 number
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
@Component
struct ProductGrid {
  @Prop products: Product[] = [];

  build() {
    Grid() {
      ForEach(this.products, (item: Product) => {
        GridItem() {
          Column() {
            Stack({ alignContent: Alignment.TopStart }) {
              Column() { Text('☕').fontSize(40) }.width('100%').height(150).backgroundColor('#EEEEEE').justifyContent(FlexAlign.Center).borderRadius({ topLeft: 8, topRight: 8 })
              if (item.isHot) {
                Text('热卖').fontSize(10).fontColor(Color.White).backgroundColor('#FF4400').padding({ left: 6, right: 6, top: 2, bottom: 2 }).borderRadius({ topLeft: 8, bottomRight: 8 })
              }
            }
            Column() {
              Text(item.name).fontSize(16).fontWeight(FontWeight.Bold).fontColor('#333').maxLines(1).textOverflow({ overflow: TextOverflow.Ellipsis }).width('100%')
              Text(item.enName).fontSize(12).fontColor('#999').maxLines(1).textOverflow({ overflow: TextOverflow.Ellipsis }).width('100%').margin({ top: 2, bottom: 10 })
              Row() {
                Text(`¥${item.price.toFixed(2)}`).fontSize(16).fontColor('#D22028').fontWeight(FontWeight.Bold)
                Text('⊕').fontSize(24).fontColor('#0035AA')
                  .onClick(() => {
                    router.pushUrl({
                      url: 'pages/ProductDetailPage',
                      params: { pid: item.id.toString() }
                    })
                  })
              }
              .width('100%').justifyContent(FlexAlign.SpaceBetween)
            }
            .padding(10).backgroundColor(Color.White)
          }
          .borderRadius(8).backgroundColor(Color.White).shadow({ radius: 4, color: '#1A000000', offsetX: 0, offsetY: 2 })
        }
      }, (item: Product) => `${item.id}`)
    }
    .columnsTemplate('1fr 1fr').columnsGap(10).rowsGap(10).padding(10).width('100%').height('100%')
  }
}