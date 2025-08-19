import { AuthService } from '../service/AuthService';
import { DataService } from '../service/DataService';
import { CarbonCalculator } from '../service/CarbonCalculator';
import { User, EcoRecord } from '../model/User';
import { router } from '@kit.ArkUI';
import { promptAction } from '@kit.ArkUI';

@Entry
@Component
export struct RecordsPage {
  @State userRecords: EcoRecord[] = [];
  @State currentUser: User | null = null;
  @State isLoading: boolean = true;

  private authService: AuthService = AuthService.getInstance();
  private dataService: DataService = DataService.getInstance();
  private carbonCalculator: CarbonCalculator = CarbonCalculator.getInstance();

  async aboutToAppear() {
    await this.loadData();

    // 创建AppStorage监听
    AppStorage.SetOrCreate('userDataUpdated', 0);
  }


  async loadData() {
    this.isLoading = true;
    try {
      this.currentUser = await this.authService.getCurrentUser();
      if (this.currentUser) {
        this.userRecords = await this.dataService.getEcoRecordsByUserId(this.currentUser.id);
      }
    } catch (error) {
      console.error('加载记录失败:', error);
      promptAction.showToast({ message: '加载失败，请重试' });
    } finally {
      this.isLoading = false;
    }
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

        Text('环保记录')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)

        Blank()

        Button() {
          Text('+')
            .fontSize(22)
            .fontColor('#fff')
        }
        .width(30)
        .height(30)
        .backgroundColor('#4CAF50')
        .borderRadius(20)
        .onClick(() => {
          router.pushUrl({ url: 'pages/AddRecordPage' })
        })
      }
      .width('100%')
      .height(56)
      .padding({ left: 16, right: 16 })
      .backgroundColor('#fff')
      .justifyContent(FlexAlign.SpaceBetween)
      .alignItems(VerticalAlign.Center)

      // 记录内容
      if (this.isLoading) {
        Column() {
          Text('加载中...')
            .fontSize(16)
            .fontColor('#666')
        }
        .width('100%')
        .height('80%')
        .justifyContent(FlexAlign.Center)
      } else if (this.userRecords.length === 0) {
        Column({ space: 20 }) {
          Text('📝')
            .fontSize(60)
          Text('暂无环保记录')
            .fontSize(16)
            .fontColor('#666')
          Button('去记录环保行为')
            .onClick(() => {
              router.pushUrl({ url: 'pages/AddRecordPage' })
            })
        }
        .width('100%')
        .height('80%')
        .justifyContent(FlexAlign.Center)
      } else {
        List({ space: 10 }) {
          ForEach(this.userRecords, (record: EcoRecord) => {
            ListItem() {
              Row() {
                Column({ space: 4 }) {
                  Text(this.carbonCalculator.getActionDescription(record.type))
                    .fontSize(14)
                    .fontWeight(FontWeight.Bold)
                    .fontColor('#333')
                    .alignSelf(ItemAlign.Start)
                  Text(`数量: ${record.amount}`)
                    .fontSize(12)
                    .fontColor('#666')
                    .alignSelf(ItemAlign.Start)
                  Text(record.date.toLocaleDateString())
                    .fontSize(12)
                    .fontColor('#999')
                    .alignSelf(ItemAlign.Start)
                }
                .alignItems(HorizontalAlign.Start)
                .layoutWeight(1)

                Column({ space: 4 }) {
                  Text(`-${this.carbonCalculator.formatCarbonReduction(record.carbonReduction)}`)
                    .fontSize(12)
                    .fontColor('#4CAF50')
                    .fontWeight(FontWeight.Bold)
                  Text(`+${this.carbonCalculator.getSuggestedPoints(record.type, record.amount)}分`)
                    .fontSize(12)
                    .fontColor('#FF9800')
                }
                .alignItems(HorizontalAlign.End)
              }
              .width('100%')
              .padding(15)
              .backgroundColor('#fff')
              .borderRadius(8)
            }
          })
        }
        .width('100%')
        .layoutWeight(1)
        .padding({ left: 15, right: 15, top: 10 })
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#f5f5f5')
  }
}