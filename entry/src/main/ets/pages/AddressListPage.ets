import router from '@ohos.router';
import CoffeeApi, { AddressItem } from '../api/CoffeeApi'; // ✅ 引入新定义的接口
import promptAction from '@ohos.promptAction';

@Entry
@Component
struct AddressListPage {
  @StorageLink('token') token: string = '';

  // ✅ 1. 使用 API 定义的 AddressItem 类型
  @State addressList: AddressItem[] = [];

  // ✅ 2. 使用 onPageShow，确保每次返回页面时都刷新数据
  onPageShow() {
    this.fetchAddressList();
  }

  async fetchAddressList() {
    if (!this.token) {
      promptAction.showToast({ message: '请先登录' });
      return;
    }
    try {
      const res = await CoffeeApi.findAddress(this.token);
      if (res.code === 200 && res.data) {
        this.addressList = res.data;
      }
    } catch (err) {
      console.error('获取地址列表失败');
    }
  }

  build() {
    Column() {
      // 顶部导航
      Row() {
        Text('< 返回').fontSize(16).fontColor('#0035AA').onClick(() => router.back())
        Text('地址管理').fontSize(18).fontWeight(FontWeight.Bold).layoutWeight(1).textAlign(TextAlign.Center).margin({ right: 40 })
      }
      .width('100%').height(50).padding({ left: 15, right: 15 }).backgroundColor(Color.White)

      // 地址列表
      List({ space: 10 }) {
        ForEach(this.addressList, (item: AddressItem) => {
          ListItem() {
            Row() {
              // 左侧信息
              Column({ space: 5 }) {
                Row() {
                  Text(item.name).fontSize(16).fontWeight(FontWeight.Bold).margin({ right: 10 })
                  // ✅ 接口字段是 tel
                  Text(item.tel).fontSize(16).fontColor('#666')

                  // ✅ 接口 isDefault 是 1 (默认) 或 0 (非默认)
                  if (item.isDefault === 1) {
                    Text('默认').fontSize(10).fontColor(Color.White).backgroundColor('#0035AA')
                      .padding({ left: 4, right: 4, top: 2, bottom: 2 }).borderRadius(4).margin({ left: 10 })
                  }
                }
                // ✅ 拼接完整地址：省 + 市 + 区 + 详细
                Text(`${item.province}${item.city}${item.county}${item.addressDetail}`)
                  .fontSize(14).fontColor('#333').maxLines(2).textOverflow({ overflow: TextOverflow.Ellipsis })
              }
              .layoutWeight(1)
              .alignItems(HorizontalAlign.Start)

              // 右侧编辑图标
              Text('✎')
                .fontSize(20).fontColor('#999').padding(10)
                .onClick(() => {
                  // 跳转编辑 (后续实现编辑功能时会用到这些参数)
                  router.pushUrl({
                    url: 'pages/AddressEditPage',
                    params: { editMode: true, addressData: item }
                  })
                })
            }
            .width('100%').padding(15).backgroundColor(Color.White).borderRadius(8)
          }
        })
      }
      .width('100%').layoutWeight(1).padding(10)

      // 底部按钮
      Button('新增地址', { type: ButtonType.Normal })
        .width('90%').height(50).backgroundColor('#0035AA').borderRadius(25).fontSize(18)
        .margin({ bottom: 20 })
        .onClick(() => {
          router.pushUrl({ url: 'pages/AddressEditPage', params: { editMode: false } })
        })
    }
    .width('100%').height('100%').backgroundColor('#F5F5F5')
  }
}