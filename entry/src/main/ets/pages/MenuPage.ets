import CoffeeApi, { CategoryItem, ProductItem } from '../api/CoffeeApi';
import router from '@ohos.router';
import promptAction from '@ohos.promptAction';

@Component
export struct MenuPage {
  onSearchClick: () => void = () => {};

  @State categories: CategoryItem[] = [];
  @State products: ProductItem[] = [];
  @State selectedIndex: number = 0;
  @State isLoading: boolean = false;

  @StorageLink('token') token: string = '';
  @StorageLink('refreshCart') refreshCart: boolean = false;

  aboutToAppear() {
    this.initMenuData();
  }

  async initMenuData() {
    this.isLoading = true;
    try {
      const res = await CoffeeApi.getTypes();
      if ((res.code === 200 || res.code === '200') && res.data && res.data.length > 0) {
        this.categories = res.data;
        await this.loadProducts(this.categories[0].type);
      }
    } catch (err) {
      console.error('分类加载失败, 请检查网络或API');
    } finally {
      this.isLoading = false;
    }
  }

  async loadProducts(type: string) {
    this.products = [];
    try {
      const res = await CoffeeApi.getProductsByType(type);
      if ((res.code === 200 || res.code === '200') && res.data) {
        this.products = res.data;
      }
    } catch (err) {
      console.error(`商品加载失败: ${type}`);
    }
  }

  async addToCart(item: ProductItem) {
    if (!this.token) {
      promptAction.showToast({ message: '请先登录' });
      router.pushUrl({ url: 'pages/LoginPage' });
      return;
    }

    try {
      const res = await CoffeeApi.addShopcart(this.token, item.pid, 1, '默认');
      if (res.code === 200 || res.code === '200') {
        promptAction.showToast({ message: '已加入购物车' });
        this.refreshCart = true;
      } else {
        promptAction.showToast({ message: res.msg || '加入失败' });
      }
    } catch (err) {
      promptAction.showToast({ message: '网络请求异常' });
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
        // 左侧分类 (保持不变)
        List() {
          ForEach(this.categories, (item: CategoryItem, index: number) => {
            ListItem() {
              Row() {
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
                  this.loadProducts(item.type);
                }
              })
            }
          }, (item: CategoryItem) => item.type)
        }
        .width('25%').height('100%').backgroundColor('#F9F9F9')

        // 右侧商品 (UI变更区域)
        Stack() {
          if (this.isLoading && this.products.length === 0) {
            LoadingProgress().width(40).height(40).color('#0035AA')
          } else {
            // ✅ 修改点 1: 将 List 替换为 Grid
            Grid() {
              ForEach(this.products, (item: ProductItem) => {
                GridItem() {
                  this.GoodsItemBuilder(item)
                }
              }, (item: ProductItem) => item.pid)
            }
            .columnsTemplate('1fr 1fr') // ✅ 关键：设置两列，比例 1:1
            .rowsGap(10)     // 行间距
            .columnsGap(10)  // 列间距
            .padding(10)     // 整体内边距
            .layoutWeight(1)
            .width('100%')
            .height('100%')
            .scrollBar(BarState.Off)
          }
        }
        // 背景设为浅灰，让白色卡片更明显
        .width('75%').height('100%').backgroundColor('#F5F5F5')
      }
      .layoutWeight(1).width('100%')
    }
    .width('100%').height('100%').backgroundColor(Color.White)
  }

  // ✅ 修改点 2: 重新设计卡片样式 (由 Row 改为 Column)
  @Builder GoodsItemBuilder(item: ProductItem) {
    Column() {
      // 图片区域
      Image(item.smallImg)
        .width('100%') // 占满卡片宽度
        .height(110)   // 设定固定高度
        .objectFit(ImageFit.Cover)
        .borderRadius({ topLeft: 8, topRight: 8 }) // 只有上面两个角是圆角
        .backgroundColor('#EEEEEE')

      // 内容区域
      Column() {
        Text(item.name)
          .fontSize(14)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333')
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .margin({ top: 5 })

        Text(item.enname)
          .fontSize(10)
          .fontColor('#999')
          .margin({ top: 2, bottom: 8 })
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })

        // 价格和加购按钮
        Row() {
          Text(`¥${item.price}`)
            .fontSize(16).fontColor('#D22028').fontWeight(FontWeight.Bold)

          Text('⊕')
            .fontSize(24).fontColor('#0035AA')
            .onClick((event: ClickEvent) => {
              this.addToCart(item);
            })
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween) // 两端对齐
        .alignItems(VerticalAlign.Center)
      }
      .padding(8)
      .width('100%')
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
    .backgroundColor(Color.White)
    .borderRadius(8)
    .shadow({ radius: 4, color: '#1A000000', offsetY: 2 }) // 增加一点阴影让它像卡片
    .onClick(() => {
      router.pushUrl({
        url: 'pages/ProductDetailPage',
        params: { pid: item.pid }
      });
    })
  }
}