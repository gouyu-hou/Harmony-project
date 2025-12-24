import router from '@ohos.router';
import CoffeeApi, { AddressItem, ApiResponse } from '../api/CoffeeApi'; // ✅ 1. 引入 ApiResponse
import promptAction from '@ohos.promptAction';

// 明确定义路由参数接口
interface AddressPageParams {
  editMode: boolean;
  addressData?: AddressItem;
}

@Entry
@Component
struct AddressEditPage {
  @StorageLink('token') token: string = '';

  // 页面模式
  @State isEditMode: boolean = false;

  // 表单数据
  @State aid: string = '';
  @State name: string = '';
  @State tel: string = '';
  @State province: string = '';
  @State city: string = '';
  @State county: string = '';
  @State addressDetail: string = '';
  @State isDefault: boolean = false;
  @State areaCode: string = '110101';

  aboutToAppear() {
    // 强制转换为明确的接口类型
    const params = router.getParams() as AddressPageParams;

    if (params) {
      this.isEditMode = params.editMode;

      // 如果是编辑模式，回填数据
      if (this.isEditMode && params.addressData) {
        const data = params.addressData;
        this.aid = data.aid;
        this.name = data.name;
        this.tel = data.tel;
        this.province = data.province;
        this.city = data.city;
        this.county = data.county;
        this.addressDetail = data.addressDetail;
        this.areaCode = data.areaCode;
        this.isDefault = data.isDefault === 1;
      }
    }
  }

  // 提交保存
  async handleSave() {
    if (!this.name || !this.tel || !this.addressDetail) {
      promptAction.showToast({ message: '请填写完整信息' });
      return;
    }

    const addressData: AddressItem = {
      aid: this.aid,
      name: this.name,
      tel: this.tel,
      province: this.province || '北京市',
      city: this.city || '北京市',
      county: this.county || '东城区',
      addressDetail: this.addressDetail,
      areaCode: this.areaCode,
      postalCode: '000000',
      isDefault: this.isDefault ? 1 : 0
    };

    try {
      // ✅ 2. 【核心修复】显式声明 res 的类型，消除隐式 any
      let res: ApiResponse<string>;

      if (this.isEditMode) {
        res = await CoffeeApi.editAddress(this.token, addressData);
      } else {
        res = await CoffeeApi.addAddress(this.token, addressData);
      }

      // 兼容判断
      if (res.code === 200 || res.code === 'B001' || res.msg === 'Success') {
        promptAction.showToast({ message: this.isEditMode ? '修改成功' : '添加成功' });
        router.back();
      } else {
        promptAction.showToast({ message: res.msg || '操作失败' });
      }
    } catch (err) {
      promptAction.showToast({ message: '网络请求失败' });
    }
  }

  // 删除地址
  async handleDelete() {
    try {
      const res = await CoffeeApi.deleteAddress(this.token, this.aid);
      if (res.code === 200) {
        promptAction.showToast({ message: '删除成功' });
        router.back();
      } else {
        promptAction.showToast({ message: res.msg || '删除失败' });
      }
    } catch (err) {
      promptAction.showToast({ message: '请求失败' });
    }
  }

  build() {
    Column() {
      // 导航栏
      Row() {
        Text('< 返回').fontSize(16).fontColor('#0035AA').onClick(() => router.back())
        Text(this.isEditMode ? '编辑地址' : '新增地址')
          .fontSize(18).fontWeight(FontWeight.Bold).layoutWeight(1).textAlign(TextAlign.Center).margin({ right: 40 })
      }
      .width('100%').height(50).padding({ left: 15, right: 15 }).backgroundColor(Color.White)

      // 表单区域
      Column() {
        // 显式声明回调参数 val 为 string 类型
        this.InputItem('姓名', '请输入姓名', this.name, (val: string) => { this.name = val })
        this.InputItem('手机号', '请输入手机号', this.tel, (val: string) => { this.tel = val }, InputType.PhoneNumber)

        this.InputItem('省份', '如: 广东省', this.province, (val: string) => { this.province = val })
        this.InputItem('城市', '如: 广州市', this.city, (val: string) => { this.city = val })
        this.InputItem('区县', '如: 天河区', this.county, (val: string) => { this.county = val })

        this.InputItem('详细地址', '街道、楼牌号', this.addressDetail, (val: string) => { this.addressDetail = val })

        // 设为默认地址开关
        Row() {
          Text('设为默认地址').fontSize(16).fontColor('#333')
          Toggle({ type: ToggleType.Switch, isOn: this.isDefault })
            .selectedColor('#0035AA')
            .onChange((isOn: boolean) => {
              this.isDefault = isOn;
            })
        }
        .width('100%').height(60).justifyContent(FlexAlign.SpaceBetween)
        .border({ width: { bottom: 1 }, color: '#F0F0F0' })
      }
      .padding({ left: 15, right: 15 })
      .backgroundColor(Color.White)

      // 底部按钮区
      Column({ space: 15 }) {
        Button('保存', { type: ButtonType.Normal })
          .width('100%').height(50).backgroundColor('#0035AA').borderRadius(25)
          .onClick(() => this.handleSave())

        if (this.isEditMode) {
          Button('删除地址', { type: ButtonType.Normal })
            .width('100%').height(50).backgroundColor(Color.White).fontColor('#D22028')
            .border({ width: 1, color: '#D22028' }).borderRadius(25)
            .onClick(() => {
              AlertDialog.show({
                title: '提示',
                message: '确定要删除这条地址吗？',
                primaryButton: { value: '取消', action: () => {} },
                secondaryButton: {
                  value: '删除',
                  fontColor: 'red',
                  action: () => this.handleDelete()
                }
              })
            })
        }
      }
      .padding(20)
      .margin({ top: 30 })
    }
    .width('100%').height('100%').backgroundColor('#F5F5F5')
  }

  // 自定义 Builder
  @Builder InputItem(label: string, placeholder: string, textVal: string, onChange: (val: string) => void, inputType: InputType = InputType.Normal) {
    Row() {
      Text(label).width(80).fontSize(16).fontColor('#333')
      TextInput({ text: textVal, placeholder: placeholder })
        .layoutWeight(1)
        .backgroundColor(Color.Transparent)
        .type(inputType)
        .onChange((value: string) => {
          onChange(value);
        })
    }
    .height(60)
    .border({ width: { bottom: 1 }, color: '#F0F0F0' })
    .width('100%')
  }
}