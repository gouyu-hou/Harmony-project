import router from '@ohos.router';
import CoffeeApi, { AddressItem } from '../api/CoffeeApi';
import promptAction from '@ohos.promptAction';

interface SettlementParams {
  sids: string[];
  totalPrice: number;
}

@Entry
@Component
struct SettlementPage {
  @StorageLink('token') token: string = '';
  @State sids: string[] = [];
  @State totalPrice: number = 0;
  @State currentAddress: AddressItem | null = null;

  aboutToAppear() {
    const params = router.getParams() as SettlementParams;
    if (params) {
      this.sids = params.sids || [];
      this.totalPrice = params.totalPrice || 0;
    }
    this.fetchDefaultAddress();
  }

  async fetchDefaultAddress() {
    try {
      const res = await CoffeeApi.findAddress(this.token);
      if (res.code === 200 && res.data) {
        const def = res.data.find(item => item.isDefault === 1);
        this.currentAddress = def || (res.data.length > 0 ? res.data[0] : null);
      }
    } catch (err) {
      console.error('获取地址失败');
    }
  }

  async handlePay() {
    if (!this.currentAddress) {
      promptAction.showToast({ message: '请先添加收货地址' });
      return;
    }
    if (this.sids.length === 0) return;

    try {
      const res = await CoffeeApi.pay(
        this.token,
        this.sids,
        this.currentAddress.tel,
        `${this.currentAddress.province}${this.currentAddress.city}${this.currentAddress.county}${this.currentAddress.addressDetail}`,
        this.currentAddress.name
      );

      if (res.code === 200 || res.code === 'B001') {
        promptAction.showToast({ message: '支付成功！☕' });
        router.replaceUrl({ url: 'pages/MyOrderPage' }); // 支付成功去订单页
      } else {
        promptAction.showToast({ message: res.msg || '支付失败' });
      }
    } catch (err) {
      promptAction.showToast({ message: '支付请求异常' });
    }
  }

  build() {
    Column() {
      // 导航栏
      Row() {
        Text('< 返回').fontSize(16).fontColor('#333').onClick(() => router.back())
        Text('确认订单').fontSize(18).fontWeight(FontWeight.Bold).layoutWeight(1).textAlign(TextAlign.Center).margin({ right: 40 })
      }
      .width('100%').height(50).padding({ left: 15, right: 15 }).backgroundColor(Color.White)

      Column() {
        // 地址
        Row() {
          if (this.currentAddress) {
            Column() {
              Text(`${this.currentAddress.province} ${this.currentAddress.city} ${this.currentAddress.county}`).fontSize(12).fontColor('#666')
              Text(this.currentAddress.addressDetail).fontSize(18).fontWeight(FontWeight.Bold).margin({ top: 4, bottom: 4 })
              Text(`${this.currentAddress.name} ${this.currentAddress.tel}`).fontSize(14).fontColor('#666')
            }.alignItems(HorizontalAlign.Start).layoutWeight(1)
          } else {
            Text('请选择收货地址').fontSize(16).fontWeight(FontWeight.Bold)
          }
          Text('>').fontSize(18).fontColor('#999')
        }
        .width('100%').padding(20).backgroundColor(Color.White).borderRadius(10)
        .onClick(() => { router.pushUrl({ url: 'pages/AddressListPage' }); })

        // 金额
        Column() {
          Row() {
            Text('商品总额').fontSize(16).fontColor('#333')
            Text(`¥${this.totalPrice}`).fontSize(16).fontWeight(FontWeight.Bold)
          }.width('100%').justifyContent(FlexAlign.SpaceBetween).padding(15)
          Divider()
          Row() {
            Text('实付款').fontSize(16).fontColor('#333')
            Text(`¥${this.totalPrice}`).fontSize(20).fontColor('#D22028').fontWeight(FontWeight.Bold)
          }.width('100%').justifyContent(FlexAlign.SpaceBetween).padding(15)
        }.backgroundColor(Color.White).borderRadius(10).margin({ top: 15 })

      }.padding(15).layoutWeight(1).backgroundColor('#F5F5F5')

      // 底部支付
      Row() {
        Text(`合计: ¥${this.totalPrice}`).fontSize(16).fontWeight(FontWeight.Bold).fontColor('#D22028')
        Button('立即支付', { type: ButtonType.Normal })
          .borderRadius(20)
          .width(120).height(40).backgroundColor('#0035AA')
          .onClick(() => this.handlePay())
      }
      .width('100%').height(60).backgroundColor(Color.White)
      .justifyContent(FlexAlign.SpaceBetween).padding({ left: 20, right: 20 })
      .shadow({ radius: 10, color: '#1A000000', offsetY: -2 })
    }
    .width('100%').height('100%').backgroundColor('#F5F5F5')
  }
}