import { AuthService } from '../service/AuthService';
import { DataService } from '../service/DataService';
import { CarbonCalculator } from '../service/CarbonCalculator';
import { EcoRecord } from '../model/User';
import { router } from '@kit.ArkUI';
import { promptAction } from '@kit.ArkUI';

// 环保行为项接口
interface ActionItem {
  type: string;
  name: string;
}

// 行为分类接口
interface ActionsByCategory {
  绿色出行: ActionItem[];
  节约用水: ActionItem[];
  节约用电: ActionItem[];
  垃圾分类回收: ActionItem[];
  绿色消费: ActionItem[];
  植树造林: ActionItem[];
  环境清理: ActionItem[];
  其他环保行为: ActionItem[];
}

@Entry
@Component
struct AddRecordPage {
  @State selectedCategory: string = '';
  @State selectedActionType: string = '';
  @State quantity: number = 1;
  @State description: string = '';
  @State location: string = '';
  @State isLoading: boolean = false;
  @State carbonReduction: number = 0;
  @State points: number = 0;
  
  private authService: AuthService = AuthService.getInstance();
  private dataService: DataService = DataService.getInstance();
  private carbonCalculator: CarbonCalculator = CarbonCalculator.getInstance();
  
  // 环保行为分类
  private categories: string[] = ['绿色出行', '节约用水', '节约用电', '垃圾分类回收', '绿色消费', '植树造林', '环境清理', '其他环保行为'];
  
  // 各分类下的具体行为
  private actionsByCategory: ActionsByCategory = {
    '绿色出行': [
      { type: 'walk_1km', name: '步行1公里（替代开车）' } as ActionItem,
      { type: 'bike_1km', name: '骑行1公里（替代开车）' } as ActionItem,
      { type: 'public_transport_1km', name: '乘坐公共交通1公里' } as ActionItem,
      { type: 'carpool_1km', name: '拼车出行1公里' } as ActionItem
    ],
    '节约用水': [
      { type: 'save_water_1L', name: '节约用水1升' } as ActionItem,
      { type: 'shower_reduce_1min', name: '减少淋浴时间1分钟' } as ActionItem
    ],
    '节约用电': [
      { type: 'save_electricity_1kwh', name: '节约用电1度' } as ActionItem,
      { type: 'led_bulb', name: '使用LED灯泡（一天）' } as ActionItem,
      { type: 'unplug_device', name: '拔掉待机设备插头（一天）' } as ActionItem
    ],
    '垃圾分类回收': [
      { type: 'recycle_paper_1kg', name: '回收纸张1公斤' } as ActionItem,
      { type: 'recycle_plastic_1kg', name: '回收塑料1公斤' } as ActionItem,
      { type: 'recycle_glass_1kg', name: '回收玻璃1公斤' } as ActionItem,
      { type: 'recycle_metal_1kg', name: '回收金属1公斤' } as ActionItem,
      { type: 'compost_1kg', name: '堆肥有机垃圾1公斤' } as ActionItem
    ],
    '绿色消费': [
      { type: 'reusable_bag', name: '使用环保袋（一次）' } as ActionItem,
      { type: 'reusable_bottle', name: '使用可重复水瓶（一次）' } as ActionItem,
      { type: 'local_food_1kg', name: '购买本地食品1公斤' } as ActionItem,
      { type: 'vegetarian_meal', name: '素食一餐' } as ActionItem
    ],
    '植树造林': [
      { type: 'plant_tree', name: '种植一棵树' } as ActionItem,
      { type: 'plant_flower', name: '种植花草一株' } as ActionItem
    ],
    '环境清理': [
      { type: 'clean_beach_1hour', name: '海滩清理1小时' } as ActionItem,
      { type: 'clean_park_1hour', name: '公园清理1小时' } as ActionItem
    ],
    '其他环保行为': [
      { type: 'environmental_education', name: '参与环保教育活动' } as ActionItem
    ]
  };

  aboutToAppear() {
    this.updateCalculations();
  }

  build() {
    Column() {
      // 顶部导航
      Row() {
        Button('← 返回')
          .backgroundColor(Color.Transparent)
          .fontColor('#333')
          .onClick(() => {
            router.back();
          })
        
        Blank()
        
        Text('记录环保行为')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
        
        Blank()
        
        Text('')
          .width(60)
      }
      .width('100%')
      .height(56)
      .padding({ left: 16, right: 16 })
      .backgroundColor('#fff')

      Scroll() {
        Column({ space: 20 }) {
          // 选择环保行为分类
          Column({ space: 10 }) {
            Text('选择环保行为分类')
              .fontSize(16)
              .fontWeight(FontWeight.Bold)
              .alignSelf(ItemAlign.Start)
            
            Grid() {
              ForEach(this.categories, (category: string) => {
                GridItem() {
                  Text(category)
                    .fontSize(14)
                    .fontColor(this.selectedCategory === category ? '#fff' : '#333')
                    .backgroundColor(this.selectedCategory === category ? '#4CAF50' : '#f0f0f0')
                    .padding({ top: 8, bottom: 8, left: 12, right: 12 })
                    .borderRadius(20)
                    .onClick(() => {
                      this.selectedCategory = category;
                      this.selectedActionType = ''
                      this.updateCalculations()
                    })
                }
              })
            }
            .columnsTemplate('1fr 1fr')
            .rowsGap(10)
            .columnsGap(10)
          }
          .width('100%')
          .alignItems(HorizontalAlign.Start)

          // 选择具体行为
          if (this.selectedCategory) {
            Column({ space: 10 }) {
              Text('选择具体行为')
                .fontSize(16)
                .fontWeight(FontWeight.Bold)
                .alignSelf(ItemAlign.Start)
              
              Column({ space: 8 }) {
                ForEach(this.getActionsByCategory(this.selectedCategory), (action: ActionItem) => {
                  Row() {
                    Radio({ value: action.type, group: 'actionType' })
                      .checked(this.selectedActionType === action.type)
                      .onChange((isChecked: boolean) => {
                        if (isChecked) {
                          this.selectedActionType = action.type
                          this.updateCalculations()
                        }
                      })
                    
                    Text(action.name)
                      .fontSize(14)
                      .fontColor('#333')
                      .margin({ left: 10 })
                      .layoutWeight(1)
                  }
                  .width('100%')
                  .padding(10)
                  .backgroundColor('#f8f8f8')
                  .borderRadius(8)
                  .onClick(() => {
                    this.selectedActionType = action.type
                    this.updateCalculations()
                  })
                })
              }
            }
            .width('100%')
            .alignItems(HorizontalAlign.Start)
          }

          // 数量输入
          if (this.selectedActionType) {
            Column({ space: 10 }) {
              Text('数量')
                .fontSize(16)
                .fontWeight(FontWeight.Bold)
                .alignSelf(ItemAlign.Start)
              
              Row({ space: 15 }) {
                Button('-')
                  .width(40)
                  .height(40)
                  .backgroundColor('#f0f0f0')
                  .fontColor('#333')
                  .enabled(this.quantity > 1)
                  .onClick(() => {
                    if (this.quantity > 1) {
                      this.quantity--
                      this.updateCalculations()
                    }
                  })
                
                Text(this.quantity.toString())
                  .fontSize(18)
                  .fontWeight(FontWeight.Bold)
                  .width(60)
                  .textAlign(TextAlign.Center)
                
                Button('+')
                  .width(40)
                  .height(40)
                  .backgroundColor('#4CAF50')
                  .fontColor('#fff')
                  .onClick(() => {
                    this.quantity++
                    this.updateCalculations()
                  })
              }
              .justifyContent(FlexAlign.Center)
            }
            .width('100%')
            .alignItems(HorizontalAlign.Start)
          }

          // 环保效果预览
          if (this.selectedActionType && this.quantity > 0) {
            Column({ space: 10 }) {
              Text('环保效果预览')
                .fontSize(16)
                .fontWeight(FontWeight.Bold)
                .fontColor('#4CAF50')
              
              Row() {
                Column({ space: 5 }) {
                  Text('减排量')
                    .fontSize(12)
                    .fontColor('#666')
                  Text(this.carbonCalculator.formatCarbonReduction(this.carbonReduction))
                    .fontSize(16)
                    .fontWeight(FontWeight.Bold)
                    .fontColor('#4CAF50')
                }
                .layoutWeight(1)
                
                Column({ space: 5 }) {
                  Text('获得积分')
                    .fontSize(12)
                    .fontColor('#666')
                  Text(`${this.points} 分`)
                    .fontSize(16)
                    .fontWeight(FontWeight.Bold)
                    .fontColor('#FF9800')
                }
                .layoutWeight(1)
              }
            }
            .width('100%')
            .padding(15)
            .backgroundColor('#E8F5E8')
            .borderRadius(10)
          }

          // 描述输入
          Column({ space: 10 }) {
            Text('描述（可选）')
              .fontSize(16)
              .fontWeight(FontWeight.Bold)
              .alignSelf(ItemAlign.Start)
            
            TextArea({ placeholder: '描述一下你的环保行为...' })
              .width('100%')
              .height(80)
              .backgroundColor('#f8f8f8')
              .borderRadius(8)
              .onChange((value: string) => {
                this.description = value;
              })
          }
          .width('100%')
          .alignItems(HorizontalAlign.Start)

          // 地点输入
          Column({ space: 10 }) {
            Text('地点（可选）')
              .fontSize(16)
              .fontWeight(FontWeight.Bold)
              .alignSelf(ItemAlign.Start)
            
            TextInput({ placeholder: '在哪里进行的环保行为？' })
              .width('100%')
              .height(50)
              .backgroundColor('#f8f8f8')
              .borderRadius(8)
              .onChange((value: string) => {
                this.location = value
              })
          }
          .width('100%')
          .alignItems(HorizontalAlign.Start)

          // 提交按钮
          Button(this.isLoading ? '保存中...' : '保存记录')
            .width('100%')
            .height(50)
            .backgroundColor('#4CAF50')
            .borderRadius(25)
            .fontSize(18)
            .fontColor('#fff')
            .enabled(!this.isLoading && this.selectedActionType !== '')
            .onClick(() => {
              this.handleSaveRecord()
            })
        }
        .width('100%')
        .padding(20)
      }
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#f5f5f5')
  }

  private updateCalculations() {
    if (this.selectedActionType && this.quantity > 0) {
      this.carbonReduction = this.carbonCalculator.calculateSingleAction(this.selectedActionType, this.quantity)
      this.points = this.carbonCalculator.getSuggestedPoints(this.selectedActionType, this.quantity)
    } else {
      this.carbonReduction = 0
      this.points = 0
    }
  }

  private async handleSaveRecord() {
    if (!this.selectedActionType) {
      promptAction.showToast({ message: '请选择环保行为' })
      return
    }

    this.isLoading = true;

    try {
      const currentUser = await this.authService.getCurrentUser()
      if (!currentUser) {
        promptAction.showToast({ message: '请先登录' })
        router.replaceUrl({ url: 'pages/LoginPage' })
        return
      }

      // 创建环保记录
      const record = new EcoRecord(
        currentUser.id,
        this.selectedActionType,
        this.description || this.carbonCalculator.getActionDescription(this.selectedActionType),
        this.points,
        this.carbonReduction
      )
      record.amount = this.quantity; // 设置数量
      
      if (this.location) {
        record.location = this.location
      }

      // 保存记录
      const saved = await this.dataService.saveEcoRecord(record)
      if (!saved) {
        promptAction.showToast({ message: '保存失败，请重试' })
        return
      }

      // 更新用户积分和减排量
      currentUser.addPoints(this.points)
      currentUser.addCarbonReduction(this.carbonReduction)
      
      // 检查是否获得新勋章
      const reductionLevel = this.carbonCalculator.getReductionLevel(currentUser.carbonReduction)
      if (!currentUser.badges.includes(reductionLevel.level)) {
        currentUser.addBadge(reductionLevel.level)
        promptAction.showToast({ message: `恭喜获得新勋章：${reductionLevel.level}` })
      }

      // 保存用户更新
      await this.dataService.saveUser(currentUser)
      await this.dataService.setCurrentUser(currentUser)
      
      // 显示成功提示
      promptAction.showToast({ message: `记录保存成功！获得${this.points}积分` })
      
      // 不是返回上一页，而是直接跳转到首页，强制刷新数据
      router.replaceUrl({ url: 'pages/Index' })
    } catch (error) {
      console.error('保存记录失败:', error)
      promptAction.showToast({ message: '保存失败，请重试' })
    } finally {
      this.isLoading = false;
    }
  }

  private getActionsByCategory(category: string): ActionItem[] {
    switch (category) {
      case '绿色出行':
        return this.actionsByCategory.绿色出行;
      case '节约用水':
        return this.actionsByCategory.节约用水;
      case '节约用电':
        return this.actionsByCategory.节约用电;
      case '垃圾分类回收':
        return this.actionsByCategory.垃圾分类回收;
      case '绿色消费':
        return this.actionsByCategory.绿色消费;
      case '植树造林':
        return this.actionsByCategory.植树造林;
      case '环境清理':
        return this.actionsByCategory.环境清理;
      case '其他环保行为':
        return this.actionsByCategory.其他环保行为;
      default:
        return [];
    }
  }
}