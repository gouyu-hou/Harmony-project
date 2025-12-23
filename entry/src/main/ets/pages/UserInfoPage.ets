import router from '@ohos.router';
import CoffeeApi, { UserInfo } from '../api/CoffeeApi';
import promptAction from '@ohos.promptAction';

@Entry
@Component
struct UserInfoPage {
  // 1. 获取 Token
  @StorageLink('token') token: string = '';

  // 2. 定义状态，默认给点占位符
  @State userInfo: UserInfo = {
    userId: '...',
    nickName: '加载中...',
    userImg: '',
    desc: '...',
    phone: '...'
  };

  // 3. 页面显示时拉取数据
  aboutToAppear() {
    this.fetchData();
  }

  async fetchData() {
    // 打印日志方便调试
    console.info(`[UserInfoPage] Token: ${this.token}`);

    if (!this.token) {
      promptAction.showToast({ message: '请先登录' });
      return;
    }

    try {
      const res = await CoffeeApi.getUserInfo(this.token);
      console.info(`[UserInfoPage] 接口返回: ${JSON.stringify(res)}`);

      if (res.code === 200 && res.data) {
        // 成功！更新 UI
        this.userInfo = res.data;
        // 同步更新本地缓存
        AppStorage.SetOrCreate('userInfo', JSON.stringify(this.userInfo));
      } else {
        console.warn('[UserInfoPage] 数据格式不符合预期');
      }
    } catch (err) {
      console.error('[UserInfoPage] 请求异常');
    }
  }

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
        // --- 头像行 (动态) ---
        Row() {
          Text('头像').fontSize(16).fontColor('#333')
          // 使用 API 返回的图片，失败显示默认图
          Image(this.userInfo.userImg || $r('app.media.home_active'))
            .width(40).height(40)
            .borderRadius(20)
            .backgroundColor('#EEE')
            .objectFit(ImageFit.Cover) // 防止图片变形
        }
        .width('100%').justifyContent(FlexAlign.SpaceBetween).padding({ top: 15, bottom: 15 })
        Divider()

        // --- ID 行 (动态) ---
        this.InfoRow('用户id', this.userInfo.userId || '未知', true)
        Divider()

        // --- 手机号行 (动态) ---
        this.InfoRow('手机号', this.userInfo.phone || '未绑定', true)
        Divider()

        // --- 昵称行 (动态) ---
        this.InfoRow('昵称', this.userInfo.nickName || '未设置', false)
        Divider()

        // --- 简介行 (动态) ---
        Column() {
          Text('简介').fontSize(16).fontColor('#333').margin({ bottom: 10 })
          Text(this.userInfo.desc || '这个家伙很懒，什么都没写~')
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