import router from '@ohos.router';

@Entry
@Component
struct UserInfoPage {
  build() {
    Column() {
      // 1. 顶部导航 (蓝色背景)
      Row() {
        Text('< 返回')
          .fontSize(16).fontColor(Color.White)
          .onClick(() => router.back())
        Text('个人资料')
          .fontSize(18).fontWeight(FontWeight.Bold).fontColor(Color.White)
          .layoutWeight(1).textAlign(TextAlign.Center).margin({ right: 40 })
      }
      .width('100%').height(50).padding({ left: 15, right: 15 })
      .backgroundColor('#0035AA') // 瑞幸蓝

      // 2. 蓝色背景延伸区
      Column().width('100%').height(50).backgroundColor('#0035AA')

      // 3. 资料卡片
      Column() {
        // 头像行
        Row() {
          Text('头像').fontSize(16).fontColor('#333')
          Image($r('app.media.home_active')).width(40).height(40).borderRadius(20).backgroundColor('#EEE')
        }
        .width('100%').justifyContent(FlexAlign.SpaceBetween).padding({ top: 15, bottom: 15 })
        Divider()

        // ID 行
        this.InfoRow('用户id', 'coffe1651234234254', true)
        Divider()

        // 手机号行
        this.InfoRow('手机号', '13434711077', true)
        Divider()

        // 昵称行
        this.InfoRow('昵称', '苟宇', false)
        Divider()

        // 简介行
        Column() {
          Text('简介').fontSize(16).fontColor('#333').margin({ bottom: 10 })
          Text('2022与你相约在粤嵌，爱你呦么么哒')
            .fontSize(14).fontColor('#666').lineHeight(20)
        }
        .width('100%').alignItems(HorizontalAlign.Start).padding({ top: 15, bottom: 15 })

      }
      .width('92%')
      .backgroundColor(Color.White)
      .borderRadius(10)
      .padding({ left: 15, right: 15 })
      .margin({ top: -50 }) // 上移覆盖蓝色背景
      .shadow({ radius: 5, color: '#1A000000', offsetY: 2 })

    }
    .width('100%').height('100%').backgroundColor('#F5F5F5')
  }

  @Builder InfoRow(label: string, value: string, isGray: boolean) {
    Row() {
      Text(label).fontSize(16).fontColor('#333')
      Text(value).fontSize(16).fontColor(isGray ? '#999' : '#333')
    }
    .width('100%').justifyContent(FlexAlign.SpaceBetween)
    .padding({ top: 15, bottom: 15 })
  }
}