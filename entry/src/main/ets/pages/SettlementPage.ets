// entry/src/main/ets/pages/SettlementPage.ets
import router from '@ohos.router';
import CoffeeApi, { AddressItem, ShopCartItem } from '../api/CoffeeApi'; // 引入 ShopCartItem
import promptAction from '@ohos.promptAction';

interface SettlementParams {
  sids: string[];
  totalPrice?: number; // 变为可选，因为我们要重新计算
}

@Entry
@Component
struct SettlementPage {
  @StorageLink('token') token: string = '';
  @State sids: string[] = [];
  @State totalPrice: number = 0;
  @State currentAddress: AddressItem | null = null;

  // 【新增】用于存储从服务器拉取的待支付商品列表
  @State orderItems: ShopCartItem[] = [];

  aboutToAppear() {
    const params = router.getParams() as SettlementParams;
    if (params && params.sids) {
      this.sids = params.sids;
      // 拿到 sids 后，立即请求服务器获取准确的商品信息
      this.fetchOrderItems();
    }
    this.fetchDefaultAddress();
  }

  // 【新增】调用 commitShopcart 接口
  async fetchOrderItems() {
    if (this.sids.length === 0) return;

    try {
      // 这里的 sids 必须是数组，API内部会处理 JSON.stringify
      const res = await CoffeeApi.commitShopcart(this.token, this.sids);

      console.info('【Debug】结算页商品查询:', JSON.stringify(res));

      if (res.code === 200 || res.code === '200') {
        if (res.data && Array.isArray(res.data)) {
          this.orderItems = res.data;
          // 【核心】使用服务器返回的数据重新计算总价，确保金额准确
          this.calculateTotal();
        }
      }
    } catch (err) {
      console.error('【Debug】获取结算商品失败', JSON.stringify(err));
      promptAction.showToast({ message: '获取订单商品失败' });
    }
  }

  calculateTotal() {
    let total = 0;
    this.orderItems.forEach(item => {
      // 注意：接口可能返回 price 是字符串，安全起见转换一下
      const price = typeof item.price === 'string' ? parseFloat(item.price) : item.price;
      total += price * item.count;
    });
    this.totalPrice = total;
  }

  async fetchDefaultAddress() {
    try {
      const res = await CoffeeApi.findAddress(this.token);
      if (res.code === 200 && res.data) {
        // 优先找默认地址(isDefault === 1)，没有则取第一个
        const def = res.data.find(item => item.isDefault === 1);
        this.currentAddress = def || (res.data.length > 0 ? res.data[0] : null);
      }
    } catch (err) {
      console.error('获取地址失败');
    }
  }

  async handlePay() {
    if (!this.currentAddress) {
      promptAction.showToast({ message: '请先选择收货地址' });
      return;
    }
    if (this.sids.length === 0) {
      promptAction.showToast({ message: '订单异常，无商品' });
      return;
    }

    try {
      const res = await CoffeeApi.pay(
        this.token,
        this.sids,
        this.currentAddress.tel,
        `${this.currentAddress.province}${this.currentAddress.city}${this.currentAddress.county}${this.currentAddress.addressDetail}`,
        this.currentAddress.name
      );

      if (res.code === 200 || res.code === '200' || res.code === 'B001'|| res.code === 60000) {
        promptAction.showToast({ message: '支付成功！☕' });

        // ✅✅✅ 新增：设置全局标记，通知购物袋刷新
        AppStorage.SetOrCreate('refreshCart', true);

        // 支付成功后跳转
        // ✅✅✅ 关键修改 2：使用 router.back() 返回上一页（购物袋），而不是跳转去订单页
        // 这样你能立即看到购物袋变空的效果
        setTimeout(() => {
          router.back();
        }, 500);
      } else {
        promptAction.showToast({ message: res.msg || '支付失败' });
      }
    } catch (err) {
      promptAction.showToast({ message: '支付请求异常' });
    }
  }

  // 【新增】待支付商品列表项组件
  @Builder OrderItemView(item: ShopCartItem) {
    Row() {
      Image(item.small_img).width(60).height(60).borderRadius(4).backgroundColor('#F5F5F5').objectFit(ImageFit.Cover)
      Column() {
        Text(item.name).fontSize(14).fontWeight(FontWeight.Bold).maxLines(1).textOverflow({ overflow: TextOverflow.Ellipsis })
        Text(item.rule).fontSize(12).fontColor('#999').margin({ top: 4 })
        Row() {
          Text(`¥${item.price}`).fontSize(14).fontColor('#333').fontWeight(FontWeight.Bold)
          Text(`x${item.count}`).fontSize(12).fontColor('#999')
        }.width('100%').justifyContent(FlexAlign.SpaceBetween).margin({ top: 8 })
      }
      .layoutWeight(1).margin({ left: 10 }).alignItems(HorizontalAlign.Start)
    }
    .width('100%').padding({ top: 10, bottom: 10 })
  }

  build() {
    Column() {
      // 导航栏
      Row() {
        Text('< 返回').fontSize(16).fontColor('#333').onClick(() => router.back())
        Text('确认订单').fontSize(18).fontWeight(FontWeight.Bold).layoutWeight(1).textAlign(TextAlign.Center).margin({ right: 40 })
      }
      .width('100%').height(50).padding({ left: 15, right: 15 }).backgroundColor(Color.White)

      Scroll() {
        Column() {
          // 1. 地址模块
          Row() {
            if (this.currentAddress) {
              Column() {
                Row() {
                  Text(this.currentAddress.isDefault === 1 ? '默认' : '家')
                    .fontSize(10).fontColor(Color.White).backgroundColor('#0035AA')
                    .padding({ left: 4, right: 4, top: 1, bottom: 1 }).borderRadius(2).margin({ right: 5 })
                  Text(`${this.currentAddress.province} ${this.currentAddress.city} ${this.currentAddress.county}`)
                    .fontSize(12).fontColor('#666')
                }
                Text(this.currentAddress.addressDetail).fontSize(18).fontWeight(FontWeight.Bold).margin({ top: 6, bottom: 6 })
                Text(`${this.currentAddress.name} ${this.currentAddress.tel}`).fontSize(14).fontColor('#666')
              }.alignItems(HorizontalAlign.Start).layoutWeight(1)
            } else {
              Column() {
                Text('请选择收货地址').fontSize(16).fontWeight(FontWeight.Bold)
                Text('点击前往添加地址').fontSize(12).fontColor('#999').margin({ top: 5 })
              }.alignItems(HorizontalAlign.Start)
            }
            Text('>').fontSize(18).fontColor('#999')
          }
          .width('100%').padding(20).backgroundColor(Color.White).borderRadius(10)
          .onClick(() => { router.pushUrl({ url: 'pages/AddressListPage' }); })

          // 2. 【新增】商品清单模块
          Column() {
            Text('订单详情').fontSize(14).fontWeight(FontWeight.Bold).padding({ bottom: 5 })
            Divider().color('#F0F0F0')

            if (this.orderItems.length > 0) {
              ForEach(this.orderItems, (item: ShopCartItem) => {
                this.OrderItemView(item)
              })
            } else {
              // 加载中状态
              Row() {
                LoadingProgress().width(20).height(20).color('#999')
                Text('加载商品清单...').fontSize(12).fontColor('#999').margin({ left: 5 })
              }.width('100%').padding(20).justifyContent(FlexAlign.Center)
            }

            Divider().color('#F0F0F0')
            Row() {
              Text('商品总额').fontSize(14).fontColor('#666')
              Text(`¥${this.totalPrice.toFixed(2)}`).fontSize(14).fontWeight(FontWeight.Bold)
            }.width('100%').justifyContent(FlexAlign.SpaceBetween).padding({ top: 15 })
          }
          .width('100%').padding(15).backgroundColor(Color.White).borderRadius(10).margin({ top: 15 })

        }.padding(15)
      }
      .layoutWeight(1).backgroundColor('#F5F5F5')

      // 底部支付栏
      Row() {
        Column() {
          Text(`合计: ¥${this.totalPrice.toFixed(2)}`).fontSize(16).fontWeight(FontWeight.Bold).fontColor('#D22028')
          Text('已优惠 ¥0.00').fontSize(10).fontColor('#999')
        }.alignItems(HorizontalAlign.Start)

        Button('立即支付', { type: ButtonType.Normal })
          .borderRadius(20)
          .width(110).height(38).backgroundColor('#0035AA')
          .onClick(() => this.handlePay())
      }
      .width('100%').height(60).backgroundColor(Color.White)
      .justifyContent(FlexAlign.SpaceBetween).padding({ left: 20, right: 20 })
      .shadow({ radius: 10, color: '#1A000000', offsetY: -2 })
    }
    .width('100%').height('100%').backgroundColor('#F5F5F5')
  }
}