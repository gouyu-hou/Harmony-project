import { AbilityConstant, ConfigurationConstant, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';

const DOMAIN = 0x0000;

export default class EntryAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    try {
      this.context.getApplicationContext().setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET);
    } catch (err) {
      hilog.error(DOMAIN, 'testTag', 'Failed to set colorMode. Cause: %{public}s', JSON.stringify(err));
    }

    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onCreate');

    // ================== 【新增】初始化持久化数据 ==================
    // 1. 如果本地磁盘没有 'token'，则初始化为空字符串
    PersistentStorage.PersistProp('token', '');

    // 2. 如果本地没有 'userInfo' (存用户头像昵称)，初始化为空 JSON 字符串
    PersistentStorage.PersistProp('userInfo', '{}');
  }

  onDestroy(): void {
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onDestroy');
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    // Main window is created, set main page for this ability
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onWindowStageCreate');

    // ================== 【新增】登录状态检查 ==================
    // 获取当前 Token (AppStorage 会自动从 PersistentStorage 读取磁盘数据)
    const token = AppStorage.Get<string>('token');

    // 默认跳转登录页
    let entryUrl = 'pages/LoginPage';

    // 如果 Token 存在且不为空，说明用户已登录，直接进首页
    if (token && token.trim() !== '') {
      console.info('[EntryAbility] 检测到 Token，自动跳转首页');
      entryUrl = 'pages/MainPage';
    } else {
      console.info('[EntryAbility] 无 Token，跳转登录页');
    }

    windowStage.loadContent(entryUrl, (err) => {
      if (err.code) {
        hilog.error(DOMAIN, 'testTag', 'Failed to load the content. Cause: %{public}s', JSON.stringify(err));
        return;
      }
      hilog.info(DOMAIN, 'testTag', 'Succeeded in loading the content.');
    });
  }

  onWindowStageDestroy(): void {
    // Main window is destroyed, release UI related resources
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onWindowStageDestroy');
  }

  onForeground(): void {
    // Ability has brought to foreground
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onForeground');
  }

  onBackground(): void {
    // Ability has back to background
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onBackground');
  }
}