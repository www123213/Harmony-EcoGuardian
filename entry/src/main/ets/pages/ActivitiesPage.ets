import { DataService } from '../service/DataService';
import { AuthService } from '../service/AuthService';
import { EcoActivity } from '../model/User';
import { router } from '@kit.ArkUI';
import { promptAction } from '@kit.ArkUI';

@Entry
@Component
export struct ActivitiesPage {
  @State activities: EcoActivity[] = []
  @State selectedFilter: string = '全部'
  @State isLoading: boolean = true
  @State currentUserId: string = ''
  @State filteredActivities: EcoActivity[] = [];
  
  // 监听活动数据更新标志
  @State activitiesUpdated: number = 0;
  
  private dataService: DataService = DataService.getInstance();
  private authService: AuthService = AuthService.getInstance();
  private filters: string[] = ['全部', '即将开始', '进行中', '已结束'];
  private activityTypes: string[] = ['全部', '垃圾分类', '植树造林', '海滩清理', '环保教育'];

  async aboutToAppear() {
    // 初始化数据
    this.activitiesUpdated = 0;
    await this.loadData();
  }
  
  // 添加页面显示时的生命周期钩子
  async onPageShow() {
    console.log('ActivitiesPage: onPageShow 刷新数据');
    // 检查是否需要刷新数据
    if (this.activitiesUpdated > 0) {
      console.log('ActivitiesPage: 检测到数据更新，刷新活动列表');
    }
    await this.loadData();
  }

  build() {
    Column() {
      // 顶部导航
      Row() {
        Row() {
          Button('← 返回')
            .backgroundColor(Color.Transparent)
            .fontColor('#333')
            .height(40)
            .onClick(() => {
              router.back()
            })
        }
        .width('33%')
        .alignItems(VerticalAlign.Center)
        .justifyContent(FlexAlign.Start)

        Row() {
          Text('公益活动')
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
        }
        .width('34%')
        .alignItems(VerticalAlign.Center)
        .justifyContent(FlexAlign.Center)

        Row() {
          Button(){
            Text('+')
              .fontSize(24)
              .fontColor('#fff')
          }
          .width(30)
          .height(30)
          .backgroundColor('#4CAF50')
          .borderRadius(20)
          .onClick(() => {
            router.pushUrl({ url: 'pages/CreateActivityPage' });
          })
        }
        .width('33%')
        .alignItems(VerticalAlign.Center)
        .justifyContent(FlexAlign.End)
      }
      .width('100%')
      .height(56)
      .padding({ left: 16, right: 16 })
      .backgroundColor('#fff')

      Column() {
        // 筛选标签
        Scroll() {
          Row({ space: 10 }) {
            ForEach(this.filters, (filter: string) => {
              Text(filter)
                .fontSize(14)
                .fontColor(this.selectedFilter === filter ? '#fff' : '#333')
                .backgroundColor(this.selectedFilter === filter ? '#4CAF50' : '#f0f0f0')
                .padding({ top: 6, bottom: 6, left: 12, right: 12 })
                .borderRadius(15)
                .onClick(() => {
                  this.selectedFilter = filter
                  this.updateFilteredActivities()
                })
            })
          }
          .padding({ left: 16, right: 16 })
        }
        .scrollable(ScrollDirection.Horizontal)
        .scrollBar(BarState.Off)
        .height(40)
        .margin({ top: 10 })

        // 活动列表
        if (this.isLoading) {
          Column() {
            Text('加载中...')
              .fontSize(16)
              .fontColor('#666')
          }
          .width('100%')
          .height(200)
          .justifyContent(FlexAlign.Center)
        } else if (this.filteredActivities.length === 0) {
          Column({ space: 20 }) {
            Text('🎯')
              .fontSize(60)
            Text('暂无活动')
              .fontSize(18)
              .fontColor('#666')
            Text('成为第一个发起活动的人吧！')
              .fontSize(14)
              .fontColor('#999')
            
            Button('发起活动')
              .backgroundColor('#4CAF50')
              .borderRadius(20)
              .onClick(() => {
                router.pushUrl({ url: 'pages/CreateActivityPage' });
              })
          }
          .width('100%')
          .height(300)
          .justifyContent(FlexAlign.Center)
        } else {
          List({ space: 15 }) {
            ForEach(this.filteredActivities, (activity: EcoActivity) => {
              ListItem() {
                this.buildActivityItem(activity)
              }
            })
          }
          .width('100%')
          .layoutWeight(1)
          .padding({ left: 16, right: 16, top: 10, bottom: 16 })
        }
      }
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#f5f5f5')
  }

  @Builder buildActivityItem(activity: EcoActivity) {
    Column({ space: 12 }) {
      // 活动标题和状态
      Row() {
        Text(activity.title)
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333')
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .layoutWeight(1)
        
        Text(this.getActivityStatus(activity))
          .fontSize(12)
          .fontColor('#fff')
          .backgroundColor(this.getStatusColor(activity))
          .padding({ top: 4, bottom: 4, left: 8, right: 8 })
          .borderRadius(10)
      }
      .width('100%')
      .alignItems(VerticalAlign.Top)

      // 活动类型和积分
      Row() {
        Text(`🏷️ ${activity.type}`)
          .fontSize(12)
          .fontColor('#4CAF50')
          .backgroundColor('#E8F5E8')
          .padding({ top: 4, bottom: 4, left: 8, right: 8 })
          .borderRadius(8)
        
        Blank()
        
        Text(`🎁 ${activity.points}积分`)
          .fontSize(12)
          .fontColor('#FF9800')
          .fontWeight(FontWeight.Bold)
      }
      .width('100%')

      // 活动描述
      Text(activity.description)
        .fontSize(14)
        .fontColor('#666')
        .maxLines(2)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .lineHeight(20)

      // 时间和地点
      Column({ space: 6 }) {
        Row() {
          Text('🕐')
            .fontSize(14)
          Text(`${this.formatDateTime(activity.startTime)} - ${this.formatDateTime(activity.endTime)}`)
            .fontSize(12)
            .fontColor('#666')
            .layoutWeight(1)
        }
        .width('100%')
        
        Row() {
          Text('📍')
            .fontSize(14)
          Text(activity.location)
            .fontSize(12)
            .fontColor('#666')
            .layoutWeight(1)
        }
        .width('100%')
      }

      // 参与人数和操作按钮
      Row() {
        Column({ space: 4 }) {
          Text(`${activity.currentParticipants}/${activity.maxParticipants}`)
            .fontSize(14)
            .fontWeight(FontWeight.Bold)
            .fontColor('#333')
          Text('参与人数')
            .fontSize(10)
            .fontColor('#999')
        }
        
        Blank()
        
        Row({ space: 10 }) {
          Text(`${activity.isLikedByUser(this.currentUserId) ? '❤️' : '🤍'} ${activity.likes}`)
            .fontSize(12)
            .fontColor(activity.isLikedByUser(this.currentUserId) ? '#FF5722' : '#999')
            .onClick(() => {
              this.likeActivity(activity)
            })
          
          Text(`💬 ${activity.comments.length}`)
            .fontSize(12)
            .fontColor('#999')
            .onClick(() => {
              this.viewActivityDetail(activity)
            })
        }
        
        Blank()
        
        if (this.canParticipate(activity)) {
          Button('参与')
            .height(32)
            .backgroundColor('#4CAF50')
            .borderRadius(16)
            .fontSize(12)
            .onClick(() => {
              this.participateActivity(activity)
            })
        } else if (this.isParticipating(activity)) {
          Button('已参与')
            .height(32)
            .backgroundColor('#ccc')
            .borderRadius(16)
            .fontSize(12)
            .enabled(false)
        } else {
          Button('已满')
            .height(32)
            .backgroundColor('#f44336')
            .borderRadius(16)
            .fontSize(12)
            .enabled(false)
        }
      }
      .width('100%')
      .alignItems(VerticalAlign.Center)
    }
    .width('100%')
    .padding(15)
    .backgroundColor('#fff')
    .borderRadius(10)
    .onClick(() => {
      this.viewActivityDetail(activity)
    })
  }

  private async loadData() {
    try {
      // 初始化数据服务
      await this.dataService.init(getContext(this))
      
      // 获取当前用户ID
      const currentUser = await this.authService.getCurrentUser()
      this.currentUserId = currentUser?.id || ''
      
      // 加载活动数据
      this.activities = await this.dataService.getEcoActivities()
      
      // 检查是否存在乱码数据
      const hasCorruptedData = this.activities.some(activity => 
        !activity.title || activity.title.length > 50 || /^[0-9a-f]{10,}/.test(activity.title)
      );
      
      if (hasCorruptedData) {
        console.log('检测到乱码数据，正在清理...');
        await this.dataService.clearCorruptedActivityData();
        await this.dataService.initSampleData();
        this.activities = await this.dataService.getEcoActivities();
      }
      
      // 更新活动状态
      this.updateActivityStatus()
      
      // 更新过滤结果
      this.updateFilteredActivities()
    } catch (error) {
      console.error('加载活动数据失败:', error)
      promptAction.showToast({ message: '加载失败，请重试' })
    } finally {
      this.isLoading = false;
    }
  }

  private updateActivityStatus() {
    const now = new Date()
    this.activities.forEach(activity => {
      if (now < activity.startTime) {
        activity.status = 'upcoming'
      } else if (now >= activity.startTime && now <= activity.endTime) {
        activity.status = 'ongoing'
      } else {
        activity.status = 'completed'
      }
    })
  }

  private updateFilteredActivities() {
    let filtered = this.activities

    if (this.selectedFilter !== '全部') {
      switch (this.selectedFilter) {
        case '即将开始':
          filtered = filtered.filter(activity => activity.status === 'upcoming')
          break
        case '进行中':
          filtered = filtered.filter(activity => activity.status === 'ongoing')
          break
        case '已结束':
          filtered = filtered.filter(activity => activity.status === 'completed')
          break
        case '植树造林':
        case '垃圾分类':
        case '节能减排':
        case '环保宣传':
          filtered = filtered.filter(activity => activity.type === this.selectedFilter)
          break
      }
    }

    // 按开始时间排序
    this.filteredActivities = filtered.sort((a, b) => a.startTime.getTime() - b.startTime.getTime())
  }

  private getActivityStatus(activity: EcoActivity): string {
    switch (activity.status) {
      case 'upcoming':
        return '即将开始'
      case 'ongoing':
        return '进行中'
      case 'completed':
        return '已结束'
      default:
        return '未知'
    }
  }

  private getStatusColor(activity: EcoActivity): string {
    switch (activity.status) {
      case 'upcoming':
        return '#2196F3'
      case 'ongoing':
        return '#4CAF50'
      case 'completed':
        return '#9E9E9E'
      default:
        return '#9E9E9E'
    }
  }

  private canParticipate(activity: EcoActivity): boolean {
    return activity.status === 'upcoming' && 
           activity.currentParticipants < activity.maxParticipants &&
           !this.isParticipating(activity)
  }

  private isParticipating(activity: EcoActivity): boolean {
    return activity.participants.includes(this.currentUserId)
  }

  private async participateActivity(activity: EcoActivity) {
    if (!this.currentUserId) {
      promptAction.showToast({ message: '请先登录' })
      router.pushUrl({ url: 'pages/LoginPage' })
      return
    }

    try {
      const success = activity.addParticipant(this.currentUserId)
      if (success) {
        await this.dataService.saveEcoActivity(activity)
        promptAction.showToast({ message: '参与成功！' })
        // 刷新列表
        this.activities = [...this.activities]
        this.updateFilteredActivities()
      } else {
        promptAction.showToast({ message: '参与失败，活动可能已满' })
      }
    } catch (error) {
      console.error('参与活动失败:', error)
      promptAction.showToast({ message: '参与失败，请重试' })
    }
  }

  private async likeActivity(activity: EcoActivity) {
    try {
      if (!this.currentUserId) {
        promptAction.showToast({ message: '请先登录' });
        return;
      }

      // 使用新的toggleLike方法
      const isLiked = activity.toggleLike(this.currentUserId);

      await this.dataService.saveEcoActivity(activity);

      promptAction.showToast({
        message: isLiked ? '点赞成功！' : '已取消点赞'
      });

      // 刷新列表
      this.activities = [...this.activities];
      this.updateFilteredActivities();
    } catch (error) {
      console.error('点赞操作失败:', error);
    }
  }

  private viewActivityDetail(activity: EcoActivity) {
    // 简化版详情显示
    const detailInfo = `活动详情：\n\n${activity.description}\n\n时间：${this.formatDateTime(activity.startTime)} - ${this.formatDateTime(activity.endTime)}\n\n地点：${activity.location}\n\n参与人数：${activity.currentParticipants}/${activity.maxParticipants}\n\n积分奖励：${activity.points}分`
    
    promptAction.showDialog({
      title: activity.title,
      message: detailInfo,
      buttons: [
        {
          text: '关闭',
          color: '#666'
        }
      ]
    })
  }

  private formatDateTime(date: Date): string {
    const month = (date.getMonth() + 1).toString().padStart(2, '0')
    const day = date.getDate().toString().padStart(2, '0')
    const hours = date.getHours().toString().padStart(2, '0')
    const minutes = date.getMinutes().toString().padStart(2, '0')
    return `${month}/${day} ${hours}:${minutes}`
  }
}