import router from '@ohos.router';
import CoffeeApi, { UserInfo } from '../api/CoffeeApi';
import promptAction from '@ohos.promptAction';

@Entry
@Component
struct UserInfoPage {
  @StorageLink('token') token: string = '';

  // 给初始值
  @State userInfo: UserInfo = {
    userId: '加载中...',
    nickName: '...',
    userImg: '',
    desc: '...',
    phone: '...'
  };

  aboutToAppear() {
    this.fetchData();
  }

  async fetchData() {
    if (!this.token) return;

    try {
      const res = await CoffeeApi.getUserInfo(this.token);
      console.info(`[UserInfoPage] 接口返回: ${JSON.stringify(res)}`);

      if (res.code === 200 || res.code === 'B001') {
        let finalData: UserInfo;

        // 1. 暴力解包：不管接口给的是数组还是对象，都统一处理
        if (Array.isArray(res.data) && res.data.length > 0) {
          finalData = res.data[0];
        } else if (res.data && !Array.isArray(res.data)) {
          finalData = res.data as UserInfo;
        } else {
          return;
        }

        // 2. 【修复点】直接赋值即可 (网络请求返回的已经是新对象，能触发刷新)
        // ❌ 不要写 { ...finalData }，ArkTS 不支持对象展开
        this.userInfo = finalData;

        // 3. 同步给全局
        AppStorage.SetOrCreate('userInfo', JSON.stringify(this.userInfo));
      }
    } catch (err) {
      console.error(`[UserInfoPage] Error: ${JSON.stringify(err)}`);
    }
  }

  build() {
    Column() {
      // 导航栏
      Row() {
        Text('< 返回').fontSize(16).fontColor(Color.White).onClick(() => router.back())
        Text('个人资料').fontSize(18).fontWeight(FontWeight.Bold).fontColor(Color.White)
          .layoutWeight(1).textAlign(TextAlign.Center).margin({ right: 40 })
      }
      .width('100%').height(50).padding({ left: 15, right: 15 }).backgroundColor('#0035AA')

      Column().width('100%').height(50).backgroundColor('#0035AA')

      // 卡片区域
      Column() {
        // --- 头像 ---
        Row() {
          Text('头像').fontSize(16).fontColor('#333')
          // 增加 alt 属性：如果网络图加载失败，显示默认图
          Image(this.userInfo.userImg)
            .alt($r('app.media.home_active'))
            .width(40).height(40).borderRadius(20).backgroundColor('#EEE')
            .objectFit(ImageFit.Cover)
        }
        .width('100%').justifyContent(FlexAlign.SpaceBetween).padding({ top: 15, bottom: 15 })
        Divider()

        // --- 直接写 UI (放弃 Builder)，保证 100% 能刷新 ---

        // ID 行
        Row() {
          Text('用户id').fontSize(16).fontColor('#333')
          Text(this.userInfo.userId || '未知').fontSize(16).fontColor('#999')
        }.width('100%').justifyContent(FlexAlign.SpaceBetween).padding({ top: 15, bottom: 15 })
        Divider()

        // 手机号行
        Row() {
          Text('手机号').fontSize(16).fontColor('#333')
          Text(this.userInfo.phone || '未绑定').fontSize(16).fontColor('#999')
        }.width('100%').justifyContent(FlexAlign.SpaceBetween).padding({ top: 15, bottom: 15 })
        Divider()

        // 昵称行
        Row() {
          Text('昵称').fontSize(16).fontColor('#333')
          Text(this.userInfo.nickName || '未设置').fontSize(16).fontColor('#333')
        }.width('100%').justifyContent(FlexAlign.SpaceBetween).padding({ top: 15, bottom: 15 })
        Divider()

        // 简介行
        Column() {
          Text('简介').fontSize(16).fontColor('#333').margin({ bottom: 10 })
          // 接口返回的 desc 可能是空字符串，这里给个默认文案
          Text(this.userInfo.desc || '这个家伙很懒，什么都没写~')
            .fontSize(14).fontColor('#666').lineHeight(20)
        }
        .width('100%').alignItems(HorizontalAlign.Start).padding({ top: 15, bottom: 15 })
      }
      .width('92%').backgroundColor(Color.White).borderRadius(10)
      .padding({ left: 15, right: 15 }).margin({ top: -50 })
      .shadow({ radius: 5, color: '#1A000000', offsetY: 2 })
    }
    .width('100%').height('100%').backgroundColor('#F5F5F5')
  }
}