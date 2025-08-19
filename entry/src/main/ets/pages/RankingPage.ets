import { DataService } from '../service/DataService';
import { AuthService } from '../service/AuthService';
import { CarbonCalculator } from '../service/CarbonCalculator';
import { User } from '../model/User';
import { router } from '@kit.ArkUI';
import { promptAction } from '@kit.ArkUI';

// 勋章接口
interface Badge {
  name: string;
  requirement: string;
  icon: string;
}

@Entry
@Component
export struct RankingPage {
  @State userRanking: User[] = [];
  @State currentUser: User | null = null;
  @State selectedTab: number = 0; // 0: 积分排行, 1: 减排排行, 2: 勋章展示
  @State isLoading: boolean = true;
  @State myRanking: number = 0;
  
  private dataService: DataService = DataService.getInstance();
  private authService: AuthService = AuthService.getInstance();
  private carbonCalculator: CarbonCalculator = CarbonCalculator.getInstance();
  private tabs: string[] = ['积分排行', '减排排行', '勋章展示'];

  async aboutToAppear() {
    await this.loadRankingData();

    // 创建AppStorage监听
    AppStorage.SetOrCreate('userDataUpdated', 0);
  }

  async onPageShow() {
    // 重新加载排行榜数据
    this.currentUser = await this.authService.getCurrentUser(true); // 强制刷新用户数据
    await this.loadRankingData();
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
        
        Text('排行榜')
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

      Column() {
        // 标签切换
        Row() {
          ForEach(this.tabs, (tab: string, index: number) => {
            Text(tab)
              .fontSize(16)
              .fontColor(this.selectedTab === index ? '#4CAF50' : '#666')
              .fontWeight(this.selectedTab === index ? FontWeight.Bold : FontWeight.Normal)
              .padding({ top: 10, bottom: 10 })
              .layoutWeight(1)
              .textAlign(TextAlign.Center)
              .onClick(() => {
                this.selectedTab = index;
              })
          })
        }
        .width('100%')
        .backgroundColor('#fff')
        .border({ width: { bottom: 1 }, color: '#e0e0e0' })

        // 我的排名卡片
        if (this.currentUser && this.myRanking > 0) {
          this.buildMyRankingCard()
        }

        // 排行榜内容
        if (this.isLoading) {
          Column() {
            Text('加载中...')
              .fontSize(16)
              .fontColor('#666')
          }
          .width('100%')
          .height(200)
          .justifyContent(FlexAlign.Center)
        } else {
          if (this.selectedTab === 0) {
            this.buildPointsRanking()
          } else if (this.selectedTab === 1) {
            this.buildCarbonRanking()
          } else {
            this.buildBadgesDisplay()
          }
        }
      }
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#f5f5f5')
  }

  @Builder buildMyRankingCard() {
    Column({ space: 10 }) {
      Text('我的排名')
        .fontSize(14)
        .fontColor('#666')
      
      Row() {
        Text(this.currentUser?.avatar || '🌱')
          .fontSize(30)
        
        Column({ space: 4 }) {
          Text(this.currentUser?.username || '')
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
          
          if (this.selectedTab === 0) {
            Text(`${this.currentUser?.points || 0} 积分`)
              .fontSize(14)
              .fontColor('#4CAF50')
          } else {
            Text(this.carbonCalculator.formatCarbonReduction(this.currentUser?.carbonReduction || 0))
              .fontSize(14)
              .fontColor('#4CAF50')
          }
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)
        .margin({ left: 10 })
        
        Column({ space: 4 }) {
          Text(`第${this.myRanking}名`)
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor('#FF9800')
          Text('当前排名')
            .fontSize(12)
            .fontColor('#999')
        }
        .alignItems(HorizontalAlign.Center)
      }
      .width('100%')
    }
    .width('100%')
    .padding(15)
    .backgroundColor('#FFF3E0')
    .borderRadius(10)
    .margin({ left: 16, right: 16, top: 10 })
  }

  @Builder buildPointsRanking() {
    List({ space: 8 }) {
      ForEach(this.userRanking, (user: User, index: number) => {
        ListItem() {
          this.buildRankingItem(user, index + 1, 'points')
        }
      })
    }
    .width('100%')
    .layoutWeight(1)
    .padding({ left: 16, right: 16, top: 10, bottom: 16 })
  }

  @Builder buildCarbonRanking() {
    List({ space: 8 }) {
      ForEach(this.getCarbonRanking(), (user: User, index: number) => {
        ListItem() {
          this.buildRankingItem(user, index + 1, 'carbon')
        }
      })
    }
    .width('100%')
    .layoutWeight(1)
    .padding({ left: 16, right: 16, top: 10, bottom: 16 })
  }

  @Builder buildBadgesDisplay() {
    Scroll() {
      Column({ space: 20 }) {
        // 我的勋章
        if (this.currentUser && this.currentUser.badges.length > 0) {
          Column({ space: 10 }) {
            Text('我的勋章')
              .fontSize(16)
              .fontWeight(FontWeight.Bold)
              .alignSelf(ItemAlign.Start)
            
            Grid() {
              ForEach(this.currentUser.badges, (badge: string) => {
                GridItem() {
                  this.buildBadgeItem(badge, true)
                }
              })
            }
            .columnsTemplate('1fr 1fr 1fr')
            .rowsGap(10)
            .columnsGap(10)
          }
          .width('100%')
          .alignItems(HorizontalAlign.Start)
        }

        // 所有勋章
        Column({ space: 10 }) {
          Text('勋章系统')
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
            .alignSelf(ItemAlign.Start)
          
          Text('通过环保行为获得不同等级的勋章')
            .fontSize(12)
            .fontColor('#666')
            .alignSelf(ItemAlign.Start)
          
          Grid() {
            ForEach(this.getAllBadges(), (badge: Badge) => {
              GridItem() {
                this.buildBadgeItem(badge.name, this.currentUser?.badges.includes(badge.name) || false, badge.requirement, badge.icon)
              }
            })
          }
          .columnsTemplate('1fr 1fr')
          .rowsGap(15)
          .columnsGap(15)
        }
        .width('100%')
        .alignItems(HorizontalAlign.Start)
      }
      .padding(16)
    }
    .layoutWeight(1)
  }

  @Builder buildRankingItem(user: User, rank: number, type: string) {
    Row() {
      // 排名
      Text(rank.toString())
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.getRankColor(rank))
        .width(40)
        .textAlign(TextAlign.Center)
      
      // 头像
      Text(user.avatar || '🌱')
        .fontSize(24)
        .margin({ left: 10, right: 10 })
      
      // 用户信息
      Column({ space: 4 }) {
        Text(user.username)
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333')
        
        Text(`等级 ${user.level}`)
          .fontSize(12)
          .fontColor('#999')
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)
      
      // 积分或减排量
      Column({ space: 4 }) {
        if (type === 'points') {
          Text(`${user.points}`)
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
            .fontColor('#4CAF50')
          Text('积分')
            .fontSize(12)
            .fontColor('#999')
        } else {
          Text(this.carbonCalculator.formatCarbonReduction(user.carbonReduction))
            .fontSize(14)
            .fontWeight(FontWeight.Bold)
            .fontColor('#4CAF50')
          Text('减排量')
            .fontSize(12)
            .fontColor('#999')
        }
      }
      .alignItems(HorizontalAlign.End)
      
      // 排名图标
      if (rank <= 3) {
        Text(this.getRankIcon(rank))
          .fontSize(20)
          .margin({ left: 10 })
      }
    }
    .width('100%')
    .padding(15)
    .backgroundColor(user.id === this.currentUser?.id ? '#E8F5E8' : '#fff')
    .borderRadius(10)
    .border({
      width: user.id === this.currentUser?.id ? 2 : 0,
      color: '#4CAF50'
    })
  }

  @Builder buildBadgeItem(badgeName: string, earned: boolean, requirement?: string, icon?: string) {
    Column({ space: 8 }) {
      Text(icon || this.getBadgeIcon(badgeName))
        .fontSize(30)
        .opacity(earned ? 1 : 0.3)
      
      Text(badgeName)
        .fontSize(12)
        .fontWeight(FontWeight.Bold)
        .fontColor(earned ? '#333' : '#999')
        .textAlign(TextAlign.Center)
      
      if (requirement) {
        Text(requirement)
          .fontSize(10)
          .fontColor('#666')
          .textAlign(TextAlign.Center)
          .maxLines(2)
      }
    }
    .width('100%')
    .padding(10)
    .backgroundColor(earned ? '#E8F5E8' : '#f8f8f8')
    .borderRadius(8)
    .border({
      width: earned ? 2 : 1,
      color: earned ? '#4CAF50' : '#e0e0e0'
    })
  }

  private async loadRankingData() {
    try {
      // 获取当前用户
      this.currentUser = await this.authService.getCurrentUser()
      
      // 获取积分排行榜
      this.userRanking = await this.dataService.getPointsRanking()
      
      // 计算我的排名
      if (this.currentUser) {
        this.myRanking = this.userRanking.findIndex(user => user.id === this.currentUser?.id) + 1;
      }
    } catch (error) {
      console.error('加载排行榜数据失败:', error)
      promptAction.showToast({ message: '加载失败，请重试' })
    } finally {
      this.isLoading = false;
    }
  }

  private getCarbonRanking(): User[] {
    return [...this.userRanking].sort((a, b) => b.carbonReduction - a.carbonReduction);
  }

  private getRankColor(rank: number): string {
    switch (rank) {
      case 1:
        return '#FFD700' // 金色
      case 2:
        return '#C0C0C0' // 银色
      case 3:
        return '#CD7F32' // 铜色
      default:
        return '#666'
    }
  }

  private getRankIcon(rank: number): string {
    switch (rank) {
      case 1:
        return '🥇'
      case 2:
        return '🥈'
      case 3:
        return '🥉'
      default:
        return ''
    }
  }

  private getBadgeIcon(badgeName: string): string {
    const iconMap: Record<string, string> = {
      '环保新手': '🌱',
      '环保达人': '🌿',
      '环保专家': '🌳',
      '环保大使': '🏆',
      '环保卫士': '👑',
      '节水达人': '💧',
      '低碳出行': '🚲',
      '垃圾分类': '♻️',
      '植树造林': '🌲',
      '清洁海洋': '🌊'
    }
    return iconMap[badgeName] || '🏅';
  }

  private getAllBadges(): Badge[] {
    const badges: Badge[] = [
      { name: '环保新手', requirement: '减排10kg CO₂', icon: '🌱' },
      { name: '环保达人', requirement: '减排50kg CO₂', icon: '🌿' },
      { name: '环保专家', requirement: '减排100kg CO₂', icon: '🌳' },
      { name: '环保大使', requirement: '减排500kg CO₂', icon: '🏆' },
      { name: '环保卫士', requirement: '减排1000kg CO₂', icon: '👑' },
      { name: '节水达人', requirement: '节水行为20次', icon: '💧' },
      { name: '低碳出行', requirement: '绿色出行50次', icon: '🚲' },
      { name: '垃圾分类', requirement: '垃圾分类30次', icon: '♻️' },
      { name: '植树造林', requirement: '种植树木10棵', icon: '🌲' },
      { name: '清洁海洋', requirement: '参与清洁活动5次', icon: '🌊' }
    ];
    return badges;
  }
}