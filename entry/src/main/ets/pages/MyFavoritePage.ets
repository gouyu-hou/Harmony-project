import router from '@ohos.router';
import CoffeeApi, { ProductItem } from '../api/CoffeeApi';
import promptAction from '@ohos.promptAction';

@Entry
@Component
struct MyFavoritePage {
  @StorageLink('token') token: string = '';

  // 收藏列表数据
  @State favoriteList: ProductItem[] = [];

  // 页面显示时拉取数据
  onPageShow() {
    this.fetchFavorites();
  }

  async fetchFavorites() {
    if (!this.token) {
      promptAction.showToast({ message: '请先登录' });
      return;
    }
    try {
      const res = await CoffeeApi.findAllLike(this.token);
      if (res.code === 200 && res.data) {
        this.favoriteList = res.data;
      } else {
        // 如果没有数据或 code 不对，清空列表
        this.favoriteList = [];
      }
    } catch (err) {
      console.error('获取收藏列表失败');
    }
  }

  // 取消收藏
  async handleRemove(pid: string) {
    try {
      const res = await CoffeeApi.notLike(this.token, pid);
      if (res.code === 200 || res.code === 'B001' || res.msg === 'Success') {
        promptAction.showToast({ message: '已取消收藏' });
        // 重新拉取列表刷新
        this.fetchFavorites();
      } else {
        promptAction.showToast({ message: res.msg || '操作失败' });
      }
    } catch (err) {
      promptAction.showToast({ message: '网络请求失败' });
    }
  }

  build() {
    Column() {
      // 顶部导航
      Row() {
        Text('< 返回').fontSize(16).fontColor('#0035AA').onClick(() => router.back())
        Text('我的收藏').fontSize(18).fontWeight(FontWeight.Bold).layoutWeight(1).textAlign(TextAlign.Center).margin({ right: 40 })
      }
      .width('100%').height(50).padding({ left: 15, right: 15 }).backgroundColor(Color.White)

      // 列表区域
      if (this.favoriteList.length === 0) {
        // 空状态
        Column() {
          Text('暂无收藏商品').fontSize(16).fontColor('#999').margin({ top: 100 })
        }.width('100%').layoutWeight(1)
      } else {
        List({ space: 10 }) {
          ForEach(this.favoriteList, (item: ProductItem) => {
            ListItem() {
              Row() {
                // 商品图片
                Image(item.smallImg)
                  .width(80).height(80).objectFit(ImageFit.Cover)
                  .borderRadius(8).backgroundColor('#F5F5F5')
                  .margin({ right: 10 })

                // 商品信息
                Column() {
                  Text(item.name).fontSize(16).fontWeight(FontWeight.Bold).maxLines(1).textOverflow({ overflow: TextOverflow.Ellipsis })
                  Text(item.enname).fontSize(12).fontColor('#999').maxLines(1).textOverflow({ overflow: TextOverflow.Ellipsis }).margin({ top: 4 })
                  Blank()
                  Text(`¥${item.price}`).fontSize(16).fontColor('#D22028').fontWeight(FontWeight.Bold)
                }
                .layoutWeight(1).height(80).alignItems(HorizontalAlign.Start)
                .onClick(() => {
                  // 点击跳转详情页
                  router.pushUrl({ url: 'pages/ProductDetailPage', params: { pid: item.pid } })
                })

                // 删除按钮
                Column() {
                  Text('🗑️') // 这里可以用图片代替
                    .fontSize(20)
                    .fontColor('#999')
                    .padding(10)
                    .onClick(() => {
                      // 弹窗确认
                      AlertDialog.show({
                        title: '提示',
                        message: '确定取消收藏该商品吗？',
                        primaryButton: { value: '取消', action: () => {} },
                        secondaryButton: {
                          value: '确定',
                          fontColor: 'red',
                          action: () => this.handleRemove(item.pid)
                        }
                      })
                    })
                }.height(80).justifyContent(FlexAlign.Center)

              }
              .width('100%').padding(10).backgroundColor(Color.White).borderRadius(8)
            }
          })
        }
        .width('100%').layoutWeight(1).padding(10)
      }
    }
    .width('100%').height('100%').backgroundColor('#F5F5F5')
  }
}