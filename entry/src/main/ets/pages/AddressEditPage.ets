import router from '@ohos.router';
import CoffeeApi, { AddressItem, ApiResponse } from '../api/CoffeeApi';
import promptAction from '@ohos.promptAction';

// ---------------------- 1. 定义省市区数据结构与模拟数据 ----------------------
interface AreaItem {
  label: string;
  value: string;
  children?: AreaItem[];
}

// 模拟数据（实际开发中通常从JSON文件或API获取）
const CITY_DATA: AreaItem[] = [
  {
    label: '北京市', value: '110000', children: [
    {
      label: '北京市', value: '110100', children: [
      { label: '东城区', value: '110101' },
      { label: '西城区', value: '110102' },
      { label: '朝阳区', value: '110105' }
    ]
    }
  ]
  },
  {
    label: '广东省', value: '440000', children: [
    {
      label: '广州市', value: '440100', children: [
      { label: '天河区', value: '440106' },
      { label: '海珠区', value: '440105' },
      { label: '越秀区', value: '440104' }
    ]
    },
    {
      label: '深圳市', value: '440300', children: [
      { label: '南山区', value: '440305' },
      { label: '福田区', value: '440304' }
    ]
    }
  ]
  },
  {
    label: '上海市', value: '310000', children: [
    {
      label: '上海市', value: '310100', children: [
      { label: '黄浦区', value: '310101' },
      { label: '徐汇区', value: '310104' }
    ]
    }
  ]
  }
];

// ---------------------- 2. 业务代码 ----------------------

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
  // 省市区直接存储文字，用于提交和显示
  @State province: string = '';
  @State city: string = '';
  @State county: string = '';

  @State addressDetail: string = '';
  @State areaCode: string = '000000';
  @State isDefault: boolean = false;
  @State isLoading: boolean = false;

  // --- 选择器相关状态 ---
  @State showAreaPicker: boolean = false; // 控制选择器显示
  @State multiRange: string[][] = [[], [], []]; // 选择器的三列数据
  @State multiSelect: number[] = [0, 0, 0]; // 当前选中的索引 [省, 市, 区]

  // 临时存储选择器选中的值，点击“确定”时才赋值给表单
  private tempProvince: string = '';
  private tempCity: string = '';
  private tempCounty: string = '';

  async aboutToAppear() {
    // 初始化选择器数据（默认加载第一条路径）
    this.initPickerData();

    const params = router.getParams() as AddressParams;
    if (params && params.aid) {
      this.aid = params.aid;
      await this.fetchAddressDetail(this.aid);
      // 获取详情后，尝试回显选择器的位置
      this.locatePickerPosition();
    }
  }

  // 初始化选择器数据（构建初始的 Range）
  initPickerData() {
    const provinces = CITY_DATA.map(item => item.label);
    const cities = CITY_DATA[0]?.children?.map(item => item.label) || [];
    const counties = CITY_DATA[0]?.children?.[0]?.children?.map(item => item.label) || [];
    this.multiRange = [provinces, cities, counties];
    this.multiSelect = [0, 0, 0];

    // 初始化临时选中值
    this.tempProvince = CITY_DATA[0].label;
    this.tempCity = CITY_DATA[0]?.children?.[0]?.label || '';
    this.tempCounty = CITY_DATA[0]?.children?.[0]?.children?.[0]?.label || '';
  }

  // 根据当前的 province/city/county 定位选择器的索引 (用于编辑模式回显)
  locatePickerPosition() {
    if (!this.province) return;

    // 1. 找省的索引
    const pIndex = CITY_DATA.findIndex(p => p.label === this.province);
    if (pIndex === -1) return; // 没找到，保持默认

    // 2. 找市的索引
    const currentProvince = CITY_DATA[pIndex];
    const cities = currentProvince.children || [];
    const cIndex = cities.findIndex(c => c.label === this.city);
    // 如果没找到市，默认选第一个
    const safeCIndex = cIndex === -1 ? 0 : cIndex;

    // 3. 找区的索引
    const currentCity = cities[safeCIndex];
    const counties = currentCity?.children || [];
    const coIndex = counties.findIndex(co => co.label === this.county);
    const safeCoIndex = coIndex === -1 ? 0 : coIndex;

    // 4. 更新 Range 和 Select
    this.multiRange = [
      CITY_DATA.map(p => p.label),
      cities.map(c => c.label),
      counties.map(co => co.label)
    ];
    this.multiSelect = [pIndex, safeCIndex, safeCoIndex];
  }

  // 处理选择器滚动变化（核心级联逻辑）
  handlePickerChange(value: string | string[], index: number | number[]) {
    // TextPicker 在多列模式下，index 返回的是 number[]，但也可能根据版本不同表现不同
    // 我们这里主要依赖传入的 index 数组
    const indices = index as number[];
    const pIndex = indices[0];
    const cIndex = indices[1];
    const coIndex = indices[2];

    // 检查是否是“省”发生了变化
    if (pIndex !== this.multiSelect[0]) {
      // 省变了 -> 更新市列表(默认第0个)，更新区列表(默认第0个)
      const newCities = CITY_DATA[pIndex]?.children || [];
      const newCounties = newCities[0]?.children || [];

      this.multiRange[1] = newCities.map(c => c.label);
      this.multiRange[2] = newCounties.map(c => c.label);
      this.multiSelect = [pIndex, 0, 0]; // 重置后两列索引

      // 更新临时值
      this.tempProvince = CITY_DATA[pIndex].label;
      this.tempCity = newCities[0]?.label || '';
      this.tempCounty = newCounties[0]?.label || '';

    } else if (cIndex !== this.multiSelect[1]) {
      // 市变了 -> 更新区列表(默认第0个)
      const currentProvince = CITY_DATA[pIndex];
      const currentCity = currentProvince.children?.[cIndex];
      const newCounties = currentCity?.children || [];

      this.multiRange[2] = newCounties.map(c => c.label);
      this.multiSelect = [pIndex, cIndex, 0]; // 重置区索引

      // 更新临时值
      this.tempProvince = currentProvince.label;
      this.tempCity = currentCity?.label || '';
      this.tempCounty = newCounties[0]?.label || '';

    } else {
      // 只有区变了
      this.multiSelect = [pIndex, cIndex, coIndex];

      const p = CITY_DATA[pIndex];
      const c = p.children?.[cIndex];
      const co = c?.children?.[coIndex];

      this.tempProvince = p.label;
      this.tempCity = c?.label || '';
      this.tempCounty = co?.label || '';
    }

    // 强制触发 UI 刷新 (ArkTS 有时对数组内部修改不敏感，重新赋值整个数组)
    this.multiRange = [...this.multiRange];
  }

  // 确认选择
  confirmAreaSelection() {
    this.province = this.tempProvince;
    this.city = this.tempCity;
    this.county = this.tempCounty;
    this.showAreaPicker = false;
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
      }
    } catch (err) {
      promptAction.showToast({ message: '获取地址详情失败' });
    } finally {
      this.isLoading = false;
    }
  }

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
      let res: ApiResponse<string>;
      if (this.aid) {
        res = await CoffeeApi.editAddress(this.token, addressData);
      } else {
        res = await CoffeeApi.addAddress(this.token, addressData);
      }

      if (res.code === 200 || res.code === '200' || res.msg === 'Success' || res.code === 9000 || res.code === 30000) {
        promptAction.showToast({ message: '保存成功' });
        router.back();
      } else {
        promptAction.showToast({ message: res.msg || '保存失败' });
      }
    } catch (err) {
      promptAction.showToast({ message: '请求异常' });
    }
  }

  async handleDelete() {
    if (!this.aid) return;
    try {
      const res = await CoffeeApi.deleteAddress(this.token, this.aid);
      if (res.code === 200 || res.code === '200' || res.msg === 'Success' || res.code === '10000' || res.code === 10000) {
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
    Stack({ alignContent: Alignment.Bottom }) { // 使用 Stack 以便放置底部弹窗
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

            // 【修改点】 替换原有的三个 InputRow 为一个选择区域
            Column() {
              Row() {
                Text('所在地区').width(70).fontSize(16).fontColor('#333')
                Row() {
                  if (this.province) {
                    Text(`${this.province} ${this.city} ${this.county}`)
                      .fontSize(16).fontColor('#333')
                  } else {
                    Text('请选择省/市/区')
                      .fontSize(16).fontColor('#999')
                  }
                }
                .layoutWeight(1)
                Blank()
                Text('>').fontSize(16).fontColor('#999')
              }
              .height(40)
              .width('100%')
              .onClick(() => {
                // 点击展开选择器
                this.showAreaPicker = true;
                // 每次打开时，重新校准一次位置，防止上次没保存的改动残留
                this.locatePickerPosition();
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

      // 【新增】自定义底部选择器弹窗
      if (this.showAreaPicker) {
        Column() {
          // 遮罩层 (点击关闭)
          Column()
            .width('100%')
            .layoutWeight(1)
            .backgroundColor('#99000000') // 半透明黑色
            .onClick(() => { this.showAreaPicker = false })

          // 选择器面板
          Column() {
            // 工具栏
            Row() {
              Text('取消').fontColor('#666').onClick(() => { this.showAreaPicker = false })
              Text('选择地区').fontWeight(FontWeight.Bold)
              Text('确定').fontColor('#0035AA').onClick(() => { this.confirmAreaSelection() })
            }
            .width('100%').height(50).padding({ left: 20, right: 20 })
            .justifyContent(FlexAlign.SpaceBetween)
            .border({ width: { bottom: 1 }, color: '#F0F0F0' })
            .backgroundColor(Color.White)

            // 级联选择器组件
            TextPicker({ range: this.multiRange, selected: this.multiSelect })
              .layoutWeight(1)
              .width('100%')
              .backgroundColor(Color.White)
              .onChange((value: string | string[], index: number | number[]) => {
                this.handlePickerChange(value, index);
              })
          }
          .height(300) // 弹窗高度
          .width('100%')
          .backgroundColor(Color.White)
          .transition({ type: TransitionType.Insert, translate: { y: 300 } }) // 简单的进场动画
        }
        .width('100%').height('100%')
        // 设置 zIndex 确保浮在最上层
        .zIndex(999)
      }
    }
  }

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