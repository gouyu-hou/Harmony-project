import CoffeeApi, { CategoryItem, ProductItem } from '../api/CoffeeApi';
import router from '@ohos.router';
import promptAction from '@ohos.promptAction'; // ✅ 新增：引入弹窗工具

@Component
export struct MenuPage {
  onSearchClick: () => void = () => {};

  @State categories: CategoryItem[] = [];
  @State products: ProductItem[] = [];
  @State selectedIndex: number = 0;
  @State isLoading: boolean = false;

  // ✅ 新增：获取 Token 和 购物车刷新控制
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

  // ✅ 新增：加入购物车逻辑
  async addToCart(item: ProductItem) {
    // 1. 检查登录
    if (!this.token) {
      promptAction.showToast({ message: '请先登录' });
      router.pushUrl({ url: 'pages/LoginPage' });
      return;
    }

    try {
      // 2. 调用接口
      // 注意：列表页快速加购通常使用默认规格，这里传参 "默认"
      // 如果你的业务逻辑强制必须选规格，则这里应该弹窗，而不是直接调用 API
      const res = await CoffeeApi.addShopcart(this.token, item.pid, 1, '默认');

      if (res.code === 200 || res.code === '200') {
        promptAction.showToast({ message: '已加入购物车' });
        // 3. 触发全局刷新 (通知购物车页面更新)
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

        // 右侧商品
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
      Image(item.smallImg)
        .width(80).height(80)
        .borderRadius(4)
        .objectFit(ImageFit.Cover)
        .backgroundColor('#F5F5F5')
        .margin({ right: 10 })

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

          // ✅ 修改点：点击加号调用 addToCart
          Text('⊕')
            .fontSize(24).fontColor('#0035AA')
            .onClick((event: ClickEvent) => {
              // 阻止事件冒泡 (如果需要防止触发跳转详情页)
              // event.stopPropagation(); // ArkTS 中视版本支持情况，一般不用写，onClick默认捕获

              this.addToCart(item);
            })
        }
        .width('100%').justifyContent(FlexAlign.SpaceBetween)
      }
      .layoutWeight(1).alignItems(HorizontalAlign.Start)
    }
    .padding(10).width('100%')
    .onClick(() => {
      // 点击整行跳转详情页
      router.pushUrl({
        url: 'pages/ProductDetailPage',
        params: { pid: item.pid }
      });
    })
  }
}