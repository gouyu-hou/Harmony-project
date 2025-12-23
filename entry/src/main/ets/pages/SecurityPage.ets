import router from '@ohos.router';

@Entry
@Component
struct SecurityPage {
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
      content: '是否确认注销号，一旦确认无法恢复！',
      onConfirm: () => {
        // 执行注销逻辑，跳转回登录
        router.clear();
        router.pushUrl({ url: 'pages/LoginPage' })
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

      // 【修改点 1】将 Spacer() 改为 Blank()，用于自动填充剩余空间
      Blank()

      // 3. 退出登录按钮
      Button('退出登录', { type: ButtonType.Normal })
        .width('90%').height(50).backgroundColor('#0035AA').borderRadius(25).fontSize(18)
        .margin({ bottom: 30 })
        .onClick(() => {
          // 清除路由栈并回登录页
          router.clear();
          router.pushUrl({ url: 'pages/LoginPage' });
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

  build() {
    Column() {
      // 标题 + 关闭
      Row() {
        Text('修改密码').fontSize(18).fontWeight(FontWeight.Bold)
        Text('×').fontSize(24).fontColor('#999').onClick(() => this.controller?.close())
      }
      .width('100%').justifyContent(FlexAlign.SpaceBetween).margin({ bottom: 20 })

      // 【修改点 2】使用提取出来的组件，并传递状态引用 ($oldPwd)
      // 这样输入的内容才能保存到变量里
      PwdInputItem({ label: '旧密码', placeholder: '输入密码', text: $oldPwd })
      PwdInputItem({ label: '新密码', placeholder: '输入密码', text: $newPwd })

      // 确认按钮
      Button('确认修改', { type: ButtonType.Normal })
        .width('100%').height(45).backgroundColor('#0035AA').borderRadius(22).margin({ top: 20 })
        .onClick(() => {
          // 这里可以打印一下，验证输入是否成功
          console.info(`修改密码: 旧=${this.oldPwd}, 新=${this.newPwd}`);
          this.controller?.close();
        })
    }
    .width('100%').backgroundColor(Color.White).padding(20)
    .borderRadius({ topLeft: 16, topRight: 16 })
  }
}

// 【修改点 3】将原来的 @Builder PwdInput 提取为独立的 Component
// 这样可以使用 @Link 实现双向绑定
@Component
struct PwdInputItem {
  label: string = '';
  placeholder: string = '';
  @Link text: string; // 接收父组件的状态

  build() {
    Row() {
      Text(this.label).width(60).fontSize(16).fontColor('#333')
      TextInput({ text: this.text, placeholder: this.placeholder })
        .layoutWeight(1)
        .backgroundColor(Color.Transparent)
        .onChange((value) => {
          this.text = value; // 更新状态
        })
      // 确保你有这个图片资源，没有的话可以用 Text('👁️') 代替
      Image($r('app.media.denglu_mimakejian'))
        .width(20).height(20).opacity(0.5)
    }
    .height(50).border({ width: { bottom: 1 }, color: '#F0F0F0' })
  }
}


// 2. 通用确认弹窗 (保持不变，已经没有语法错误)
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