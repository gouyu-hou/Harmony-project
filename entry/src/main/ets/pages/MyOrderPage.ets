import router from '@ohos.router';
import CoffeeApi, { OrderItem, OrderProduct } from '../api/CoffeeApi';
import promptAction from '@ohos.promptAction';

// 1. 定义后端数据库原始结构
interface RawDbOrder {
  id: number;
  oid: string;
  pid: string;
  name: string;
  price: string;
  smallImg: string;
  count: number;
  rule: string;
  status: number;
  createdAt: string;
  updatedAt: string;
  address: string;
  phone: string;
  receiver: string;
  userId: string;
}

@Entry
@Component
struct MyOrderPage {
  @StorageLink('token') token: string = '';

  @State currentStatus: number = 0;
  @State orderList: OrderItem[] = [];
  @State isLoading: boolean = false;

  aboutToAppear() {
    this.fetchOrders(this.currentStatus);
  }

  // 2. 数据清洗函数 (保持不变)
  normalizeOrderData(flatList: RawDbOrder[]): OrderItem[] {
    const orderMap = new Map<string, OrderItem>();

    flatList.forEach((item) => {
      if (!orderMap.has(item.oid)) {
        orderMap.set(item.oid, {
          oid: item.oid,
          status: item.status,
          date: item.createdAt || item.updatedAt,
          amount: 0,
          address: item.address,
          phone: item.phone,
          receiver: item.receiver,
          products: [] as OrderProduct[]
        } as OrderItem);
      }

      const order = orderMap.get(item.oid);

      if (order) {
        const unitPrice = parseFloat(item.price);
        const itemTotalPrice = unitPrice * item.count;
        order.amount += itemTotalPrice;

        order.products.push({
          pid: item.pid,
          name: item.name,
          smallImg: item.smallImg,
          price: unitPrice,
          count: item.count,
          rule: item.rule
        });
      }
    });

    const result = Array.from(orderMap.values());
    result.forEach(order => {
      order.amount = parseFloat(order.amount.toFixed(2));
    });

    return result.sort((a, b) => {
      const timeA = new Date(a.date).getTime();
      const timeB = new Date(b.date).getTime();
      return timeB - timeA;
    });
  }

  // 3. ✅【暴力查找】提取订单数组
  // 不管包了几层，只要找到 result 是个数组，就把它挖出来
  findOrderArrayInObject(obj: Object): RawDbOrder[] | null {
    if (!obj) return null;

    // 强制转换为 KV 结构方便访问
    const root = obj as Record<string, Object>;

    // 策略 1: 直接看最外层有没有 result 且是数组 (对应标准 API)
    // 结构: { code: 70000, result: [...] }
    if (root['result'] && Array.isArray(root['result'])) {
      console.info('[MyOrderPage] 命中策略1: root.result 是数组');
      return root['result'] as RawDbOrder[];
    }

    // 策略 2: 看看 data 里面有没有 result (对应常见的 Wrapper 结构)
    // 结构: { code: 200, data: { code: 70000, result: [...] } }
    if (root['data']) {
      let dataObj = root['data'];
      // 如果 data 是字符串，尝试解开
      if (typeof dataObj === 'string') {
        try { dataObj = JSON.parse(dataObj); } catch (e) {}
      }

      const innerData = dataObj as Record<string, Object>;
      if (innerData && innerData['result'] && Array.isArray(innerData['result'])) {
        console.info('[MyOrderPage] 命中策略2: root.data.result 是数组');
        return innerData['result'] as RawDbOrder[];
      }

      // 策略 3: data 本身就是数组?
      if (Array.isArray(dataObj)) {
        console.info('[MyOrderPage] 命中策略3: root.data 本身是数组');
        return dataObj as RawDbOrder[];
      }
    }

    // 策略 4: 看看 result 字段里面有没有 result (对应某些嵌套结构)
    if (root['result']) {
      let resultObj = root['result'];
      if (typeof resultObj === 'string') {
        try { resultObj = JSON.parse(resultObj); } catch (e) {}
      }
      const innerResult = resultObj as Record<string, Object>;
      if (innerResult && innerResult['result'] && Array.isArray(innerResult['result'])) {
        console.info('[MyOrderPage] 命中策略4: root.result.result 是数组');
        return innerResult['result'] as RawDbOrder[];
      }
    }

    return null;
  }

  // 4. 获取订单
  async fetchOrders(status: number) {
    this.isLoading = true;
    this.orderList = [];

    try {
      // 1. 获取原始对象 (HttpUtil 已经 parse 过了)
      const rawRes = await CoffeeApi.findOrder(this.token, status);

      console.info('[MyOrderPage] API 响应类型: ' + typeof rawRes);

      // 🔍 调试必杀技：如果失败，可以在 Log 里看到真实数据结构
      // console.info('[MyOrderPage] 真实数据结构: ' + JSON.stringify(rawRes));

      // 2. 调用暴力查找函数
      const targetList = this.findOrderArrayInObject(rawRes as Object);

      if (targetList && targetList.length > 0) {
        console.info('[MyOrderPage] 成功提取到订单条数: ' + targetList.length);
        this.orderList = this.normalizeOrderData(targetList);
      } else if (targetList && targetList.length === 0) {
        console.info('[MyOrderPage] 提取到了数组，但是是空的');
        this.orderList = [];
      } else {
        console.warn('[MyOrderPage] 未能在响应中找到订单数组 (result)');
        // 如果还不行，打开上面的 JSON.stringify 看看到底藏在哪
        this.orderList = [];
      }

    } catch (err) {
      console.error('[MyOrderPage] Error:', JSON.stringify(err as Object));
      promptAction.showToast({ message: '获取订单失败' });
    } finally {
      this.isLoading = false;
    }
  }

  // ... handleReceive 和 handleDelete ...
  async handleReceive(oid: string) {
    try {
      const res = await CoffeeApi.receiveOrder(this.token, oid);
      // 简单宽容判断
      const str = JSON.stringify(res);
      if (str.includes('200') || str.includes('success')) {
        promptAction.showToast({ message: '确认收货成功' });
        this.fetchOrders(this.currentStatus);
      } else {
        promptAction.showToast({ message: '操作失败' });
      }
    } catch (err) {
      promptAction.showToast({ message: '网络异常' });
    }
  }

  async handleDelete(oid: string) {
    try {
      const res = await CoffeeApi.removeOrder(this.token, oid);
      const str = JSON.stringify(res);
      if (str.includes('200') || str.includes('success')) {
        promptAction.showToast({ message: '删除成功' });
        this.fetchOrders(this.currentStatus);
      } else {
        promptAction.showToast({ message: '删除失败' });
      }
    } catch (err) {
      promptAction.showToast({ message: '网络异常' });
    }
  }

  @Builder OrderItemView(item: OrderItem) {
    Column() {
      Row() {
        Text(`订单号: ${item.oid}`).fontSize(12).fontColor('#999')
        Blank()
        Text(item.status === 2 ? '已完成' : '进行中')
          .fontSize(14)
          .fontColor(item.status === 2 ? '#999' : '#D22028')
      }
      .width('100%').padding({ bottom: 10 })

      Divider().color('#F5F5F5')

      Column() {
        ForEach(item.products, (prod: OrderProduct) => {
          Row() {
            Image(prod.smallImg)
              .width(60).height(60).borderRadius(4)
              .objectFit(ImageFit.Cover)
              .backgroundColor('#F5F5F5')

            Column() {
              Text(prod.name).fontSize(14).fontWeight(FontWeight.Bold).maxLines(1).textOverflow({ overflow: TextOverflow.Ellipsis })
              Text(prod.rule).fontSize(12).fontColor('#999').margin({ top: 4 })
            }
            .layoutWeight(1).alignItems(HorizontalAlign.Start).padding({ left: 10 })

            Column() {
              Text(`¥${prod.price}`).fontSize(14).fontColor('#333')
              Text(`x${prod.count}`).fontSize(12).fontColor('#999')
            }.alignItems(HorizontalAlign.End)
          }
          .width('100%').padding({ top: 10, bottom: 10 })
        }, (prod: OrderProduct) => `${item.oid}_${prod.pid}`)
      }
      .width('100%')

      Divider().color('#F5F5F5')

      Row() {
        Text(item.date ? item.date.split('T')[0] : '').fontSize(12).fontColor('#999')
        Blank()
        Column() {
          Row() {
            Text('共').fontSize(12).fontColor('#999')
            Text(`${item.products.reduce((sum, p) => sum + p.count, 0)}`)
              .fontSize(12).fontColor('#D22028').margin({ left: 2, right: 2 })
            Text('件商品 合计:').fontSize(12).fontColor('#999')
            Text(`¥${item.amount}`).fontSize(16).fontWeight(FontWeight.Bold).fontColor('#333').margin({ left: 5 })
          }

          Row() {
            if (item.status === 1) {
              Button('确认收货', { type: ButtonType.Normal })
                .width(80).height(28).fontSize(12).backgroundColor(Color.White).fontColor('#0035AA')
                .border({ width: 1, color: '#0035AA', radius: 14 })
                .margin({ top: 10 })
                .onClick(() => this.handleReceive(item.oid))
            } else if (item.status === 2) {
              Button('删除订单', { type: ButtonType.Normal })
                .width(80).height(28).fontSize(12).backgroundColor(Color.White).fontColor('#999')
                .border({ width: 1, color: '#CCC', radius: 14 })
                .margin({ top: 10 })
                .onClick(() => {
                  AlertDialog.show({
                    title: '提示',
                    message: '确认删除该订单吗？',
                    primaryButton: { value: '取消', action: () => {} },
                    secondaryButton: { value: '删除', fontColor: 'red', action: () => this.handleDelete(item.oid) }
                  })
                })
            }
          }.justifyContent(FlexAlign.End).width('100%')
        }.alignItems(HorizontalAlign.End)
      }
      .width('100%').padding({ top: 10 })
    }
    .width('100%')
    .padding(15)
    .backgroundColor(Color.White)
    .borderRadius(8)
    .margin({ bottom: 10 })
  }

  build() {
    Column() {
      Row() {
        Text('<').fontSize(24).fontColor('#333').padding({ right: 20 })
          .onClick(() => router.back())
        Text('我的订单').fontSize(18).fontWeight(FontWeight.Bold)
      }
      .width('100%').height(50).padding({ left: 15 }).backgroundColor(Color.White)

      Tabs({ index: this.currentStatus }) {
        TabContent().tabBar('全部')
        TabContent().tabBar('进行中')
        TabContent().tabBar('已完成')
      }
      .onChange((index: number) => {
        this.currentStatus = index;
        this.fetchOrders(index);
      })
      .barMode(BarMode.Fixed)
      .barWidth('100%')
      .barHeight(44)

      if (this.isLoading) {
        Column() {
          LoadingProgress().width(40).height(40).color('#0035AA')
        }.layoutWeight(1).justifyContent(FlexAlign.Center)
      } else if (this.orderList.length === 0) {
        Column() {
          Text('暂无相关订单').fontSize(14).fontColor('#999').margin({ top: 10 })
        }.layoutWeight(1).justifyContent(FlexAlign.Center)
      } else {
        List() {
          ForEach(this.orderList, (item: OrderItem) => {
            ListItem() {
              this.OrderItemView(item)
            }
          }, (item: OrderItem) => item.oid)
        }
        .layoutWeight(1)
        .padding(10)
        .width('100%')
      }
    }
    .width('100%').height('100%').backgroundColor('#F5F5F5')
  }
}