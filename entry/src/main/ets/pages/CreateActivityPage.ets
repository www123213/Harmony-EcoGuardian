import { DataService } from '../service/DataService';
import { AuthService } from '../service/AuthService';
import { EcoActivity } from '../model/User';
import { router } from '@kit.ArkUI';
import { promptAction } from '@kit.ArkUI';

@Entry
@Component
struct CreateActivityPage {
  @State title: string = '';
  @State description: string = '';
  @State location: string = '';
  @State selectedCategory: string = '垃圾清理';
  @State maxParticipants: number = 10;
  @State selectedDate: string = '';
  @State selectedTime: string = '';
  @State isSubmitting: boolean = false;
  
  private dataService: DataService = DataService.getInstance();
  private authService: AuthService = AuthService.getInstance();
  private categories: string[] = ['垃圾清理', '植树造林', '海滩清理', '环保宣传', '节能减排', '生态保护'];
  private participantOptions: number[] = [5, 10, 15, 20, 30, 50, 100];

  build() {
    Column() {
      // 顶部导航
      Row() {
        Button('取消')
          .backgroundColor(Color.Transparent)
          .fontColor('#666')
          .onClick(() => {
            router.back();
          })
        
        Blank()
        
        Text('发起活动')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
        
        Blank()
        
        Button('发布')
          .backgroundColor(this.canSubmit() ? '#4CAF50' : '#ccc')
          .fontColor('#fff')
          .enabled(this.canSubmit())
          .onClick(() => {
            this.submitActivity();
          })
      }
      .width('100%')
      .height(56)
      .padding({ left: 16, right: 16 })
      .backgroundColor('#fff')
      .border({ width: { bottom: 1 }, color: '#e0e0e0' })

      Scroll() {
        Column({ space: 20 }) {
          // 活动标题
          Column({ space: 8 }) {
            Row() {
              Text('活动标题')
                .fontSize(16)
                .fontWeight(FontWeight.Bold)
              Text('*')
                .fontSize(16)
                .fontColor('#FF5722')
            }
            .alignItems(VerticalAlign.Center)
            
            TextInput({ placeholder: '请输入活动标题' })
              .height(44)
              .backgroundColor('#f8f8f8')
              .borderRadius(8)
              .onChange((value: string) => {
                this.title = value;
              })
          }
          .alignItems(HorizontalAlign.Start)
          .width('100%')

          // 活动分类
          Column({ space: 8 }) {
            Text('活动分类')
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
                    .textAlign(TextAlign.Center)
                    .onClick(() => {
                      this.selectedCategory = category;
                    })
                }
              })
            }
            .columnsTemplate('1fr 1fr 1fr')
            .rowsGap(10)
            .columnsGap(10)
          }
          .alignItems(HorizontalAlign.Start)
          .width('100%')

          // 活动描述
          Column({ space: 8 }) {
            Row() {
              Text('活动描述')
                .fontSize(16)
                .fontWeight(FontWeight.Bold)
              Text('*')
                .fontSize(16)
                .fontColor('#FF5722')
            }
            .alignItems(VerticalAlign.Center)
            
            TextArea({ placeholder: '请详细描述活动内容、目标和注意事项...' })
              .height(100)
              .backgroundColor('#f8f8f8')
              .borderRadius(8)
              .onChange((value: string) => {
                this.description = value;
              })
          }
          .alignItems(HorizontalAlign.Start)
          .width('100%')

          // 活动地点
          Column({ space: 8 }) {
            Row() {
              Text('活动地点')
                .fontSize(16)
                .fontWeight(FontWeight.Bold)
              Text('*')
                .fontSize(16)
                .fontColor('#FF5722')
            }
            .alignItems(VerticalAlign.Center)
            
            TextInput({ placeholder: '请输入具体地址' })
              .height(44)
              .backgroundColor('#f8f8f8')
              .borderRadius(8)
              .onChange((value: string) => {
                this.location = value;
              })
          }
          .alignItems(HorizontalAlign.Start)
          .width('100%')

          // 活动时间
          Column({ space: 8 }) {
            Row() {
              Text('活动时间')
                .fontSize(16)
                .fontWeight(FontWeight.Bold)
              Text('*')
                .fontSize(16)
                .fontColor('#FF5722')
            }
            .alignItems(VerticalAlign.Center)
            
            Row({ space: 10 }) {
              TextInput({ placeholder: '选择日期 (YYYY-MM-DD)' })
                .layoutWeight(1)
                .height(44)
                .backgroundColor('#f8f8f8')
                .borderRadius(8)
                .onChange((value: string) => {
                  this.selectedDate = value;
                })
              
              TextInput({ placeholder: '选择时间 (HH:MM)' })
                .layoutWeight(1)
                .height(44)
                .backgroundColor('#f8f8f8')
                .borderRadius(8)
                .onChange((value: string) => {
                  this.selectedTime = value;
                })
            }
            .width('100%')
          }
          .alignItems(HorizontalAlign.Start)
          .width('100%')

          // 参与人数限制
          Column({ space: 8 }) {
            Text('参与人数限制')
              .fontSize(16)
              .fontWeight(FontWeight.Bold)
              .alignSelf(ItemAlign.Start)
            
            Row({ space: 10 }) {
              ForEach(this.participantOptions, (count: number) => {
                Text(`${count}人`)
                  .fontSize(14)
                  .fontColor(this.maxParticipants === count ? '#fff' : '#333')
                  .backgroundColor(this.maxParticipants === count ? '#4CAF50' : '#f0f0f0')
                  .padding({ top: 6, bottom: 6, left: 10, right: 10 })
                  .borderRadius(15)
                  .onClick(() => {
                    this.maxParticipants = count;
                  })
              })
            }
            .width('100%')
          }
          .alignItems(HorizontalAlign.Start)
          .width('100%')

          // 活动须知
          Column({ space: 8 }) {
            Text('活动须知')
              .fontSize(16)
              .fontWeight(FontWeight.Bold)
              .alignSelf(ItemAlign.Start)
            
            Column({ space: 5 }) {
              Text('• 请准时参加活动，如有特殊情况请提前联系组织者')
                .fontSize(12)
                .fontColor('#666')
                .alignSelf(ItemAlign.Start)
              Text('• 活动期间请注意安全，听从组织者安排')
                .fontSize(12)
                .fontColor('#666')
                .alignSelf(ItemAlign.Start)
              Text('• 建议穿着舒适的服装和运动鞋')
                .fontSize(12)
                .fontColor('#666')
                .alignSelf(ItemAlign.Start)
              Text('• 活动结束后请配合清理现场')
                .fontSize(12)
                .fontColor('#666')
                .alignSelf(ItemAlign.Start)
            }
            .width('100%')
            .padding(12)
            .backgroundColor('#f8f9fa')
            .borderRadius(8)
          }
          .alignItems(HorizontalAlign.Start)
          .width('100%')

          // 提交按钮
          Button(this.isSubmitting ? '发布中...' : '发布活动')
            .width('100%')
            .height(48)
            .backgroundColor(this.canSubmit() && !this.isSubmitting ? '#4CAF50' : '#ccc')
            .fontColor('#fff')
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
            .borderRadius(8)
            .enabled(this.canSubmit() && !this.isSubmitting)
            .onClick(() => {
              this.submitActivity();
            })
        }
        .padding(16)
      }
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#fff')
  }

  private canSubmit(): boolean {
    return this.title.trim() !== '' &&
           this.description.trim() !== '' &&
           this.location.trim() !== '' &&
           this.selectedDate !== '' &&
           this.selectedTime !== ''
  }

  private async submitActivity() {
    if (!this.canSubmit()) {
      promptAction.showToast({ message: '请填写完整的活动信息' })
      return
    }

    // 验证日期格式
    if (!this.isValidDate(this.selectedDate)) {
      promptAction.showToast({ message: '请输入正确的日期格式 (YYYY-MM-DD)' })
      return
    }

    // 验证时间格式
    if (!this.isValidTime(this.selectedTime)) {
      promptAction.showToast({ message: '请输入正确的时间格式 (HH:MM)' })
      return
    }

    // 验证活动时间不能是过去时间
    const activityDateTime = new Date(`${this.selectedDate} ${this.selectedTime}`)
    if (activityDateTime <= new Date()) {
      promptAction.showToast({ message: '活动时间不能早于当前时间' })
      return
    }

    this.isSubmitting = true

    try {
      const currentUser = await this.authService.getCurrentUser()
      if (!currentUser) {
        promptAction.showToast({ message: '请先登录' })
        return
      }

      const newActivity = new EcoActivity(
        this.title.trim(),
        this.description.trim(),
        this.selectedCategory,
        currentUser.username,
        new Date(this.selectedDate + ' ' + this.selectedTime),
        new Date(this.selectedDate + ' ' + this.selectedTime),
        this.location.trim(),
        this.maxParticipants,
        0
      )

      await this.dataService.saveActivity(newActivity)
      
      promptAction.showToast({ message: '活动发布成功！' })
      
      // 跳转到首页强制刷新数据
      setTimeout(() => {
        router.replaceUrl({ url: 'pages/Index' })
      }, 1000)
      
    } catch (error) {
      console.error('发布活动失败:', error)
      promptAction.showToast({ message: '发布失败，请重试' })
    } finally {
      this.isSubmitting = false
    }
  }

  private isValidDate(dateStr: string): boolean {
    const regex = /^\d{4}-\d{2}-\d{2}$/
    if (!regex.test(dateStr)) return false
    
    const date = new Date(dateStr)
    return date instanceof Date && !isNaN(date.getTime())
  }

  private isValidTime(timeStr: string): boolean {
    const regex = /^\d{2}:\d{2}$/
    if (!regex.test(timeStr)) return false
    
    const timeParts = timeStr.split(':').map(Number)
    const hours = timeParts[0]
    const minutes = timeParts[1]
    return hours >= 0 && hours <= 23 && minutes >= 0 && minutes <= 59
  }
}