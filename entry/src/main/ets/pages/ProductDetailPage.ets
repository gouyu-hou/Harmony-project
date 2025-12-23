import router from '@ohos.router';
import CoffeeApi, { ProductDetail } from '../api/CoffeeApi';
import promptAction from '@ohos.promptAction';

@Entry
@Component
struct ProductDetailPage {
  @State product: ProductDetail | null = null;
  @State isLoading: boolean = true;
  private pid: string = '';

  aboutToAppear() {
    // 1. 获取路由传递过来的参数
    const params = router.getParams() as Record<string, string>;
    if (params && params['pid']) {
      this.pid = params['pid'];
      this.fetchDetail();
    } else {
      promptAction.showToast({ message: '参数错误' });
      this.isLoading = false;
    }
  }

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

  build() {
    Column() {
      // 顶部导航栏
      Row() {
        Text('< 返回').fontSize(16).fontColor('#0035AA')
          .onClick(() => router.back())
        Text('商品详情').fontSize(18).fontWeight(FontWeight.Bold).layoutWeight(1).textAlign(TextAlign.Center).padding({ right: 40 })
      }
      .width('100%').height(50).padding({ left: 15, right: 15 }).backgroundColor(Color.White)

      if (this.isLoading) {
        // 加载中
        Column() {
          LoadingProgress().width(50).height(50).color('#0035AA')
        }.width('100%').layoutWeight(1).justifyContent(FlexAlign.Center)
      } else if (this.product) {
        // 详情内容
        Scroll() {
          Column() {
            // 大图
            Image(this.product.large_img)
              .width('100%')
              .height(300)
              .objectFit(ImageFit.Cover)
              .backgroundColor('#F5F5F5')

            Column() {
              // 标题与价格
              Text(this.product.name).fontSize(24).fontWeight(FontWeight.Bold).fontColor('#333')
              Text(this.product.enname).fontSize(14).fontColor('#999').margin({ top: 5, bottom: 15 })

              Row() {
                Text(`¥${this.product.price}`).fontSize(24).fontColor('#D22028').fontWeight(FontWeight.Bold)
              }.width('100%').margin({ bottom: 20 })

              // 描述
              Text('商品描述').fontSize(16).fontWeight(FontWeight.Bold).margin({ bottom: 10 })
              Text(this.product.desc || '暂无描述')
                .fontSize(14).fontColor('#666').lineHeight(24)

              // 规格展示 (如果有)
              if (this.product.tem) {
                Text('可选温度: ' + this.product.tem).fontSize(14).fontColor('#666').margin({ top: 10 })
              }
            }
            .padding(20)
            .width('100%')
            .alignItems(HorizontalAlign.Start)
          }
        }
        .layoutWeight(1)

        // 底部按钮栏
        Row() {
          Button('加入购物车')
            .backgroundColor('#0035AA')
            .width('80%')
            .height(45)
            .borderRadius(22.5)
            .onClick(() => {
              promptAction.showToast({ message: '加入购物车成功 (模拟)' });
            })
        }
        .width('100%').height(70).backgroundColor(Color.White)
        .justifyContent(FlexAlign.Center)
        .shadow({ radius: 10, color: '#1A000000', offsetY: -2 })
      } else {
        // 数据为空
        Text('未找到商品信息').margin({ top: 50 })
      }
    }
    .width('100%').height('100%').backgroundColor(Color.White)
  }
}