import router from '@ohos.router';
// ✅ 引入 ApiResponse，确保类型检查通过
import CoffeeApi, { ProductDetail, ApiResponse } from '../api/CoffeeApi';
import promptAction from '@ohos.promptAction';

interface ProductParams {
  pid: string;
}

@Entry
@Component
struct ProductDetailPage {
  @StorageLink('token') token: string = '';

  @State product: ProductDetail | null = null;
  @State isLoading: boolean = true;
  @State isFavorite: boolean = false;

  private pid: string = '';

  aboutToAppear() {
    const params = router.getParams() as ProductParams;

    if (params && params.pid) {
      this.pid = params.pid;
      this.fetchDetail();

      if (this.token) {
        this.checkFavoriteStatus();
      }
    } else {
      promptAction.showToast({ message: '参数错误' });
      this.isLoading = false;
    }
  }

  // 获取详情
  async fetchDetail() {
    try {
      const res = await CoffeeApi.getProductDetail(this.pid);
      if (res.code === 200 && res.data) {
        this.product = res.data;
      } else {
        promptAction.showToast({ message: res.msg || '获取详情失败' });
      }
    } catch (err) {
      console.error(`详情请求异常: ${JSON.stringify(err)}`);
    } finally {
      this.isLoading = false;
    }
  }

  // 检查收藏状态
  async checkFavoriteStatus() {
    try {
      const res = await CoffeeApi.findLike(this.token, this.pid);
      if (res.code === 200 && Array.isArray(res.data) && res.data.length > 0) {
        this.isFavorite = true;
      } else {
        this.isFavorite = false;
      }
    } catch (err) {
      console.error('检查收藏状态失败');
    }
  }

  // 切换收藏/取消收藏
  async toggleFavorite() {
    if (!this.token) {
      promptAction.showToast({ message: '请先登录' });
      return;
    }

    try {
      // ✅ 【修复点】显式定义 res 类型，防止报错
      let res: ApiResponse<string>;

      if (this.isFavorite) {
        res = await CoffeeApi.notLike(this.token, this.pid);
      } else {
        res = await CoffeeApi.like(this.token, this.pid);
      }

      if (res.code === 200 || res.code === 'B001' || res.msg === 'Success') {
        this.isFavorite = !this.isFavorite;
        promptAction.showToast({ message: this.isFavorite ? '收藏成功' : '已取消收藏' });
      } else {
        promptAction.showToast({ message: res.msg || '操作失败' });
      }
    } catch (err) {
      promptAction.showToast({ message: '网络请求失败' });
    }
  }

  // ✅ 【补回】加入购物车逻辑
  async addToCart() {
    if (!this.token) {
      promptAction.showToast({ message: '请先登录' });
      return;
    }

    try {
      // ✅ 显式定义 res 类型
      let res: ApiResponse<null> = await CoffeeApi.addShopcart(this.token, this.pid, 1, '默认');

      if (res.code === 200 || res.code === 'B001' || res.msg === 'Success') {
        promptAction.showToast({ message: '加入购物车成功' });
      } else {
        promptAction.showToast({ message: res.msg || '加入失败' });
      }
    } catch (err) {
      promptAction.showToast({ message: '网络请求异常' });
    }
  }

  build() {
    Column() {
      // 顶部导航栏
      Row() {
        Text('< 返回').fontSize(16).fontColor('#0035AA')
          .onClick(() => router.back())
        Text('商品详情').fontSize(18).fontWeight(FontWeight.Bold).layoutWeight(1).textAlign(TextAlign.Center)
        // 收藏图标
        Text(this.isFavorite ? '♥' : '♡')
          .fontSize(28).fontColor(this.isFavorite ? '#D22028' : '#333')
          .onClick(() => this.toggleFavorite()).margin({ left: 10 })
      }
      .width('100%').height(50).padding({ left: 15, right: 15 }).backgroundColor(Color.White)

      if (this.isLoading) {
        Column() { LoadingProgress().width(50).height(50).color('#0035AA') }
        .width('100%').layoutWeight(1).justifyContent(FlexAlign.Center)
      } else if (this.product) {
        // 详情内容
        Scroll() {
          Column() {
            Image(this.product.large_img).width('100%').height(300).objectFit(ImageFit.Cover).backgroundColor('#F5F5F5')
            Column() {
              Text(this.product.name).fontSize(24).fontWeight(FontWeight.Bold).fontColor('#333')
              Text(this.product.enname).fontSize(14).fontColor('#999').margin({ top: 5, bottom: 15 })
              Row() {
                Text(`¥${this.product.price}`).fontSize(24).fontColor('#D22028').fontWeight(FontWeight.Bold)
              }.width('100%').margin({ bottom: 20 })
              Text('商品描述').fontSize(16).fontWeight(FontWeight.Bold).margin({ bottom: 10 })
              Text(this.product.desc || '暂无描述').fontSize(14).fontColor('#666').lineHeight(24)
              if (this.product.tem) {
                Text('可选温度: ' + this.product.tem).fontSize(14).fontColor('#666').margin({ top: 10 })
              }
            }
            .padding(20).width('100%').alignItems(HorizontalAlign.Start)
          }
        }.layoutWeight(1)

        // 底部按钮栏
        Row() {
          Button('加入购物车')
            .backgroundColor('#0035AA')
            .width('80%').height(45).borderRadius(22.5)
            .onClick(() => {
              // ✅ 调用加入购物车
              this.addToCart();
            })
        }
        .width('100%').height(70).backgroundColor(Color.White)
        .justifyContent(FlexAlign.Center)
        .shadow({ radius: 10, color: '#1A000000', offsetY: -2 })
      } else {
        Text('未找到商品信息').margin({ top: 50 })
      }
    }
    .width('100%').height('100%').backgroundColor(Color.White)
  }
}