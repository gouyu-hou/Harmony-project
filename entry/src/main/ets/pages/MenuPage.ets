import http from '@ohos.net.http';

// --- 1. 数据接口定义 ---
interface MenuItem {
  id: number;
  name: string;
  price: string;
  image?: string;
  description?: string;
  isHot?: boolean; // 标记是否为热卖
}

interface MenuCategory {
  title: string;
  goods: MenuItem[];
}

interface ApiResponse {
  code: number;
  msg: string;
  data: MenuCategory[];
}

// --- 2. 本地保底数据 (当接口挂了或没网时显示这个) ---
const LOCAL_MOCK_DATA: MenuCategory[] = [
  {
    title: '热卖推荐',
    goods: [
      { id: 1, name: '焦糖拿铁', price: '28.00', description: 'Caramel Latte | 焦糖风味，甜蜜暖心', isHot: true },
      { id: 2, name: '榛果拿铁', price: '28.00', description: 'Hazelnut Latte | 榛果浓香，回味无穷', isHot: true },
      { id: 3, name: '奥瑞白', price: '28.00', description: 'Flat White | 奶泡细腻，咖香浓郁', isHot: true },
      { id: 4, name: '黑糖波波拿铁', price: '28.00', description: 'Brown Sugar Bubble Latte | Q弹波波', isHot: true },
      { id: 5, name: '满杯百香果', price: '25.00', description: 'Passion Fruit | 酸甜百香果，维C满满', isHot: true },
      { id: 6, name: '椰子冰', price: '28.00', description: 'Coconut Ice | 清爽椰香，冰凉一夏', isHot: true }
    ]
  },
  {
    title: '拿铁',
    goods: [
      { id: 1, name: '焦糖拿铁', price: '28.00', description: 'Caramel Latte', isHot: true },
      { id: 2, name: '榛果拿铁', price: '28.00', description: 'Hazelnut Latte', isHot: true },
      { id: 4, name: '黑糖波波拿铁', price: '28.00', description: 'Brown Sugar Bubble Latte', isHot: true },
      { id: 10, name: '生椰拿铁', price: '29.00', description: 'Coconut Latte | 人气爆款', isHot: true },
      { id: 11, name: '厚乳拿铁', price: '28.00', description: 'Rich Milk Latte', isHot: false }
    ]
  },
  {
    title: '咖啡',
    goods: [
      { id: 3, name: '奥瑞白', price: '28.00', description: 'Flat White', isHot: true },
      { id: 12, name: '标准美式', price: '22.00', description: 'Americano | 经典黑咖', isHot: false },
      { id: 13, name: '卡布奇诺', price: '24.00', description: 'Cappuccino', isHot: false },
      { id: 14, name: '摩卡', price: '27.00', description: 'Mocha', isHot: false }
    ]
  },
  {
    title: '瑞纳冰',
    goods: [
      { id: 6, name: '椰子冰', price: '28.00', description: 'Coconut Ice', isHot: true },
      { id: 15, name: '巧克力瑞纳冰', price: '27.00', description: 'Chocolate Ice', isHot: false },
      { id: 16, name: '抹茶瑞纳冰', price: '27.00', description: 'Matcha Ice', isHot: false }
    ]
  },
  {
    title: '水果茶',
    goods: [
      { id: 5, name: '满杯百香果', price: '25.00', description: 'Passion Fruit', isHot: true },
      { id: 17, name: '桃桃冰', price: '26.00', description: 'Peach Ice', isHot: false }
    ]
  }
];
@Component
export struct MenuPage {
  onSearchClick: () => void = () => {};

  @State categoryList: MenuCategory[] = [];
  @State selectedIndex: number = 0;
  @State isLoading: boolean = true;

  aboutToAppear() {
    this.fetchMenuData();
  }

  async fetchMenuData() {
    let httpRequest = http.createHttp();

    try {
      console.info('正在请求菜单接口...');
      let response = await httpRequest.request(
        'https://apis.netstart.cn/coffee/menu',
        {
          method: http.RequestMethod.GET,
          expectDataType: http.HttpDataType.OBJECT,
          readTimeout: 5000, // 5秒超时
          connectTimeout: 5000
        }
      );

      if (response.responseCode === 200) {
        const res = response.result as ApiResponse;
        if (res.code === 200 && res.data && res.data.length > 0) {
          console.info('网络数据请求成功');
          this.categoryList = res.data;
          this.isLoading = false;
        } else {
          throw new Error('接口数据为空');
        }
      } else {
        throw new Error('HTTP状态码错误');
      }

    } catch (err) {
      console.error('网络请求失败，加载本地保底数据: ' + JSON.stringify(err));
      // 【关键逻辑】：网络失败时，使用本地数据
      this.categoryList = LOCAL_MOCK_DATA;
      this.isLoading = false;
    } finally {
      httpRequest.destroy();
    }
  }

  build() {
    Column() {
      // 1. 顶部搜索框
      Row() {
        Text('🔍').fontSize(14).fontColor('#999').margin({ left: 10, right: 5 })
        Text('请输入搜索关键词').fontSize(14).fontColor('#CCC')
      }
      .width('92%')
      .height(35)
      .backgroundColor('#F5F5F5')
      .borderRadius(18)
      .margin({ top: 10, bottom: 10 })
      .padding({ left: 10 })
      .onClick(() => {
        this.onSearchClick();
      })

      // 2. 内容区域
      if (this.isLoading) {
        Column() {
          LoadingProgress().width(40).height(40).color('#0035AA')
          Text('正在加载菜单...').fontSize(14).fontColor('#999').margin({ top: 10 })
        }
        .width('100%').layoutWeight(1).justifyContent(FlexAlign.Center)
      } else {
        Row() {
          // 2.1 左侧分类列表
          List() {
            ForEach(this.categoryList, (item: MenuCategory, index: number) => {
              ListItem() {
                Row() {
                  if (this.selectedIndex === index) {
                    Divider().vertical(true).strokeWidth(4).color('#0035AA').height(20).borderRadius(2)
                  }
                  Text(item.title)
                    .fontSize(14)
                    .fontColor(this.selectedIndex === index ? '#333' : '#666')
                    .fontWeight(this.selectedIndex === index ? FontWeight.Bold : FontWeight.Normal)
                    .layoutWeight(1)
                    .textAlign(TextAlign.Center)
                }
                .width('100%')
                .height(50)
                .backgroundColor(this.selectedIndex === index ? Color.White : '#F9F9F9')
                .onClick(() => {
                  this.selectedIndex = index;
                })
              }
            })
          }
          .width('25%')
          .height('100%')
          .backgroundColor('#F9F9F9')

          // 2.2 右侧商品列表
          Column() {
            if (this.categoryList.length > 0) {
              Text(this.categoryList[this.selectedIndex].title)
                .fontSize(12)
                .fontColor('#333')
                .width('100%')
                .padding({ left: 10, top: 10, bottom: 10 })
                .backgroundColor(Color.White)
            }

            List() {
              if (this.categoryList.length > 0) {
                ForEach(this.categoryList[this.selectedIndex].goods, (goods: MenuItem) => {
                  ListItem() {
                    this.GoodsItemBuilder(goods)
                  }
                })
              }
            }
            .layoutWeight(1)
            .width('100%')
          }
          .width('75%')
          .height('100%')
          .backgroundColor(Color.White)
        }
        .layoutWeight(1)
        .width('100%')
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Color.White)
  }

  @Builder GoodsItemBuilder(item: MenuItem) {
    Row() {
      // 图片占位
      Stack({ alignContent: Alignment.TopStart }) {
        Column() {
          Text('☕').fontSize(30)
        }
        .width(80).height(80)
        .backgroundColor('#EEE')
        .justifyContent(FlexAlign.Center)
        .borderRadius(4)
      }
      .margin({ right: 10 })

      // 商品信息
      Column() {
        Text(item.name)
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333')
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })

        Text(item.description || '暂无描述')
          .fontSize(12)
          .fontColor('#999')
          .margin({ top: 2, bottom: 15 })
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })

        Row() {
          Text(`¥${item.price}`)
            .fontSize(16)
            .fontColor('#D22028')
            .fontWeight(FontWeight.Bold)

          Text('⊕')
            .fontSize(24)
            .fontColor('#0035AA')
            .onClick(() => {
              console.info(`加购: ${item.name}`);
            })
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween)
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
    }
    .padding(10)
    .width('100%')
  }
}