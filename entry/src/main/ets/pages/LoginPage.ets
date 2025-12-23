import router from '@ohos.router';
import CoffeeApi from '../api/CoffeeApi';
import promptAction from '@ohos.promptAction'; // 用于弹窗提示

const THEME_COLOR = '#0035AA';
const TEXT_GRAY = '#999999';

@Entry
@Component
struct LoginPage {
  // 状态管理
  @State isForgotPasswordPage: boolean = false;
  @State loginPhone: string = '13800138000'; // 方便测试预填
  @State loginPassword: string = '123456';

  @State fpPhone: string = '';
  @State fpNewPassword: string = '';
  @State fpEmail: string = '';
  @State fpVerifyCode: string = '';

  // 注册弹窗控制器
  dialogController: CustomDialogController = new CustomDialogController({
    builder: RegisterDialog(),
    alignment: DialogAlignment.Bottom,
    customStyle: true,
    autoCancel: true
  })

  build() {
    Column() {
      // --- 顶部导航栏 ---
      Row() {
        Row({ space: 10 }) {
          // 这里可以换成你的 Logo 图片
          Text('☕').fontSize(30)
          Text('Luckin Coffee')
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor('#333')
        }

        // 右上角“首页”按钮
        Text('首页')
          .fontSize(16)
          .fontColor(THEME_COLOR)
          .fontWeight(FontWeight.Medium)
          .onClick(() => {
            router.pushUrl({ url: 'pages/MainPage' });
          })
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .padding({ top: 10, bottom: 10 })

      // --- 页面内容切换 ---
      if (this.isForgotPasswordPage) {
        this.ForgotPasswordView()
      } else {
        this.LoginView()
      }
    }
    .width('100%')
    .height('100%')
    .padding({ left: 30, right: 30, top: 20 })
    .backgroundColor(Color.White)
  }

  // --- 登录视图 ---
  @Builder
  LoginView() {
    Column() {
      Column({ space: 10 }) {
        Text('欢迎回来！')
          .fontSize(32)
          .fontWeight(FontWeight.Regular)
          .width('100%')
          .fontColor('#333')
        Text('Please login to your accounts')
          .fontSize(18)
          .fontColor(TEXT_GRAY)
          .width('100%')
      }
      .margin({ top: 40, bottom: 40 })

      Column({ space: 0 }) {
        InputRow({ label: '手机号', placeholder: '请输入手机号', value: $loginPhone })
        InputRow({ label: '密码', placeholder: '请输入密码', value: $loginPassword, isPassword: true })

        Text('忘记密码?')
          .fontSize(14)
          .fontColor('#666')
          .width('100%')
          .textAlign(TextAlign.End)
          .margin({ top: 15, bottom: 30 })
          .onClick(() => {
            animateTo({ duration: 300 }, () => {
              this.isForgotPasswordPage = true;
            })
          })
      }

      Column({ space: 20 }) {
        // --- 登录按钮逻辑修改 ---
        Button('登录', { type: ButtonType.Normal })
          .width('100%')
          .height(50)
          .backgroundColor(THEME_COLOR)
          .borderRadius(25)
          .fontSize(18)
          .onClick(async () => {
            await this.handleLogin();
          })

        Button('注册', { type: ButtonType.Normal })
          .width('100%')
          .height(50)
          .backgroundColor(Color.White)
          .border({ width: 1, color: '#E0E0E0' })
          .borderRadius(25)
          .fontColor('#333')
          .fontSize(18)
          .onClick(() => {
            if (this.dialogController != null) {
              this.dialogController.open();
            }
          })
      }
    }
  }

  // 处理登录逻辑
  // --- 替换 LoginPage.ets 中的 handleLogin 方法 ---
  async handleLogin() {
    if (!this.loginPhone || !this.loginPassword) {
      promptAction.showToast({ message: '请输入手机号和密码' });
      return;
    }

    try {
      console.info(`[Login Debug] 正在尝试登录... 账号:${this.loginPhone}`);

      // 调用 API (此时 res 被推断为 ApiResponse<LoginData>)
      const res = await CoffeeApi.login(this.loginPhone, this.loginPassword);

      console.info('[Login Debug] 接口返回结果:', JSON.stringify(res));

      // 获取 Token (兼容两种常见格式)
      // 优先取外层 token
      let token: string | undefined = res.token;

      // 如果外层没有，且 data 存在，且 data.token 存在
      // 【关键修改】：这里不需要 as any 了，因为 LoginData 接口里定义了 token?
      if (!token && res.data && res.data.token) {
        token = res.data.token;
      }

      // 验证 Token 是否存在且不为空字符串
      if (String(res.code) === '200' && token) {
        console.info('[Login Debug] 登录成功，Token:', token);
        promptAction.showToast({ message: '登录成功' });

        // 保存 Token 并跳转
        AppStorage.SetOrCreate('token', token);
        router.pushUrl({ url: 'pages/MainPage' });

      } else {
        const errorMsg = res.msg || '登录失败，请检查账号密码';
        console.warn('[Login Debug] 登录失败:', errorMsg);
        promptAction.showToast({ message: errorMsg });
      }

    } catch (err) {
      // 这里的 err 类型是不确定的，JSON.stringify 是安全的，但不要直接 err.message
      console.error('[Login Debug] 网络或代码异常');
      promptAction.showToast({ message: '请求失败，请检查网络' });
    }
  }

  // --- 忘记密码视图 ---
  @Builder
  ForgotPasswordView() {
    Column() {
      Column({ space: 10 }) {
        Text('忘记密码!')
          .fontSize(32).fontWeight(FontWeight.Regular).width('100%').fontColor('#333')
      }
      .margin({ top: 40, bottom: 40 })

      Column({ space: 0 }) {
        InputRow({ label: '手机号', placeholder: '手机号', value: $fpPhone })
        InputRow({ label: '新密码', placeholder: '新密码', value: $fpNewPassword, isPassword: true })
        // ... 其他输入略 ...
      }

      Text('已有账号，立即登录')
        .fontSize(14).fontColor('#333').width('100%').textAlign(TextAlign.End).margin({ top: 15, bottom: 40 })
        .onClick(() => {
          animateTo({ duration: 300 }, () => { this.isForgotPasswordPage = false; })
        })

      Button('提 交', { type: ButtonType.Normal })
        .width('100%').height(50).backgroundColor(THEME_COLOR).borderRadius(25).fontSize(18)
    }
  }
}

// --- 通用组件 ---
@Component
struct InputRow {
  label: string = '';
  placeholder: string = '';
  @Link value: string;
  isPassword: boolean = false;
  @State showPass: boolean = false;

  build() {
    Column() {
      Row() {
        Text(this.label).width(80).fontSize(16).fontColor('#333')
        TextInput({ text: this.value, placeholder: this.placeholder })
          .layoutWeight(1)
          .backgroundColor(Color.Transparent)
          .type(this.isPassword && !this.showPass ? InputType.Password : InputType.Normal)
          .onChange((val) => { this.value = val; })
          .placeholderColor(TEXT_GRAY)

        // if (this.isPassword) {
        //   Text(this.showPass ? '👁️' : '🙈') // 简单图标代替
        //     .margin({ right: 10, left: 10 })
        //     .onClick(() => { this.showPass = !this.showPass; })
        // }
      }
      .height(60)
      .width('100%')
      .alignItems(VerticalAlign.Center)
      Divider().color('#F0F0F0').strokeWidth(1)
    }
  }
}

// --- 注册弹窗组件 ---
@CustomDialog
struct RegisterDialog {
  controller?: CustomDialogController = undefined;
  @State regPhone: string = '';
  @State regPass: string = '';
  @State regNick: string = '';

  build() {
    Column() {
      Row() {
        Text('注册').fontSize(24).fontColor('#333')
        Text('×').fontSize(30).fontColor('#999999').onClick(() => { this.controller?.close() })
      }
      .width('100%').justifyContent(FlexAlign.SpaceBetween).margin({ bottom: 20 })

      Column() {
        InputRow({ label: '手机号', placeholder: '请输入手机号', value: $regPhone })
        InputRow({ label: '密码', placeholder: '请输入密码', value: $regPass, isPassword: true })
        InputRow({ label: '昵称', placeholder: '请输入昵称', value: $regNick })
      }
      .margin({ bottom: 30 })

      Button('注册', { type: ButtonType.Normal })
        .width('100%').height(50).backgroundColor('#0035AA').borderRadius(25).fontSize(18)
        .onClick(async () => {
          await this.handleRegister();
        })
    }
    .width('100%').backgroundColor(Color.White).padding(30).borderRadius({ topLeft: 20, topRight: 20 })
  }

  // 注册逻辑
  async handleRegister() {
    if (!this.regPhone || !this.regPass || !this.regNick) {
      promptAction.showToast({ message: '请填写完整信息' });
      return;
    }

    try {
      const res = await CoffeeApi.register(this.regPhone, this.regPass, this.regNick);
      console.info('注册结果:', JSON.stringify(res));

      if (res.code == 200) {
        promptAction.showToast({ message: '注册成功，请登录' });
        this.controller?.close();
      } else {
        promptAction.showToast({ message: res.msg || '注册失败' });
      }
    } catch (err) {
      promptAction.showToast({ message: '网络请求失败' });
    }
  }
}