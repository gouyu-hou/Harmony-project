// entry/src/main/ets/pages/LoginPage.ets
import router from '@ohos.router';
import CoffeeApi from '../api/CoffeeApi';
import promptAction from '@ohos.promptAction';
import { BusinessError } from '@ohos.base'; // <--- 【必须添加这一行】

const THEME_COLOR = '#0035AA';
const TEXT_GRAY = '#999999';

@Entry
@Component
struct LoginPage {
  @State isForgotPasswordPage: boolean = false;
  @State loginPhone: string = '13434711088'; // 预填方便测试
  @State loginPassword: string = '1111';

  // 注册弹窗
  dialogController: CustomDialogController = new CustomDialogController({
    builder: RegisterDialog(),
    alignment: DialogAlignment.Bottom,
    customStyle: true,
    autoCancel: true
  })

  build() {
    Column() {
      // 顶部工具栏
      Row() {
        Row({ space: 10 }) {
          Text('☕').fontSize(30)
          Text('Luckin Coffee').fontSize(18).fontWeight(FontWeight.Bold)
        }
        Text('首页').fontSize(16).fontColor(THEME_COLOR)
          .onClick(() => router.pushUrl({ url: 'pages/MainPage' }))
      }
      .width('100%').justifyContent(FlexAlign.SpaceBetween).padding({ top: 10, bottom: 10 })

      if (this.isForgotPasswordPage) {
        this.ForgotPasswordView()
      } else {
        this.LoginView()
      }
    }
    .width('100%').height('100%').padding(30).backgroundColor(Color.White)
  }

  @Builder
  LoginView() {
    Column() {
      Column({ space: 10 }) {
        Text('欢迎回来！').fontSize(32).width('100%')
        Text('Please login to your accounts').fontSize(18).fontColor(TEXT_GRAY).width('100%')
      }.margin({ top: 40, bottom: 40 })

      InputRow({ label: '手机号', placeholder: '请输入手机号', value: $loginPhone })
      InputRow({ label: '密码', placeholder: '请输入密码', value: $loginPassword, isPassword: true })

      Text('忘记密码?').fontSize(14).fontColor('#666').width('100%').textAlign(TextAlign.End)
        .margin({ top: 15, bottom: 30 })
        .onClick(() => { this.isForgotPasswordPage = true })

      Button('登录', { type: ButtonType.Normal })
        .width('100%').height(50).backgroundColor(THEME_COLOR).borderRadius(25)
        .onClick(() => this.handleLogin())

      Button('注册', { type: ButtonType.Normal })
        .width('100%').height(50).backgroundColor(Color.White).fontColor('#333')
        .border({ width: 1, color: '#E0E0E0' }).borderRadius(25).margin({ top: 20 })
        .onClick(() => this.dialogController.open())
    }
  }

  // 登录核心逻辑
  // entry/src/main/ets/pages/LoginPage.ets

  // 修改 LoginPage.ets 里的 handleLogin 方法
  // 修改 LoginPage.ets 中的 handleLogin 方法

  async handleLogin() {
    if (!this.loginPhone || !this.loginPassword) {
      promptAction.showToast({ message: '请输入手机号和密码' });
      return;
    }

    try {
      const res = await CoffeeApi.login(this.loginPhone, this.loginPassword);

      // ... (中间获取 token 的代码保持不变) ...
      let token = res.token || (res.data && res.data.token);

      if (res.code === 200 && token) {
        // 1. 先存 Token
        AppStorage.SetOrCreate<string>('token', token);

        // 2. 【新增】立即获取用户信息并存储
        try {
          const userRes = await CoffeeApi.getUserInfo(token);
          if (userRes.code === 200 && userRes.data) {
            // 将对象转为字符串存储，方便 PersistentStorage 处理
            AppStorage.SetOrCreate<string>('userInfo', JSON.stringify(userRes.data));
          }
        } catch (e) {
          console.error('获取用户信息失败');
        }

        // 2. 尝试使用 setTimeout 将跳转推迟到下一个事件循环，
        // 有时能解决异步回调中丢失 UI 上下文的问题
        setTimeout(() => {
          console.info('[Login] 尝试跳转...');

          // 尝试改用 pushUrl 看是否能成功 (有时 replaceUrl 对栈的要求较高)
          router.pushUrl({
            url: 'pages/MainPage'
          }).catch((err: BusinessError) => {
            console.error(`[Login 跳转失败] code:${err.code}, msg:${err.message}`);
            // 如果这里报 100002，绝对是 main_pages.json 没生效
            if (err.code === 100002) {
              promptAction.showToast({ message: '请执行 Build -> Clean Project' });
            }
          });
        }, 100);

      } else {
        promptAction.showToast({ message: res.msg || '登录失败' });
      }
    } catch (err) {
      const error = err as BusinessError;
      console.error(`[Login] 异常: ${error.message}`);
      promptAction.showToast({ message: '网络请求失败，请检查网络' });
    }
  }

  @Builder ForgotPasswordView() {
    Column() {
      Text('忘记密码').fontSize(32).margin({ top: 40, bottom: 40 })
      Text('接口文档暂不支持直接重置密码，请联系管理员。').fontColor(TEXT_GRAY)
      Button('返回登录').margin({ top: 20 }).onClick(() => { this.isForgotPasswordPage = false })
    }
  }
}

// 通用输入行组件
@Component
struct InputRow {
  label: string = '';
  placeholder: string = '';
  @Link value: string;
  isPassword: boolean = false;

  build() {
    Column() {
      Row() {
        Text(this.label).width(80).fontSize(16)
        TextInput({ text: this.value, placeholder: this.placeholder })
          .layoutWeight(1).backgroundColor(Color.Transparent)
          .type(this.isPassword ? InputType.Password : InputType.Normal)
          .onChange((val) => { this.value = val })
      }.height(60)
      Divider().color('#F0F0F0')
    }
  }
}

// 注册弹窗组件
@CustomDialog
struct RegisterDialog {
  controller?: CustomDialogController;
  @State regPhone: string = '';
  @State regPass: string = '';
  @State regNick: string = '';

  build() {
    Column() {
      Row() {
        Text('快速注册').fontSize(24)
        Text('×').fontSize(30).onClick(() => this.controller?.close())
      }.width('100%').justifyContent(FlexAlign.SpaceBetween).margin({ bottom: 20 })

      InputRow({ label: '手机号', placeholder: '请输入手机号', value: $regPhone })
      InputRow({ label: '密码', placeholder: '请输入密码', value: $regPass, isPassword: true })
      InputRow({ label: '昵称', placeholder: '请输入昵称', value: $regNick })

      Button('立即注册', { type: ButtonType.Normal })
        .width('100%').height(50).backgroundColor(THEME_COLOR).borderRadius(25).margin({ top: 30 })
        .onClick(() => this.handleRegister())
    }
    .width('100%').backgroundColor(Color.White).padding(30).borderRadius({ topLeft: 20, topRight: 20 })
  }

  async handleRegister() {
    if (!this.regPhone || !this.regPass || !this.regNick) {
      promptAction.showToast({ message: '请填写完整信息' });
      return;
    }
    try {
      const res = await CoffeeApi.register(this.regPhone, this.regPass, this.regNick);
      if (String(res.code) === '200') {
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