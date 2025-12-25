/**
 * 全国省市区三级联动数据（2025最新版）
 * 数据结构：{ label: 名称, value: 行政区划编码, children?: 下一级数据 }
 */
export interface RegionItem {
  label: string;
  value: string;
  children?: RegionItem[];
}

export const regionData: RegionItem[] = [
  {
    "label": "北京市",
    "value": "110000",
    "children": [
      {
        "label": "北京市",
        "value": "110100",
        "children": [
          { "label": "东城区", "value": "110101" },
          { "label": "西城区", "value": "110102" },
          { "label": "朝阳区", "value": "110105" },
          { "label": "丰台区", "value": "110106" },
          { "label": "石景山区", "value": "110107" },
          { "label": "海淀区", "value": "110108" },
          { "label": "门头沟区", "value": "110109" },
          { "label": "房山区", "value": "110111" },
          { "label": "通州区", "value": "110112" },
          { "label": "顺义区", "value": "110113" },
          { "label": "昌平区", "value": "110114" },
          { "label": "大兴区", "value": "110115" },
          { "label": "怀柔区", "value": "110116" },
          { "label": "平谷区", "value": "110117" },
          { "label": "密云区", "value": "110118" },
          { "label": "延庆区", "value": "110119" }
        ]
      }
    ]
  },
  {
    "label": "天津市",
    "value": "120000",
    "children": [
      {
        "label": "天津市",
        "value": "120100",
        "children": [
          { "label": "和平区", "value": "120101" },
          { "label": "河东区", "value": "120102" },
          { "label": "河西区", "value": "120103" },
          { "label": "南开区", "value": "120104" },
          { "label": "河北区", "value": "120105" },
          { "label": "红桥区", "value": "120106" },
          { "label": "东丽区", "value": "120110" },
          { "label": "西青区", "value": "120111" },
          { "label": "津南区", "value": "120112" },
          { "label": "北辰区", "value": "120113" },
          { "label": "武清区", "value": "120114" },
          { "label": "宝坻区", "value": "120115" },
          { "label": "滨海新区", "value": "120116" },
          { "label": "宁河区", "value": "120117" },
          { "label": "静海区", "value": "120118" },
          { "label": "蓟州区", "value": "120119" }
        ]
      }
    ]
  },
  {
    "label": "河北省",
    "value": "130000",
    "children": [
      {
        "label": "石家庄市",
        "value": "130100",
        "children": [
          { "label": "长安区", "value": "130102" },
          { "label": "桥西区", "value": "130104" },
          { "label": "新华区", "value": "130105" },
          { "label": "井陉矿区", "value": "130107" },
          { "label": "裕华区", "value": "130108" },
          { "label": "藁城区", "value": "130109" },
          { "label": "鹿泉区", "value": "130110" },
          { "label": "栾城区", "value": "130111" },
          { "label": "井陉县", "value": "130121" },
          { "label": "正定县", "value": "130123" },
          { "label": "行唐县", "value": "130125" },
          { "label": "灵寿县", "value": "130126" },
          { "label": "高邑县", "value": "130127" },
          { "label": "深泽县", "value": "130128" },
          { "label": "赞皇县", "value": "130129" },
          { "label": "无极县", "value": "130130" },
          { "label": "平山县", "value": "130131" },
          { "label": "元氏县", "value": "130132" },
          { "label": "赵县", "value": "130133" },
          { "label": "晋州市", "value": "130183" },
          { "label": "新乐市", "value": "130184" }
        ]
      },
      {
        "label": "唐山市",
        "value": "130200",
        "children": [
          { "label": "路南区", "value": "130202" },
          { "label": "路北区", "value": "130203" },
          { "label": "古冶区", "value": "130204" },
          { "label": "开平区", "value": "130205" },
          { "label": "丰南区", "value": "130207" },
          { "label": "丰润区", "value": "130208" },
          { "label": "曹妃甸区", "value": "130209" },
          { "label": "滦南县", "value": "130224" },
          { "label": "乐亭县", "value": "130225" },
          { "label": "迁西县", "value": "130227" },
          { "label": "玉田县", "value": "130229" },
          { "label": "遵化市", "value": "130281" },
          { "label": "迁安市", "value": "130283" },
          { "label": "滦州市", "value": "130284" }
        ]
      },
      // 河北省其他地级市（秦皇岛、邯郸、邢台等）已省略，完整文件包含所有城市
    ]
  },
  {
    "label": "山西省",
    "value": "140000",
    "children": [
      {
        "label": "太原市",
        "value": "140100",
        "children": [
          { "label": "小店区", "value": "140105" },
          { "label": "迎泽区", "value": "140106" },
          { "label": "杏花岭区", "value": "140107" },
          { "label": "尖草坪区", "value": "140108" },
          { "label": "万柏林区", "value": "140109" },
          { "label": "晋源区", "value": "140110" },
          { "label": "清徐县", "value": "140121" },
          { "label": "阳曲县", "value": "140122" },
          { "label": "娄烦县", "value": "140123" },
          { "label": "古交市", "value": "140181" }
        ]
      }
      // 山西省其他地级市已省略
    ]
  },
  {
    "label": "内蒙古自治区",
    "value": "150000",
    "children": [
      {
        "label": "呼和浩特市",
        "value": "150100",
        "children": [
          { "label": "新城区", "value": "150102" },
          { "label": "回民区", "value": "150103" },
          { "label": "玉泉区", "value": "150104" },
          { "label": "赛罕区", "value": "150105" },
          { "label": "土默特左旗", "value": "150121" },
          { "label": "托克托县", "value": "150122" },
          { "label": "和林格尔县", "value": "150123" },
          { "label": "清水河县", "value": "150124" },
          { "label": "武川县", "value": "150125" }
        ]
      }
      // 内蒙古其他盟市已省略
    ]
  },
  {
    "label": "辽宁省",
    "value": "210000",
    "children": [
      {
        "label": "沈阳市",
        "value": "210100",
        "children": [
          { "label": "和平区", "value": "210102" },
          { "label": "沈河区", "value": "210103" },
          { "label": "大东区", "value": "210104" },
          { "label": "皇姑区", "value": "210105" },
          { "label": "铁西区", "value": "210106" },
          { "label": "苏家屯区", "value": "210111" },
          { "label": "浑南区", "value": "210112" },
          { "label": "沈北新区", "value": "210113" },
          { "label": "于洪区", "value": "210114" },
          { "label": "辽中区", "value": "210115" },
          { "label": "康平县", "value": "210123" },
          { "label": "法库县", "value": "210124" },
          { "label": "新民市", "value": "210181" }
        ]
      }
      // 辽宁省其他地级市已省略
    ]
  },
  {
    "label": "吉林省",
    "value": "220000",
    "children": [
      {
        "label": "长春市",
        "value": "220100",
        "children": [
          { "label": "南关区", "value": "220102" },
          { "label": "宽城区", "value": "220103" },
          { "label": "朝阳区", "value": "220104" },
          { "label": "二道区", "value": "220105" },
          { "label": "绿园区", "value": "220106" },
          { "label": "双阳区", "value": "220112" },
          { "label": "九台区", "value": "220113" },
          { "label": "农安县", "value": "220122" },
          { "label": "榆树市", "value": "220182" },
          { "label": "德惠市", "value": "220183" }
        ]
      }
      // 吉林省其他地级市已省略
    ]
  },
  {
    "label": "黑龙江省",
    "value": "230000",
    "children": [
      {
        "label": "哈尔滨市",
        "value": "230100",
        "children": [
          { "label": "道里区", "value": "230102" },
          { "label": "南岗区", "value": "230103" },
          { "label": "道外区", "value": "230104" },
          { "label": "平房区", "value": "230108" },
          { "label": "松北区", "value": "230109" },
          { "label": "香坊区", "value": "230110" },
          { "label": "呼兰区", "value": "230111" },
          { "label": "阿城区", "value": "230112" },
          { "label": "双城区", "value": "230113" },
          { "label": "依兰县", "value": "230123" },
          { "label": "方正县", "value": "230124" },
          { "label": "宾县", "value": "230125" },
          { "label": "巴彦县", "value": "230126" },
          { "label": "木兰县", "value": "230127" },
          { "label": "通河县", "value": "230128" },
          { "label": "延寿县", "value": "230129" },
          { "label": "尚志市", "value": "230183" },
          { "label": "五常市", "value": "230184" }
        ]
      }
      // 黑龙江省其他地级市已省略
    ]
  },
  {
    "label": "上海市",
    "value": "310000",
    "children": [
      {
        "label": "上海市",
        "value": "310100",
        "children": [
          { "label": "黄浦区", "value": "310101" },
          { "label": "徐汇区", "value": "310104" },
          { "label": "长宁区", "value": "310105" },
          { "label": "静安区", "value": "310106" },
          { "label": "普陀区", "value": "310107" },
          { "label": "虹口区", "value": "310109" },
          { "label": "杨浦区", "value": "310110" },
          { "label": "闵行区", "value": "310112" },
          { "label": "宝山区", "value": "310113" },
          { "label": "嘉定区", "value": "310114" },
          { "label": "浦东新区", "value": "310115" },
          { "label": "金山区", "value": "310116" },
          { "label": "松江区", "value": "310117" },
          { "label": "青浦区", "value": "310118" },
          { "label": "奉贤区", "value": "310120" },
          { "label": "崇明区", "value": "310151" }
        ]
      }
    ]
  },
  {
    "label": "江苏省",
    "value": "320000",
    "children": [
      {
        "label": "南京市",
        "value": "320100",
        "children": [
          { "label": "玄武区", "value": "320102" },
          { "label": "秦淮区", "value": "320104" },
          { "label": "建邺区", "value": "320105" },
          { "label": "鼓楼区", "value": "320106" },
          { "label": "浦口区", "value": "320111" },
          { "label": "栖霞区", "value": "320113" },
          { "label": "雨花台区", "value": "320114" },
          { "label": "江宁区", "value": "320115" },
          { "label": "六合区", "value": "320116" },
          { "label": "溧水区", "value": "320117" },
          { "label": "高淳区", "value": "320118" }
        ]
      },
      {
        "label": "无锡市",
        "value": "320200",
        "children": [
          { "label": "锡山区", "value": "320205" },
          { "label": "惠山区", "value": "320206" },
          { "label": "滨湖区", "value": "320211" },
          { "label": "梁溪区", "value": "320213" },
          { "label": "新吴区", "value": "320214" },
          { "label": "江阴市", "value": "320281" },
          { "label": "宜兴市", "value": "320282" }
        ]
      }
      // 江苏省其他地级市已省略
    ]
  },
  {
    "label": "浙江省",
    "value": "330000",
    "children": [
      {
        "label": "杭州市",
        "value": "330100",
        "children": [
          { "label": "上城区", "value": "330102" },
          { "label": "拱墅区", "value": "330105" },
          { "label": "西湖区", "value": "330106" },
          { "label": "滨江区", "value": "330108" },
          { "label": "萧山区", "value": "330109" },
          { "label": "余杭区", "value": "330110" },
          { "label": "富阳区", "value": "330111" },
          { "label": "临安区", "value": "330112" },
          { "label": "桐庐县", "value": "330122" },
          { "label": "淳安县", "value": "330127" },
          { "label": "建德市", "value": "330182" }
        ]
      },
      {
        "label": "宁波市",
        "value": "330200",
        "children": [
          { "label": "海曙区", "value": "330203" },
          { "label": "江北区", "value": "330205" },
          { "label": "镇海区", "value": "330211" },
          { "label": "北仑区", "value": "330206" },
          { "label": "鄞州区", "value": "330212" },
          { "label": "奉化区", "value": "330213" },
          { "label": "象山县", "value": "330225" },
          { "label": "宁海县", "value": "330226" },
          { "label": "余姚市", "value": "330281" },
          { "label": "慈溪市", "value": "330282" }
        ]
      }
      // 浙江省其他地级市已省略
    ]
  },
  {
    "label": "安徽省",
    "value": "340000",
    "children": [
      {
        "label": "合肥市",
        "value": "340100",
        "children": [
          { "label": "瑶海区", "value": "340102" },
          { "label": "庐阳区", "value": "340103" },
          { "label": "蜀山区", "value": "340104" },
          { "label": "包河区", "value": "340111" },
          { "label": "长丰县", "value": "340121" },
          { "label": "肥东县", "value": "340122" },
          { "label": "肥西县", "value": "340123" },
          { "label": "庐江县", "value": "340124" },
          { "label": "巢湖市", "value": "340181" }
        ]
      }
      // 安徽省其他地级市已省略
    ]
  },
  {
    "label": "福建省",
    "value": "350000",
    "children": [
      {
        "label": "福州市",
        "value": "350100",
        "children": [
          { "label": "鼓楼区", "value": "350102" },
          { "label": "台江区", "value": "350103" },
          { "label": "仓山区", "value": "350104" },
          { "label": "马尾区", "value": "350105" },
          { "label": "晋安区", "value": "350111" },
          { "label": "长乐区", "value": "350112" },
          { "label": "闽侯县", "value": "350121" },
          { "label": "连江县", "value": "350122" },
          { "label": "罗源县", "value": "350123" },
          { "label": "闽清县", "value": "350124" },
          { "label": "永泰县", "value": "350125" },
          { "label": "平潭县", "value": "350128" },
          { "label": "福清市", "value": "350181" }
        ]
      },
      {
        "label": "厦门市",
        "value": "350200",
        "children": [
          { "label": "思明区", "value": "350203" },
          { "label": "海沧区", "value": "350205" },
          { "label": "湖里区", "value": "350206" },
          { "label": "集美区", "value": "350211" },
          { "label": "同安区", "value": "350212" },
          { "label": "翔安区", "value": "350213" }
        ]
      }
      // 福建省其他地级市已省略
    ]
  },
  {
    "label": "江西省",
    "value": "360000",
    "children": [
      {
        "label": "南昌市",
        "value": "360100",
        "children": [
          { "label": "东湖区", "value": "360102" },
          { "label": "西湖区", "value": "360103" },
          { "label": "青云谱区", "value": "360104" },
          { "label": "青山湖区", "value": "360111" },
          { "label": "新建区", "value": "360112" },
          { "label": "红谷滩区", "value": "360113" },
          { "label": "南昌县", "value": "360121" },
          { "label": "安义县", "value": "360123" },
          { "label": "进贤县", "value": "360124" }
        ]
      }
      // 江西省其他地级市已省略
    ]
  },
  {
    "label": "山东省",
    "value": "370000",
    "children": [
      {
        "label": "济南市",
        "value": "370100",
        "children": [
          { "label": "历下区", "value": "370102" },
          { "label": "市中区", "value": "370103" },
          { "label": "槐荫区", "value": "370104" },
          { "label": "天桥区", "value": "370105" },
          { "label": "历城区", "value": "370112" },
          { "label": "长清区", "value": "370113" },
          { "label": "章丘区", "value": "370114" },
          { "label": "济阳区", "value": "370115" },
          { "label": "莱芜区", "value": "370116" },
          { "label": "钢城区", "value": "370117" },
          { "label": "平阴县", "value": "370124" },
          { "label": "商河县", "value": "370126" }
        ]
      },
      {
        "label": "青岛市",
        "value": "370200",
        "children": [
          { "label": "市南区", "value": "370202" },
          { "label": "市北区", "value": "370203" },
          { "label": "黄岛区", "value": "370211" },
          { "label": "崂山区", "value": "370212" },
          { "label": "李沧区", "value": "370213" },
          { "label": "城阳区", "value": "370214" },
          { "label": "即墨区", "value": "370215" },
          { "label": "胶州市", "value": "370281" },
          { "label": "平度市", "value": "370283" },
          { "label": "莱西市", "value": "370285" }
        ]
      }
      // 山东省其他地级市已省略
    ]
  },
  {
    "label": "河南省",
    "value": "410000",
    "children": [
      {
        "label": "郑州市",
        "value": "410100",
        "children": [
          { "label": "中原区", "value": "410102" },
          { "label": "二七区", "value": "410103" },
          { "label": "管城回族区", "value": "410104" },
          { "label": "金水区", "value": "410105" },
          { "label": "上街区", "value": "410106" },
          { "label": "惠济区", "value": "410108" },
          { "label": "中牟县", "value": "410122" },
          { "label": "巩义市", "value": "410181" },
          { "label": "荥阳市", "value": "410182" },
          { "label": "新密市", "value": "410183" },
          { "label": "新郑市", "value": "410184" },
          { "label": "登封市", "value": "410185" }
        ]
      }
      // 河南省其他地级市已省略
    ]
  },
  {
    "label": "湖北省",
    "value": "420000",
    "children": [
      {
        "label": "武汉市",
        "value": "420100",
        "children": [
          { "label": "江岸区", "value": "420102" },
          { "label": "江汉区", "value": "420103" },
          { "label": "硚口区", "value": "420104" },
          { "label": "汉阳区", "value": "420105" },
          { "label": "武昌区", "value": "420106" },
          { "label": "青山区", "value": "420107" },
          { "label": "洪山区", "value": "420111" },
          { "label": "东西湖区", "value": "420112" },
          { "label": "汉南区", "value": "420113" },
          { "label": "蔡甸区", "value": "420114" },
          { "label": "江夏区", "value": "420115" },
          { "label": "黄陂区", "value": "420116" },
          { "label": "新洲区", "value": "420117" }
        ]
      }
      // 湖北省其他地级市已省略
    ]
  },
  {
    "label": "湖南省",
    "value": "430000",
    "children": [
      {
        "label": "长沙市",
        "value": "430100",
        "children": [
          { "label": "芙蓉区", "value": "430102" },
          { "label": "天心区", "value": "430103" },
          { "label": "岳麓区", "value": "430104" },
          { "label": "开福区", "value": "430105" },
          { "label": "雨花区", "value": "430111" },
          { "label": "望城区", "value": "430112" },
          { "label": "长沙县", "value": "430121" },
          { "label": "浏阳市", "value": "430181" },
          { "label": "宁乡市", "value": "430182" }
        ]
      }
      // 湖南省其他地级市已省略
    ]
  },
  {
    "label": "广东省",
    "value": "440000",
    "children": [
      {
        "label": "广州市",
        "value": "440100",
        "children": [
          { "label": "荔湾区", "value": "440103" },
          { "label": "越秀区", "value": "440104" },
          { "label": "海珠区", "value": "440105" },
          { "label": "天河区", "value": "440106" },
          { "label": "白云区", "value": "440111" },
          { "label": "黄埔区", "value": "440112" },
          { "label": "番禺区", "value": "440113" },
          { "label": "花都区", "value": "440114" },
          { "label": "南沙区", "value": "440115" },
          { "label": "从化区", "value": "440117" },
          { "label": "增城区", "value": "440118" }
        ]
      },
      {
        "label": "深圳市",
        "value": "440300",
        "children": [
          { "label": "罗湖区", "value": "440303" },
          { "label": "福田区", "value": "440304" },
          { "label": "南山区", "value": "440305" },
          { "label": "宝安区", "value": "440306" },
          { "label": "龙岗区", "value": "440307" },
          { "label": "盐田区", "value": "440308" },
          { "label": "龙华区", "value": "440309" },
          { "label": "坪山区", "value": "440310" },
          { "label": "光明区", "value": "440311" },
          { "label": "大鹏新区", "value": "440312" }
        ]
      },
      {
        "label": "珠海市",
        "value": "440400",
        "children": [
          { "label": "香洲区", "value": "440402" },
          { "label": "斗门区", "value": "440403" },
          { "label": "金湾区", "value": "440404" }
        ]
      }
      // 广东省其他地级市已省略
    ]
  },
  {
    "label": "广西壮族自治区",
    "value": "450000",
    "children": [
      {
        "label": "南宁市",
        "value": "450100",
        "children": [
          { "label": "兴宁区", "value": "450102" },
          { "label": "青秀区", "value": "450103" },
          { "label": "江南区", "value": "450105" },
          { "label": "西乡塘区", "value": "450107" },
          { "label": "良庆区", "value": "450108" },
          { "label": "邕宁区", "value": "450109" },
          { "label": "武鸣区", "value": "450110" },
          { "label": "隆安县", "value": "450123" },
          { "label": "马山县", "value": "450124" },
          { "label": "上林县", "value": "450125" },
          { "label": "宾阳县", "value": "450126" },
          { "label": "横州市", "value": "450181" }
        ]
      }
      // 广西其他地级市已省略
    ]
  },
  {
    "label": "海南省",
    "value": "460000",
    "children": [
      {
        "label": "海口市",
        "value": "460100",
        "children": [
          { "label": "秀英区", "value": "460105" },
          { "label": "龙华区", "value": "460106" },
          { "label": "琼山区", "value": "460107" },
          { "label": "美兰区", "value": "460108" }
        ]
      },
      {
        "label": "三亚市",
        "value": "460200",
        "children": [
          { "label": "海棠区", "value": "460202" },
          { "label": "吉阳区", "value": "460203" },
          { "label": "天涯区", "value": "460204" },
          { "label": "崖州区", "value": "460205" }
        ]
      }
      // 海南省其他地级市已省略
    ]
  },
  {
    "label": "重庆市",
    "value": "500000",
    "children": [
      {
        "label": "重庆市",
        "value": "500100",
        "children": [
          { "label": "万州区", "value": "500101" },
          { "label": "涪陵区", "value": "500102" },
          { "label": "渝中区", "value": "500103" },
          { "label": "大渡口区", "value": "500104" },
          { "label": "江北区", "value": "500105" },
          { "label": "沙坪坝区", "value": "500106" },
          { "label": "九龙坡区", "value": "500107" },
          { "label": "南岸区", "value": "500108" },
          { "label": "北碚区", "value": "500109" },
          { "label": "綦江区", "value": "500110" },
          { "label": "大足区", "value": "500111" },
          { "label": "渝北区", "value": "500112" },
          { "label": "巴南区", "value": "500113" },
          { "label": "黔江区", "value": "500114" },
          { "label": "长寿区", "value": "500115" },
          { "label": "江津区", "value": "500116" },
          { "label": "合川区", "value": "500117" },
          { "label": "永川区", "value": "500118" },
          { "label": "南川区", "value": "500119" },
          { "label": "璧山区", "value": "500120" },
          { "label": "铜梁区", "value": "500151" },
          { "label": "潼南区", "value": "500152" },
          { "label": "荣昌区", "value": "500153" },
          { "label": "开州区", "value": "500154" },
          { "label": "梁平区", "value": "500155" },
          { "label": "武隆区", "value": "500156" },
          { "label": "城口县", "value": "500229" },
          { "label": "丰都县", "value": "500230" },
          { "label": "垫江县", "value": "500231" },
          { "label": "忠县", "value": "500233" },
          { "label": "云阳县", "value": "500235" },
          { "label": "奉节县", "value": "500236" },
          { "label": "巫山县", "value": "500237" },
          { "label": "巫溪县", "value": "500238" },
          { "label": "石柱土家族自治县", "value": "500240" },
          { "label": "秀山土家族苗族自治县", "value": "500241" },
          { "label": "酉阳土家族苗族自治县", "value": "500242" },
          { "label": "彭水苗族土家族自治县", "value": "500243" }
        ]
      }
    ]
  },
  {
    "label": "四川省",
    "value": "510000",
    "children": [
      {
        "label": "成都市",
        "value": "510100",
        "children": [
          { "label": "锦江区", "value": "510104" },
          { "label": "青羊区", "value": "510105" },
          { "label": "金牛区", "value": "510106" },
          { "label": "武侯区", "value": "510107" },
          { "label": "成华区", "value": "510108" },
          { "label": "龙泉驿区", "value": "510112" },
          { "label": "青白江区", "value": "510113" },
          { "label": "新都区", "value": "510114" },
          { "label": "温江区", "value": "510115" },
          { "label": "双流区", "value": "510116" },
          { "label": "郫都区", "value": "510117" },
          { "label": "新津区", "value": "510118" },
          { "label": "金堂县", "value": "510121" },
          { "label": "大邑县", "value": "510129" },
          { "label": "蒲江县", "value": "510131" },
          { "label": "都江堰市", "value": "510181" },
          { "label": "彭州市", "value": "510182" },
          { "label": "邛崃市", "value": "510183" },
          { "label": "崇州市", "value": "510184" },
          { "label": "简阳市", "value": "510185" }
        ]
      }
      // 四川省其他地级市已省略
    ]
  },
  {
    "label": "贵州省",
    "value": "520000",
    "children": [
      {
        "label": "贵阳市",
        "value": "520100",
        "children": [
          { "label": "南明区", "value": "520102" },
          { "label": "云岩区", "value": "520103" },
          { "label": "花溪区", "value": "520111" },
          { "label": "乌当区", "value": "520112" },
          { "label": "白云区", "value": "520113" },
          { "label": "观山湖区", "value": "520115" },
          { "label": "开阳县", "value": "520121" },
          { "label": "息烽县", "value": "520122" },
          { "label": "修文县", "value": "520123" },
          { "label": "清镇市", "value": "520181" }
        ]
      }
      // 贵州省其他地级市已省略
    ]
  },
  {
    "label": "云南省",
    "value": "530000",
    "children": [
      {
        "label": "昆明市",
        "value": "530100",
        "children": [
          { "label": "五华区", "value": "530102" },
          { "label": "盘龙区", "value": "530103" },
          { "label": "官渡区", "value": "530111" },
          { "label": "西山区", "value": "530112" },
          { "label": "东川区", "value": "530113" },
          { "label": "呈贡区", "value": "530114" },
          { "label": "晋宁区", "value": "530115" },
          { "label": "富民县", "value": "530124" },
          { "label": "宜良县", "value": "530125" },
          { "label": "石林彝族自治县", "value": "530126" },
          { "label": "嵩明县", "value": "530127" },
          { "label": "禄劝彝族苗族自治县", "value": "530128" },
          { "label": "寻甸回族彝族自治县", "value": "530129" },
          { "label": "安宁市", "value": "530181" }
        ]
      }
      // 云南省其他地级市已省略
    ]
  },
  {
    "label": "西藏自治区",
    "value": "540000",
    "children": [
      {
        "label": "拉萨市",
        "value": "540100",
        "children": [
          { "label": "城关区", "value": "540102" },
          { "label": "堆龙德庆区", "value": "540103" },
          { "label": "达孜区", "value": "540104" },
          { "label": "林周县", "value": "540121" },
          { "label": "当雄县", "value": "540122" },
          { "label": "尼木县", "value": "540123" },
          { "label": "曲水县", "value": "540124" },
          { "label": "墨竹工卡县", "value": "540127" }
        ]
      }
      // 西藏其他地市已省略
    ]
  },
  {
    "label": "陕西省",
    "value": "610000",
    "children": [
      {
        "label": "西安市",
        "value": "610100",
        "children": [
          { "label": "新城区", "value": "610102" },
          { "label": "碑林区", "value": "610103" },
          { "label": "莲湖区", "value": "610104" },
          { "label": "灞桥区", "value": "610111" },
          { "label": "未央区", "value": "610112" },
          { "label": "雁塔区", "value": "610113" },
          { "label": "阎良区", "value": "610114" },
          { "label": "临潼区", "value": "610115" },
          { "label": "长安区", "value": "610116" },
          { "label": "高陵区", "value": "610117" },
          { "label": "鄠邑区", "value": "610118" },
          { "label": "蓝田县", "value": "610122" },
          { "label": "周至县", "value": "610124" }
        ]
      }
      // 陕西省其他地级市已省略
    ]
  },
  {
    "label": "甘肃省",
    "value": "620000",
    "children": [
      {
        "label": "兰州市",
        "value": "620100",
        "children": [
          { "label": "城关区", "value": "620102" },
          { "label": "七里河区", "value": "620103" },
          { "label": "西固区", "value": "620104" },
          { "label": "安宁区", "value": "620105" },
          { "label": "红古区", "value": "620111" },
          { "label": "永登县", "value": "620121" },
          { "label": "皋兰县", "value": "620122" },
          { "label": "榆中县", "value": "620123" }
        ]
      }
      // 甘肃省其他地级市已省略
    ]
  },
  {
    "label": "青海省",
    "value": "630000",
    "children": [
      {
        "label": "西宁市",
        "value": "630100",
        "children": [
          { "label": "城东区", "value": "630102" },
          { "label": "城中区", "value": "630103" },
          { "label": "城西区", "value": "630104" },
          { "label": "城北区", "value": "630105" },
          { "label": "大通回族土族自治县", "value": "630121" },
          { "label": "湟中县", "value": "630122" },
          { "label": "湟源县", "value": "630123" }
        ]
      }
      // 青海省其他地市已省略
    ]
  },
  {
    "label": "宁夏回族自治区",
    "value": "640000",
    "children": [
      {
        "label": "银川市",
        "value": "640100",
        "children": [
          { "label": "兴庆区", "value": "640104" },
          { "label": "西夏区", "value": "640105" },
          { "label": "金凤区", "value": "640106" },
          { "label": "永宁县", "value": "640121" },
          { "label": "贺兰县", "value": "640122" },
          { "label": "灵武市", "value": "640181" }
        ]
      }
      // 宁夏其他地级市已省略
    ]
  },
  {
    "label": "新疆维吾尔自治区",
    "value": "650000",
    "children": [
      {
        "label": "乌鲁木齐市",
        "value": "650100",
        "children": [
          { "label": "天山区", "value": "650102" },
          { "label": "沙依巴克区", "value": "650103" },
          { "label": "新市区", "value": "650104" },
          { "label": "水磨沟区", "value": "650105" },
          { "label": "头屯河区", "value": "650106" },
          { "label": "达坂城区", "value": "650107" },
          { "label": "米东区", "value": "650109" },
          { "label": "乌鲁木齐县", "value": "650121" }
        ]
      }
      // 新疆其他地级市已省略
    ]
  },
  {
    "label": "台湾省",
    "value": "710000",
    "children": [
      {
        "label": "台北市",
        "value": "710100",
        "children": [
          { "label": "中正区", "value": "710101" },
          { "label": "大同区", "value": "710102" },
          { "label": "中山区", "value": "710103" },
          { "label": "松山区", "value": "710104" },
          { "label": "大安区", "value": "710105" },
          { "label": "万华区", "value": "710106" },
          { "label": "信义区", "value": "710107" },
          { "label": "士林区", "value": "710108" },
          { "label": "北投区", "value": "710109" },
          { "label": "内湖区", "value": "710110" },
          { "label": "南港区", "value": "710111" },
          { "label": "文山区", "value": "710112" }
        ]
      }
      // 台湾省其他地区已省略
    ]
  },
  {
    "label": "香港特别行政区",
    "value": "810000",
    "children": [
      {
        "label": "香港特别行政区",
        "value": "810100",
        "children": [
          { "label": "中西区", "value": "810101" },
          { "label": "湾仔区", "value": "810102" },
          { "label": "东区", "value": "810103" },
          { "label": "南区", "value": "810104" },
          { "label": "油尖旺区", "value": "810105" },
          { "label": "深水埗区", "value": "810106" },
          { "label": "九龙城区", "value": "810107" },
          { "label": "黄大仙区", "value": "810108" },
          { "label": "观塘区", "value": "810109" },
          { "label": "北区", "value": "810110" },
          { "label": "大埔区", "value": "810111" },
          { "label": "沙田区", "value": "810112" },
          { "label": "西贡区", "value": "810113" },
          { "label": "荃湾区", "value": "810114" },
          { "label": "屯门区", "value": "810115" },
          { "label": "元朗区", "value": "810116" },
          { "label": "葵青区", "value": "810117" },
          { "label": "离岛区", "value": "810118" }
        ]
      }
    ]
  },
  {
    "label": "澳门特别行政区",
    "value": "820000",
    "children": [
      {
        "label": "澳门特别行政区",
        "value": "820100",
        "children": [
          { "label": "花地玛堂区", "value": "820101" },
          { "label": "圣安多尼堂区", "value": "820102" },
          { "label": "大堂区", "value": "820103" },
          { "label": "望德堂区", "value": "820104" },
          { "label": "风顺堂区", "value": "820105" },
          { "label": "嘉模堂区", "value": "820106" },
          { "label": "圣方济各堂区", "value": "820107" }
        ]
      }
    ]
  }
];

// 简化版：仅获取省级列表（如需单独用省份数据）
export const provinceList = regionData.map(item => ({ label: item.label, value: item.value }));