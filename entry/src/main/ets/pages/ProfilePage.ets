import { DataService } from '../service/DataService';
import { AuthService } from '../service/AuthService';
import { CarbonCalculator } from '../service/CarbonCalculator';
import { User, EcoRecord } from '../model/User';
import { router } from '@kit.ArkUI';
import { promptAction } from '@kit.ArkUI';

@Entry
@Component
export struct ProfilePage {
  @State currentUser: User | null = null;
  @State userRecords: EcoRecord[] = [];
  @State isLoading: boolean = true;
  @State showLogoutDialog: boolean = false;
  @State showEditDialog: boolean = false;
  @State editUsername: string = '';
  @State editAvatar: string = '';
  
  private dataService: DataService = DataService.getInstance();
  private authService: AuthService = AuthService.getInstance();
  private carbonCalculator: CarbonCalculator = CarbonCalculator.getInstance();
  private avatarOptions: string[] = ['🌱', '🌿', '🌳', '🌲', '🍃', '🌺', '🌻', '🌼', '🌷', '🌹'];

  async aboutToAppear() {
    await this.loadUserData();
    // 初始化AppStorage
    AppStorage.SetOrCreate('userDataUpdated', 0);
  }

  async onPageShow() {
    // 每次页面显示时强制重新加载最新数据
    this.isLoading = true;
    await this.loadUserData(true);
  }

  build() {
    Column() {
      if (this.isLoading) {
        Column() {
          Text('加载中...')
            .fontSize(16)
            .fontColor('#666')
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Center)
      } else if (this.currentUser) {
        this.buildProfileContent()
      } else {
        this.buildLoginPrompt()
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#f5f5f5')
  }

  @Builder buildProfileContent() {
    Scroll() {
      Column({ space: 16 }) {
        // 用户信息卡片
        this.buildUserInfoCard()
        
        // 统计数据卡片
        this.buildStatsCard()
        
        // 勋章展示
        this.buildBadgesCard()
        
        // 功能菜单
        this.buildMenuCard()
        
        // 退出登录按钮
        Button('退出登录')
          .width('100%')
          .height(48)
          .backgroundColor('#FF5722')
          .fontColor('#fff')
          .fontSize(16)
          .borderRadius(8)
          .onClick(() => {
            this.showLogoutDialog = true
          })
      }
      .padding(16)
    }
    .layoutWeight(1)
    
    // 退出登录确认对话框
    if (this.showLogoutDialog) {
      this.buildLogoutDialog()
    }
    
    // 编辑用户信息对话框
    if (this.showEditDialog) {
      this.buildEditDialog()
    }
  }

  @Builder buildUserInfoCard() {
    Column({ space: 15 }) {
      Row() {
        // 头像
        Text(this.currentUser?.avatar || '🌱')
          .fontSize(50)
          .width(80)
          .height(80)
          .backgroundColor('#E8F5E8')
          .borderRadius(40)
          .textAlign(TextAlign.Center)
          .onClick(() => {
            this.editUsername = this.currentUser?.username || ''
            this.editAvatar = this.currentUser?.avatar || '🌱'
            this.showEditDialog = true
          })
        
        Column({ space: 8 }) {
          Text(this.currentUser?.username || '')
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .fontColor('#333')
          
          Text(`等级 ${this.currentUser?.level || 1}`)
            .fontSize(14)
            .fontColor('#4CAF50')
            .backgroundColor('#E8F5E8')
            .padding({ top: 4, bottom: 4, left: 8, right: 8 })
            .borderRadius(12)
          
          Text(this.currentUser?.email || '')
            .fontSize(12)
            .fontColor('#666')
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)
        .margin({ left: 15 })
        
        Button('编辑')
          .backgroundColor('#4CAF50')
          .fontColor('#fff')
          .fontSize(12)
          .padding({ top: 6, bottom: 6, left: 12, right: 12 })
          .borderRadius(15)
          .onClick(() => {
            this.editUsername = this.currentUser?.username || ''
            this.editAvatar = this.currentUser?.avatar || '🌱'
            this.showEditDialog = true
          })
      }
      .width('100%')
      .alignItems(VerticalAlign.Center)
      
      // 加入时间
      Text(`加入时间：${this.formatDate(this.currentUser?.createdAt || '')}`)
        .fontSize(12)
        .fontColor('#999')
        .alignSelf(ItemAlign.Start)
    }
    .width('100%')
    .padding(20)
    .backgroundColor('#fff')
    .borderRadius(12)
  }

  @Builder buildStatsCard() {
    Column({ space: 15 }) {
      Text('我的环保数据')
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .alignSelf(ItemAlign.Start)
      
      Row() {
        this.buildStatItem('总积分', (this.currentUser?.points || 0).toString(), '#FF9800')
        this.buildStatItem('减排量', this.carbonCalculator.formatCarbonReduction(this.currentUser?.carbonReduction || 0), '#4CAF50')
        this.buildStatItem('记录数', this.userRecords.length.toString(), '#2196F3')
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      
      Row() {
        this.buildStatItem('勋章数', (this.currentUser?.badges.length || 0).toString(), '#9C27B0')
        this.buildStatItem('等级', `Lv.${this.currentUser?.level || 1}`, '#607D8B')
        this.buildStatItem('排名', this.getUserRanking(), '#E91E63')
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
    }
    .width('100%')
    .padding(20)
    .backgroundColor('#fff')
    .borderRadius(12)
  }

  @Builder buildStatItem(label: string, value: string, color: string) {
    Column({ space: 5 }) {
      Text(value)
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor(color)
      Text(label)
        .fontSize(12)
        .fontColor('#666')
    }
    .alignItems(HorizontalAlign.Center)
    .layoutWeight(1)
  }

  @Builder buildBadgesCard() {
    Column({ space: 15 }) {
      Row() {
        Text('我的勋章')
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
        
        Blank()
        
        Text(`${this.currentUser?.badges.length || 0}/10`)
          .fontSize(12)
          .fontColor('#666')
      }
      .width('100%')
      
      if (this.currentUser?.badges && this.currentUser.badges.length > 0) {
        Grid() {
          ForEach(this.currentUser.badges.slice(0, 6), (badge: string) => {
            GridItem() {
              Column({ space: 4 }) {
                Text(this.getBadgeIcon(badge))
                  .fontSize(24)
                Text(badge)
                  .fontSize(10)
                  .fontColor('#333')
                  .textAlign(TextAlign.Center)
                  .maxLines(1)
              }
              .width('100%')
              .padding(8)
              .backgroundColor('#E8F5E8')
              .borderRadius(8)
            }
          })
          
          if (this.currentUser.badges.length > 6) {
            GridItem() {
              Column({ space: 4 }) {
                Text('+')
                  .fontSize(20)
                  .fontWeight(FontWeight.Bold)
                Text(`${this.currentUser.badges.length - 6}个`)
                  .fontSize(10)
                  .fontColor('#666')
              }
              .width('100%')
              .padding(8)
              .backgroundColor('#f0f0f0')
              .borderRadius(8)
              .onClick(() => {
                router.pushUrl({ url: 'pages/RankingPage' })
              })
            }
          }
        }
        .columnsTemplate('1fr 1fr 1fr')
        .rowsGap(8)
        .columnsGap(8)
      } else {
        Text('暂无勋章，快去参与环保活动获得勋章吧！')
          .fontSize(12)
          .fontColor('#999')
          .textAlign(TextAlign.Center)
          .padding(20)
      }
    }
    .width('100%')
    .padding(20)
    .backgroundColor('#fff')
    .borderRadius(12)
  }

  @Builder buildMenuCard() {
    Column() {
      this.buildMenuItem('📊', '我的记录', '查看环保记录详情', () => {
        // 跳转到记录页面
        router.pushUrl({ url: 'pages/RecordPage'})
      })
      
      Divider().color('#f0f0f0')
      
      this.buildMenuItem('🏆', '排行榜', '查看积分和减排排名', () => {
        router.pushUrl({ url: 'pages/RankingPage' })
      })
      
      Divider().color('#f0f0f0')
      
      this.buildMenuItem('📚', '环保知识', '学习环保小知识', () => {
        router.pushUrl({ url: 'pages/KnowledgePage' })
      })
      
      Divider().color('#f0f0f0')
      
      this.buildMenuItem('⚙️', '设置', '应用设置和偏好', () => {
        promptAction.showToast({ message: '设置功能开发中...' })
      })
      
      Divider().color('#f0f0f0')
      
      this.buildMenuItem('❓', '帮助与反馈', '获取帮助或提供反馈', () => {
        promptAction.showToast({ message: '帮助功能开发中...' })
      })
    }
    .width('100%')
    .backgroundColor('#fff')
    .borderRadius(12)
  }

  @Builder buildMenuItem(icon: string, title: string, subtitle: string, onClick: () => void) {
    Row() {
      Text(icon)
        .fontSize(20)
        .width(40)
      
      Column({ space: 4 }) {
        Text(title)
          .fontSize(14)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333')
          .alignSelf(ItemAlign.Start)
        Text(subtitle)
          .fontSize(12)
          .fontColor('#666')
          .alignSelf(ItemAlign.Start)
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)
      .margin({ left: 10 })
      
      Text('>')
        .fontSize(16)
        .fontColor('#ccc')
    }
    .width('100%')
    .padding(15)
    .onClick(onClick)
  }

  @Builder buildLoginPrompt() {
    Column({ space: 20 }) {
      Text('🌱')
        .fontSize(80)
      
      Text('请先登录')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor('#333')
      
      Text('登录后可以查看个人信息和环保数据')
        .fontSize(14)
        .fontColor('#666')
        .textAlign(TextAlign.Center)
      
      Button('去登录')
        .width(200)
        .height(44)
        .backgroundColor('#4CAF50')
        .fontColor('#fff')
        .fontSize(16)
        .borderRadius(22)
        .onClick(() => {
          router.pushUrl({ url: 'pages/LoginPage' })
        })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .padding(40)
  }

  @Builder buildLogoutDialog() {
    Column() {
      Column({ space: 20 }) {
        Text('确认退出')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
        
        Text('确定要退出登录吗？')
          .fontSize(14)
          .fontColor('#666')
        
        Row({ space: 15 }) {
          Button('取消')
            .layoutWeight(1)
            .backgroundColor('#f0f0f0')
            .fontColor('#333')
            .onClick(() => {
              this.showLogoutDialog = false
            })
          
          Button('确定')
            .layoutWeight(1)
            .backgroundColor('#FF5722')
            .fontColor('#fff')
            .onClick(async () => {
              await this.authService.logout()
              this.showLogoutDialog = false
              this.currentUser = null
              promptAction.showToast({ message: '已退出登录' })
            })
        }
        .width('100%')
      }
      .width(280)
      .padding(20)
      .backgroundColor('#fff')
      .borderRadius(12)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('rgba(0,0,0,0.5)')
    .justifyContent(FlexAlign.Center)
    .onClick(() => {
      this.showLogoutDialog = false
    })
  }

  @Builder buildEditDialog() {
    Column() {
      Column({ space: 20 }) {
        Text('编辑个人信息')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
        
        Column({ space: 15 }) {
          Column({ space: 8 }) {
            Text('用户名')
              .fontSize(14)
              .fontWeight(FontWeight.Bold)
              .alignSelf(ItemAlign.Start)
            
            TextInput({ text: this.editUsername })
              .onChange((value: string) => {
                this.editUsername = value
              })
          }
          .alignItems(HorizontalAlign.Start)
          .width('100%')
          
          Column({ space: 8 }) {
            Text('选择头像')
              .fontSize(14)
              .fontWeight(FontWeight.Bold)
              .alignSelf(ItemAlign.Start)
            
            Grid() {
              ForEach(this.avatarOptions, (avatar: string) => {
                GridItem() {
                  Text(avatar)
                    .fontSize(24)
                    .width(40)
                    .height(40)
                    .backgroundColor(this.editAvatar === avatar ? '#E8F5E8' : '#f8f8f8')
                    .borderRadius(20)
                    .textAlign(TextAlign.Center)
                    .border({
                      width: this.editAvatar === avatar ? 2 : 0,
                      color: '#4CAF50'
                    })
                    .onClick(() => {
                      this.editAvatar = avatar
                    })
                }
              })
            }
            .columnsTemplate('1fr 1fr 1fr 1fr 1fr')
            .rowsGap(8)
            .columnsGap(8)
          }
          .alignItems(HorizontalAlign.Start)
          .width('100%')
        }
        
        Row({ space: 15 }) {
          Button('取消')
            .layoutWeight(1)
            .backgroundColor('#f0f0f0')
            .fontColor('#333')
            .onClick(() => {
              this.showEditDialog = false
            })
          
          Button('保存')
            .layoutWeight(1)
            .backgroundColor('#4CAF50')
            .fontColor('#fff')
            .onClick(async () => {
              await this.saveUserInfo()
            })
        }
        .width('100%')
      }
      .width(320)
      .height(500)
      .padding(20)
      .backgroundColor('#fff')
      .borderRadius(12)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('rgba(0,0,0,0.5)')
    .justifyContent(FlexAlign.Center)
    .onClick(() => {
      this.showEditDialog = false
    })
  }

  private async loadUserData(forceRefresh: boolean = false) {
    try {
      this.isLoading = true;
      this.currentUser = await this.authService.getCurrentUser(forceRefresh);
      if (this.currentUser) {
        this.userRecords = await this.dataService.getUserRecords(this.currentUser.id);
      }
    } catch (error) {
      console.error('加载用户数据失败:', error);
    } finally {
      this.isLoading = false;
    }
  }

  private async saveUserInfo() {
    if (!this.currentUser || !this.editUsername.trim()) {
      promptAction.showToast({ message: '用户名不能为空' });
      return;
    }

    try {
      const updatedUser = new User(this.editUsername.trim(), this.currentUser.email, this.currentUser.password);
      updatedUser.id = this.currentUser.id;
      updatedUser.avatar = this.editAvatar;
      updatedUser.points = this.currentUser.points;
      updatedUser.level = this.currentUser.level;
      updatedUser.joinDate = this.currentUser.joinDate;
      updatedUser.carbonReduction = this.currentUser.carbonReduction;
      updatedUser.badges = this.currentUser.badges;
      
      await this.authService.updateUserInfo(updatedUser);
      this.currentUser = updatedUser;
      this.showEditDialog = false;
      
      // 通知其他页面更新数据
      AppStorage.Set('userDataUpdated', new Date().getTime());
      
      // 显示成功提示
      promptAction.showToast({ message: '保存成功' });
      
      // 直接跳转到首页，确保数据刷新
      router.replaceUrl({ url: 'pages/Index' });
    } catch (error) {
      console.error('保存用户信息失败:', error);
      promptAction.showToast({ message: '保存失败，请重试' });
    }
  }

  private formatDate(dateStr: string): string {
    if (!dateStr) return '未知'
    const date = new Date(dateStr)
    return `${date.getFullYear()}-${(date.getMonth() + 1).toString().padStart(2, '0')}-${date.getDate().toString().padStart(2, '0')}`
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
    return iconMap[badgeName] || '🏅'
  }

  private getUserRanking(): string {
    // 这里应该从数据服务获取实际排名
    // 暂时返回模拟数据
    return '前10%'
  }
}