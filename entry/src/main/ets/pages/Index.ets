import { AuthService } from '../service/AuthService';
import { DataService } from '../service/DataService';
import { User, EcoRecord } from '../model/User';
import { router } from '@kit.ArkUI';
import { ActivitiesPage } from './ActivitiesPage';
import { RankingPage } from './RankingPage';
import { ProfilePage } from './ProfilePage';
import { CarbonCalculator } from '../service/CarbonCalculator';
import { RecordsPage } from './RecordPage';

@Entry
@Component
struct Index {
  @State index: number = 0;
  @State currentUser: User | null = null;
  @State isLoggedIn: boolean = false;
  @State userRecords: EcoRecord[] = [];

  private authService: AuthService = AuthService.getInstance();
  private dataService: DataService = DataService.getInstance();
  private carbonCalculator: CarbonCalculator = CarbonCalculator.getInstance();

  @Builder TabBarBuilder(title: string, selectIndex: number, selectEmoji: string, normalEmoji: string) {
    Column() {
      Text(this.index === selectIndex ? selectEmoji : normalEmoji)
        .fontSize(22)
        .margin({ top: 10 })
      Text(title)
        .margin({ top: 5 })
        .fontColor(this.index === selectIndex ? '#4CAF50' : '#6B6B6B')
        .fontSize(14)
    }
    .height(56)
    .width('100%')
  }

  async aboutToAppear() {
    // 初始化数据服务
    await this.dataService.init(getContext(this));

    // 初始化示例数据
    await this.dataService.initSampleData();

    // 检查登录状态
    await this.checkLoginStatus();
  }

  async onPageShow() {
    // 页面显示时强制刷新数据
    await this.checkLoginStatus(true);
    
    // 初始化示例数据并确保环保知识数据正确加载
    await this.dataService.initSampleData();
  }

  async checkLoginStatus(forceRefresh: boolean = false) {
    this.currentUser = await this.authService.getCurrentUser(forceRefresh);
    this.isLoggedIn = this.currentUser !== null;
    if (this.currentUser) {
      await this.loadUserRecords();
    }
  }

  async loadUserRecords() {
    if (this.currentUser) {
      this.userRecords = await this.dataService.getEcoRecordsByUserId(this.currentUser.id);
    }
  }

  @Builder buildHomePage() {
    Scroll() {
      Column({ space: 15 }) {
        // 用户欢迎信息
        Row() {
          Column({ space: 5 }) {
            Text(`你好，${this.currentUser?.username || '环保达人'}`)
              .fontSize(20)
              .fontWeight(FontWeight.Bold)
            Text(`当前积分：${this.currentUser?.points || 0}`)
              .fontSize(14)
              .fontColor('#666')
          }
          .alignItems(HorizontalAlign.Start)

          Blank()

          Text(this.currentUser?.avatar || '🌱')
            .fontSize(40)
        }
        .width('100%')
        .padding(20)
        .backgroundColor('#fff')
        .borderRadius(10)

        // 快速操作
        Row({ space: 15 }) {
          this.buildQuickAction('📝', '记录环保', () => {
            router.pushUrl({ url: 'pages/AddRecordPage' });
          })
          this.buildQuickAction('🎯', '参与活动', () => {
            router.pushUrl({url: 'pages/ActivitiesPage'});
          })
          this.buildQuickAction('📊', '查看排名', () => {
            router.pushUrl({url: 'pages/RankingPage'});
          })
          this.buildQuickAction('📚', '环保知识', () => {
            router.pushUrl({ url: 'pages/KnowledgePage' });
          })
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceAround)

        // 今日环保提示
        Column({ space: 10 }) {
          Text('💡 今日环保小贴士')
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
          Text('使用可重复水瓶，每次可减少0.1kg CO₂排放')
            .fontSize(14)
            .fontColor('#666')
        }
        .width('100%')
        .padding(15)
        .backgroundColor('#E8F5E8')
        .borderRadius(10)

        // 最新活动预览
        Column({ space: 10 }) {
          Row() {
            Text('🎪 最新活动')
              .fontSize(16)
              .fontWeight(FontWeight.Bold)
            Blank()
            Text('查看更多 >')
              .fontSize(12)
              .fontColor('#4CAF50')
              .onClick(() => {
                router.pushUrl({url: 'pages/ActivitiesPage'});
              })
          }
          .width('100%')

          Text('社区垃圾分类志愿活动')
            .fontSize(14)
            .fontColor('#333')
          Text('明天 09:00 | 阳光社区广场')
            .fontSize(12)
            .fontColor('#666')
        }
        .width('100%')
        .padding(15)
        .backgroundColor('#fff')
        .borderRadius(10)
      }
      .padding(15)
    }
  }

  @Builder buildQuickAction(icon: string, title: string, action: () => void) {
    Column({ space: 8 }) {
      Text(icon)
        .fontSize(30)
      Text(title)
        .fontSize(12)
        .fontColor('#333')
    }
    .width(70)
    .height(70)
    .backgroundColor('#fff')
    .borderRadius(10)
    .justifyContent(FlexAlign.Center)
    .onClick(action)
  }

  @Builder buildLoginPage() {
    Column({ space: 20 }) {
      // Logo和标题
      Column({ space: 10 }) {
        Text('🌱')
          .fontSize(60)
        Text('环保公益')
          .fontSize(28)
          .fontWeight(FontWeight.Bold)
          .fontColor('#2E7D32')
        Text('让环保成为生活方式')
          .fontSize(16)
          .fontColor('#666')
      }
      .margin({ top: 100 })

      // 登录按钮
      Button('开始环保之旅')
        .width('80%')
        .height(50)
        .backgroundColor('#4CAF50')
        .borderRadius(25)
        .fontSize(18)
        .onClick(() => {
          router.pushUrl({ url: 'pages/LoginPage' });
        })

      // 注册按钮
      Button('新用户注册')
        .width('80%')
        .height(50)
        .backgroundColor('#81C784')
        .borderRadius(25)
        .fontSize(18)
        .onClick(() => {
          router.pushUrl({ url: 'pages/RegisterPage' });
        })

      Blank()
    }
    .width('100%')
    .height('100%')
    .padding(20)
  }



  build() {
    if (this.isLoggedIn) {
      Tabs({ barPosition: BarPosition.End }) {
        TabContent() {
          // 首页
          this.buildHomePage()
        }
        .backgroundColor('#F1F3F5')
        .tabBar(this.TabBarBuilder('首页', 0, '🏠', '🏡'))

        TabContent() {
          // 活动
          ActivitiesPage()
        }
        .backgroundColor('#F1F3F5')
        .tabBar(this.TabBarBuilder('活动', 1, '🎯', '🚩'))

        TabContent() {
          // 记录
          RecordsPage()
        }
        .backgroundColor('#F1F3F5')
        .tabBar(this.TabBarBuilder('记录', 2, '📊', '📝'))

        TabContent() {
          // 排行
          RankingPage()
        }
        .backgroundColor('#F1F3F5')
        .tabBar(this.TabBarBuilder('排行', 3, '👑', '🏆'))

        TabContent() {
          // 我的
          ProfilePage()
        }
        .backgroundColor('#F1F3F5')
        .tabBar(this.TabBarBuilder('我的', 4, '😊', '👤'))
      }
      .width('100%')
      .height('100%')
      .onChange((index: number) => {
        this.index = index
      })
    } else {
      this.buildLoginPage()
    }
  }
}