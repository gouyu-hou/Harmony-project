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

// 基础响应接口
interface BasicResponse {
  code: number | string;
  msg?: string;
  data?: Object;
  result?: Object;
}

@Entry
@Component
struct MyOrderPage {
  @StorageLink('token') token: string = '';

  @State currentStatus: number = 0; // 0:全部, 1:进行中, 2:已完成
  @State orderList: OrderItem[] = [];
  @State isLoading: boolean = false;

  aboutToAppear() {
    this.fetchOrders(this.currentStatus);
  }

  // 2. 数据清洗函数 (已修复字面量类型报错)
  normalizeOrderData(flatList: RawDbOrder[]): OrderItem[] {
    const orderMap = new Map<string, OrderItem>();

    flatList.forEach((item) => {
      if (!orderMap.has(item.oid)) {
        // 显式声明类型，解决 arkts-no-untyped-obj-literals
        const newOrder: OrderItem = {
          oid: item.oid,
          status: item.status,
          date: item.createdAt || item.updatedAt,
          amount: 0,
          address: item.address,
          products: []
        };
        orderMap.set(item.oid, newOrder);
      }

      const order = orderMap.get(item.oid);

      if (order) {
        const unitPrice = parseFloat(item.price);
        const itemTotalPrice = unitPrice * item.count;
        order.amount += itemTotalPrice;

        // 显式声明类型
        const product: OrderProduct = {
          pid: item.pid,
          name: item.name,
          smallImg: item.smallImg,
          price: unitPrice,
          count: item.count,
          rule: item.rule
        };
        order.products.push(product);
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

  // 3. 提取订单数组
  findOrderArrayInObject(obj: Object): RawDbOrder[] | null {
    if (!obj) return null;
    const root = obj as Record<string, Object>;

    if (root['result'] && Array.isArray(root['result'])) {
      return root['result'] as RawDbOrder[];
    }
    if (root['data']) {
      let dataObj = root['data'];
      if (typeof dataObj === 'string') {
        try { dataObj = JSON.parse(dataObj); } catch (e) {}
      }
      const innerData = dataObj as Record<string, Object>;
      if (innerData && innerData['result'] && Array.isArray(innerData['result'])) {
        return innerData['result'] as RawDbOrder[];
      }
      if (Array.isArray(dataObj)) {
        return dataObj as RawDbOrder[];
      }
    }
    if (root['result']) {
      let resultObj = root['result'];
      if (typeof resultObj === 'string') {
        try { resultObj = JSON.parse(resultObj); } catch (e) {}
      }
      const innerResult = resultObj as Record<string, Object>;
      if (innerResult && innerResult['result'] && Array.isArray(innerResult['result'])) {
        return innerResult['result'] as RawDbOrder[];
      }
    }
    return null;
  }

  async fetchOrders(status: number) {
    this.isLoading = true;
    this.orderList = [];

    try {
      const rawRes = await CoffeeApi.findOrder(this.token, status);
      const targetList = this.findOrderArrayInObject(rawRes as Object);

      if (targetList && targetList.length > 0) {
        this.orderList = this.normalizeOrderData(targetList);
      } else {
        this.orderList = [];
      }
    } catch (err) {
      console.error('[MyOrderPage] Error:', JSON.stringify(err as Object));
      promptAction.showToast({ message: '获取订单失败' });
    } finally {
      this.isLoading = false;
    }
  }

  // ✅ 核心修复：删除订单逻辑
  async handleDelete(oid: string) {
    try {
      const res = await CoffeeApi.removeOrder(this.token, oid);
      const response = res as Object as BasicResponse;
      const code = response.code;

      if (code == 200 || code == '200' || code == 70000 || code == '70000') {

        // 🔥 1. 找到索引
        const index = this.orderList.findIndex(item => item.oid === oid);
        if (index !== -1) {
          // 🔥 2. 使用 splice 直接从数组中移除
          // 相比 filter，splice 是原地变异操作，ArkUI 能够精确捕捉并立即执行删除动画/刷新
          this.orderList.splice(index, 1);
        }

        promptAction.showToast({ message: '删除成功' });
      } else {
        promptAction.showToast({ message: response.msg || '删除失败' });
      }
    } catch (err) {
      promptAction.showToast({ message: '网络异常' });
    }
  }

  // ✅ 核心修复：确认收货逻辑
  async handleReceive(oid: string) {
    try {
      const res = await CoffeeApi.receiveOrder(this.token, oid);
      const response = res as Object as BasicResponse;
      const code = response.code;

      if (code == 200 || code == '200' || code == 70000 || code == '70000') {

        const index = this.orderList.findIndex(item => item.oid === oid);

        if (index !== -1) {
          if (this.currentStatus === 1) {
            // 场景A：如果在“进行中”Tab，收货后它就不属于这里了 -> 直接移除
            this.orderList.splice(index, 1);
          } else {
            // 场景B：如果在“全部”Tab，它还在列表里，但状态变了

            // 🚫 避免使用 const newObj = { ...oldObj } (严格模式报错)
            // ✅ 手动构建新对象，只修改 status
            const oldItem = this.orderList[index];
            const newItem: OrderItem = {
              oid: oldItem.oid,
              status: 2, // 状态改为已完成
              date: oldItem.date,
              amount: oldItem.amount,
              address: oldItem.address,
              products: oldItem.products
            };

            // 🔥 使用 splice(index, 1, newItem) 替换元素
            // 这会强制 UI 认为该行数据已更新，立即重绘按钮
            this.orderList.splice(index, 1, newItem);
          }
        }

        promptAction.showToast({ message: '确认收货成功' });

      } else {
        promptAction.showToast({ message: response.msg || '操作失败' });
      }
    } catch (err) {
      promptAction.showToast({ message: '网络异常' });
    }
  }

  @Builder OrderItemView(item: OrderItem) {
    Column() {
      // 头部
      Row() {
        Text(`订单号: ${item.oid}`)
          .fontSize(12)
          .fontColor('#999')
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .layoutWeight(1)

        Text(item.status === 2 ? '已完成' : '进行中')
          .fontSize(14)
          .fontColor(item.status === 2 ? '#999' : '#D22028')
          .margin({ left: 8 })
      }
      .width('100%')
      .padding({ bottom: 8 })

      Divider().color('#F5F5F5')

      // 商品列表
      Column() {
        ForEach(item.products, (prod: OrderProduct) => {
          Row() {
            Image(prod.smallImg)
              .width(60)
              .height(60)
              .borderRadius(4)
              .objectFit(ImageFit.Cover)
              .backgroundColor('#F5F5F5')

            Column() {
              Text(prod.name)
                .fontSize(14)
                .fontWeight(FontWeight.Bold)
                .maxLines(1)
                .textOverflow({ overflow: TextOverflow.Ellipsis })

              Text(prod.rule)
                .fontSize(12)
                .fontColor('#999')
                .margin({ top: 4 })
                .maxLines(1)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
            }
            .layoutWeight(1)
            .alignItems(HorizontalAlign.Start)
            .padding({ left: 10, right: 10 })

            Column() {
              Text(`¥${prod.price}`).fontSize(14).fontColor('#333')
              Text(`x${prod.count}`).fontSize(12).fontColor('#999')
            }
            .alignItems(HorizontalAlign.End)
          }
          .width('100%')
          .padding({ top: 10, bottom: 10 })
        }, (prod: OrderProduct) => `${item.oid}_${prod.pid}`)
      }
      .width('100%')

      Divider().color('#F5F5F5')

      // 底部信息栏
      Column() {
        Row() {
          Text(item.date ? item.date.split('T')[0] : '')
            .fontSize(12)
            .fontColor('#999')

          Blank()

          Row() {
            Text('共').fontSize(12).fontColor('#999')
            Text(`${item.products.reduce((sum, p) => sum + p.count, 0)}`)
              .fontSize(12)
              .fontColor('#D22028')
              .margin({ left: 2, right: 2 })
            Text('件 合计:').fontSize(12).fontColor('#999')
            Text(`¥${item.amount}`)
              .fontSize(16)
              .fontWeight(FontWeight.Bold)
              .fontColor('#333')
              .margin({ left: 4 })
          }
        }
        .width('100%')
        .padding({ top: 8, bottom: 8 })

        Row() {
          Blank()

          // 根据 item.status 动态显示按钮
          if (item.status === 1) {
            Button('确认收货', { type: ButtonType.Normal })
              .width(84)
              .height(28)
              .fontSize(12)
              .backgroundColor(Color.White)
              .fontColor('#0035AA')
              .border({ width: 1, color: '#0035AA', radius: 14 })
              .onClick(() => this.handleReceive(item.oid))
          } else if (item.status === 2) {
            Button('删除订单', { type: ButtonType.Normal })
              .width(84)
              .height(28)
              .fontSize(12)
              .backgroundColor(Color.White)
              .fontColor('#999')
              .border({ width: 1, color: '#CCC', radius: 14 })
              .onClick(() => {
                AlertDialog.show({
                  title: '提示',
                  message: '确认删除该订单吗？',
                  primaryButton: { value: '取消', action: () => {} },
                  secondaryButton: { value: '删除', fontColor: 'red', action: () => this.handleDelete(item.oid) }
                })
              })
          }
        }
        .width('100%')
      }
      .width('100%')
    }
    .width('100%')
    .padding(12)
    .backgroundColor(Color.White)
    .borderRadius(8)
  }

  build() {
    Column() {
      // 导航栏
      Row() {
        Text('<')
          .fontSize(24)
          .fontColor('#333')
          .padding({ right: 20 })
          .onClick(() => router.back())
        Text('我的订单').fontSize(18).fontWeight(FontWeight.Bold)
      }
      .width('100%')
      .height(50)
      .padding({ left: 15 })
      .backgroundColor(Color.White)

      // Tabs
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
      .backgroundColor(Color.White)
      .height(44)

      // 调试信息 (可删)
      if (this.orderList.length > 0) {
        Text(`已加载 ${this.orderList.length} 个订单`)
          .fontSize(10)
          .fontColor(Color.Gray)
          .margin({ top: 5, bottom: 5 })
      }

      // 内容区域
      if (this.isLoading) {
        Column() {
          LoadingProgress().width(40).height(40).color('#0035AA')
        }
        .layoutWeight(1)
        .width('100%')
        .justifyContent(FlexAlign.Center)
      } else if (this.orderList.length === 0) {
        Column() {
          Text('暂无相关订单')
            .fontSize(14)
            .fontColor('#999')
            .margin({ top: 10 })
        }
        .layoutWeight(1)
        .width('100%')
        .justifyContent(FlexAlign.Center)
      } else {
        // 列表
        List({ space: 12 }) {
          // ⚠️ ForEach Key 必须唯一且稳定，这里使用 item.oid
          ForEach(this.orderList, (item: OrderItem) => {
            ListItem() {
              this.OrderItemView(item)
            }
          }, (item: OrderItem) => item.oid)
        }
        .layoutWeight(1)
        .width('100%')
        .padding({ left: 12, right: 12, top: 10, bottom: 20 })
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }
}