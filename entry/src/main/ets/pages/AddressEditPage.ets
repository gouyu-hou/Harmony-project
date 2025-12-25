import router from '@ohos.router';
import CoffeeApi, { AddressItem, ApiResponse } from '../api/CoffeeApi';
import promptAction from '@ohos.promptAction';
// 确保路径正确
import { cityData } from '../data/regionData';

interface AddressParams {
  aid?: string;
}

@Entry
@Component
struct AddressEditPage {
  @StorageLink('token') token: string = '';

  // --- 表单数据 ---
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

  // --- 选择器状态 ---
  @State isPickerShow: boolean = false;

  // 【修复报错1】定义 multiRange 状态变量
  @State multiRange: string[][] = [[], [], []];

  // 选中索引 [省, 市, 区]
  @State selectIndices: number[] = [0, 0, 0];

  // 刷新标识：用于强制刷新 UI
  @State pickerRefreshKey: number = 0;

  async aboutToAppear() {
    const params = router.getParams() as AddressParams;

    // 1. 初始化数据
    this.initPickerData();

    // 2. 编辑模式回显
    if (params && params.aid) {
      this.aid = params.aid;
      await this.fetchAddressDetail(this.aid);
    }
  }

  initPickerData() {
    // 默认加载第0个
    this.updatePickerData(0, 0);
  }

  // 【修复报错2】定义 updatePickerData 方法
  updatePickerData(pIndex: number, cIndex: number) {
    // 1. 准备省份数据
    const provinces = cityData.map(p => p.province);

    // 校验索引
    if (pIndex >= cityData.length) pIndex = 0;

    // 2. 准备城市数据
    const provinceNode = cityData[pIndex];
    // 直辖市显示空字符串
    const cities = provinceNode.cities.map(c => c.name ? c.name : "");

    // 校验索引
    if (cIndex >= provinceNode.cities.length) cIndex = 0;

    // 3. 准备区县数据
    const districts = provinceNode.cities[cIndex].districts;

    // 更新二维数组状态
    this.multiRange = [provinces, cities, districts];
  }

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

        this.locatePickerFromText();
      }
    } catch (err) {
      promptAction.showToast({ message: '获取详情失败' });
    } finally {
      this.isLoading = false;
    }
  }

  locatePickerFromText() {
    // 1. 找省
    let pIndex = cityData.findIndex(p => p.province === this.province);
    if (pIndex === -1) pIndex = 0;

    // 2. 找市
    // 临时构造当前省的城市列表进行查找
    const tempCities = cityData[pIndex].cities.map(c => c.name ? c.name : "");
    let cIndex = tempCities.findIndex(c => c === this.city);
    if (cIndex === -1) cIndex = 0;

    // 3. 找区
    const tempDistricts = cityData[pIndex].cities[cIndex].districts;
    let dIndex = tempDistricts.findIndex(d => d === this.county);
    if (dIndex === -1) dIndex = 0;

    // 更新数据源和选中项
    this.updatePickerData(pIndex, cIndex);
    this.selectIndices = [pIndex, cIndex, dIndex];

    // 强制刷新
    this.pickerRefreshKey++;
  }

  onPickerConfirm() {
    const pIndex = this.selectIndices[0];
    const cIndex = this.selectIndices[1];
    const dIndex = this.selectIndices[2];

    // 从当前 Range 中取值
    if (this.multiRange[0][pIndex] !== undefined) {
      this.province = this.multiRange[0][pIndex];
    }
    if (this.multiRange[1][cIndex] !== undefined) {
      this.city = this.multiRange[1][cIndex];
    }
    if (this.multiRange[2][dIndex] !== undefined) {
      this.county = this.multiRange[2][dIndex];
    }

    this.isPickerShow = false;
  }

  // --- 保存逻辑 ---
  async handleSave() {
    if (!this.name || !this.tel || !this.addressDetail || !this.province) {
      promptAction.showToast({ message: '请完善地址信息' });
      return;
    }

    // 2. 手机号正则校验
    const phoneRegex = /^1[3-9]\d{9}$/;
    if (!phoneRegex.test(this.tel)) {
      promptAction.showToast({ message: '手机号格式不正确' });
      return; // 校验失败，直接返回，不进行保存
    }

    const addressData: AddressItem = {
      aid: this.aid, name: this.name, tel: this.tel, province: this.province,
      city: this.city, county: this.county, addressDetail: this.addressDetail,
      areaCode: this.areaCode, postalCode: '000000', isDefault: this.isDefault ? 1 : 0
    };
    try {
      let res: ApiResponse<string>;
      if (this.aid) res = await CoffeeApi.editAddress(this.token, addressData);
      else res = await CoffeeApi.addAddress(this.token, addressData);

      if (res.code === 200 || res.code === '200' || res.msg === 'Success' || res.code === 9000 || res.code === 30000) {
        promptAction.showToast({ message: '保存成功' });
        router.back();
      } else {
        promptAction.showToast({ message: res.msg || '保存失败' });
      }
    } catch (err) { promptAction.showToast({ message: '请求异常' }); }
  }

  // --- 删除逻辑 ---
  async handleDelete() {
    if (!this.aid) return;
    try {
      const res = await CoffeeApi.deleteAddress(this.token, this.aid);
      if (res.code === 200 || res.code === '200' || res.msg === 'Success' || res.code === '10000' || res.code === 10000) {
        promptAction.showToast({ message: '删除成功' });
        router.back();
      } else { promptAction.showToast({ message: res.msg || '删除失败' }); }
    } catch (err) { promptAction.showToast({ message: '删除异常' }); }
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
              title: '提示', message: '确定删除该地址吗？',
              primaryButton: { value: '取消', action: () => {} },
              secondaryButton: { value: '删除', fontColor: 'red', action: () => this.handleDelete() }
            })
          })
        }
      }
      .width('100%').height(50).padding({ left: 15, right: 15 }).backgroundColor(Color.White)

      if (this.isLoading) {
        Column() { LoadingProgress() }.layoutWeight(1).justifyContent(FlexAlign.Center)
      } else {
        Column({ space: 15 }) {
          this.InputRow('联系人', '请填写收货人姓名', this.name, (val: string) => { this.name = val })
          this.InputRow('手机号', '请填写收货人手机号', this.tel, (val: string) => { this.tel = val }, InputType.PhoneNumber)

          // 所在地区
          Column() {
            Row() {
              Text('所在地区').width(70).fontSize(16).fontColor('#333')
              // 显示逻辑：如果 city 为空字符串，界面上就只显示 省 + 区
              Text(this.province ? `${this.province} ${this.city} ${this.county}` : '请选择所在地区')
                .layoutWeight(1).fontSize(16)
                .fontColor(this.province ? '#333' : '#999')
              Text('>').fontSize(18).fontColor('#999')
            }
            .height(50).width('100%')
            .onClick(() => {
              // 打开前确保数据一致
              if (this.selectIndices.length === 3) {
                this.updatePickerData(this.selectIndices[0], this.selectIndices[1]);
              }
              // 强制刷新一次 Key
              this.pickerRefreshKey++;
              this.isPickerShow = true;
            })
            Divider().color('#F0F0F0')
          }

          this.InputRow('详细地址', '街道、楼牌号等', this.addressDetail, (val: string) => { this.addressDetail = val })

          Row() {
            Text('设为默认地址').fontSize(16).fontColor('#333')
            Toggle({ type: ToggleType.Switch, isOn: this.isDefault })
              .selectedColor('#0035AA')
              .onChange((isOn: boolean) => { this.isDefault = isOn; })
          }
          .width('100%').justifyContent(FlexAlign.SpaceBetween).padding({ top: 5, bottom: 5 })

          Button('保存', { type: ButtonType.Normal })
            .width('100%').height(45).backgroundColor('#0035AA').borderRadius(22.5).margin({ top: 30 })
            .onClick(() => this.handleSave())
        }
        .padding(20).backgroundColor(Color.White).borderRadius(10).margin(15)
      }
    }
    .width('100%').height('100%').backgroundColor('#F5F5F5')
    // 绑定 Sheet，禁用默认 X 号
    .bindSheet($$this.isPickerShow, this.CityPickerBuilder(), {
      height: 300,
      dragBar: false,
      showClose: false, // 关键：去除叉号
      backgroundColor: Color.White,
      onDisappear: () => { this.isPickerShow = false }
    })
  }

  @Builder CityPickerBuilder() {
    Column() {
      // 自定义工具栏
      Row() {
        Text('选择地区').fontSize(18).fontWeight(FontWeight.Bold).fontColor('#333')
        Blank()
        Text('确定').fontSize(16).fontColor('#0035AA').fontWeight(FontWeight.Medium)
          .onClick(() => this.onPickerConfirm())
      }
      .width('100%').height(50).padding({ left: 20, right: 20 })
      .alignItems(VerticalAlign.Center)
      .border({ width: { bottom: 1 }, color: '#F0F0F0' })

      // Picker 组件
      TextPicker({ range: this.multiRange, selected: this.selectIndices })
      // 绑定 Key 实现强制重绘
        .id('picker_' + this.pickerRefreshKey)
        .layoutWeight(1)
        .canLoop(false)
        .onChange((value: string | string[], index: number | number[]) => {
          if (Array.isArray(index)) {
            const newP = index[0];
            const newC = index[1];
            const oldP = this.selectIndices[0];
            const oldC = this.selectIndices[1];

            // 1. 省份变动
            if (newP !== oldP) {
              this.updatePickerData(newP, 0); // 更新数据
              this.selectIndices = [newP, 0, 0]; // 重置索引

              // 延迟 20ms 强制刷新 UI，解决不跳转问题
              setTimeout(() => {
                this.pickerRefreshKey++;
              }, 20);
            }
            // 2. 城市变动
            else if (newC !== oldC) {
              this.updatePickerData(newP, newC); // 更新数据
              this.selectIndices = [newP, newC, 0]; // 重置索引

              // 延迟 20ms 强制刷新 UI
              setTimeout(() => {
                this.pickerRefreshKey++;
              }, 20);
            }
            // 3. 仅区变动
            else {
              this.selectIndices = index;
            }
          }
        })
    }
    .width('100%').height('100%')
  }

  @Builder InputRow(label: string, placeholder: string, value: string, onChange: (val: string) => void, inputType: InputType = InputType.Normal) {
    Column() {
      Row() {
        Text(label).width(70).fontSize(16).fontColor('#333')
        TextInput({ placeholder: placeholder, text: value })
          .layoutWeight(1).height(40).backgroundColor(Color.Transparent)
          .type(inputType).onChange(onChange)
      }
      Divider().color('#F0F0F0')
    }
  }
}