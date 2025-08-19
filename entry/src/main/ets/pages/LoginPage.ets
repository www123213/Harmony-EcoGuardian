import { AuthService } from '../service/AuthService';
import { router } from '@kit.ArkUI';
import { promptAction } from '@kit.ArkUI';

@Entry
@Component
struct LoginPage {
  @State email: string = '';
  @State password: string = '';
  @State isLoading: boolean = false;
  private authService: AuthService = AuthService.getInstance();

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
        
        Text('登录')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
        
        Blank()
        
        // 占位，保持标题居中
        Text('')
          .width(60)
      }
      .width('100%')
      .height(56)
      .padding({ left: 16, right: 16 })
      .backgroundColor('#fff')

      // 登录表单
      Column({ space: 20 }) {
        // Logo
        Column({ space: 10 }) {
          Text('🌱')
            .fontSize(80)
          Text('欢迎回来')
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
            .fontColor('#2E7D32')
          Text('继续你的环保之旅')
            .fontSize(16)
            .fontColor('#666')
        }
        .margin({ top: 60, bottom: 40 })

        // 邮箱输入
        Column({ space: 8 }) {
          Text('邮箱')
            .fontSize(14)
            .fontColor('#333')
            .alignSelf(ItemAlign.Start)
          
          TextInput({ placeholder: '请输入邮箱地址' })
            .width('100%')
            .height(50)
            .backgroundColor('#f8f8f8')
            .borderRadius(8)
            .padding({ left: 16, right: 16 })
            .type(InputType.Email)
            .onChange((value: string) => {
              this.email = value;
            })
        }
        .width('100%')
        .alignItems(HorizontalAlign.Start)

        // 密码输入
        Column({ space: 8 }) {
          Text('密码')
            .fontSize(14)
            .fontColor('#333')
            .alignSelf(ItemAlign.Start)
          
          TextInput({ placeholder: '请输入密码' })
            .width('100%')
            .height(50)
            .backgroundColor('#f8f8f8')
            .borderRadius(8)
            .padding({ left: 16, right: 16 })
            .type(InputType.Password)
            .onChange((value: string) => {
              this.password = value;
            })
        }
        .width('100%')
        .alignItems(HorizontalAlign.Start)

        // 登录按钮
        Button(this.isLoading ? '登录中...' : '登录')
          .width('100%')
          .height(50)
          .backgroundColor('#4CAF50')
          .borderRadius(25)
          .fontSize(18)
          .fontColor('#fff')
          .enabled(!this.isLoading)
          .onClick(() => {
            this.handleLogin()
          })

        // 注册链接
        Row() {
          Text('还没有账号？')
            .fontSize(14)
            .fontColor('#666')
          
          Text('立即注册')
            .fontSize(14)
            .fontColor('#4CAF50')
            .onClick(() => {
              router.replaceUrl({ url: 'pages/RegisterPage' });
            })
        }
        .margin({ top: 20 })

        // 快速登录提示
        Column({ space: 10 }) {
          Text('💡 体验提示')
            .fontSize(14)
            .fontWeight(FontWeight.Bold)
            .fontColor('#FF9800')
          Text('可以使用任意邮箱和密码注册新账号')
            .fontSize(12)
            .fontColor('#666')
            .textAlign(TextAlign.Center)
        }
        .width('100%')
        .padding(15)
        .backgroundColor('#FFF3E0')
        .borderRadius(8)
        .margin({ top: 30 })
      }
      .width('100%')
      .padding({ left: 30, right: 30 })
      .layoutWeight(1)

      Blank()
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#f5f5f5')
  }

  async handleLogin() {
    if (!this.email.trim()) {
      promptAction.showToast({ message: '请输入邮箱' })
      return
    }

    if (!this.password.trim()) {
      promptAction.showToast({ message: '请输入密码' })
      return
    }

    this.isLoading = true;

    try {
      const result = await this.authService.login(this.email.trim(), this.password)
      
      if (result.success) {
        promptAction.showToast({ message: '登录成功' })
        // 返回主页
        router.replaceUrl({ url: 'pages/Index' })
      } else {
        promptAction.showToast({ message: result.message })
      }
    } catch (error) {
      console.error('登录失败:', error)
      promptAction.showToast({ message: '登录失败，请重试' })
    } finally {
      this.isLoading = false;
    }
  }
}