import router from '@ohos.router';
import promptAction from '@ohos.promptAction';
import CoffeeApi, { ProductDetail, ApiResponse } from '../api/CoffeeApi';

@Entry
@Component
struct ProductDetailPage {
  @State pid: string = '';
  @State product: ProductDetail | null = null;
  @State isLoading: boolean = true;

  // 规格选择状态
  @State currentTemp: string = '';
  @State currentSugar: string = '';
  @State currentCream: string = '';
  @State buyCount: number = 1;

  // 收藏状态
  @State isLiked: boolean = false;

  // 用户Token
  @StorageLink('token') token: string = '';

  aboutToAppear() {
    const params = router.getParams() as Record<string, string>;
    if (params && params.pid) {
      this.pid = params.pid;
      this.loadData();
    } else {
      promptAction.showToast({ message: '参数错误' });
      router.back();
    }
  }

  async loadData() {
    this.isLoading = true;
    try {
      const detailPromise = CoffeeApi.getProductDetail(this.pid);

      if (this.token) {
        this.checkLikeStatus();
      }

      const res = await detailPromise;
      // ✅ 修复点：添加 [0] 取出数组中的第一个商品详情
      if (res.code === 200 && res.data) {
        // 如果编译器认为它是数组，我们就取第一个；如果是对象，TS可能会在这里报错，所以建议使用 any 或断言临时过渡，或者直接取值
        // 根据你的报错，res.data 确实是数组，所以直接用 res.data[0]
        this.product = Array.isArray(res.data) ? res.data[0] : res.data;
        this.initSpecs();
      }
    } catch (err) {
      console.error('详情加载失败', err);
      promptAction.showToast({ message: '商品加载失败' });
    } finally {
      this.isLoading = false;
    }
  }

  async checkLikeStatus() {
    if (!this.token) return;
    try {
      const res = await CoffeeApi.findLike(this.token, this.pid);
      // ✅ 修复点：根据 API 返回判断，如果有数据则视为已收藏
      if (res.code === 200 && res.data && Array.isArray(res.data) && res.data.length > 0) {
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
  }

  getRuleString(): string {
    const rules: string[] = [];
    if (this.currentTemp) rules.push(this.currentTemp);
    if (this.currentSugar) rules.push(this.currentSugar);
    if (this.currentCream) rules.push(this.currentCream);
    return rules.join('/');
  }

  async toggleLike() {
    if (!this.checkLogin()) return;

    try {
      if (this.isLiked) {
        const res = await CoffeeApi.notLike(this.token, this.pid);
        if (res.code === 200 || res.code === 'B001' || res.msg === 'Success') {
          this.isLiked = false;
          promptAction.showToast({ message: '已取消收藏' });
        }
      } else {
        const res = await CoffeeApi.like(this.token, this.pid);
        if (res.code === 200 || res.code === 'B001' || res.msg === 'Success') {
          this.isLiked = true;
          promptAction.showToast({ message: '收藏成功' });
        }
      }
    } catch (err) {
      promptAction.showToast({ message: '操作失败' });
    }
  }

  async handleAddToCart() {
    if (!this.checkLogin()) return;

    const rule = this.getRuleString();
    try {
      const res = await CoffeeApi.addShopcart(this.token, this.pid, this.buyCount, rule);
      if (res.code === 200 || res.code === 'B001' || res.msg === 'Success') {
        promptAction.showToast({ message: '已加入购物袋 🛍️' });
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
                  Text(`¥${this.product.price}`).fontSize(24).fontWeight(FontWeight.Bold).fontColor('#D22028')
                }
                .width('100%').margin({ top: 15, bottom: 15 })

                Divider().color('#EEE')

                // 规格选择区
                if (this.product.tem) {
                  this.SpecSection('温度', this.product.tem.split('/'), this.currentTemp, (val: string) => this.currentTemp = val)
                }
                if (this.product.sugar) {
                  this.SpecSection('糖度', this.product.sugar.split('/'), this.currentSugar, (val: string) => this.currentSugar = val)
                }
                if (this.product.cream) {
                  this.SpecSection('其他', this.product.cream.split('/'), this.currentCream, (val: string) => this.currentCream = val)
                }

                Divider().color('#EEE').margin({ top: 10, bottom: 10 })

                // 数量选择
                Row() {
                  Text('选择数量').fontSize(14).fontColor('#333')
                  Blank()
                  Row() {
                    Text('－').fontSize(20).padding(10).onClick(() => { if (this.buyCount > 1) this.buyCount-- })
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

          // 3. 底部操作栏
          Row() {
            Column() {
              Text(this.isLiked ? '♥' : '♡')
                .fontSize(24).fontColor(this.isLiked ? '#D22028' : '#333')
              Text('收藏').fontSize(10).fontColor('#666')
            }
            .padding({ left: 20, right: 20 })
            .onClick(() => this.toggleLike())

            Button('加入购物袋', { type: ButtonType.Normal })
              .layoutWeight(1)
              .height(44)
              .backgroundColor('#0035AA')
              .borderRadius(22)
              .fontSize(16)
              .margin({ left: 10, right: 15 })
              .onClick(() => this.handleAddToCart())
          }
          .width('100%').height(60).backgroundColor(Color.White)
          .shadow({ radius: 10, color: '#1A000000', offsetY: -2 })
        }
        .width('100%').height('100%')
      }
    }
    .width('100%').height('100%').backgroundColor('#F9F9F9')
  }

  @Builder SpecSection(title: string, options: string[], current: string, onSelect: (val: string) => void) {
    Column() {
      Text(title).fontSize(14).fontColor('#333').margin({ top: 10, bottom: 8 })
      Flex({ wrap: FlexWrap.Wrap }) {
        ForEach(options, (opt: string) => {
          Text(opt)
            .fontSize(12)
            .fontColor(current === opt ? Color.White : '#666')
            .backgroundColor(current === opt ? '#0035AA' : '#F0F0F0')
            .padding({ left: 15, right: 15, top: 6, bottom: 6 })
            .borderRadius(15)
            .margin({ right: 10, bottom: 10 })
            .onClick(() => onSelect(opt))
        }, (item: string) => item)
      }
    }.alignItems(HorizontalAlign.Start).width('100%')
  }
}