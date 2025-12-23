import router from '@ohos.router';
import { MenuPage } from './MenuPage';
import CoffeeApi, { BannerItem } from '../api/CoffeeApi';

// --- 数据模型定义 ---
// ⚠️ 注意：为了避免类型冲突，建议统一使用 API 中的 ProductItem
// 这里为了兼容你现在的代码，保留了本地 Product 定义
interface Product {
  id: number;
  name: string;
  enName: string;
  price: number;
  isHot?: boolean;
  category: string;
  // 兼容字段：后续对接 API 时图片字段通常是 smallImg
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

  // 初始化 Banner 数据
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
          Text('User').fontSize(16).fontWeight(FontWeight.Bold).fontColor('#0035AA')
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
              }, (item: BannerItem) => item.pid)
            }
            .width('100%').height(200).autoPlay(true).indicator(true)
          } else {
            // 占位图
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

// --- 组件：购物袋 ---
@Component
struct BagPage {
  build() {
    Column() {
      Row() {
        Text('< 返回').fontSize(16).fontColor('#0035AA')
        Text('购物袋').fontSize(18).fontWeight(FontWeight.Bold).layoutWeight(1).textAlign(TextAlign.Center).padding({right: 40})
      }
      .width('100%').height(50).padding({ left: 15, right: 15 })
      .backgroundColor(Color.White)

      Column() {
        Text('luckin coffee 的新鲜').fontColor(Color.White).fontSize(14)
        Text('喝下第一口，你就懂了').fontColor(Color.White).fontSize(12).margin({top:5})
      }
      .width('100%').height(80).backgroundColor('#A89A8E').justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Start).padding({left: 20})

      Column() {
        Text('✖').fontSize(60).fontColor('#DDD').margin({ bottom: 20 })
        Text('请先登录').fontSize(14).fontColor('#999').margin({ bottom: 30 })

        Button('去登录', { type: ButtonType.Normal })
          .width(120).height(40)
          .backgroundColor('#0035AA')
          .borderRadius(20)
          .fontSize(14)
          .onClick(() => {
            router.pushUrl({ url: 'pages/LoginPage' });
          })
      }
      .layoutWeight(1).width('100%').justifyContent(FlexAlign.Center)
    }
    .width('100%').height('100%').backgroundColor('#F5F5F5')
  }
}

// --- 组件：我的页面 ---
@Component
struct MineView {
  build() {
    Column() {
      Stack({ alignContent: Alignment.BottomStart }) {
        Column().width('100%').height(200).backgroundColor('#333')

        Row() {
          Stack({ alignContent: Alignment.Center }) {
            Circle().width(60).height(60).fill(Color.White)
            Text('头像').fontSize(12)
          }.margin({ right: 15 })

          Column() {
            Text('User').fontSize(18).fontWeight(FontWeight.Bold).fontColor(Color.White).margin({ bottom: 5 })
            Text('Welcome back').fontSize(12).fontColor('#EEE')
          }
          .alignItems(HorizontalAlign.Start)
        }
        .width('100%').padding({ left: 20, bottom: 30 })
      }
      .width('100%').height(200)

      Column() {
        this.MenuItem('个人资料', () => { router.pushUrl({ url: 'pages/UserInfoPage' }) })
        Divider().color('#F5F5F5')
        this.MenuItem('我的订单', () => { router.pushUrl({ url: 'pages/MyOrderPage' }) })
        Divider().color('#F5F5F5')
        this.MenuItem('我的收藏', () => { router.pushUrl({ url: 'pages/MyFavoritePage' }) })
        Divider().color('#F5F5F5')
        this.MenuItem('地址管理', () => { router.pushUrl({ url: 'pages/AddressListPage' }) })
        Divider().color('#F5F5F5')
        this.MenuItem('安全中心', () => { router.pushUrl({ url: 'pages/SecurityPage' }) })
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
            })
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

  performSearch(keyword: string) {
    if (!keyword || keyword.trim() === '') { this.searchResults = []; return; }
    this.searchResults = PRODUCT_DB.filter(product => product.name.includes(keyword) || product.enName.toLowerCase().includes(keyword.toLowerCase()));
    if (!this.searchHistory.includes(keyword)) { this.searchHistory.unshift(keyword); }
  }
}

// --- 组件：商品网格 (核心修复处) ---
@Component
struct ProductGrid {
  // ✅ 修复：必须给 @Prop 提供一个默认值
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
                    // 可以在这里跳转详情页，注意传递 pid/id
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
      }, (item: Product) => item.id.toString())
    }
    .columnsTemplate('1fr 1fr').columnsGap(10).rowsGap(10).padding(10).width('100%').height('100%')
  }
}