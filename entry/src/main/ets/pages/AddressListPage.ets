import router from '@ohos.router';

// 1. 【新增】定义地址数据的接口结构
interface AddressModel {
  id: number;
  name: string;
  phone: string;
  address: string;
  isDefault: boolean;
}

@Entry
@Component
struct AddressListPage {
  // 2. 【修改】使用明确的类型 AddressModel[]，不再用 any[]
  @State addressList: AddressModel[] = [
    { id: 1, name: '苟宇', phone: '13434711077', address: '广东省广州市天河区珠吉街道100号', isDefault: true },
    { id: 2, name: '爱丽丝', phone: '16809801654', address: '北京市北京市东城区108街道', isDefault: false }
  ];

  build() {
    Column() {
      // 顶部导航 (保持不变)
      Row() {
        Text('< 返回').fontSize(16).fontColor('#0035AA').onClick(() => router.back())
        Text('地址管理').fontSize(18).fontWeight(FontWeight.Bold).layoutWeight(1).textAlign(TextAlign.Center).margin({ right: 40 })
      }
      .width('100%').height(50).padding({ left: 15, right: 15 }).backgroundColor(Color.White)

      // 地址列表
      List({ space: 10 }) {
        // 3. 【修改】ForEach 中指定 item 的类型为 AddressModel
        ForEach(this.addressList, (item: AddressModel) => {
          ListItem() {
            Row() {
              // 左侧信息
              Column({ space: 5 }) {
                Row() {
                  Text(item.name).fontSize(16).fontWeight(FontWeight.Bold).margin({ right: 10 })
                  Text(item.phone).fontSize(16).fontColor('#666')
                  if (item.isDefault) {
                    Text('默认').fontSize(10).fontColor(Color.White).backgroundColor('#0035AA')
                      .padding({ left: 4, right: 4, top: 2, bottom: 2 }).borderRadius(4).margin({ left: 10 })
                  }
                }
                Text(item.address).fontSize(14).fontColor('#333').maxLines(2).textOverflow({ overflow: TextOverflow.Ellipsis })
              }
              .layoutWeight(1)
              .alignItems(HorizontalAlign.Start)

              // 右侧编辑图标
              Text('✎')
                .fontSize(20).fontColor('#999').padding(10)
                .onClick(() => {
                  // 跳转编辑 (参数对象也建议定义类型，这里保持简单传参)
                  router.pushUrl({ url: 'pages/AddressEditPage', params: { editMode: true, data: item } })
                })
            }
            .width('100%').padding(15).backgroundColor(Color.White).borderRadius(8)
          }
        })
      }
      .width('100%').layoutWeight(1).padding(10)

      // 底部按钮 (保持不变)
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