import router from '@ohos.router';

// 定义接口
interface AddressModel {
  id: number;
  name: string;
  phone: string;
  address: string;
  isDefault: boolean;
}

interface RouterParams {
  editMode: boolean;
  data?: AddressModel;
}

@Entry
@Component
struct AddressEditPage {
  @State isEditMode: boolean = false;
  @State name: string = '';
  @State phone: string = '';
  @State region: string = '';
  @State detail: string = '';
  @State postCode: string = '';
  @State isDefault: boolean = false;

  // 地区选择弹窗
  regionDialog: CustomDialogController = new CustomDialogController({
    builder: RegionPicker({
      onConfirm: (val: string) => { this.region = val }
    }),
    alignment: DialogAlignment.Bottom,
    customStyle: true
  })

  aboutToAppear() {
    const params = router.getParams() as RouterParams;
    if (params && params.editMode && params.data) {
      this.isEditMode = true;
      const data = params.data;
      this.name = data.name;
      this.phone = data.phone;
      this.detail = data.address;
      this.isDefault = data.isDefault;
      this.region = "广东省/广州市/天河区";
    }
  }

  build() {
    Column() {
      // 1. 顶部
      Row() {
        Text('< 返回')
          .fontSize(16).fontColor('#0035AA')
          .onClick(() => router.back())
        Text(this.isEditMode ? '编辑地址' : '新增地址')
          .fontSize(18).fontWeight(FontWeight.Bold)
          .layoutWeight(1).textAlign(TextAlign.Center).margin({ right: 40 })
      }
      .width('100%').height(50).padding({ left: 15, right: 15 }).backgroundColor(Color.White)

      // 2. 表单区域
      Column() {
        // 修改点：InputItem 现在是一个组件，所以可以用 $name 传参
        InputItem({ label: '姓名', placeholder: '姓名', value: $name })
        Divider().color('#F0F0F0')

        InputItem({ label: '电话', placeholder: '电话', value: $phone })
        Divider().color('#F0F0F0')

        // 地区选择
        Row() {
          Text('地区').width(80).fontSize(16).fontColor('#333')
          Text(this.region || '地区')
            .layoutWeight(1).fontSize(16)
            .fontColor(this.region ? '#333' : '#999')
          Text('>').fontSize(16).fontColor('#999')
        }
        .height(55).width('100%').alignItems(VerticalAlign.Center)
        .onClick(() => { this.regionDialog.open() })

        Divider().color('#F0F0F0')
        InputItem({ label: '详细地址', placeholder: '详细地址', value: $detail })
        Divider().color('#F0F0F0')
        InputItem({ label: '邮政编码', placeholder: '邮政编码', value: $postCode })
      }
      .backgroundColor(Color.White).borderRadius(8).padding({ left: 15, right: 15 }).margin(10)

      // 3. 默认开关
      Row() {
        Text('设为默认收货地址').fontSize(16).fontColor('#333')
        Toggle({ type: ToggleType.Switch, isOn: this.isDefault })
          .selectedColor('#0035AA')
          .onChange((isOn) => { this.isDefault = isOn })
      }
      .width('95%').height(55).backgroundColor(Color.White).borderRadius(8)
      .padding({ left: 15, right: 15 }).justifyContent(FlexAlign.SpaceBetween).margin({ top: 10 })

      // 修改点：使用 Blank() 替代 Spacer()，占据剩余空间
      Blank()

      // 4. 保存按钮
      Button('保存', { type: ButtonType.Normal })
        .width('90%').height(50).backgroundColor('#0035AA').borderRadius(25).fontSize(18)
        .margin({ bottom: 20 })
        .onClick(() => {
          router.back();
        })
    }
    .width('100%').height('100%').backgroundColor('#F5F5F5')
  }
}

// 修改点：将 InputItem 提取为独立的 Component
@Component
struct InputItem {
  label: string = '';
  placeholder: string = '';
  // 使用 @Link 接收父组件传来的状态（实现双向绑定）
  @Link value: string;

  build() {
    Row() {
      Text(this.label).width(80).fontSize(16).fontColor('#333')
      TextInput({ text: this.value, placeholder: this.placeholder })
        .layoutWeight(1).backgroundColor(Color.Transparent)
        .onChange((v) => { this.value = v })
    }
    .height(55).width('100%')
  }
}

// 地区选择弹窗
@CustomDialog
struct RegionPicker {
  controller?: CustomDialogController;
  onConfirm: (val: string) => void = () => {};

  build() {
    Column() {
      Row() {
        Text('取消').fontColor('#999').onClick(() => this.controller?.close())
        Text('确认').fontColor('#0035AA').onClick(() => {
          this.onConfirm('广东省/广州市/天河区');
          this.controller?.close();
        })
      }
      .width('100%').justifyContent(FlexAlign.SpaceBetween).padding(15)

      Row() {
        Column() { Text('广东省').fontSize(16).fontWeight(FontWeight.Bold).padding(10) }
        Column() { Text('广州市').fontSize(16).fontWeight(FontWeight.Bold).padding(10) }
        Column() { Text('天河区').fontSize(16).fontWeight(FontWeight.Bold).padding(10) }
      }
      .width('100%').justifyContent(FlexAlign.SpaceAround).height(200)
    }
    .width('100%').backgroundColor(Color.White).borderRadius({ topLeft: 16, topRight: 16 })
  }
}