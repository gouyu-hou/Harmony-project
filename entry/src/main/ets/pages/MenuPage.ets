// entry/src/main/ets/pages/MenuPage.ets
import CoffeeApi, { CategoryItem, ProductItem } from '../api/CoffeeApi';
import router from '@ohos.router';
@Component
export struct MenuPage {
  onSearchClick: () => void = () => {};

  // 数据源
  @State categories: CategoryItem[] = []; // 左侧分类
  @State products: ProductItem[] = [];    // 右侧商品
  @State selectedIndex: number = 0;       // 当前选中的分类索引
  @State isLoading: boolean = false;      // 加载状态

  aboutToAppear() {
    this.initMenuData();
  }

  // 初始化：获取分类列表
  async initMenuData() {
    this.isLoading = true;
    try {
      const res = await CoffeeApi.getTypes();
      if (res.code === 200 && res.data && res.data.length > 0) {
        this.categories = res.data;
        // 默认加载第一个分类的商品
        await this.loadProducts(this.categories[0].type);
      }
    } catch (err) {
      console.error('分类加载失败, 请检查网络或API');
    } finally {
      this.isLoading = false;
    }
  }

  // 切换分类：加载对应商品
  async loadProducts(type: string) {
    // 切换时先让列表空一下，或者显示Loading，防止视觉混淆
    this.products = [];
    try {
      const res = await CoffeeApi.getProductsByType(type);
      if (res.code === 200 && res.data) {
        this.products = res.data;
      }
    } catch (err) {
      console.error(`商品加载失败: ${type}`);
    }
  }

  build() {
    Column() {
      // 1. 搜索框 (保持不变)
      Row() {
        Text('🔍').fontSize(14).fontColor('#999').margin({ left: 10, right: 5 })
        Text('请输入搜索关键词').fontSize(14).fontColor('#CCC')
      }
      .width('92%').height(35).backgroundColor('#F5F5F5').borderRadius(18)
      .margin({ top: 10, bottom: 10 }).padding({ left: 10 })
      .onClick(() => { this.onSearchClick(); })

      // 2. 主体内容
      Row() {
        // 2.1 左侧分类栏
        List() {
          ForEach(this.categories, (item: CategoryItem, index: number) => {
            ListItem() {
              Row() {
                // 选中时的左侧蓝条
                if (this.selectedIndex === index) {
                  Divider().vertical(true).strokeWidth(4).color('#0035AA').height(20).borderRadius(2)
                }
                Text(item.typeDesc)
                  .fontSize(14)
                  .fontColor(this.selectedIndex === index ? '#333' : '#666')
                  .fontWeight(this.selectedIndex === index ? FontWeight.Bold : FontWeight.Normal)
                  .layoutWeight(1)
                  .textAlign(TextAlign.Center)
              }
              .width('100%').height(50)
              .backgroundColor(this.selectedIndex === index ? Color.White : '#F9F9F9')
              .onClick(() => {
                if (this.selectedIndex !== index) {
                  this.selectedIndex = index;
                  this.loadProducts(item.type); // 点击切换数据
                }
              })
            }
          }, (item: CategoryItem) => item.type)
        }
        .width('25%').height('100%').backgroundColor('#F9F9F9')

        // 2.2 右侧商品栏
        Stack() {
          if (this.isLoading && this.products.length === 0) {
            LoadingProgress().width(40).height(40).color('#0035AA')
          } else {
            List() {
              ForEach(this.products, (item: ProductItem) => {
                ListItem() {
                  this.GoodsItemBuilder(item)
                }
              }, (item: ProductItem) => item.pid)
            }
            .layoutWeight(1).width('100%').height('100%')
          }
        }
        .width('75%').height('100%').backgroundColor(Color.White)
      }
      .layoutWeight(1).width('100%')
    }
    .width('100%').height('100%').backgroundColor(Color.White)
  }

  @Builder GoodsItemBuilder(item: ProductItem) {
    Row() {
      // 图片
      Image(item.smallImg)
        .width(80).height(80)
        .borderRadius(4)
        .objectFit(ImageFit.Cover)
        .backgroundColor('#F5F5F5') // 图片加载前的底色
        .margin({ right: 10 })

      // 信息
      Column() {
        Text(item.name)
          .fontSize(16).fontWeight(FontWeight.Bold).fontColor('#333')
          .maxLines(1).textOverflow({ overflow: TextOverflow.Ellipsis })

        Text(item.enname)
          .fontSize(12).fontColor('#999')
          .margin({ top: 2, bottom: 15 })
          .maxLines(1).textOverflow({ overflow: TextOverflow.Ellipsis })

        Row() {
          Text(`¥${item.price}`)
            .fontSize(16).fontColor('#D22028').fontWeight(FontWeight.Bold)

          Text('⊕')
            .fontSize(24).fontColor('#0035AA')
            .onClick(() => {
              // 这里预留加购逻辑
              console.info(`点击了加购: ${item.name}`);
            })
        }
        .width('100%').justifyContent(FlexAlign.SpaceBetween)
      }
      .layoutWeight(1).alignItems(HorizontalAlign.Start)
    }
    .padding(10).width('100%')
    .onClick(() => {
      router.pushUrl({
        url: 'pages/ProductDetailPage',
        params: {
          pid: item.pid // 传递 pid 参数
        }
      });
    })
  }
}