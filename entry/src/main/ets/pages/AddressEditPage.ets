import router from '@ohos.router';
import CoffeeApi, { AddressItem, ApiResponse } from '../api/CoffeeApi';
import promptAction from '@ohos.promptAction';

// 【修复1】定义一个明确的接口，替代对象字面量类型
interface AddressParams {
  aid?: string;
}

@Entry
@Component
struct AddressEditPage {
  @StorageLink('token') token: string = '';

  // 表单状态
  @State aid: string = '';
  @State name: string = '';
  @State tel: string = '';
  @State province: string = '';
  @State city: string = '';
  @State county: string = '';
  @State addressDetail: string = '';
  @State areaCode: string = '000000';
  @State isDefault: boolean = false;

  @State isLoading: boolean = false;

  async aboutToAppear() {
    // 【修复1】使用接口 AddressParams 进行类型断言
    const params = router.getParams() as AddressParams;
    if (params && params.aid) {
      this.aid = params.aid;
      this.fetchAddressDetail(this.aid);
    }
  }

  // 获取详情（编辑模式）
  async fetchAddressDetail(aid: string) {
    this.isLoading = true;
    try {
      const res = await CoffeeApi.findAddressByAid(this.token, aid);
      if ((res.code === 200 || res.code === '200') && res.data && res.data.length > 0) {
        const detail = res.data[0];
        this.name = detail.name;
        this.tel = detail.tel;
        this.province = detail.province;
        this.city = detail.city;
        this.county = detail.county;
        this.addressDetail = detail.addressDetail;
        this.areaCode = detail.areaCode;
        this.isDefault = detail.isDefault === 1;
      }
    } catch (err) {
      promptAction.showToast({ message: '获取地址详情失败' });
    } finally {
      this.isLoading = false;
    }
  }

  // 保存（新增或修改）
  async handleSave() {
    if (!this.name || !this.tel || !this.addressDetail || !this.province) {
      promptAction.showToast({ message: '请完善地址信息' });
      return;
    }

    const addressData: AddressItem = {
      aid: this.aid,
      name: this.name,
      tel: this.tel,
      province: this.province,
      city: this.city,
      county: this.county,
      addressDetail: this.addressDetail,
      areaCode: this.areaCode,
      postalCode: '000000',
      isDefault: this.isDefault ? 1 : 0
    };

    try {
      // 【修复2】显式指定 res 的类型，避免隐式 any
      let res: ApiResponse<string>;

      if (this.aid) {
        // 编辑模式
        res = await CoffeeApi.editAddress(this.token, addressData);
      } else {
        // 新增模式
        res = await CoffeeApi.addAddress(this.token, addressData);
      }

      if (res.code === 200 || res.code === '200' || res.msg === 'Success') {
        promptAction.showToast({ message: '保存成功' });
        router.back();
      } else {
        promptAction.showToast({ message: res.msg || '保存失败' });
      }
    } catch (err) {
      promptAction.showToast({ message: '请求异常' });
    }
  }

  // 删除地址
  async handleDelete() {
    if (!this.aid) return;

    try {
      const res = await CoffeeApi.deleteAddress(this.token, this.aid);
      if (res.code === 200 || res.code === '200' || res.msg === 'Success') {
        promptAction.showToast({ message: '删除成功' });
        router.back();
      } else {
        promptAction.showToast({ message: res.msg || '删除失败' });
      }
    } catch (err) {
      promptAction.showToast({ message: '删除异常' });
    }
  }

  build() {
    Column() {
      // 导航栏
      Row() {
        Text('<').fontSize(24).fontColor('#333').padding({ right: 20 }).onClick(() => router.back())
        Text(this.aid ? '编辑地址' : '新增地址').fontSize(18).fontWeight(FontWeight.Bold)
        Blank()
        if (this.aid) {
          Text('删除').fontSize(14).fontColor('#D22028').onClick(() => {
            AlertDialog.show({
              title: '提示',
              message: '确定删除该地址吗？',
              primaryButton: { value: '取消', action: () => {} },
              secondaryButton: { value: '删除', fontColor: 'red', action: () => this.handleDelete() }
            })
          })
        }
      }
      .width('100%').height(50).padding({ left: 15, right: 15 }).backgroundColor(Color.White)

      // 表单区域
      if (this.isLoading) {
        Column() { LoadingProgress() }.layoutWeight(1).justifyContent(FlexAlign.Center)
      } else {
        Column({ space: 15 }) {

          this.InputRow('联系人', '请填写收货人姓名', this.name, (val: string) => { this.name = val })
          this.InputRow('手机号', '请填写收货人手机号', this.tel, (val: string) => { this.tel = val }, InputType.PhoneNumber)

          this.InputRow('省份', '如：广东省', this.province, (val: string) => { this.province = val })
          this.InputRow('城市', '如：广州市', this.city, (val: string) => { this.city = val })
          this.InputRow('区县', '如：天河区', this.county, (val: string) => { this.county = val })

          this.InputRow('详细地址', '街道、楼牌号等', this.addressDetail, (val: string) => { this.addressDetail = val })

          // 默认地址开关
          Row() {
            Text('设为默认地址').fontSize(16).fontColor('#333')
            Toggle({ type: ToggleType.Switch, isOn: this.isDefault })
              .selectedColor('#0035AA')
              .onChange((isOn: boolean) => { this.isDefault = isOn; })
          }
          .width('100%').justifyContent(FlexAlign.SpaceBetween)
          .padding({ top: 5, bottom: 5 })

          Button('保存', { type: ButtonType.Normal })
            .width('100%').height(45).backgroundColor('#0035AA').borderRadius(22.5).margin({ top: 30 })
            .onClick(() => this.handleSave())

        }
        .padding(20).backgroundColor(Color.White).borderRadius(10).margin(15)
      }
    }
    .width('100%').height('100%').backgroundColor('#F5F5F5')
  }

  // InputRow 组件保持不变，InputType 是系统枚举，不会报错
  @Builder InputRow(label: string, placeholder: string, value: string, onChange: (val: string) => void, inputType: InputType = InputType.Normal) {
    Column() {
      Row() {
        Text(label).width(70).fontSize(16).fontColor('#333')
        TextInput({ placeholder: placeholder, text: value })
          .layoutWeight(1)
          .height(40)
          .backgroundColor(Color.Transparent)
          .type(inputType)
          .onChange(onChange)
      }
      Divider().color('#F0F0F0')
    }
  }
}