import router from '@ohos.router';
import CoffeeApi, { AddressItem } from '../api/CoffeeApi';
import promptAction from '@ohos.promptAction';

@Entry
@Component
struct AddressListPage {
  @StorageLink('token') token: string = '';
  @State addressList: AddressItem[] = [];
  @State isLoading: boolean = false;

  // 使用 onPageShow 确保从编辑页返回时能刷新数据
  onPageShow() {
    this.fetchAddressList();
  }

  async fetchAddressList() {
    this.isLoading = true;
    try {
      const res = await CoffeeApi.findAddress(this.token);
      if (res.code === 200 || res.code === '200') {
        this.addressList = res.data || [];
      } else {
        this.addressList = [];
      }
    } catch (err) {
      console.error('获取地址列表失败', JSON.stringify(err));
    } finally {
      this.isLoading = false;
    }
  }

  build() {
    Column() {
      // 1. 导航栏
      Row() {
        Text('<').fontSize(24).fontColor('#333').padding({ right: 20 })
          .onClick(() => router.back())
        Text('地址管理').fontSize(18).fontWeight(FontWeight.Bold)
      }
      .width('100%').height(50).padding({ left: 15 }).backgroundColor(Color.White)

      // 2. 地址列表
      if (this.isLoading) {
        Column() {
          LoadingProgress().width(40).height(40).color('#0035AA')
        }.layoutWeight(1).justifyContent(FlexAlign.Center)
      } else if (this.addressList.length === 0) {
        Column() {
          Image($r('app.media.shopbag_bg')).width(150).height(150).opacity(0.5) // 假设有个空状态图，或者用默认图
          Text('暂无收货地址').fontSize(14).fontColor('#999').margin({ top: 10 })
        }.layoutWeight(1).justifyContent(FlexAlign.Center)
      } else {
        List({ space: 10 }) {
          ForEach(this.addressList, (item: AddressItem) => {
            ListItem() {
              this.AddressItemView(item)
            }
          }, (item: AddressItem) => item.aid)
        }
        .layoutWeight(1).padding(10).width('100%')
      }

      // 3. 新增按钮
      Button('新增收货地址', { type: ButtonType.Normal })
        .width('90%').height(45).backgroundColor('#0035AA').borderRadius(22.5)
        .margin({ bottom: 20 })
        .onClick(() => {
          // 跳转到编辑页，不带 params 表示新增
          router.pushUrl({ url: 'pages/AddressEditPage' });
        })
    }
    .width('100%').height('100%').backgroundColor('#F5F5F5')
  }

  @Builder AddressItemView(item: AddressItem) {
    Row() {
      Column() {
        Row() {
          Text(item.name).fontSize(16).fontWeight(FontWeight.Bold).fontColor('#333')
          Text(item.tel).fontSize(14).fontColor('#666').margin({ left: 10 })
          if (item.isDefault === 1) {
            Text('默认').fontSize(10).fontColor(Color.White).backgroundColor('#D22028')
              .padding({ left: 4, right: 4, top: 1, bottom: 1 }).borderRadius(2).margin({ left: 10 })
          }
        }
        .width('100%').margin({ bottom: 8 })

        Text(`${item.province}${item.city}${item.county}${item.addressDetail}`)
          .fontSize(14).fontColor('#333').maxLines(2).textOverflow({ overflow: TextOverflow.Ellipsis })
      }
      .layoutWeight(1).alignItems(HorizontalAlign.Start)

      // 编辑图标
      Text('编辑').fontSize(14).fontColor('#999').padding({ left: 15, top: 10, bottom: 10 })
        .onClick(() => {
          // 跳转到编辑页，携带 aid
          router.pushUrl({
            url: 'pages/AddressEditPage',
            params: { aid: item.aid }
          });
        })
    }
    .width('100%').padding(15).backgroundColor(Color.White).borderRadius(8)
  }
}