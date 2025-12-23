import router from '@ohos.router';

@Entry
@Component
struct MyFavoritePage {
  build() {
    Column() {
      // 1. 顶部 Header (复用风格)
      Stack({ alignContent: Alignment.Top }) {
        Column().width('100%').height(120).backgroundColor('#0035AA')
        Row() {
          Text('< 返回')
            .fontSize(16).fontColor(Color.White)
            .onClick(() => router.back())
          Text('我的收藏')
            .fontSize(18).fontWeight(FontWeight.Bold).fontColor(Color.White)
            .layoutWeight(1).textAlign(TextAlign.Center).margin({ right: 40 })
        }
        .width('100%').height(50).padding({ left: 15, right: 15 })
      }
      .height(60)
      .width('100%')

      // 2. 白色卡片区域
      Column() {
        // 空状态容器
        Column() {
          // --- 修改开始：使用容器模拟“假图片”占位 ---
          Stack({ alignContent: Alignment.Center }) {
            // 1. 灰色背景层
            Column()
              .width('100%')
              .height('100%')
              .backgroundColor('#F5F5F5') // 浅灰色背景
              .borderRadius(8) // 加一点圆角

            // 2. 中间的占位图标 (用 Emoji 代替)
            Text('🖼️') // 这里用星星代表收藏缺省，也可以用 '🖼️' 代表图片缺省
              .fontSize(36)
              .fontColor('#CCCCCC') // 浅灰色图标
          }
          .width(80)
          .height(80)
          .margin({ bottom: 15 })
          // --- 修改结束 ---

          Text('没有收藏数据!')
            .fontSize(14)
            .fontColor('#999')
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      }
      .width('100%')
      .layoutWeight(1)
      .backgroundColor(Color.White)
      .borderRadius({ topLeft: 12, topRight: 12 })
      .clip(true)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }
}