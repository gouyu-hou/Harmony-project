// entry/src/main/ets/pages/SecurityPage.ets
import router from '@ohos.router';
import promptAction from '@ohos.promptAction';
import CoffeeApi from '../api/CoffeeApi';

@Entry
@Component
struct SecurityPage {
  @StorageLink('token') token: string = '';

  // 修改密码弹窗
  pwdDialog: CustomDialogController = new CustomDialogController({
    builder: ChangePasswordDialog(),
    alignment: DialogAlignment.Bottom,
    customStyle: true
  })

  // 注销确认弹窗
  deleteDialog: CustomDialogController = new CustomDialogController({
    builder: ConfirmDialog({
      title: '注销账号',
      content: '是否确认注销账号，一旦确认无法恢复！',
      onConfirm: async () => {
        // ✅ 完善点 1：调用注销接口
        // 在初始化时直接获取 AppStorage 中的 token 比较安全
        const token = AppStorage.Get<string>('token') || '';

        if (!token) {
          router.pushUrl({ url: 'pages/LoginPage' });
          return;
        }

        try {
          const res = await CoffeeApi.destroyAccount(token);
          if (res.code === 200 || res.code === '200') {
            promptAction.showToast({ message: '注销成功' });

            // 清除本地存储的 Token 和 用户信息
            AppStorage.SetOrCreate('token', '');
            AppStorage.SetOrCreate('userInfo', '{}');

            // 清空路由栈并跳转登录页
            router.clear();
            router.replaceUrl({ url: 'pages/LoginPage' });
          } else {
            promptAction.showToast({ message: res.msg || '注销失败' });
          }
        } catch (err) {
          promptAction.showToast({ message: '网络异常，请稍后重试' });
        }
      }
    }),
    alignment: DialogAlignment.Center,
    autoCancel: true
  })

  build() {
    Column() {
      // 1. 顶部
      Row() {
        Text('< 返回').fontSize(16).fontColor('#0035AA').onClick(() => router.back())
        Text('安全中心').fontSize(18).fontWeight(FontWeight.Bold).layoutWeight(1).textAlign(TextAlign.Center).margin({ right: 40 })
      }
      .width('100%').height(50).padding({ left: 15, right: 15 }).backgroundColor(Color.White)

      // 蓝色背景装饰
      Column().width('100%').height(50).backgroundColor('#0035AA')

      // 2. 菜单区域
      Column() {
        this.MenuItem('修改密码', () => { this.pwdDialog.open() })
        Divider().color('#F0F0F0')
        this.MenuItem('注销账号', () => { this.deleteDialog.open() })
      }
      .backgroundColor(Color.White).borderRadius(8)
      .margin({ left: 15, right: 15, top: -30 }) // 上移
      .padding({ top: 5, bottom: 5 })

      Blank()

      // 3. 退出登录按钮
      Button('退出登录', { type: ButtonType.Normal })
        .width('90%').height(50).backgroundColor('#0035AA').borderRadius(25).fontSize(18)
        .margin({ bottom: 30 })
        .onClick(() => {
          // 清除路由栈并回登录页
          AppStorage.SetOrCreate('token', '');
          AppStorage.SetOrCreate('userInfo', '{}');
          router.clear();
          router.replaceUrl({ url: 'pages/LoginPage' });
        })
    }
    .width('100%').height('100%').backgroundColor('#F5F5F5')
  }

  @Builder MenuItem(title: string, onClick: () => void) {
    Row() {
      Text(title).fontSize(16).fontColor('#333')
      Text('>').fontSize(16).fontColor('#999')
    }
    .width('100%').height(55).justifyContent(FlexAlign.SpaceBetween).padding({ left: 15, right: 15 })
    .onClick(onClick)
  }
}

// --- 弹窗组件 ---

// 1. 修改密码弹窗
@CustomDialog
struct ChangePasswordDialog {
  controller?: CustomDialogController;
  @State oldPwd: string = '';
  @State newPwd: string = '';

  // 获取 Token 用于接口请求
  @StorageLink('token') token: string = '';

  build() {
    Column() {
      // 标题 + 关闭
      Row() {
        Text('修改密码').fontSize(18).fontWeight(FontWeight.Bold)
        Text('×').fontSize(24).fontColor('#999').onClick(() => this.controller?.close())
      }
      .width('100%').justifyContent(FlexAlign.SpaceBetween).margin({ bottom: 20 })

      PwdInputItem({ label: '旧密码', placeholder: '请输入旧密码', text: $oldPwd })
      PwdInputItem({ label: '新密码', placeholder: '请输入新密码', text: $newPwd })

      // 确认按钮
      Button('确认修改', { type: ButtonType.Normal })
        .width('100%').height(45).backgroundColor('#0035AA').borderRadius(22).margin({ top: 20 })
        .onClick(async () => {
          // ✅ 完善点 2：调用修改密码接口
          if (!this.oldPwd || !this.newPwd) {
            promptAction.showToast({ message: '请输入完整的密码信息' });
            return;
          }

          // 2. 密码长度校验
          if (this.newPwd.length < 4) {
            promptAction.showToast({ message: '密码必须大于3位数' });
            return;
          }

          // 3. 新旧密码一致性校验
          if (this.oldPwd === this.newPwd) {
            promptAction.showToast({ message: '与原密码一致，修改失败' });
            // 直接 return，不执行跳转逻辑
            return;
          }

          try {
            const res = await CoffeeApi.updatePassword(this.token, this.oldPwd, this.newPwd);

            if (res.code === 200 || res.code === '200') {
              promptAction.showToast({ message: '修改成功，请重新登录' });
              this.controller?.close();

              // 修改密码后通常需要重新登录
              AppStorage.SetOrCreate('token', '');
              AppStorage.SetOrCreate('userInfo', '{}');
              router.clear();
              router.replaceUrl({ url: 'pages/LoginPage' });
            } else {
              promptAction.showToast({ message: res.msg || '修改失败' });
            }
          } catch (err) {
            promptAction.showToast({ message: '请求异常，请稍后重试' });
          }
        })
    }
    .width('100%').backgroundColor(Color.White).padding(20)
    .borderRadius({ topLeft: 16, topRight: 16 })
  }
}

// 独立的输入框组件
@Component
struct PwdInputItem {
  label: string = '';
  placeholder: string = '';
  @Link text: string;

  build() {
    Row() {
      Text(this.label).width(60).fontSize(16).fontColor('#333')
      TextInput({ text: this.text, placeholder: this.placeholder })
        .layoutWeight(1)
        .backgroundColor(Color.Transparent)
        .type(InputType.Password) // 设置为密码输入模式
        .onChange((value) => {
          this.text = value;
        })
      // 这里的图标可以根据需求添加点击切换明文/密文逻辑，目前仅作展示
      // Image($r('app.media.denglu_mimakejian'))
      //   .width(20).height(20).opacity(0.5)
    }
    .height(50).border({ width: { bottom: 1 }, color: '#F0F0F0' })
  }
}

// 2. 通用确认弹窗
@CustomDialog
struct ConfirmDialog {
  controller?: CustomDialogController;
  title: string = '';
  content: string = '';
  onConfirm: () => void = () => {};

  build() {
    Column() {
      Text(this.title).fontSize(18).fontWeight(FontWeight.Bold).margin({ top: 20, bottom: 10 })
      Text(this.content).fontSize(14).fontColor('#666').margin({ bottom: 20 }).padding({ left: 20, right: 20 })

      Divider().color('#F0F0F0')

      Row() {
        Text('取消').layoutWeight(1).textAlign(TextAlign.Center).height(50).fontColor('#666')
          .onClick(() => this.controller?.close())
        Divider().vertical(true).height(50).color('#F0F0F0')
        Text('确认').layoutWeight(1).textAlign(TextAlign.Center).height(50).fontColor('#0035AA')
          .onClick(() => {
            this.onConfirm();
            this.controller?.close();
          })
      }
    }
    .width('80%').backgroundColor(Color.White).borderRadius(12)
  }
}