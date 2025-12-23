import router from '@ohos.router';

@Entry
@Component
struct MyOrderPage {
  // 当前选中的 Tab 索引: 0=全部, 1=进行中, 2=已完成
  @State currentTabIndex: number = 0;

  // Tab 标题数组
  tabs: string[] = ['全部', '进行中', '已完成'];

  build() {
    Column() {
      // 1. 蓝色背景 + 顶部导航
      Stack({ alignContent: Alignment.Top }) {
        // 纯色背景块
        Column().width('100%').height(120).backgroundColor('#0035AA')

        // 导航栏内容
        Row() {
          Text('< 返回')
            .fontSize(16).fontColor(Color.White)
            .onClick(() => router.back())
          Text('我的订单')
            .fontSize(18).fontWeight(FontWeight.Bold).fontColor(Color.White)
            .layoutWeight(1).textAlign(TextAlign.Center).margin({ right: 40 })
        }
        .width('100%').height(50).padding({ left: 15, right: 15 })
      }
      .height(60) // 限制 Stack 高度，让下面的白色卡片自然盖上来
      .width('100%')

      // 2. 白色卡片区域 (Tabs + 内容)
      Column() {
        // --- 自定义 Tab 栏 ---
        Row() {
          ForEach(this.tabs, (item: string, index: number) => {
            Column() {
              Text(item)
                .fontSize(14)
                .fontColor(this.currentTabIndex === index ? '#0035AA' : '#666')
                .fontWeight(this.currentTabIndex === index ? FontWeight.Bold : FontWeight.Normal)
                .margin({ bottom: 8 })

              // 选中时的蓝色下划线
              if (this.currentTabIndex === index) {
                Divider().width(20).strokeWidth(3).color('#0035AA').borderRadius(2)
              } else {
                // 占位，防止高度跳动
                Divider().width(20).strokeWidth(3).color(Color.Transparent)
              }
            }
            .layoutWeight(1)
            .height(40)
            .justifyContent(FlexAlign.End)
            .onClick(() => {
              this.currentTabIndex = index;
            })
          })
        }
        .width('100%')
        .border({ width: { bottom: 1 }, color: '#F5F5F5' })

        // --- 内容区域 (空状态) ---
        Column() {
          // 这里使用一个灰色的图标或方块代替缺省图
          // 如果你有图片资源，请替换 Image($r('app.media.empty_order'))
          Text('🔍').fontSize(14).fontColor('#999').margin({ left: 10, right: 5 })

          Text('没有订单数据!')
            .fontSize(14)
            .fontColor('#999')
        }
        .width('100%')
        .layoutWeight(1) // 撑满剩余高度
        .justifyContent(FlexAlign.Center) // 垂直居中
        .backgroundColor(Color.White) // 确保背景白

      }
      .width('100%')
      .layoutWeight(1) // 撑满页面剩余空间
      .backgroundColor(Color.White)
      .borderRadius({ topLeft: 12, topRight: 12 }) // 顶部圆角
      .clip(true) // 裁剪圆角
      .margin({ top: -10 }) // 稍微上移一点点，或者直接贴合
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }
}