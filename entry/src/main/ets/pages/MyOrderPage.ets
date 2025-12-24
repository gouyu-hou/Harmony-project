import router from '@ohos.router';
import CoffeeApi, { OrderItem, OrderProduct,ApiResponse, ShopCartItem } from '../api/CoffeeApi';
import promptAction from '@ohos.promptAction';

@Entry
@Component
struct MyOrderPage {
  @StorageLink('token') token: string = '';
  // 0=全部, 1=进行中, 2=已完成
  @State currentStatus: number = 0;
  @State orderList: OrderItem[] = [];
  @State isLoading: boolean = false;

  // ✅ 必须定义这个，否则 handleDelete 里的 this.cartList 会报错
  @State cartList: ShopCartItem[] = [];
  @State totalPrice: number = 0;

  // ✅ 必须定义这个，否则 handleDelete 里的 this.calculateTotal() 会报错
  calculateTotal() {
    let total = 0;
    this.cartList.forEach((item) => {
      total += item.price * item.count;
    });
    this.totalPrice = total;
  }

  tabs: string[] = ['全部', '进行中', '已完成'];

  onPageShow() {
    this.fetchOrders();
  }

  async fetchOrders() {
    if (!this.token) return;
    this.isLoading = true;
    this.orderList = [];
    try {
      const res = await CoffeeApi.findOrder(this.token, this.currentStatus);
      if (res.code === 200 && res.result) {
        this.orderList = Array.isArray(res.result) ? res.result : [];
      }
    } catch (err) {
      console.error('获取订单失败');
    } finally {
      this.isLoading = false;
    }
  }

  async handleReceive(oid: string) {
    try {
      const res = await CoffeeApi.receiveOrder(this.token, oid);
      if (res.code === 200 || res.code === 'B001') {
        promptAction.showToast({ message: '确认收货成功' });
        this.fetchOrders();
      } else {
        promptAction.showToast({ message: res.msg || '操作失败' });
      }
    } catch (err) {
      promptAction.showToast({ message: '网络请求失败' });
    }
  }

  async handleDelete(sid: string) {
    try {
      const res: ApiResponse<null> = await CoffeeApi.deleteShopcart(this.token, [sid]);
      if (res.code === 6000 || res.code === 200 || res.code === '200') {

        // ✅ 核心修复：
        const newList = this.cartList.filter(item => item.sid !== sid);
        // 先置空再赋值，这是 ArkUI 强制刷新的“大招”
        this.cartList = [];
        this.cartList = newList;

        this.calculateTotal();
        promptAction.showToast({ message: '已删除' });
      } else {
        promptAction.showToast({ message: res.msg || '删除失败' });
      }
    } catch (err) {
      promptAction.showToast({ message: '删除异常' });
    }
  }

  build() {
    Column() {
      // 1. 顶部导航
      Stack({ alignContent: Alignment.Top }) {
        Column().width('100%').height(100).backgroundColor('#0035AA')
        Row() {
          Text('< 返回').fontSize(16).fontColor(Color.White).onClick(() => router.back())
          Text('我的订单').fontSize(18).fontWeight(FontWeight.Bold).fontColor(Color.White)
            .layoutWeight(1).textAlign(TextAlign.Center).margin({ right: 40 })
        }
        .width('100%').height(50).padding({ left: 15, right: 15 })
      }.height(60).width('100%')

      // 2. Tab 栏
      Column() {
        Row() {
          ForEach(this.tabs, (item: string, index: number) => {
            Column() {
              Text(item)
                .fontSize(14)
                .fontColor(this.currentStatus === index ? '#0035AA' : '#666')
                .fontWeight(this.currentStatus === index ? FontWeight.Bold : FontWeight.Normal)
                .margin({ bottom: 8 })
              if (this.currentStatus === index) {
                Divider().width(20).strokeWidth(3).color('#0035AA').borderRadius(2)
              } else {
                Divider().width(20).strokeWidth(3).color(Color.Transparent)
              }
            }
            .layoutWeight(1).height(40).justifyContent(FlexAlign.End)
            .onClick(() => {
              if (this.currentStatus !== index) {
                this.currentStatus = index;
                this.fetchOrders();
              }
            })
          })
        }.width('100%').border({ width: { bottom: 1 }, color: '#F5F5F5' })

        // 3. 订单列表
        if (this.isLoading) {
          Column() { LoadingProgress().width(40).height(40).color('#0035AA') }
          .layoutWeight(1).justifyContent(FlexAlign.Center)
        } else if (this.orderList.length === 0) {
          Column() {
            Text('📦').fontSize(50).margin({ bottom: 10 })
            Text('暂无订单').fontSize(14).fontColor('#999')
          }.layoutWeight(1).justifyContent(FlexAlign.Center)
        } else {
          List({ space: 15 }) {
            ForEach(this.orderList, (order: OrderItem) => {
              ListItem() {
                this.OrderCard(order)
              }
            }, (item: OrderItem) => item.oid)
          }
          .layoutWeight(1).width('100%').padding(15)
        }
      }
      .layoutWeight(1).width('100%').backgroundColor(Color.White)
      .borderRadius({ topLeft: 12, topRight: 12 }).margin({ top: -10 })
    }
    .width('100%').height('100%').backgroundColor('#F5F5F5')
  }

  @Builder OrderCard(order: OrderItem) {
    Column() {
      // 头部
      Row() {
        Text(order.oid).fontSize(12).fontColor('#999')
        Text(order.status === 2 ? '已完成' : '进行中')
          .fontSize(14).fontColor(order.status === 2 ? '#999' : '#D22028')
      }.width('100%').justifyContent(FlexAlign.SpaceBetween).margin({ bottom: 10 })

      Divider().color('#F5F5F5')

      // 商品列表
      Column({ space: 10 }) {
        ForEach(order.products, (prod: OrderProduct) => {
          Row() {
            Image(prod.smallImg).width(60).height(60).borderRadius(4).backgroundColor('#F5F5F5')
            Column() {
              Text(prod.name).fontSize(14).fontWeight(FontWeight.Bold).maxLines(1)
              Text(prod.rule).fontSize(12).fontColor('#999').margin({ top: 4 })
            }.layoutWeight(1).alignItems(HorizontalAlign.Start).margin({ left: 10 })
            Column() {
              Text(`¥${prod.price}`).fontSize(14).fontColor('#333')
              Text(`x${prod.count}`).fontSize(12).fontColor('#999').margin({ top: 4 })
            }.alignItems(HorizontalAlign.End)
          }.width('100%').padding({ top: 10, bottom: 10 })
        }, (p: OrderProduct, i: number) => `${p.pid}_${i}`)
      }

      Divider().color('#F5F5F5')

      // 底部
      Row() {
        Text(order.date).fontSize(12).fontColor('#CCC')
        Blank()
        Text(`总计 ¥${order.amount}`).fontSize(14).fontWeight(FontWeight.Bold).margin({ right: 10 })

        if (order.status === 1) {
          // ✅ 修复点：使用 Normal 类型并手动设置圆角
          Button('确认收货', { type: ButtonType.Normal })
            .borderRadius(14)
            .backgroundColor('#0035AA').fontSize(12).height(28)
            .onClick(() => this.handleReceive(order.oid))
        } else {
          // ✅ 修复点：使用 Normal 类型并手动设置圆角
          Button('删除订单', { type: ButtonType.Normal })
            .borderRadius(14)
            .backgroundColor(Color.White).fontColor('#999').fontSize(12).height(28)
            .border({ width: 1, color: '#EEE' })
            .onClick(() => {
              AlertDialog.show({
                title: '提示',
                message: '确认删除此订单？',
                primaryButton: { value: '取消', action: () => {} },
                secondaryButton: { value: '删除', fontColor: 'red', action: () => this.handleDelete(order.oid) }
              })
            })
        }
      }.width('100%').margin({ top: 10 }).alignItems(VerticalAlign.Center)
    }
    .width('100%').padding(15).backgroundColor(Color.White).borderRadius(8)
    .shadow({ radius: 5, color: '#0D000000', offsetY: 2 })
  }
}