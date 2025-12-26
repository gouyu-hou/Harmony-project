import router from '@ohos.router';
import promptAction from '@ohos.promptAction';
import CoffeeApi, { ProductDetail, ShopCartItem, ProductItem, ApiResponse } from '../api/CoffeeApi';

// 扩展接口以支持 API 返回的额外字段 (如 milk)
interface ProductDetailFull extends ProductDetail {
  milk?: string;
  milk_desc?: string;
}

@Entry
@Component
struct ProductDetailPage {
  @State pid: string = '';
  @State product: ProductDetailFull | null = null;
  @State isLoading: boolean = true;

  // 动态规格状态
  @State currentTemp: string = '';
  @State currentSugar: string = '';
  @State currentCream: string = '';
  @State currentMilk: string = '';
  @State buyCount: number = 1;

  // 收藏状态
  @State isLiked: boolean = false;
  // 购物车数量
  @State cartCount: number = 0;

  // 用户Token
  @StorageLink('token') token: string = '';

  aboutToAppear() {
    const params = router.getParams() as Record<string, string>;
    if (params && params['pid']) {
      this.pid = params.pid;
      this.loadData();
    } else {
      promptAction.showToast({ message: '参数错误' });
      router.back();
    }
  }

  onPageShow() {
    if (this.token) {
      this.updateCartCount();
    }
  }

  async loadData() {
    this.isLoading = true;
    try {
      const detailPromise = CoffeeApi.getProductDetail(this.pid);

      if (this.token) {
        this.checkLikeStatus();
        this.updateCartCount();
      }

      const res = await detailPromise;

      if ((res.code === 200 || res.code === '200') && res.data) {
        if (Array.isArray(res.data) && res.data.length > 0) {
          this.product = res.data[0] as ProductDetailFull;
          this.initSpecs();
        }
      }
    } catch (err) {
      console.error('详情加载失败', JSON.stringify(err));
      promptAction.showToast({ message: '商品加载失败' });
    } finally {
      this.isLoading = false;
    }
  }

  async updateCartCount() {
    if (!this.token) return;
    try {
      const res: ApiResponse<ShopCartItem[]> = await CoffeeApi.findAllShopcart(this.token);
      if ((res.code === 200 || res.code === '200') && res.data) {
        this.cartCount = res.data.length;
      }
    } catch (err) {
      console.error('购物车数量获取失败', JSON.stringify(err));
    }
  }

  async checkLikeStatus() {
    if (!this.token) return;
    try {
      const res: ApiResponse<ProductItem[]> = await CoffeeApi.findLike(this.token, this.pid);

      if ((res.code === 200 || res.code === '200') &&
      res.data &&
      Array.isArray(res.data) &&
        res.data.length > 0) {
        this.isLiked = true;
      } else {
        this.isLiked = false;
      }
    } catch (err) {
      this.isLiked = false;
    }
  }

  initSpecs() {
    if (!this.product) return;
    if (this.product.tem) this.currentTemp = this.product.tem.split('/')[0];
    if (this.product.sugar) this.currentSugar = this.product.sugar.split('/')[0];
    if (this.product.cream) this.currentCream = this.product.cream.split('/')[0];
    if (this.product.milk) this.currentMilk = this.product.milk.split('/')[0];
  }

  getRuleString(): string {
    const rules: string[] = [];
    if (this.currentTemp) rules.push(this.currentTemp);
    if (this.currentSugar) rules.push(this.currentSugar);
    if (this.currentCream) rules.push(this.currentCream);
    if (this.currentMilk) rules.push(this.currentMilk);
    return rules.join('/');
  }

  async toggleLike() {
    if (!this.checkLogin()) return;
    const previousState = this.isLiked;
    this.isLiked = !this.isLiked;

    try {
      if (this.isLiked) {
        await CoffeeApi.like(this.token, this.pid);
        promptAction.showToast({ message: '收藏成功' });
      } else {
        await CoffeeApi.notLike(this.token, this.pid);
        promptAction.showToast({ message: '已取消收藏' });
      }
    } catch (err) {
      this.isLiked = previousState;
      promptAction.showToast({ message: '网络请求失败' });
    }
  }

  async handleAddToCart() {
    if (!this.checkLogin()) return;

    const rule = this.getRuleString();

    try {
      const res = await CoffeeApi.addShopcart(this.token, this.pid, this.buyCount, rule);
      if (res.code === 200 || res.code === '200' || res.code === 'B001' || res.code === 3000 || res.msg === 'Success') {
        promptAction.showToast({ message: '已加入购物袋 🛍️' });
        this.updateCartCount();
      } else {
        promptAction.showToast({ message: res.msg || '添加失败' });
      }
    } catch (err) {
      promptAction.showToast({ message: '网络请求失败' });
    }
  }

  checkLogin(): boolean {
    if (!this.token) {
      promptAction.showToast({ message: '请先登录' });
      router.pushUrl({ url: 'pages/LoginPage' });
      return false;
    }
    return true;
  }

  build() {
    Column() {
      // 1. 顶部导航栏
      Row() {
        Text('<').fontSize(24).padding(15).onClick(() => router.back())
        Text('商品详情').fontSize(18).fontWeight(FontWeight.Bold)
        Blank()
        Text(' ').width(40)
      }
      .width('100%').height(50).backgroundColor(Color.White).zIndex(10)

      if (this.isLoading) {
        Column() {
          LoadingProgress().width(50).height(50).color('#0035AA')
          Text('加载美味中...').fontSize(14).fontColor('#999').margin({ top: 10 })
        }.layoutWeight(1).justifyContent(FlexAlign.Center)
      } else if (this.product) {
        Stack({ alignContent: Alignment.Bottom }) {
          // 2. 滚动内容区
          Scroll() {
            Column() {
              // 商品大图
              Image(this.product.large_img)
                .width('100%').height(300).objectFit(ImageFit.Cover).backgroundColor('#F5F5F5')

              Column() {
                // 标题和价格
                Row() {
                  Column() {
                    Text(this.product.name).fontSize(20).fontWeight(FontWeight.Bold).fontColor('#333')
                    Text(this.product.enname).fontSize(14).fontColor('#999').margin({ top: 4 })
                  }.alignItems(HorizontalAlign.Start)

                  Blank()
                  Text(`¥${Number(this.product.price).toFixed(2)}`).fontSize(24).fontWeight(FontWeight.Bold).fontColor('#D22028')
                }
                .width('100%').margin({ top: 15, bottom: 15 })

                Divider().color('#EEE')

                // 动态规格
                if (this.product.tem) {
                  SpecView({
                    title: this.product.tem_desc || '温度',
                    options: this.product.tem.split('/'),
                    selected: $currentTemp
                  })
                }

                if (this.product.sugar) {
                  SpecView({
                    title: this.product.sugar_desc || '糖度',
                    options: this.product.sugar.split('/'),
                    selected: $currentSugar
                  })
                }

                if (this.product.cream) {
                  SpecView({
                    title: this.product.cream_desc || '奶油',
                    options: this.product.cream.split('/'),
                    selected: $currentCream
                  })
                }

                if (this.product.milk) {
                  SpecView({
                    title: this.product.milk_desc || '奶',
                    options: this.product.milk.split('/'),
                    selected: $currentMilk
                  })
                }

                Divider().color('#EEE').margin({ top: 10, bottom: 10 })

                // 数量选择
                Row() {
                  Text('选择数量').fontSize(14).fontColor('#333')
                  Blank()
                  Row() {
                    Text('－').fontSize(15).padding(10).onClick(() => { if (this.buyCount > 1) this.buyCount-- })
                    Text(this.buyCount.toString()).fontSize(16).margin({ left: 10, right: 10 })
                    Text('＋').fontSize(20).padding(10).onClick(() => this.buyCount++)
                  }
                }.width('100%').height(50)

                // 商品描述
                Text('商品描述').fontSize(16).fontWeight(FontWeight.Bold).margin({ top: 20, bottom: 10 }).width('100%')
                Text(this.product.desc || '暂无描述').fontSize(14).fontColor('#666').lineHeight(24)

                Blank().height(80)
              }
              .padding(15)
              .backgroundColor(Color.White)
              .borderRadius({ topLeft: 20, topRight: 20 })
              .margin({ top: -20 })
            }
          }.width('100%').height('100%')

          // 3. 底部操作栏 (重点优化区域)
          Row() {
            // 左侧：购物袋 + 收藏
            Row() {
              // --- 1. 购物袋模块 ---
              Column() {
                // 图标层 (使用 Stack 固定高度，确保与旁边收藏对齐)
                Stack({ alignContent: Alignment.TopEnd }) {
                  Image($r('app.media.shopbag'))
                    .width(24)
                    .height(24)
                    .objectFit(ImageFit.Contain)

                  // 红色数量角标
                  if (this.cartCount > 0) {
                    Text(this.cartCount > 99 ? '99+' : this.cartCount.toString())
                      .fontSize(8)
                      .fontColor(Color.White)
                      .backgroundColor('#FF0000')
                      .borderRadius(8)
                      .padding({ left: 3, right: 3 })
                      .height(14)
                      .constraintSize({ minWidth: 14 })
                      .textAlign(TextAlign.Center)
                      .offset({ x: 5, y: -5 }) // 微调角标位置
                  }
                }
                .width(30)
                .height(30) // 固定高度 30
                .alignContent(Alignment.Center)

                // 文字层
                Text('购物袋')
                  .fontSize(10)
                  .fontColor('#666')
                  .margin({ top: 0 }) // 紧贴图标
              }
              .justifyContent(FlexAlign.Center)
              .alignItems(HorizontalAlign.Center)
              .width(50)
              .height('100%')
              .onClick(() => {
                // ✅ 修改：跳转到首页 (MainPage 通常包含购物袋Tab)
                // 跳转到主页，并传递 index: 2 以便切换到购物袋 Tab
                router.pushUrl({
                  url: 'pages/MainPage',
                  params: { index: 2 }
                });
              })

              // --- 2. 收藏模块 ---
              Column() {
                // 图标层 (同样固定高度 30)
                Stack({ alignContent: Alignment.Center }) {
                  Text(this.isLiked ? '♥' : '♡')
                    .fontSize(24)
                    .fontColor(this.isLiked ? '#D22028' : '#333')
                    .fontWeight(this.isLiked ? FontWeight.Bold : FontWeight.Normal)
                    .textAlign(TextAlign.Center)
                }
                .width(30)
                .height(30) // 确保与左边高度一致

                // 文字层
                Text('收藏')
                  .fontSize(10)
                  .fontColor('#666')
                  .margin({ top: 0 })
              }
              .justifyContent(FlexAlign.Center)
              .alignItems(HorizontalAlign.Center)
              .width(50)
              .height('100%')
              .onClick(() => this.toggleLike())
              .margin({ left: 10 })
            }
            .padding({ left: 15 })

            // 右侧：加购按钮
            Button('加入购物袋', { type: ButtonType.Normal })
              .layoutWeight(1)
              .height(42) // 按钮高度
              .backgroundColor('#0035AA')
              .borderRadius(21)
              .fontSize(16)
              .margin({ left: 15, right: 20 })
              .onClick(() => this.handleAddToCart())
          }
          .width('100%')
          .height(80) // ✅ 增加高度，防止被切
          .padding({ bottom: 15 }) // ✅ 底部内边距，抬高内容
          .backgroundColor(Color.White)
          .shadow({ radius: 10, color: '#1A000000', offsetY: -2 })
        }
        .width('100%').height('100%')
      }
    }
    .width('100%').height('100%').backgroundColor('#F9F9F9')
  }
}

// 规格选择子组件
@Component
struct SpecView {
  @Prop title: string;
  @Prop options: string[];
  @Link selected: string;

  build() {
    Column() {
      Text(this.title).fontSize(14).fontColor('#333').margin({ top: 10, bottom: 8 })
      Flex({ wrap: FlexWrap.Wrap }) {
        ForEach(this.options, (opt: string) => {
          Text(opt)
            .fontSize(12)
            .fontColor(this.selected === opt ? Color.White : '#666')
            .backgroundColor(this.selected === opt ? '#0035AA' : '#F0F0F0')
            .padding({ left: 15, right: 15, top: 6, bottom: 6 })
            .borderRadius(15)
            .margin({ right: 10, bottom: 10 })
            .onClick(() => {
              this.selected = opt;
            })
        }, (item: string) => item)
      }
    }.alignItems(HorizontalAlign.Start).width('100%')
  }
}